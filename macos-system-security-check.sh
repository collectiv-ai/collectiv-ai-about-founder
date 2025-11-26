---

### 3. `macos-system-security-check.sh`

```bash
#!/usr/bin/env bash
#
# macos-system-security-check.sh
# Basic security & system overview for macOS.
# Read-only, for my own machines in the CollectivAI lab.

set -e

echo "=== macOS System & Security Check ==="
echo

echo "[1/7] System information"
sw_vers || echo "sw_vers not available"
uname -a
echo

echo "[2/7] Hardware (short)"
system_profiler SPHardwareDataType 2>/dev/null | awk 'NR<=25'
echo

echo "[3/7] FileVault status"
if command -v fdesetup >/dev/null 2>&1; then
  fdesetup status
else
  echo "fdesetup not found – cannot check FileVault."
fi
echo

echo "[4/7] Firewall status"
if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null | grep -qi "enabled"; then
  echo "Firewall: ENABLED"
else
  echo "Firewall: DISABLED"
fi
echo

echo "[5/7] Gatekeeper status"
spctl --status 2>/dev/null || echo "spctl not available"
echo

echo "[6/7] SIP (System Integrity Protection)"
csrutil status 2>/dev/null || echo "csrutil not available (run from Recovery to check)"
echo

echo "[7/7] Logged-in user & last reboot"
echo "Current user: $(whoami)"
last reboot | head -n 3
echo

echo "=== Summary ==="
echo "-> Check FileVault, Firewall and Gatekeeper above."
echo "-> This script is read-only and part of the CollectivAI macOS lab."
