#!/usr/bin/env bash
set -euo pipefail
STAMPS_DIR="/workspace/.stamps"; mkdir -p "$STAMPS_DIR"
if [[ "${SAGEATTENTION_BUILD:-false}" == "true" ]]; then
  if [[ ! -f "$STAMPS_DIR/sageattention-build" ]]; then
    echo "[sageattention] building at runtime..."
    pip install --no-binary=:all: sageattention
    touch "$STAMPS_DIR/sageattention-build"
    echo "[sageattention] done."
  else
    echo "[sageattention] already built."
  fi
else
  echo "[sageattention] skipped (set SAGEATTENTION_BUILD=true to enable)"
fi
