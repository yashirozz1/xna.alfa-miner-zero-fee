# Alfa Miner CPU

[![Windows x64](https://github.com/yashirozz1/xna.alfa-miner/actions/workflows/windows.yml/badge.svg)](https://github.com/yashirozz1/xna.alfa-miner/actions/workflows/windows.yml)

Minerador de CPU para Windows x64. Nome do executável: **`alfa-miner-cpu.exe`**.
Nome e descrição do produto: **Alfa Miner CPU**.

## Baixar a compilação

1. Abra [Actions → Windows x64](https://github.com/yashirozz1/xna.alfa-miner/actions/workflows/windows.yml).
2. Entre na execução mais recente concluída com sucesso.
3. Em **Artifacts**, baixe `alfa-miner-cpu-windows-x64-<commit>`.

É necessário estar conectado ao GitHub para baixar artefatos. Eles ficam
disponíveis por 30 dias; uma nova execução gera outro pacote.

O download contém:

| Arquivo | Conteúdo |
|---|---|
| `alfa-miner-cpu-6.26.0-windows-x64.zip` | Executável, licença, créditos e este guia |
| `alfa-miner-cpu-6.26.0-source.zip` | Código-fonte do mesmo commit |
| `SHA256SUMS.txt` | Hashes SHA-256 dos dois ZIPs |

Após extrair o ZIP do Windows, confira a versão no PowerShell:

```powershell
.\alfa-miner-cpu.exe --version
.\alfa-miner-cpu.exe --help
```

Esses comandos apenas exibem informações. A configuração de pool, carteira e
limites de CPU deve ser fornecida por você. Consulte `src/config.json` no código
como referência; o ZIP não inclui uma configuração de mineração ativa.

## Compilar no GitHub

Cada push na `main` e pull request executa o workflow. Para compilar manualmente,
abra **Actions → Windows x64 → Run workflow**.

O runner Windows 2022 usa MSVC 2022 e CMake 3.31.10. A compilação inclui TLS,
hwloc e os algoritmos de CPU, com CUDA, OpenCL e MSR desativados. O pacote não
inclui o driver WinRing0; otimizações que dependem de MSR ficam indisponíveis.

Antes de publicar o artefato, o workflow confere nome/descrição nos recursos do
executável e executa `--version` e `--help`. Não inicia mineração nem altera
proteções do sistema. Esses testes não medem hashrate ou conectividade com pool.

## Compilar localmente

Pré-requisitos: Windows x64, Git, Python, Visual Studio 2022 Build Tools com C++
e Windows SDK. Na raiz do repositório, em PowerShell:

```powershell
git clone https://github.com/xmrig/xmrig-deps.git .deps
git -C .deps checkout ddfb65ec8bf4803a6c1c2037969546d018c76b54
python -m pip install cmake==3.31.10
$cmakeDirectory = python -c "import cmake; print(cmake.CMAKE_BIN_DIR)"
.\ci\build-windows.ps1 -CMake (Join-Path $cmakeDirectory 'cmake.exe')
```

Os pacotes ficam em `dist/`. Faça commit das alterações antes de empacotar:
o ZIP do código-fonte é gerado a partir de `HEAD`.

## Licença e créditos

GPL-3.0-or-later. Consulte [LICENSE](LICENSE) e [NOTICE.md](NOTICE.md) para
origem, versões e créditos do código e das dependências.
