#!/usr/bin/env bash
# Malicious pattern database for offline security scanner
# Derived from moltbook-ay trojan analysis and ClawHavoc campaign patterns

# Each pattern: SEVERITY|CATEGORY|REGEX|DESCRIPTION
# Severity: CRITICAL, HIGH, MEDIUM
# Categories: c2_download, archive_exec, exec_download, cred_access, exfiltration, obfuscation, persistence

SCAN_PATTERNS=(
  # C2/Download — curl/wget/fetch to external URLs
  'CRITICAL|c2_download|curl\s+(-[a-zA-Z]*\s+)*https?://|curl downloading from external URL'
  'CRITICAL|c2_download|wget\s+(-[a-zA-Z]*\s+)*https?://|wget downloading from external URL'
  'CRITICAL|c2_download|fetch\s*\(\s*["\x27]https?://|fetch() to external URL'
  'CRITICAL|c2_download|Invoke-WebRequest|PowerShell web request'

  # Archive execution — password-protected ZIP/7z extraction (moltbook-ay pattern)
  'CRITICAL|archive_exec|unzip\s+-P|Password-protected ZIP extraction'
  'CRITICAL|archive_exec|7z\s+x\s+-p|Password-protected 7z extraction'
  'CRITICAL|archive_exec|tar\s+.*\|\s*bash|Archive piped to bash execution'

  # Exec download — chmod+execute, bash -c with curl, eval with subshell
  'CRITICAL|exec_download|chmod\s+\+x.*&&.*\./|Download + chmod + execute chain'
  'CRITICAL|exec_download|curl.*\|\s*bash|curl piped to bash'
  'CRITICAL|exec_download|curl.*\|\s*sh|curl piped to sh'
  'CRITICAL|exec_download|wget.*\|\s*bash|wget piped to bash'
  'CRITICAL|exec_download|wget.*\|\s*sh|wget piped to sh'
  'CRITICAL|exec_download|eval\s*\$\(|eval with command substitution'

  # Credential access — reading sensitive files
  'HIGH|cred_access|cat\s+.*\.env\b|Reading .env file'
  'HIGH|cred_access|cat\s+.*\.ssh/id_rsa|Reading SSH private key'
  'HIGH|cred_access|cat\s+.*\.ssh/id_ed25519|Reading SSH private key'
  'HIGH|cred_access|\bprintenv\b|Dumping environment variables'
  'HIGH|cred_access|cat\s+.*/\.aws/credentials|Reading AWS credentials'
  'HIGH|cred_access|cat\s+.*/\.kube/config|Reading Kubernetes config'

  # Data exfiltration — curl POST with variable data, netcat to IPs
  'CRITICAL|exfiltration|curl\s+(-[a-zA-Z]*\s+)*-d\s*\$|curl POST with variable data'
  'CRITICAL|exfiltration|curl\s+.*--data.*\$|curl POST with variable data'
  'CRITICAL|exfiltration|nc\s+-[a-z]*\s+\d+\.\d+\.\d+\.\d+|Netcat to IP address'
  'CRITICAL|exfiltration|ncat\s+.*\d+\.\d+\.\d+\.\d+|Ncat to IP address'

  # Obfuscation — base64 to shell, hex-encoded strings
  'HIGH|obfuscation|base64\s+(-d|--decode).*\|\s*(bash|sh)|Base64 decode piped to shell'
  'HIGH|obfuscation|echo\s+.*\|\s*base64\s+(-d|--decode).*\|\s*(bash|sh)|Echo + base64 decode to shell'
  'HIGH|obfuscation|\\\\x[0-9a-fA-F]{2}\\\\x[0-9a-fA-F]{2}\\\\x[0-9a-fA-F]{2}|Hex-encoded string sequence'
  'HIGH|obfuscation|python3?\s+-c\s+.*exec\s*\(|Python exec() from command line'

  # Persistence — crontab, bashrc/profile modification
  'HIGH|persistence|crontab\s+-[el]|Crontab modification'
  'HIGH|persistence|>>\s*~/\.bashrc|Appending to .bashrc'
  'HIGH|persistence|>>\s*~/\.profile|Appending to .profile'
  'HIGH|persistence|>>\s*~/\.zshrc|Appending to .zshrc'
  'HIGH|persistence|systemctl\s+enable|Enabling systemd service'
)
