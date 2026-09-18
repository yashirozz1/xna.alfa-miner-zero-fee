#!/usr/bin/env python3
"""Check the packaged Linux executable without starting hashing or connections."""
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile


def run(*command):
    result = subprocess.run(command, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True, timeout=30)
    if result.returncode:
        raise RuntimeError(f'{command[0]} exited {result.returncode}:\n{result.stdout}')
    return re.sub(r'\x1b\[[0-9;]*m', '', result.stdout)


def main():
    executable = str(Path(sys.argv[1]).resolve(strict=True))
    metadata = run('file', '-b', executable)
    if 'ELF 64-bit' not in metadata or 'x86-64' not in metadata:
        raise RuntimeError(f'Unexpected architecture: {metadata}')
    print(metadata.strip())
    version = run(executable, '--version')
    if not version.startswith('Alfa Miner CPU 6.26.0'):
        raise RuntimeError(f'Unexpected version: {version}')
    print(version.strip())
    help_text = run(executable, '--help')
    if 'donate level, default 0% (minimum 0%)' not in help_text:
        raise RuntimeError('Help does not document the zero donation default.')
    libraries = run('ldd', executable)
    print(libraries.strip())
    if 'not found' in libraries or re.search(r'lib(?:uv|ssl|crypto|hwloc)[.-]', libraries):
        raise RuntimeError('Unexpected external dependency: ' + libraries)
    with tempfile.TemporaryDirectory(prefix='alfa-dry-run-') as temporary:
        for case in ('default', 'explicit-zero', 'cli-zero'):
            config = {
                'autosave': False, 'background': False, 'colors': False,
                'title': False, 'dry-run': True,
                'cpu': {'enabled': False, 'huge-pages': False},
                'http': {'enabled': False},
                'pools': [{'url': '127.0.0.1:1', 'user': 'ci-no-mining',
                           'pass': 'x', 'algo': 'rx/0'}],
            }
            extra = []
            if case == 'explicit-zero':
                config['donate-level'] = 0
            elif case == 'cli-zero':
                config['donate-level'] = 1
                extra = ['--donate-level=0']
            path = Path(temporary) / (case + '.json')
            path.write_text(json.dumps(config), encoding='utf-8')
            output = run(executable, '--dry-run', '--config', str(path), *extra)
            if not re.search(r'DONATE\s+0%', output):
                raise RuntimeError(f'Donation check {case} failed:\n{output}')
            print(f'Donation smoke test {case!r} passed: DONATE 0%')
    print('Linux executable verified. No mining was started.')


if __name__ == '__main__':
    main()
