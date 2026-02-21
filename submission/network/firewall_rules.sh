#!/usr/bin/env bash

# firewall_rules.sh - Edge device firewall configuration

set -euo pipefail

CAMERA_VLAN="10.50.20.0/24"
MGMT_VLAN="10.50.1.0/24"

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established/related
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH from management VLAN only
iptables -A INPUT -p tcp --dport 22 -s ${MGMT_VLAN} -j ACCEPT

# Allow RTSP from camera VLAN only (TCP/UDP 554)
iptables -A INPUT -p tcp --dport 554 -s ${CAMERA_VLAN} -j ACCEPT
iptables -A INPUT -p udp --dport 554 -s ${CAMERA_VLAN} -j ACCEPT

# Allow HTTPS outbound (S3 uploads / API calls)
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Block camera VLAN from accessing management VLAN
iptables -A FORWARD -s ${CAMERA_VLAN} -d ${MGMT_VLAN} -j DROP

# Block camera VLAN from accessing corporate VLAN
iptables -A FORWARD -s ${CAMERA_VLAN} -d 10.50.10.0/24 -j DROP

# Allow ICMP (diagnostics)
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# Optional logging for dropped packets
iptables -A INPUT -j LOG --log-prefix "IPTables-Dropped: " --log-level 4

echo "Firewall rules applied successfully"
