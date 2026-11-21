"""Lint or simulate the scalar RV32I baseline with Verilator."""

import argparse
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['lint', 'test'])
    args = parser.parse_args()
    verilator = shutil.which('verilator')
    if verilator is None:
        parser.exit(1, 'Verilator is required. On Windows, run this script inside WSL.\n')

    command = [verilator, '-Wall', '-Wno-UNUSEDSIGNAL', '-Wno-UNUSEDPARAM',
               '-Wno-DECLFILENAME', '--timescale', '1ns/1ps', '-f', 'rtl/files.f']
    if args.action == 'lint':
        command += ['--lint-only', '--top-module', 'cpu']
    else:
        (ROOT / 'build').mkdir(exist_ok=True)
        command += ['--binary', '--timing', '--assert', '--top-module', 'cpu_tb',
                    '--Mdir', 'build/obj', '-o', 'cpu_tb', 'tb/cpu_tb.sv']
    try:
        subprocess.run(command, cwd=ROOT, check=True)
        if args.action == 'test':
            subprocess.run([str(ROOT / 'build/obj/cpu_tb')], cwd=ROOT, check=True)
    except (OSError, subprocess.CalledProcessError) as error:
        print(error, file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
