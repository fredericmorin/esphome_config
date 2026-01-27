#!/bin/bash
set -euo pipefail

log() { echo "$(tput setaf 2)[ok]$(tput sgr0) $@"; }
SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P )"

cd "$SCRIPT_ROOT"
[ ! -e "$SCRIPT_ROOT/.venv" ] && log "Setup venv" && python3 -m venv --prompt venv .venv
[ ! -e "$SCRIPT_ROOT/.venv/bin/uv" ] && log "Install uv" && "$SCRIPT_ROOT/.venv/bin/pip" install uv
source "$SCRIPT_ROOT/.venv/bin/activate"

if [[ ! $(find "$SCRIPT_ROOT/.venv/esphome.check" -newermt "1 day ago" 2>/dev/null) ]]; then
    uv pip install -U esphome
    touch "$SCRIPT_ROOT/.venv/esphome.check"
fi

[ ! -e "$SCRIPT_ROOT/.env" ] && log "Missing .env file. Creating template .env file." && cat << EOF > .env
HA_HOST=ha
EOF

source "$SCRIPT_ROOT/.env"
