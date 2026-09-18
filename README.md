# Alfa Miner CPU

[![Windows x64](https://github.com/yashirozz1/xna.alfa-miner-zero-fee/actions/workflows/windows.yml/badge.svg)](https://github.com/yashirozz1/xna.alfa-miner-zero-fee/actions/workflows/windows.yml)
[![Linux x64](https://github.com/yashirozz1/xna.alfa-miner-zero-fee/actions/workflows/linux.yml/badge.svg)](https://github.com/yashirozz1/xna.alfa-miner-zero-fee/actions/workflows/linux.yml)

Minerador de CPU para Windows e Linux x64. Executáveis: **`alfa-miner-cpu.exe`**
no Windows e **`alfa-miner-cpu`** no Linux.
Nome e descrição do produto: **Alfa Miner CPU**.

Esta edição usa **0% de doação ao desenvolvedor por padrão e como mínimo**.
O exemplo de configuração e a configuração interna também usam `"donate-level": 0`.
Isso não altera eventuais taxas cobradas pela pool. Uma configuração externa com
valor maior que zero ainda ativa uma doação voluntária; mantenha zero ou use
`--donate-level=0` ao reutilizar uma configuração anterior.

## Baixar a compilação

### Linux x64

Abra [Actions → Linux x64](https://github.com/yashirozz1/xna.alfa-miner-zero-fee/actions/workflows/linux.yml),
entre na execução mais recente com sucesso nos dois jobs e baixe o artefato
`alfa-miner-cpu-zero-fee-linux-x64-<commit>`.

O artefato contém o binário em `.tar.gz`, o código-fonte correspondente em outro
`.tar.gz` e `SHA256SUMS.txt`. Depois de extrair o ZIP baixado do GitHub:

```bash
sha256sum -c SHA256SUMS.txt
tar -xzf alfa-miner-cpu-6.26.0-zero-fee-linux-x64.tar.gz
cd alfa-miner-cpu-6.26.0-zero-fee-linux-x64
./alfa-miner-cpu --version
./alfa-miner-cpu --help
```

O pacote preserva a permissão de execução. A base de compilação é Ubuntu 22.04
x86_64; o mesmo pacote é testado em Ubuntu 24.04. libuv, OpenSSL e hwloc são
incorporadas estaticamente. A glibc continua dinâmica: este pacote não atende
Alpine/musl, ARM64 ou distribuições anteriores ao Ubuntu 22.04. Confira
`BUILD-INFO.txt` para dependências e origem da compilação.

### Windows x64

1. Abra [Actions → Windows x64](https://github.com/yashirozz1/xna.alfa-miner-zero-fee/actions/workflows/windows.yml).
2. Entre na execução mais recente concluída com sucesso.
3. Em **Artifacts**, baixe `alfa-miner-cpu-zero-fee-windows-x64-<commit>`.

É necessário estar conectado ao GitHub para baixar artefatos. Eles ficam
disponíveis por 30 dias; uma nova execução gera outro pacote.

O download contém:

| Arquivo | Conteúdo |
|---|---|
| `alfa-miner-cpu-6.26.0-zero-fee-windows-x64.zip` | Executável, licença, créditos e este guia |
| `alfa-miner-cpu-6.26.0-zero-fee-source.zip` | Código-fonte do mesmo commit |
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

Cada push na `main` e pull request executa os workflows. Para compilar manualmente,
abra **Actions → Linux x64** ou **Windows x64 → Run workflow**.

O workflow Linux compila as bibliotecas libuv 1.51.0, hwloc 2.12.1 e OpenSSL
3.0.16 a partir dos scripts upstream e gera um pacote com as licenças dessas
bibliotecas. Valida arquitetura ELF x86_64, dependências, versão, ajuda e os
três casos de doação zero em Ubuntu 22.04 e 24.04, sem iniciar mineração.

O runner Windows 2022 usa MSVC 2022 e CMake 3.31.10. A compilação inclui TLS,
hwloc e os algoritmos de CPU, com CUDA, OpenCL e MSR desativados. O pacote não
inclui o driver WinRing0; otimizações que dependem de MSR ficam indisponíveis.

Antes de publicar o artefato, o workflow confere nome/descrição nos recursos do
executável e executa `--version`, `--help` e três testes `--dry-run` confirmando
`DONATE 0%`: padrão omitido, zero explícito e opção CLI sobrescrevendo uma
configuração de 1%. Não inicia mineração nem altera proteções do sistema.
Esses testes não medem hashrate ou conectividade com pool.

## Compilar localmente

### Linux

Na raiz de uma cópia limpa do repositório, em Ubuntu 22.04 ou 24.04 x64:

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake automake libtool autoconf pkg-config wget perl python3 file
bash ci/build-linux.sh
```

Os pacotes Linux ficam em `dist/linux/`. Para manter a mesma base de compatibilidade
do artefato público, compile em Ubuntu 22.04. Não é necessário executar o build
como root; o acesso administrativo é usado apenas para instalar ferramentas.

### Windows

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
