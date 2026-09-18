param(
    [string]$CMake = 'cmake',
    [string]$Dependencies = '.deps/msvc2022/x64'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$projectDirectory = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath $projectDirectory
try {
    git rev-parse --verify HEAD | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Commit the source before packaging.' }
    $sourceChanges = git status --porcelain --untracked-files=normal
    if ($LASTEXITCODE -ne 0 -or $sourceChanges) {
        throw 'Commit source changes before building so the source ZIP matches the binary.'
    }
    if (-not (Test-Path -LiteralPath $Dependencies -PathType Container)) {
        throw "Dependencies not found: $Dependencies. See README.md."
    }
    & $CMake -S . -B build -G 'Visual Studio 17 2022' -A x64 `
        "-DXMRIG_DEPS=$((Resolve-Path -LiteralPath $Dependencies).Path)" `
        -DWITH_CUDA=OFF -DWITH_OPENCL=OFF -DWITH_MSR=OFF
    if ($LASTEXITCODE -ne 0) { throw 'CMake configuration failed.' }
    & $CMake --build build --config Release --parallel 4
    if ($LASTEXITCODE -ne 0) { throw 'Compilation failed.' }

    $executable = Join-Path $projectDirectory 'build/Release/alfa-miner-cpu.exe'
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
        throw 'The compiler output executable is missing.'
    }
    $metadata = (Get-Item -LiteralPath $executable).VersionInfo
    if ($metadata.ProductName -ne 'Alfa Miner CPU' -or
        $metadata.FileDescription -ne 'Alfa Miner CPU' -or
        $metadata.OriginalFilename -ne 'alfa-miner-cpu.exe') {
        throw "Unexpected executable metadata: $($metadata | Out-String)"
    }
    $versionOutput = & $executable --version
    if ($LASTEXITCODE -ne 0 -or ($versionOutput -join "`n") -notmatch '^Alfa Miner CPU 6\.26\.0') {
        throw 'Version smoke test failed.'
    }
    $versionOutput | Write-Output
    $helpOutput = & $executable --help
    if ($LASTEXITCODE -ne 0 -or ($helpOutput -join "`n") -notmatch 'Usage:') {
        throw 'Help smoke test failed.'
    }
    if (($helpOutput -join "`n") -notmatch 'donate level, default 0% \(minimum 0%\)') {
        throw 'Help does not document the zero donation default.'
    }

    # Dry-run returns before Controller::start: no hashing or pool connections.
    foreach ($case in @('default', 'explicit-zero', 'cli-zero')) {
        $checkConfig = @{
            autosave = $false
            background = $false
            colors = $false
            title = $false
            'dry-run' = $true
            cpu = @{ enabled = $false; 'huge-pages' = $false }
            http = @{ enabled = $false }
            pools = @(@{ url = '127.0.0.1:1'; user = 'ci-no-mining'; pass = 'x'; algo = 'rx/0' })
        }
        $checkArguments = @('--dry-run', '--config', "build/donation-$case.json")
        if ($case -eq 'explicit-zero') { $checkConfig['donate-level'] = 0 }
        if ($case -eq 'cli-zero') {
            $checkConfig['donate-level'] = 1
            $checkArguments += '--donate-level=0'
        }
        $checkConfig | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath "build/donation-$case.json" -Encoding ascii
        $checkOutput = & $executable @checkArguments 2>&1
        $checkExit = $LASTEXITCODE
        $checkText = ($checkOutput -join "`n") -replace '\x1b\[[0-9;]*m', ''
        if ($checkExit -ne 0 -or $checkText -notmatch 'DONATE\s+0%') {
            throw "Donation smoke test '$case' failed (exit $checkExit): $checkText"
        }
        Write-Output "Donation smoke test '$case' passed: DONATE 0%"
    }

    $packageDirectory = Join-Path $projectDirectory 'build/package'
    $distributionDirectory = Join-Path $projectDirectory 'dist'
    New-Item -ItemType Directory -Force -Path $packageDirectory, $distributionDirectory | Out-Null
    Copy-Item -LiteralPath $executable -Destination $packageDirectory
    Copy-Item -LiteralPath LICENSE, NOTICE.md, README.md -Destination $packageDirectory
    $binaryArchive = Join-Path $distributionDirectory 'alfa-miner-cpu-6.26.0-zero-fee-windows-x64.zip'
    $sourceArchive = Join-Path $distributionDirectory 'alfa-miner-cpu-6.26.0-zero-fee-source.zip'
    Compress-Archive -Path "$packageDirectory/*" -DestinationPath $binaryArchive -Force
    git archive --format=zip "--output=$sourceArchive" HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Source archive failed.' }
    $hashes = foreach ($archive in @($binaryArchive, $sourceArchive)) {
        $hash = Get-FileHash -LiteralPath $archive -Algorithm SHA256
        '{0}  {1}' -f $hash.Hash.ToLowerInvariant(), (Split-Path -Leaf $archive)
    }
    $hashes | Set-Content -LiteralPath (Join-Path $distributionDirectory 'SHA256SUMS.txt') -Encoding ascii
    Write-Output 'Verified executable metadata, --version, --help and zero donation dry-runs. No mining was started.'
    $hashes | Write-Output
} finally {
    Pop-Location
}
