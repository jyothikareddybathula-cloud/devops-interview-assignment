#!/usr/bin/env bash

set -euo pipefail

INTERFACE="eno1"
EXPECTED_MTU="1500"

echo "Starting VPN MTU remediation..."

# Check if interface exists
if ! ip link show "$INTERFACE" > /dev/null 2>&1; then
  echo "ERROR: Interface $INTERFACE not found."
  exit 1
fi

# Get current MTU
CURRENT_MTU=$(ip link show "$INTERFACE" | awk '/mtu/ {print $5}')

echo "Current MTU on $INTERFACE: $CURRENT_MTU"

# If MTU already correct, exit safely
if [[ "$CURRENT_MTU" == "$EXPECTED_MTU" ]]; then
  echo "MTU already set to $EXPECTED_MTU. No action required."
  exit 0
fi

echo "Incorrect MTU detected. Updating MTU to $EXPECTED_MTU..."

# Apply fix
if ! ip link set dev "$INTERFACE" mtu "$EXPECTED_MTU"; then
  echo "ERROR: Failed to update MTU."
  exit 1
fi

# Verify change
NEW_MTU=$(ip link show "$INTERFACE" | awk '/mtu/ {print $5}')

if [[ "$NEW_MTU" != "$EXPECTED_MTU" ]]; then
  echo "ERROR: MTU verification failed. Expected $EXPECTED_MTU but found $NEW_MTU."
  exit 1
fi

echo "MTU successfully updated to $EXPECTED_MTU."

echo "Verifying VPN tunnel status..."

# Basic VPN verification (check for fragmentation issues)
if ip -s link show "$INTERFACE" | grep -qi "fragment"; then
  echo "WARNING: Fragmentation indicators still present. Further investigation required."
else
  echo "No fragmentation indicators detected."
fi

echo "Remediation complete."
exit 0
