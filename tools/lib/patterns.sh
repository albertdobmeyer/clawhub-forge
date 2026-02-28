#!/usr/bin/env bash
# Malicious pattern database for offline security scanner
# Derived from moltbook-ay trojan analysis and ClawHavoc campaign patterns

# Each pattern: SEVERITY|CATEGORY|REGEX|DESCRIPTION|MITRE_ID|CVE_IDS
# Severity: CRITICAL, HIGH, MEDIUM
# Categories: c2_download, archive_exec, exec_download, cred_access,
#   exfiltration, obfuscation, persistence, privilege_escalation,
#   container_escape, supply_chain, env_injection, resource_abuse

SCAN_PATTERNS=(
  # ── C2/Download — curl/wget/fetch to external URLs ──
  'CRITICAL|c2_download|curl\s+(-[a-zA-Z]*\s+)*https?://|curl downloading from external URL|T1105|'
  'CRITICAL|c2_download|wget\s+(-[a-zA-Z]*\s+)*https?://|wget downloading from external URL|T1105|'
  'CRITICAL|c2_download|fetch\s*\(\s*["\x27]https?://|fetch() to external URL|T1105|'
  'CRITICAL|c2_download|Invoke-WebRequest|PowerShell web request|T1105|'

  # ── Archive execution — password-protected ZIP/7z extraction (moltbook-ay pattern) ──
  'CRITICAL|archive_exec|unzip\s+-P|Password-protected ZIP extraction|T1140|'
  'CRITICAL|archive_exec|7z\s+x\s+-p|Password-protected 7z extraction|T1140|'
  'CRITICAL|archive_exec|tar\s+.*\|\s*bash|Archive piped to bash execution|T1059.004|'

  # ── Exec download — chmod+execute, bash -c with curl, eval with subshell ──
  'CRITICAL|exec_download|chmod\s+\+x.*&&.*\./|Download + chmod + execute chain|T1059.004|'
  'CRITICAL|exec_download|curl.*\|\s*bash|curl piped to bash|T1059.004|'
  'CRITICAL|exec_download|curl.*\|\s*sh|curl piped to sh|T1059.004|'
  'CRITICAL|exec_download|wget.*\|\s*bash|wget piped to bash|T1059.004|'
  'CRITICAL|exec_download|wget.*\|\s*sh|wget piped to sh|T1059.004|'
  'CRITICAL|exec_download|eval\s*\$\(|eval with command substitution|T1059.004|'

  # ── Credential access — reading sensitive files ──
  'HIGH|cred_access|cat\s+.*\.env\b|Reading .env file|T1552.001|'
  'HIGH|cred_access|cat\s+.*\.ssh/id_rsa|Reading SSH private key|T1552.001|'
  'HIGH|cred_access|cat\s+.*\.ssh/id_ed25519|Reading SSH private key|T1552.001|'
  'HIGH|cred_access|\bprintenv\b|Dumping environment variables|T1552.001|'
  'HIGH|cred_access|cat\s+.*/\.aws/credentials|Reading AWS credentials|T1552.001|'
  'HIGH|cred_access|cat\s+.*/\.kube/config|Reading Kubernetes config|T1552.001|'

  # ── Data exfiltration — curl POST with variable data, netcat to IPs ──
  'CRITICAL|exfiltration|curl\s+(-[a-zA-Z]*\s+)*-d\s*\$|curl POST with variable data|T1041|'
  'CRITICAL|exfiltration|curl\s+.*--data.*\$|curl POST with variable data|T1041|'
  'CRITICAL|exfiltration|nc\s+-[a-z]*\s+\d+\.\d+\.\d+\.\d+|Netcat to IP address|T1041|'
  'CRITICAL|exfiltration|ncat\s+.*\d+\.\d+\.\d+\.\d+|Ncat to IP address|T1041|'

  # ── Obfuscation — base64 to shell, hex-encoded strings ──
  'HIGH|obfuscation|base64\s+(-d|--decode).*\|\s*(bash|sh)|Base64 decode piped to shell|T1027|'
  'HIGH|obfuscation|echo\s+.*\|\s*base64\s+(-d|--decode).*\|\s*(bash|sh)|Echo + base64 decode to shell|T1027|'
  'HIGH|obfuscation|\\\\x[0-9a-fA-F]{2}\\\\x[0-9a-fA-F]{2}\\\\x[0-9a-fA-F]{2}|Hex-encoded string sequence|T1027|'
  'HIGH|obfuscation|python3?\s+-c\s+.*exec\s*\(|Python exec() from command line|T1059.006|'

  # ── Persistence — crontab, bashrc/profile modification ──
  'HIGH|persistence|crontab\s+-[el]|Crontab modification|T1053.003|'
  'HIGH|persistence|>>\s*~/\.bashrc|Appending to .bashrc|T1546.004|'
  'HIGH|persistence|>>\s*~/\.profile|Appending to .profile|T1546.004|'
  'HIGH|persistence|>>\s*~/\.zshrc|Appending to .zshrc|T1546.004|'
  'HIGH|persistence|systemctl\s+enable|Enabling systemd service|T1543.002|'

  # ── Privilege escalation — sudo abuse, setuid, permissions ──
  'MEDIUM|privilege_escalation|sudo\s+chmod\s+777|World-writable permissions via sudo|T1548.001|'
  'MEDIUM|privilege_escalation|chown\s+root|Changing ownership to root|T1548.001|'
  'MEDIUM|privilege_escalation|chmod\s+u\+s|Setting setuid bit|T1548.001|'

  # ── Container escape — breaking out of container isolation ──
  'HIGH|container_escape|--privileged|Privileged container mode|T1611|'
  'HIGH|container_escape|SYS_ADMIN|SYS_ADMIN capability (container escape vector)|T1611|'
  'HIGH|container_escape|mount\s+.*/(host|rootfs)|Mounting host filesystem in container|T1611|'

  # ── Supply chain — unsafe package installation ──
  'MEDIUM|supply_chain|npm\s+install\s+[^-].*@[^/]|npm install with arbitrary version specifier|T1195.002|'
  'MEDIUM|supply_chain|pip\s+install\s+--pre|pip install pre-release packages|T1195.002|'
  'MEDIUM|supply_chain|--registry\s+https?://(?!registry\.npmjs\.org)|Custom npm registry (potential hijack)|T1195.002|'
  'MEDIUM|supply_chain|curl.*install\.sh\s*\|\s*(bash|sh)|Piped install script from URL|T1059.004|'

  # ── Environment injection — LD_PRELOAD, PATH manipulation ──
  'MEDIUM|env_injection|LD_PRELOAD=|LD_PRELOAD library injection|T1574.006|'
  'MEDIUM|env_injection|export\s+PATH=(?!.*\$PATH)|PATH replacement (not extension)|T1574.007|'
  'MEDIUM|env_injection|env\s+-i\s|Cleared environment execution|T1059.004|'

  # ── Resource abuse — denial of service patterns ──
  'HIGH|resource_abuse|:\(\)\s*\{\s*:\|:\s*&\s*\}|Fork bomb|T1499.004|'
  'HIGH|resource_abuse|while\s+true.*curl|Infinite loop with network requests|T1498|'
)
