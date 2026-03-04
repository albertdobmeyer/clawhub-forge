# clawhub-forge

[![Skill CI](https://github.com/gitgoodordietrying/clawhub-forge/actions/workflows/skill-ci.yml/badge.svg)](https://github.com/gitgoodordietrying/clawhub-forge/actions/workflows/skill-ci.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

The Skill Development Workbench for [ClawHub](https://clawdhub.com). An offline-first pipeline to build, validate, and publish agent skills: `make new` → `make lint` → `make scan` → `make test` → `make publish`.

**Author**: [@gitgoodordietrying](https://github.com/gitgoodordietrying)

---

## What Is This

A complete development workbench for ClawHub skills. Twenty-five published skills, a linter, an offline security scanner (87 patterns, 13 categories including prompt injection detection, SARIF output), a zero-trust skill verifier (guilty-until-proven-innocent line classification), a test framework (100% coverage), and a gated publishing pipeline — all driven from a single Makefile.

**What you can do here:** scaffold new skills from templates, lint them for structure and content quality, scan them for malicious patterns (offline, no network required), run behavioral tests, and publish through a gated pipeline.

**What this isn't:** a runtime for running OpenClaw agents, or a sandbox for executing untrusted code. For that, see [openclaw-vault](https://github.com/gitgoodordietrying/openclaw-vault) — the hardened container companion where your API key never enters the container.

---

## Why a Workbench?

**"How is this better than just having Claude write a SKILL.md?"**

An AI can draft a skill file in seconds. What it can't do is gate its own output through a security pipeline, track quality over time, or prove to a human operator that the result is safe. This workbench exists because the gap between "generated" and "production-ready" is where real risk lives.

What the pipeline provides that raw authoring doesn't:

- **71 malicious patterns across 13 categories** — MITRE ATT&CK mapped, derived from real trojanized skills (the ClawHavoc campaign). Every skill is scanned offline before publishing.
- **Prompt injection detection** — 16 patterns detect LLM manipulation attempts: override instructions, persona hijacking, stealth commands, data theft instructions, and format token injection.
- **Multi-file scanning** — the scanner inspects ALL files in skill directories (`.md`, `.sh`, `.py`, `.js`, `.ts`, `.yaml`, `.yml`, `.json`), not just `SKILL.md`.
- **Strict mode** — `make scan-strict` blocks HIGH findings too, not just CRITICAL. Prevents ssh key theft, persistence, and container escape patterns from slipping through.
- **Post-install quarantine** — when `ALLOW_INSTALL=1` is used, the scanner auto-runs on newly installed skills and quarantines failures.
- **Suppression audit** — `.scanignore` files are validated: ranges >50 lines are rejected (prevents `L1-L9999` blanket suppression).
- **Behavioral assertions** — 168+ test assertions enforce content consistency, structural requirements, and domain accuracy across all skills.
- **Mandatory test gate** — every skill must have a test file to publish. No more silent test skipping.
- **Gated publishing** — `make publish` won't run until lint, scan, and test all pass. No human judgment call required at the gate.
- **SARIF output for CI** — GitHub code scanning integration via `make scan-sarif`, so the pipeline runs on every PR automatically.
- **Transparent allowlisting** — skills that legitimately discuss security patterns (like `security-audit`) use explicit `.scanignore` files, not global suppression. Every exception is auditable.
- **Zero-trust verification** — `make verify-all` classifies every line in every skill file. One unrecognizable line quarantines the entire skill. Catches novel attacks the blocklist misses.
- **Tool test suite** — 40+ behavioral tests verify the workbench tools themselves (`make test-tools`).
- **Trend tracking** — `make stats-trend` shows whether skills are growing or dying. `make stats-rank` shows competitive positioning.

Run `make report` to see a concrete summary of what the pipeline catches.

---

## Operator Commands

Commands for the human operator to assess workbench health and competitive position:

```bash
make verify                           # 12-point workbench health check
make report                           # Pipeline value summary
make scan-strict                      # Scan with --strict (HIGH blocks)
make verify-all                       # Zero-trust verify all skills
make verify-skill SKILL=docker-sandbox # Verify single skill
make verify-report SKILL=docker-sandbox # Per-line verdict report
make test-tools                       # Run tool behavioral tests
make check-all                        # Full pipeline + self-test + tool tests
make explore                          # Top 20 skills by downloads
make explore QUERY="docker"           # Semantic search for competitors
make explore SORT=trending            # What's hot right now
make explore SORT=installs LIMIT=50   # Most installed, larger set
make stats                            # Current adoption metrics
make stats-trend                      # Growth deltas vs previous snapshots
make stats-rank                       # Our skills ranked against top 50
```

---

## What's Not Here

Transparency about what the workbench can't do:

- **Who installed your skills** — the ClawHub API doesn't expose installer identities or per-user usage data. Download counts are the best signal available.
- **Bot/agent network visibility** — no way to distinguish human installs from automated agent installs. The API doesn't differentiate.
- **Web dashboard** — this is a CLI workbench; terminal tables are the right UX for the workflow. If you want a GUI, see the roadmap for the planned meta-repo.
- **Skill dependencies** — ClawHub has no dependency resolution. Skills are standalone by design.
- **Auto-version bumping** — too risky without human review. Version is always an explicit `VERSION=x.y.z` parameter.

---

## Quick Start

### Option A: VS Code Dev Containers

Open this repo in VS Code with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers). The devcontainer installs Node.js, Python, molthub, and all dependencies automatically.

### Option B: Local

Requirements: bash, git, python3 (for YAML/JSON validation). Optional: molthub (`npm install -g molthub`).

```bash
make help          # Show all commands
make new SKILL=my-tool          # Scaffold from template
make lint          # Lint all skills
make scan          # Security scan all skills
make test          # Run behavioral tests
make check         # Full pipeline: lint + scan + test
```

---

## The Pipeline

### Linter (`make lint`)

Automates skill quality review. Checks:
- **Frontmatter** — delimiters, required fields (`name`, `description`, `metadata`), valid slug, description length, valid JSON metadata
- **Structure** — H1 title, `## When to Use` section, `## Tips` section
- **Content quality** — line count (150-700), code block density (8+ blocks), language tags on fences, no TODO/FIXME/XXX placeholders
- **Metadata consistency** — each binary in `requires.anyBins` is referenced in the content body

### Scanner (`make scan`)

**Offline security scanner** — works without network. 87 patterns across 13 categories with MITRE ATT&CK IDs, derived from the real [moltbook-ay trojan](docs/research/security-report.md) and ClawHavoc campaign analysis. Scans ALL files in skill directories, not just SKILL.md.

| Category | Severity | What it catches |
|----------|----------|-----------------|
| C2/Download | CRITICAL | curl/wget/fetch to external URLs |
| Archive execution | CRITICAL | Password-protected ZIP/7z extraction |
| Exec download | CRITICAL | chmod+execute, bash -c with curl, eval with subshell |
| Credential access | HIGH | Reading .env, .ssh keys, AWS/K8s creds, /proc/environ, PEM files |
| Data exfiltration | CRITICAL | curl POST, netcat, DNS exfil, SCP, git push, FTP to IPs |
| Obfuscation | HIGH | Base64/hex decode to shell, Python/Perl/Ruby eval, OpenSSL decrypt |
| Persistence | HIGH | crontab, bashrc/profile/zshrc/fish, at now, launchctl |
| Privilege escalation | MEDIUM-HIGH | sudo chmod 777, setuid, sudo su, nsenter |
| Container escape | HIGH | --privileged, SYS_ADMIN, mount host, docker.sock, sysrq |
| Supply chain | MEDIUM | Unsafe npm install, pip --pre, registry hijack |
| Environment injection | MEDIUM | LD_PRELOAD, PATH manipulation, env -i |
| Resource abuse | HIGH | Fork bomb, infinite loop with network |
| **Prompt injection** | **HIGH-CRITICAL** | **Override attempts, persona hijacking, stealth instructions, data theft, LLM control tokens** |

**Output modes:** `make scan` (colored terminal), `make scan-summary` (one-line per skill), `make scan-json` (structured JSON), `make scan-sarif` (SARIF 2.1.0 for GitHub code scanning), `make scan-strict` (HIGH blocks too). Scanner self-test: `make self-test`.

Skills that legitimately discuss these patterns (like `security-audit`) can use `<!-- scan:ignore -->` inline or a `.scanignore` file. Scanignore files are audited: ranges >50 lines are rejected.

### Zero-Trust Verifier (`make verify-skill SKILL=name`)

**Guilty until proven innocent.** The scanner uses a blocklist (scan for known-bad, let everything else through). The verifier flips this: every line in every file must be classified as SAFE, or the entire skill is quarantined. No partial passes, no thresholds.

Every line gets one of three verdicts:

| Verdict | Meaning |
|---|---|
| `SAFE` | Line matches a known-safe pattern (structural markdown, prose under 500 chars, code inside fenced blocks, frontmatter fields) |
| `SUSPICIOUS` | Line doesn't match any safe pattern (possible obfuscation, unknown encoding, excessively long content) |
| `MALICIOUS` | Line triggers the 87-pattern blocklist |

**Release rule:** A skill is released from quarantine ONLY if it has ZERO malicious lines AND ZERO suspicious lines. One unrecognizable line quarantines the entire skill.

**Two-stage defense:** Post-install, skills pass through `skill-scan.sh --strict` (blocklist, fast) then `skill-verify.sh --strict` (allowlist, thorough). Both must pass.

**Trust manifests:** Our own skills can carry `.trust` files with SHA-256 content hashes, allowing them to skip verification when unchanged. External skills never have trust manifests.

```bash
make verify-skill SKILL=docker-sandbox   # Verify single skill
make verify-all                           # Verify all skills
make verify-report SKILL=docker-sandbox   # Per-line verdict report
```

### Test Framework (`make test`)

Behavioral assertions for skills — the "pytest for SKILL.md files":

```bash
assert_section_exists "$SKILL" "When to Use"
assert_contains "$SKILL" "docker\s+(run|build|exec)"
assert_not_contains "$SKILL" "(TODO|FIXME|XXX)"
assert_min_code_blocks "$SKILL" 8
assert_frontmatter_field "$SKILL" "name" "^docker-sandbox$"
```

Write `tests/<skill-name>.test.sh` with `test_*` functions. The runner discovers and executes them automatically.

### Publisher (`make publish`)

Gated pipeline: lint → scan → test must all pass before `molthub publish` runs. Usage:

```bash
make publish SKILL=my-tool VERSION=1.0.0
```

---

## Published Skills

Twenty-four production-quality skills filling infrastructure gaps in the ClawHub registry.

### Batch 1 — Gap-Fill (built in Docker sandbox)

| Skill | Install | What It Does |
|---|---|---|
| [Docker Sandbox](skills/docker-sandbox/SKILL.md) | `molthub install docker-sandbox` | Docker sandbox VM management, network proxy, workspace mounting, troubleshooting |
| [CSV Data Pipeline](skills/csv-pipeline/SKILL.md) | `molthub install csv-pipeline` | CSV/JSON/TSV processing with awk and Python — filter, join, aggregate, deduplicate, validate, convert |
| [API Development](skills/api-dev/SKILL.md) | `molthub install api-dev` | curl testing, bash/Python test runners, OpenAPI spec generation, mock servers, Express scaffolding |
| [CI/CD Pipeline](skills/cicd-pipeline/SKILL.md) | `molthub install cicd-pipeline` | GitHub Actions for Node/Python/Go/Rust, matrix builds, caching, Docker build+push, secrets management |

### Batch 2 — Post-Gold-Rush Infrastructure

| Skill | Install | What It Does |
|---|---|---|
| [SQL Toolkit](skills/sql-toolkit/SKILL.md) | `molthub install sql-toolkit` | SQLite/PostgreSQL/MySQL — schema design, queries, CTEs, window functions, migrations, EXPLAIN, indexing |
| [Test Patterns](skills/test-patterns/SKILL.md) | `molthub install test-patterns` | Jest/Vitest, pytest, Go, Rust, Bash — unit tests, mocking, fixtures, coverage, TDD, integration testing |
| [Log Analyzer](skills/log-analyzer/SKILL.md) | `molthub install log-analyzer` | Log parsing, error patterns, stack trace extraction, structured logging setup, real-time monitoring, correlation |
| [Security Audit Toolkit](skills/security-audit/SKILL.md) | `molthub install security-audit-toolkit` | Dependency scanning, secret detection, OWASP patterns, SSL/TLS verification, file permissions, audit scripts |
| [Infrastructure as Code](skills/infra-as-code/SKILL.md) | `molthub install infra-as-code` | Terraform, CloudFormation, Pulumi — VPC, compute, storage, state management, multi-environment patterns |
| [Performance Profiler](skills/perf-profiler/SKILL.md) | `molthub install perf-profiler` | CPU/memory profiling, flame graphs, benchmarking, load testing, memory leak detection, query optimization |

### Batch 3 — Niche Developer Essentials

| Skill | Install | What It Does |
|---|---|---|
| [Git Workflows](skills/git-workflows/SKILL.md) | `molthub install git-workflows` | Interactive rebase, bisect, worktree, reflog recovery, cherry-pick, subtree/submodule, sparse checkout, conflict resolution |
| [Regex Patterns](skills/regex-patterns/SKILL.md) | `molthub install regex-patterns` | Validation patterns, parsing, extraction across JS/Python/Go/grep, search-and-replace, lookahead/lookbehind |
| [SSH Tunnel](skills/ssh-tunnel/SKILL.md) | `molthub install ssh-tunnel` | Local/remote/dynamic port forwarding, jump hosts, SSH config, key management, scp/rsync, connection debugging |
| [Container Debug](skills/container-debug/SKILL.md) | `molthub install container-debug` | Docker logs, exec, networking diagnostics, resource inspection, multi-stage build debugging, health checks, Compose |
| [Data Validation](skills/data-validation/SKILL.md) | `molthub install data-validation` | JSON Schema, Zod (TypeScript), Pydantic (Python), CSV/JSON integrity checks, migration validation |
| [Shell Scripting](skills/shell-scripting/SKILL.md) | `molthub install shell-scripting` | Argument parsing, error handling, trap/cleanup, temp files, parallel execution, portability, config parsing |
| [DNS & Networking](skills/dns-networking/SKILL.md) | `molthub install dns-networking` | DNS debugging (dig/nslookup), port testing, firewall rules, curl diagnostics, proxy config, certificates |
| [Cron & Scheduling](skills/cron-scheduling/SKILL.md) | `molthub install cron-scheduling` | Cron syntax, systemd timers, one-off jobs, timezone/DST handling, job monitoring, locking, idempotent patterns |
| [Encoding & Formats](skills/encoding-formats/SKILL.md) | `molthub install encoding-formats` | Base64, URL encoding, hex, Unicode, JWT decoding, hashing/checksums, serialization format conversion |
| [Makefile & Build](skills/makefile-build/SKILL.md) | `molthub install makefile-build` | Make targets, pattern rules, Go/Python/Node/Docker Makefiles, Just and Task as modern alternatives |

### Batch 4 — Meta-Skills

| Skill | Install | What It Does |
|---|---|---|
| [Skill Writer](skills/skill-writer/SKILL.md) | `molthub install skill-writer` | SKILL.md authoring guide — format spec, frontmatter schema, content patterns, templates, publishing checklist |
| [Skill Reviewer](skills/skill-reviewer/SKILL.md) | `molthub install skill-reviewer` | Skill quality audit — scoring rubric, defect checklists, structural/content/actionability review framework |
| [Skill Search Optimizer](skills/skill-search-optimizer/SKILL.md) | `molthub install skill-search-optimizer` | Registry discoverability — semantic search mechanics, description optimization, visibility testing, competitive positioning |

### Batch 5 — The Capstone

| Skill | Install | What It Does |
|---|---|---|
| [Emergency Rescue Kit](skills/emergency-rescue/SKILL.md) | `molthub install emergency-rescue` | Git disasters, credential leaks, disk full, OOM kills, database failures, deploy rollbacks, SSH lockouts, network outages — step-by-step recovery |

---

<details>
<summary><strong>Research & Security Findings</strong></summary>

Ecosystem exploration produced several research artifacts:

- **Trojanized skill discovery** — `moltbook-ay` contained instructions to download and execute malware via password-protected archives. Classic social engineering adapted for autonomous agents. No code was executed; the `molthub install` process was [verified from source](docs/journey.md#phase-11-security-audit) to be download-extract-write only.
- **ClawHub platform analysis** — API reverse-engineering, registry discovery protocol, skill format schema, publishing flow, semantic search mechanics, and registry statistics at one week old (~200+ skills). Full report: [clawdhub-platform-report.md](docs/research/clawdhub-platform-report.md).
- **Security compilation** — Willison's "lethal trifecta" framework, CVE-2026-25253 (one-click RCE), the ClawHavoc supply chain campaign (341 malicious skills), the Moltbook database breach, and 21,639 exposed instances. Full analysis: [security-report.md](docs/research/security-report.md).
- **End-to-end narrative** — From package vetting to 24 published skills, ecosystem retraction, and lessons learned: [journey.md](docs/journey.md).

</details>

---

## Project Structure

```
clawhub-forge/
  skills/                           # Published skill bundles
    docker-sandbox/SKILL.md
    csv-pipeline/SKILL.md
    ... (25 skills total)
  tools/                            # Workbench tooling
    lib/
      common.sh                     # Colors, logging, skill discovery
      frontmatter.sh                # YAML frontmatter parser + validator
      patterns.sh                   # Malicious pattern database (87 patterns, 13 categories, MITRE ATT&CK)
      line-classifier.sh              # Zero-trust line classifier (SAFE/SUSPICIOUS/MALICIOUS)
      trust-manifest.sh               # .trust file generation + hash validation
      sarif_formatter.py              # SARIF 2.1.0 output formatter
    skill-lint.sh                   # Linter
    skill-scan.sh                   # Offline security scanner
    skill-verify.sh                 # Zero-trust skill verifier
    skill-test.sh                   # Test runner wrapper
    skill-new.sh                    # Skill scaffolder (creates skill + test)
    skill-publish.sh                # Gated publisher
    skill-stats.sh                  # Adoption metrics with trends + ranking
    registry-explore.sh             # Registry browsing + competitive search
    workbench-verify.sh             # 12-point health verification
    pipeline-report.sh              # Pipeline value summary
  templates/                        # Skill templates
    cli-tool/SKILL.md               # CLI/tool reference template
    workflow/SKILL.md               # Process/methodology template
    language-ref/SKILL.md           # Language/syntax reference template
    _test.template.sh               # Auto-generated test file template
  tests/                            # Behavioral tests
    _framework/
      runner.sh                     # Test file discovery + execution
      assertions.sh                 # assert_section_exists, assert_contains, etc.
    scanner-self-test/              # Scanner accuracy validation
      known-bad.md                  # Hits every pattern category
      known-clean.md                # Zero findings expected
      allowlisted.md                # Findings suppressed via .scanignore
      run.sh                        # Self-test runner
    docker-sandbox.test.sh          # 25 test files (100% skill coverage)
    ...
  docs/
    journey.md                      # Full session narrative
    research/
      clawdhub-platform-report.md   # API reverse-engineering report
      security-report.md            # Trojanized skill + security findings
    setup/
      claude-speckit.md             # Spec-driven development reference
      airgapped-sandbox.md          # Docker sandbox setup guide
  .devcontainer/
    devcontainer.json               # Dev container config
    package.json                    # Workbench package manifest
    setup.sh                        # Post-create setup script
  .github/workflows/
    skill-ci.yml                    # CI: lint → scan → test on PR
  Makefile                          # Single entry point for all commands
```

## How Skills Work

Each skill is a `SKILL.md` file with YAML frontmatter that tells an AI agent when and how to use it:

```yaml
---
name: my-skill
description: When to activate this skill
metadata: {"clawdbot":{"emoji":"...","requires":{"anyBins":["tool1","tool2"]}}}
---

# Skill Title

Reference material, patterns, commands, and examples the agent
can follow to perform the task.
```

Install any skill with `molthub install <slug>`. Skills are placed in `./skills/<slug>/` and loaded by the agent on demand.

---

## Companion Repositories

These three repos form a trifecta for safe engagement with the OpenClaw ecosystem:

- **[openclaw-vault](https://github.com/gitgoodordietrying/openclaw-vault)** — Run agents safely. Hardened container with proxy-side API key injection, domain allowlisting, kill switch, 15-point security verification.
- **[moltbook-pioneer](https://github.com/gitgoodordietrying/moltbook-pioneer)** — Socialize safely. Research and safe participation in the Moltbook agentic social network. Feed scanner, agent census, identity management.

---

## License

Skills are published to ClawHub under its registry terms. Source files in this repo are [MIT licensed](LICENSE).
