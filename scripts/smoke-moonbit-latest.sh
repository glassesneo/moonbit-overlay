#!/usr/bin/env bash
# smoke-moonbit-latest.sh — Hermetic smoke test for moonbit_latest.
# Runs in a temporary directory: creates a project, builds, and runs it.
# Exits non-zero if any step fails.

set -euo pipefail

echo "=== MoonBit latest smoke test ===" >&2

tmp=$(mktemp -d)
trap "rm -rf $tmp" EXIT

cd "$tmp"

echo "Creating test project..." >&2
moon new hello >/dev/null

cd hello

echo "Running test project..." >&2
moon run cmd/main >/dev/null

echo "PASS: smoke test succeeded" >&2
