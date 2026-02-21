# Post-Incident Report

## Incident Summary

| Field | Value |
|-------|-------|
| Date | 2025-11-12 |
| Duration | ~45 minutes (08:15 – 09:00 UTC) |
| Severity | High |
| Services Affected | Site-to-AWS VPN connectivity |
| Customer Impact | Packet loss, degraded video streams, intermittent API failures |

---

## What Happened

At 08:15 UTC, the MTU on edge interface `eno1` was increased from 1500 to 9000.  
This exceeded the VPN path MTU (1500), causing packet fragmentation, ESP drops, and repeated DPD timeouts.  
The VPN tunnel began flapping (down/up cycles) and packet loss reached 34%.  
At 09:00 UTC, the MTU was reverted back to 1500 and stability was restored.

---

## Timeline

- 08:15:03 – MTU changed from 1500 to 9000  
- 08:15:05 – IKE keepalive packets exceeded path MTU  
- 08:18:30 – ESP fragmentation warnings observed  
- 08:20:58 – DPD timeout, tunnel reset  
- 08:35:00 – Sustained packet loss reached 34%  
- 09:00:00 – MTU reverted to 1500  
- 09:00:10 – Tunnel stabilized  

---

## Root Cause

The edge interface MTU was misconfigured to 9000 while the VPN path MTU remained 1500.  
This caused fragmentation and VPN instability.

---

## Resolution

The MTU was restored from 9000 back to 1500 on interface `eno1`.  
After correction, packet fragmentation stopped and DPD returned to normal.

---

## Impact

- Up to 34% packet loss on ESP tunnel  
- VPN tunnel resets  
- Degraded throughput (50 Mbps → ~2 Mbps)  
- Intermittent customer-facing disruptions  

---

## Action Items

| Action | Owner | Priority | Due Date |
|--------|--------|----------|----------|
| Implement MTU validation before interface changes | Network Team | High | 2 weeks |
| Add monitoring for ESP fragmentation and DPD timeouts | DevOps | High | 2 weeks |
| Configure alerting for sustained packet loss >5% | SRE | Medium | 3 weeks |

---

## Lessons Learned

### What went well
- Logs clearly indicated MTU mismatch  
- Issue was resolved quickly once identified  

### What could be improved
- Change validation procedures  
- Better monitoring for path MTU mismatches  
- Automated rollback for unsafe network configuration changes
