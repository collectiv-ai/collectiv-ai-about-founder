#!/usr/bin/env bash
#
# network-quickcheck.sh
# Small, safe network overview for macOS or Linux. No scans, just basic info.

set -e

echo "=== Network Quickcheck ==="
echo

OS="$(uname -s)"

echo "[1/5] Interfaces"
if command -v ip >/dev/null 2>&1; then
  ip addr show
elif command -v ifconfig >/dev/null 2>&1; then
  ifconfig
else
  echo "No ip or ifconfig command available."
fi
echo

echo "[2/5] Default route"
if command -v ip >/dev/null 2>&1; then
  ip route show default || true
elif [ "$OS" = "Darwin" ]; then
  netstat -rn | grep -i 'default' || true
else
  route -n | grep '^0.0.0.0' || true
fi
echo

echo "[3/5] DNS configuration"
if [ "$OS" = "Darwin" ]; then
  scutil --dns | sed -n '1,40p' || true
else
  cat /etc/resolv.conf 2>/dev/null || echo "/etc/resolv.conf not readable."
fi
echo

echo "[4/5] Basic connectivity tests"
for host in 1.1.1.1 8.8.8.8; do
  echo "Ping $host ..."
  ping -c 2 -W 2 "$host" >/dev/null 2>&1 && echo "  -> OK" || echo "  -> FAILED"
done
echo

echo "[5/5] HTTP check"
if command -v curl >/dev/null 2>&1; then
  curl -Is https://example.com >/dev/null 2>&1 && echo "HTTP: example.com reachable" || echo "HTTP: example.com NOT reachable"
else
  echo "curl not installed – skipping HTTP check."
fi
echo

echo "=== Done ==="
echo "This script is read-only and part of the CollectivAI lab (no scanning, no attacks)."
