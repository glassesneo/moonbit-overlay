#!/usr/bin/env bash
# validate-core-bundle.sh — Verify a MOON_HOME has a complete core bundle.
# Usage: validate-core-bundle.sh <moon_home>
#
# Checks:
#   1. lib/core/target/packages.json exists and has .packages | length > 0
#   2. All required backend sentinels exist (wasm-gc, js, native)
#
# Exits non-zero with an explicit error message on any failure.

set -euo pipefail

moon_home="${1:-}"
if [[ -z "$moon_home" ]]; then
  echo "ERROR: usage: validate-core-bundle.sh <moon_home>" >&2
  exit 1
fi

packages_json="$moon_home/lib/core/target/packages.json"

# --- Check 1: packages.json exists ---
if [[ ! -f "$packages_json" ]]; then
  echo "ERROR: core bundle missing packages.json at: $packages_json" >&2
  exit 1
fi

# --- Check 2: packages.json has packages ---
pkg_count=$(jq '.packages | length' "$packages_json" 2>/dev/null || echo 0)
if [[ "$pkg_count" -le 0 ]]; then
  echo "ERROR: core bundle packages.json has 0 packages (expected > 0) at: $packages_json" >&2
  exit 1
fi
echo "OK: packages.json has $pkg_count packages" >&2

# --- Check 3: required backend sentinels ---
sentinels=(
  "lib/core/target/wasm-gc/release/bundle/builtin/builtin.mi"
  "lib/core/target/js/release/bundle/builtin/builtin.mi"
  "lib/core/target/native/release/bundle/builtin/builtin.mi"
)

missing=()
for sentinel in "${sentinels[@]}"; do
  full_path="$moon_home/$sentinel"
  if [[ ! -f "$full_path" ]]; then
    missing+=("$sentinel")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "ERROR: core bundle missing required backend sentinels:" >&2
  for m in "${missing[@]}"; do
    echo "  - $m" >&2
  done
  exit 1
fi

echo "OK: all backend sentinels present (wasm-gc, js, native)" >&2
echo "PASS: core bundle validation succeeded for: $moon_home" >&2
