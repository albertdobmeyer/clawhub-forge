# openclaw-research

Security research, ecosystem exploration, and contributions to [OpenClaw](https://github.com/anthropics/openclaw) — the 200k-star agentic workstation platform.

This repo documents what I found exploring OpenClaw and Moltbook: the threat landscape, the supply chain attacks, the architectural patterns, and 24 published skills built to fill gaps in the ecosystem. It's a research portfolio, shared for knowledge.

**Author**: [@gitgoodordietrying](https://github.com/gitgoodordietrying)

---

## Looking to run OpenClaw securely?

The hardened containment framework that emerged from this research is its own project:

**[openclaw-vault](https://github.com/gitgoodordietrying/openclaw-vault)** — defense-in-depth sandbox with proxy-side API key injection, domain allowlisting, and a kill switch. Your API key never enters the container.

---

## Research & Analysis

| Document | Contents |
|----------|----------|
| [Security Analysis](docs/security-report.md) | CVE-2026-25253, ClawHavoc (11.9% malicious skill rate), database breach, 21K exposed instances, threat model |
| [Safe Participation Guide](docs/airgapped-sandbox.md) | Operational security procedures, OpenClaw hardening config, research methodology |
| [Journey](docs/journey.md) | End-to-end narrative: package vetting, Docker sandbox setup, API reverse engineering, ecosystem analysis, trojanized skill discovery, lessons learned |
| [Platform Report](docs/research/clawdhub-platform-report.md) | ClawdHub API endpoints, skill format schema, security model, registry statistics, Moltbook/OpenClaw ecosystem analysis |

---

## Published Skills (24)

Twenty-four agent skills published to [ClawdHub](https://clawdhub.com), targeting infrastructure categories the registry's gold rush left empty — plus meta-skills for the ecosystem and an emergency rescue kit.

During ecosystem exploration, a trojanized skill (`moltbook-ay`) was discovered in the registry containing instructions to download and execute malware via password-protected archives. Full incident documentation is in the [journey](docs/journey.md).

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

## Project Structure

```
openclaw-research/
├── docs/
│   ├── security-report.md            # Security analysis compilation
│   ├── airgapped-sandbox.md          # Safe participation guide
│   ├── journey.md                    # Full exploration narrative
│   └── research/
│       └── clawdhub-platform-report.md
├── skills/                           # 24 published skills + 1 installed sample
│   ├── docker-sandbox/SKILL.md
│   ├── csv-pipeline/SKILL.md
│   ├── ...                           # (20 more)
│   ├── emergency-rescue/SKILL.md
│   └── coding-agent/SKILL.md        # (installed from registry — not ours)
└── .devcontainer/
    └── devcontainer.json             # Devcontainer config (telemetry disabled)
```

The hardened containment framework lives in its own repo: [openclaw-vault](https://github.com/gitgoodordietrying/openclaw-vault)

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

## License

Skills are published to ClawdHub under its registry terms. Source files in this repo are available for reference.
