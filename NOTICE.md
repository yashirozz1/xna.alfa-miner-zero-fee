# Créditos, licença e origem

Alfa Miner CPU é uma personalização do XMRig 6.26.0, distribuída sob
GPL-3.0-or-later. Os avisos de copyright originais foram preservados no código.
Consulte [LICENSE](LICENSE) e [README.upstream.md](README.upstream.md).

- Código original: https://github.com/xmrig/xmrig
- Tag: `v6.26.0`
- Commit: `b2ca72480c58d197e18c885d9fc1a0c8d517e60a`
- Dependências Windows: https://github.com/xmrig/xmrig-deps
- Commit das dependências: `ddfb65ec8bf4803a6c1c2037969546d018c76b54`
- Dependências Linux: libuv 1.51.0, hwloc 2.12.1 e OpenSSL 3.0.16, compiladas
  pelos scripts upstream `scripts/build.uv.sh`, `scripts/build.hwloc.sh` e
  `scripts/build.openssl3.sh`. Suas licenças acompanham o pacote Linux.

Alterações: nome e descrição exibidos, nome do executável, configuração de
compilação CPU e workflow do GitHub Actions. A doação padrão e mínima foi alterada
para 0%, incluindo os exemplos e a configuração interna. O identificador de agente
de rede original permanece preservado. Algoritmos e protocolo não foram alterados.
O perfil distribuído não usa CUDA, OpenCL ou modificação MSR; o driver
WinRing0 não é incluído.

O modo `--dry-run` não inicializa leitura interativa de teclado, pois termina
antes do loop de eventos. Isso evita tratar a entrada redirecionada do runner
Windows como um terminal interativo durante a validação.

O artefato de cada execução acompanha um arquivo com o código-fonte
correspondente ao commit compilado. As dependências externas são fixadas acima;
suas licenças e fontes estão documentadas no repositório correspondente.
