# clawhub-lab

The Skill Development Workbench for [ClawHub](https://clawdhub.com). An offline-first pipeline to build, validate, and publish agent skills: `make new` → `make lint` → `make scan` → `make test` → `make publish`.

**Author**: [@gitgoodordietrying](https://github.com/gitgoodordietrying)

---

## What Is This

A complete development workbench for ClawHub skills. Twenty-four published skills, a linter, an offline security scanner, a test framework, and a gated publishing pipeline — all driven from a single Makefile.

**What you can do here:** scaffold new skills from templates, lint them for structure and content quality, scan them for malicious patterns (offline, no network required), run behavioral tests, and publish through a gated pipeline.

**What this isn't:** a runtime for running OpenClaw agents, or a sandbox for executing untrusted code. For that, see [openclaw-vault](https://github.com/gitgoodordietrying/openclaw-vault) — the hardened container companion where your API key never enters the container.

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

**Offline security scanner** — works without network. Pattern database derived from the real [moltbook-ay trojan](docs/research/security-report.md) and ClawHavoc campaign analysis.

| Category | Severity | What it catches |
|----------|----------|-----------------|
| C2/Download | CRITICAL | curl/wget/fetch to external URLs |
| Archive execution | CRITICAL | Password-protected ZIP/7z extraction |
| Exec download | CRITICAL | chmod+execute, bash -c with curl, eval with subshell |
| Credential access | HIGH | Reading .env, .ssh/id_rsa, printenv |
| Data exfiltration | CRITICAL | curl POST with variable data, netcat to IPs |
| Obfuscation | HIGH | Base64-decode piped to shell, hex-encoded strings |
| Persistence | HIGH | crontab modification, .bashrc/.profile appending |

Skills that legitimately discuss these patterns (like `security-audit`) can use `# scan:ignore-next-line` inline or a `.scanignore` file.

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
clawhub-lab/
  skills/                           # Published skill bundles
    docker-sandbox/SKILL.md
    csv-pipeline/SKILL.md
    ... (24 skills total)
  tools/                            # Workbench tooling
    lib/
      common.sh                     # Colors, logging, skill discovery
      frontmatter.sh                # YAML frontmatter parser + validator
      patterns.sh                   # Malicious pattern database for scanner
    skill-lint.sh                   # Linter
    skill-scan.sh                   # Offline security scanner
    skill-test.sh                   # Test runner wrapper
    skill-new.sh                    # Skill scaffolder
    skill-publish.sh                # Gated publisher
    skill-stats.sh                  # Adoption metrics fetcher
  templates/                        # Skill templates
    cli-tool/SKILL.md               # CLI/tool reference template
    workflow/SKILL.md               # Process/methodology template
    language-ref/SKILL.md           # Language/syntax reference template
  tests/                            # Behavioral tests
    _framework/
      runner.sh                     # Test file discovery + execution
      assertions.sh                 # assert_section_exists, assert_contains, etc.
    docker-sandbox.test.sh          # Example test files
    sql-toolkit.test.sh
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
