#!/usr/bin/env bash
set -e
set -o pipefail
echo ">>> Running command"
echo ""
ls /github/workspace
bash -c "set -e;  set -o pipefail; $1"