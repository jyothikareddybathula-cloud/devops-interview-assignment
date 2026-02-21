# Product & Engineering Recommendations

Based on investigation of the VPN instability incident caused by MTU misconfiguration, the following improvements are recommended.

---

## Monitoring Improvements

- Monitor interface MTU changes and generate alerts on configuration drift.
- Alert on ESP packet fragmentation events.
- Alert on repeated DPD timeouts.
- Monitor VPN tunnel flapping (multiple up/down events within 5 minutes).
- Trigger alerts when packet loss exceeds 5% on encrypted tunnels.
- Monitor throughput degradation compared to baseline performance.

---

## Automated Detection

- Implement automated detection of MTU mismatch between local interface and VPN path MTU.
- Add health checks that validate tunnel stability after network configuration changes.
- Automatically rollback MTU changes if fragmentation or DPD failures are detected.
- Implement synthetic traffic tests to validate VPN connectivity post-change.

---

## Platform Changes

- Enforce MTU validation rules in configuration management pipelines.
- Require change approval for network interface MTU modifications.
- Implement configuration drift detection for edge devices.
- Integrate network configuration into Infrastructure-as-Code workflows.
- Add automated pre-change and post-change validation checks.

---

## Edge Device Improvements

- Centralized configuration management for edge interfaces.
- Version-controlled network configuration.
- Change logging with user attribution.
- Automated compliance checks for MTU values.
- Runbook automation for VPN health verification.
- Scheduled audits comparing interface MTU against expected baseline.
