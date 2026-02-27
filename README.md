# clawhub-lab

Skill development for [ClawHub](https://clawdhub.com) and ecosystem research into [OpenClaw](https://openclaw.dev), [Moltbook](https://moltbook.com), and their surrounding infrastructure. Twenty-four agent skills published to the registry — infrastructure tools the gold rush left empty — plus platform reverse-engineering, a trojanized skill discovery, and a security analysis compilation.

**Author**: [@gitgoodordietrying](https://github.com/gitgoodordietrying)

---

## What Is This

A skill development lab and ecosystem research repository. Two purposes, one codebase:

1. **Skill publisher** — 24 production-quality skills filling infrastructure gaps in the ClawHub registry (SQL, CI/CD, testing, security, profiling, and 19 more). Designed to age well past the gold rush phase.
2. **Research lab** — API reverse-engineering, registry analysis, Moltbook social network investigation, a trojanized skill incident report, and a compiled security threat landscape.

**What you can do here:** read and reuse skill source, review ecosystem research, reference the security findings, or use the development environment to write your own skills.

**What this isn't:** a runtime for running OpenClaw agents, a sandbox for executing untrusted code, or a replacement for proper container isolation. For that, see [openclaw-vault](https://github.com/gitgoodordietrying/openclaw-vault) — the hardened container companion where your API key never enters the container.

---

## The Ecosystem (Who's Who)

The naming is confusing because everything rebranded in the same week. Here's the map:

- **OpenClaw** — the agent runtime (formerly Clawdbot, then Moltbot). Open-source, runs on your machine, full system access by default.
- **ClawHub** — the skill registry. Think npm for agent plugins. Publish with `molthub publish`, install with `molthub install`. 11.9% malicious rate during the ClawHavoc campaign.
- **Moltbook** — the social network for AI agents. 1.6M registered agents, vote counts trivially exploitable, real technical discourse buried under noise.
- **molthub** — the CLI tool (`npm install -g molthub`). Package manager for ClawHub skills.

These layers stack: ClawHub supplies capabilities → OpenClaw runs the agent → Moltbook connects agents socially. For full definitions and architecture diagrams, see the [openclaw-vault README](https://github.com/gitgoodordietrying/openclaw-vault#what-is-openclaw).

---

## Published Skills

The ClawHub registry launched in late January 2026 with ~200+ skills — mostly Twitter CLI forks, crypto bots, and coding agent duplicates. What was missing: the infrastructure tools developers actually use daily. Twenty skills fill those gaps, three meta-skills help anyone write and optimize skills for the registry, and the Emergency Rescue Kit is the skill you hope you never need.

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

## Research & Security Findings

Ecosystem exploration produced several research artifacts:

- **Trojanized skill discovery** — `moltbook-ay` contained instructions to download and execute malware via password-protected archives. Classic social engineering adapted for autonomous agents. No code was executed; the `molthub install` process was [verified from source](docs/journey.md#phase-11-security-audit) to be download-extract-write only.
- **ClawHub platform analysis** — API reverse-engineering, registry discovery protocol, skill format schema, publishing flow, semantic search mechanics, and registry statistics at one week old (~200+ skills). Full report: [clawdhub-platform-report.md](docs/research/clawdhub-platform-report.md).
- **Moltbook investigation** — 1.6M agents, 154K posts, a publicly documented vote exploit, and the decision to retract rather than participate. Documented in [journey.md](docs/journey.md#phase-10-moltbook-exploration--security-incident).
- **Security compilation** — Willison's "lethal trifecta" framework, CVE-2026-25253 (one-click RCE), the ClawHavoc supply chain campaign (341 malicious skills), the Moltbook database breach, and 21,639 exposed instances. Full analysis: [security-report.md](docs/research/security-report.md).
- **End-to-end narrative** — From package vetting to 24 published skills, ecosystem retraction, and lessons learned: [journey.md](docs/journey.md).

---

## Development Environment

All skill development was done inside a Docker Desktop sandbox (Docker 4.59.0) with telemetry disabled. The sandbox provides VM-level isolation with network proxy controls — the right precaution for a one-week-old platform from an unknown ecosystem.

- **Sandbox setup guide**: [airgapped-sandbox.md](docs/setup/airgapped-sandbox.md)
- **Full container hardening**: [openclaw-vault](https://github.com/gitgoodordietrying/openclaw-vault) (proxy-side API key injection, allowlist networking, kill switch)
- **Spec-driven workflow**: [claude-speckit.md](docs/setup/claude-speckit.md) — adapted from GitHub Spec-Kit for agentic development
- **Devcontainer config**: [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) (telemetry disabled via `CLAWHUB_DISABLE_TELEMETRY=1`)

---

## Project Structure

```
clawhub-lab/
  skills/                           # Published skill bundles + one installed sample
    coding-agent/SKILL.md           # (installed from registry during research — not ours)
    docker-sandbox/SKILL.md
    csv-pipeline/SKILL.md
    api-dev/SKILL.md
    cicd-pipeline/SKILL.md
    sql-toolkit/SKILL.md
    test-patterns/SKILL.md
    log-analyzer/SKILL.md
    security-audit/SKILL.md
    infra-as-code/SKILL.md
    perf-profiler/SKILL.md
    git-workflows/SKILL.md
    regex-patterns/SKILL.md
    ssh-tunnel/SKILL.md
    container-debug/SKILL.md
    data-validation/SKILL.md
    shell-scripting/SKILL.md
    dns-networking/SKILL.md
    cron-scheduling/SKILL.md
    encoding-formats/SKILL.md
    makefile-build/SKILL.md
    skill-writer/SKILL.md
    skill-reviewer/SKILL.md
    skill-search-optimizer/SKILL.md
    emergency-rescue/SKILL.md
  docs/
    journey.md                      # Full session narrative — from package vetting to publishing
    research/
      clawdhub-platform-report.md   # Technical report: API, schemas, security model, registry stats
      security-report.md            # Trojanized skill analysis and security findings
    setup/
      claude-speckit.md             # Spec-driven development framework reference
      airgapped-sandbox.md          # Air-gapped Docker sandbox setup guide
  .devcontainer/
    devcontainer.json               # Devcontainer config (telemetry disabled)
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

- **[openclaw-vault](https://github.com/gitgoodordietrying/openclaw-vault)** — Hardened container for running OpenClaw agents. Proxy-side API key injection, domain allowlisting, kill switch, 15-point security verification. The safe way to experiment with the ecosystem.

---

## License

Skills are published to ClawHub under its registry terms. Source files in this repo are available for reference.
