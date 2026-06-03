#!/bin/sh
set -eu

SCRIPT_DIR=$(
    CDPATH= cd -- "$(dirname -- "$0")" && pwd
)
REPO_ROOT=$(
    CDPATH= cd -- "$SCRIPT_DIR/.." && pwd
)
KEYATLAS_REPO=${KEYATLAS_REPO:-/Users/taishi/codes/keyatlas.nvim}
FORMAT=markdown
OUTPUT=${HOME}/Desktop/nvim_plugins.md

if [ ! -d "$KEYATLAS_REPO" ]; then
    printf '%s\n' "keyatlas.nvim not found at: $KEYATLAS_REPO" >&2
    exit 1
fi

if [ $# -ge 1 ]; then
    case "$1" in
        markdown|text|lua)
            FORMAT=$1
            shift
            ;;
    esac
fi

if [ $# -ge 1 ]; then
    OUTPUT=$1
    shift
fi

if [ $# -ne 0 ]; then
    printf '%s\n' "usage: $0 [format] [output]" >&2
    exit 2
fi

cd "$REPO_ROOT"
trap 'rm -f "$REPO_ROOT/nvim.log"' EXIT
mkdir -p /private/tmp/nvim-state /private/tmp/nvim-cache
export XDG_STATE_HOME=/private/tmp/nvim-state
export XDG_CACHE_HOME=/private/tmp/nvim-cache
export KEYATLAS_FORMAT=$FORMAT
export KEYATLAS_OUTPUT=$OUTPUT

exec nvim --headless -u "$REPO_ROOT/nvim/init.lua" -i NONE -n \
    -c "set runtimepath+=${KEYATLAS_REPO}" \
    -c "lua local cheatsheet = require('cheatsheet'); cheatsheet.setup(); cheatsheet.export({ format = vim.env.KEYATLAS_FORMAT, output = vim.env.KEYATLAS_OUTPUT })" \
    -c 'qa!'
