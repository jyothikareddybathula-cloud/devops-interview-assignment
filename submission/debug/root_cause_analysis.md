# Root Cause Analysis

## Summary
On 2025-11-12, intermittent connectivity issues were observed between the edge site and AWS VPN. Application traffic experienced packet loss, degraded throughput, and repeated VPN tunnel resets.

## Timeline

| Time (UTC) | Event |
|------------|-------|
| 08:15:03 | Interface eno1 MTU changed from 1500 to 9000 |
| 08:15:05 | IKE keepalive packets exceeded path MTU 1500 |
| 08:18:30 | ESP packet fragmentation warnings observed |
| 08:20:58 | DPD timeout – VPN peer not responding |
| 08:35:00 | Sustained packet loss on ESP tunnel: 34% |
| 09:00:00 | MTU reverted from 9000 back to 1500 |
| 09:00:05 | ESP packet fragmentation stopped |
| 09:00:10 | Tunnel stabilized – DPD normal |

## Root Cause
The local interface MTU was incorrectly increased from 1500 to 9000.

The VPN path MTU remained 1500, causing:
- Packet fragmentation
- Path MTU discovery failures
- ESP packet drops
- DPD timeouts
- Tunnel instability

## Contributing Factors
- No validation before changing MTU
- Lack of automated MTU mismatch detection
- No alerting for packet fragmentation or DPD failures

## Evidence
From vpn_status.log:
- "Local interface eno1 MTU changed: 1500 -> 9000"
- "IKE SA keepalive: packet size 9000 exceeds path MTU 1500"
- "ESP packets being fragmented at gateway"
- "DPD timeout – peer not responding"
- "Local interface eno1 MTU changed: 9000 -> 1500"
- "Tunnel stable – DPD normal"
