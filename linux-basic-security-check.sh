#!/usr/bin/env bash
#
# linux-basic-security-check.sh
# Basic Linux security overview for my own systems in the CollectivAI lab.

set -e

echo "=== Linux Basic Security Check ==="
echo

echo "[1/6] OS information"
if [ -f /etc/os-release ]; then
  cat /etc/os-release | sed -n '1,5p'
fi
uname -a
echo

echo "[2/6] Firewall status"
if command -v ufw >/dev/null 2>&1; then
  echo "- ufw status:"
  ufw status verbose || true
elif command -v firewall-cmd >/dev/null 2>&1; then
  echo "- firewalld zones:"
  firewall-cmd --get-active-zones || true
else
  echo "No ufw or firewalld detected – firewall may be unmanaged/iptables only."
fi
echo

echo "[3/6] SSH configuration (if present)"
SSHD_CONF="/etc/ssh/sshd_config"
if [ -f "$SSHD_CONF" ]; then
  egrep -i '^(Port|PermitRootLogin|PasswordAuthentication)' "$SSHD_CONF" || true
else
  echo "No sshd_config found."
fi
echo

echo "[4/6] Listening services (ports)"
if command -v ss >/dev/null 2>&1; then
  ss -tulnp | head -n 20
elif command -v netstat >/dev/null 2>&1; then
  netstat -tulnp | head -n 20
else
  echo "Neither ss nor netstat available."
fi
echo

echo "[5/6] Failed login attempts (if journalctl present)"
if command -v journalctl >/dev/null 2>&1; then
  journalctl -u ssh --since "2 days ago" 2>/dev/null | egrep -i "failed password|authentication failure" | tail -n 15 || true
else
  echo "journalctl not available or no systemd logs."
fi
echo

echo "[6/6] Users logged in"
who || echo "who not available"
echo

echo "=== Summary ==="
echo "-> Review firewall status, SSH settings and failed login attempts."
echo "-> Script is read-only and for CollectivAI lab systems only."
