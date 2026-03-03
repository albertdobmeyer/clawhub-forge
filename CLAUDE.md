# ClawHub Forge — Skill Development Workbench

## What This Is

ClawHub Forge is a **skill development workbench and security pipeline** for the ClawHub ecosystem. It lets developers create, lint, scan, verify, test, and publish agent skills — with a heavy emphasis on offline security scanning against 87 malicious patterns across 13 MITRE ATT&CK categories.

**Role in ecosystem**: `toolchain` — the active defense layer that ensures skill quality and safety before anything reaches the agent runtime.

## This Repo Is a Lobster-TrApp Component

This repo is integrated into [lobster-trapp](https://github.com/gitgoodordietrying/lobster-trapp) as a git submodule under `components/clawhub-forge/`. The file `component.yml` in this repo's root is the **manifest contract** that tells the Lobster-TrApp GUI how to discover, display, and control this component.

### Manifest Contract Rules
- `component.yml` must always parse as valid YAML
- `identity.id` must be `clawhub-forge` (the GUI uses this as a stable key)
- `identity.role` must be `toolchain`
- Commands with `options_from` must have working commands (e.g., `ls skills/` must work from repo root)
- All `available_when` values must reference states declared in `status.states`
- Command IDs and health probe IDs must be unique

### Validating the Manifest
From the lobster-trapp root:
```bash
bash tests/orchestrator-check.sh    # Validates all manifests including this one
cargo test -p lobster-trapp          # Rust tests parse this manifest specifically
```

## Directory Structure

```
clawhub-forge/
├── Makefile                      Single entry point for all commands (~35 targets)
├── component.yml                 MANIFEST — Lobster-TrApp contract
├── skills/                       25 published skills
├── tools/
│   ├── lib/
│   │   ├── common.sh             Colors, logging, skill discovery
│   │   ├── frontmatter.sh        YAML frontmatter parser + validator
│   │   ├── patterns.sh           87 malicious patterns (MITRE ATT&CK)
│   │   ├── line-classifier.sh    SAFE/SUSPICIOUS/MALICIOUS classifier
│   │   ├── trust-manifest.sh     .trust file + SHA-256 validation
│   │   └── sarif_formatter.py    SARIF 2.1.0 output formatter
│   ├── skill-lint.sh             Linter
│   ├── skill-scan.sh             Security scanner
│   ├── skill-verify.sh           Zero-trust verifier
│   ├── skill-test.sh             Test runner
│   ├── skill-new.sh              Scaffolder
│   ├── skill-publish.sh          Gated publisher
│   ├── skill-stats.sh            Adoption metrics
│   ├── registry-explore.sh       Registry browser
│   ├── workbench-verify.sh       12-point health check
│   └── pipeline-report.sh        Value summary
├── templates/                    Skill templates (cli-tool, workflow, language-ref)
├── tests/
│   ├── _framework/               Test runner + assertions
│   ├── scanner-self-test/        Scanner accuracy validation
│   └── *.test.sh                 25 test files (100% coverage)
├── .github/workflows/
│   └── skill-ci.yml              CI: lint → scan → test on PR
└── docs/                         Research reports, setup guides
```

## Key Makefile Commands

### Development
```bash
make new SKILL=name               # Scaffold new skill
make lint                          # Lint all skills
make scan                          # Security scan all skills
make scan-one SKILL=name           # Scan single skill
make verify-skill SKILL=name       # Zero-trust verify single skill
make test                          # Run all tests (168+ assertions)
make publish SKILL=name VERSION=x  # Gated publish (lint→scan→test must pass)
```

### Analytics
```bash
make stats                         # Adoption metrics
make explore QUERY=term            # Browse ClawHub registry
make report                        # Pipeline value summary
```

### Verification
```bash
make verify                        # 12-point workbench health check
make check                         # Full pipeline: lint + scan + test
make self-test                     # Scanner self-test (known patterns)
```

## Commands Exposed to GUI (component.yml)

The manifest exposes 14 commands in 3 groups:

**Operations**: new-skill, lint, scan, verify, test, publish, lint-all, scan-all, verify-all
**Monitoring**: stats, explore, report
**Maintenance**: clean, setup

Several commands use `options_from` to dynamically populate dropdowns:
- `ls skills/` provides the skill picker for lint, scan, verify, test, publish
- `ls templates/` provides template options for new-skill
- Sort options for explore are static: `downloads`, `trending`, `installs`

## Security Pipeline

The gated publishing flow:
```
make new → make lint → make scan → make verify-skill → make test → make publish
                                                                        │
                                                            ALL must pass
```

### Scanning Capabilities
- 87 malicious patterns across 13 MITRE ATT&CK categories
- 16 prompt injection detection patterns for LLM manipulation
- Zero-trust line-by-line classification (SAFE / SUSPICIOUS / MALICIOUS)
- SARIF output for GitHub code scanning integration
- Post-install quarantine scan for newly downloaded skills

## Dual-Copy Sync

This repo may exist in two places on your machine:
- **Standalone**: `B:\REPOS\local-llm\clawhub-forge\`
- **Submodule**: `B:\REPOS\local-llm\lobster-trapp\components\clawhub-forge\`

**GitHub**: https://github.com/gitgoodordietrying/clawhub-forge

After pushing changes from either location, sync the other:
```bash
# In the other copy:
git pull
# If submodule copy, also update parent:
cd ../.. && git add components/clawhub-forge && git commit -m "Update clawhub-forge ref"
```

## What NOT to Do

- Do not change `identity.id` or `identity.role` in component.yml without coordinating with lobster-trapp
- Do not remove or rename command IDs that the GUI depends on — add new ones instead
- Do not modify `tools/lib/patterns.sh` without running `make self-test` to verify scanner accuracy
- Do not bypass the gated publish pipeline — `make publish` enforces lint→scan→test
- Do not add skills without tests — 100% coverage is the current standard
- Do not break the `ls skills/` command — the GUI uses it for dynamic dropdowns
