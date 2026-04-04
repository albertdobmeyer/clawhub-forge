# ClawHub-Forge Roadmap

**Updated:** 2026-04-03
**Current state:** 25 published skills, 87-pattern scanner, zero-trust verifier, gated publishing pipeline, 168 behavioral test assertions, AI-assisted skill creation wizard. Identity and feature set defined in `docs/forge-identity-and-design.md`.
**Cross-reference:** See `docs/trifecta.md` in the lobster-trapp root for how this module fits with openclaw-vault and moltbook-pioneer.

---

## Phase 1: Housekeeping

**Why:** Small issues that erode trust in an otherwise solid codebase. Also generates trust files which exercises the entire pipeline end-to-end (serves as a code audit).

| Task | Details |
|---|---|
| Remove duplicate `docs/security-report.md` | Keep `docs/research/security-report.md`. Delete `docs/security-report.md`. |
| Create `.devcontainer/setup.sh` | Referenced in `devcontainer.json` but doesn't exist. |
| Fix `coding-agent` skill exclusion | Either add tests and include in pipeline, or explicitly mark as draft. |
| Generate .trust files for all 25 skills | Run verify pipeline, generate SHA-256 trust manifests. |
| Add `make trust-all` target | Regenerate trust files in one command. |

**Exit criteria:** Clean repo, devcontainer works, all skills have trust files.

---

## Phase 2: Security Certificate System

**Why:** The vault needs a machine-readable clearance report to accept forge-vetted skills. This is the bridge between forge and vault.

| Task | Details |
|---|---|
| Define clearance report JSON schema | Formalize the certificate format. |
| Build `skill-certify.sh` | Generate certificate from scan+verify+test results. |
| Build `skill-export.sh` | Package skill directory + certificate for vault transfer. |
| Add `make certify` and `make export` targets | Wire into Makefile. |
| Update `skill-publish.sh` | Attach certificate to published skills. |
| Update component.yml | Add certify and export commands for GUI. |

**Exit criteria:** `make export SKILL=name` produces a skill bundle with security certificate. Vault's `install-skill.sh` can validate it.

---

## Phase 3: Content Disarm & Reconstruction (CDR)

**Why:** This is the novel feature that defines the forge's USP. ClawHub has an 11.9% malware rate — traditional scanning catches known patterns but misses novel attacks. CDR rebuilds downloaded skills from semantic intent, destroying any embedded attacks.

| Task | Details |
|---|---|
| Design CDR spec | Full spec with architecture, data flow, security boundaries. |
| Build quarantine zone | Directory management, download-to-quarantine, immediate cleanup. |
| Build CDR sanitizer | Extract safe lines from untrusted content using line-classifier.sh. |
| Build CDR intent extractor | Send safe lines to isolated LLM (Ollama default), get structured intent. |
| Build CDR generator | Reconstruct clean SKILL.md from intent + template. |
| Build CDR orchestrator | End-to-end: quarantine -> sanitize -> extract -> generate -> verify. |
| Build CDR config | LLM backend selection (Ollama/API), model, prompts. |
| Build skill download | Download from ClawHub to quarantine (never to workspace). |
| Add Makefile targets | `make download`, `make cdr`, `make install-safe`. |
| Write CDR tests | Test with known-bad fixtures, verify injection destruction. |

**Key rule:** The original downloaded file is NEVER accessible. Binary: clean rebuild or discard entirely.

**Exit criteria:** `make download SKILL=name` downloads, CDRs, verifies, and delivers a clean skill. Tests prove injection attacks are destroyed in reconstruction.

---

## Phase 4: AI-Assisted Skill Creation — COMPLETED (2026-04-03)

**Why:** Non-technical users need help writing properly formatted SKILL.md files. Reuses the CDR's LLM infrastructure.

| Task | Details | Status |
|---|---|---|
| Design creation wizard spec | What questions to ask, how to map answers to template. | Done — `docs/specs/2026-04-03-ai-assisted-skill-creation.md` |
| Build guided creation flow | Natural language -> template selection -> AI draft -> pipeline verification. | Done — `tools/skill-create.sh` (interactive + non-interactive) |
| Integration with Ollama/API | Use same LLM backend as CDR for skill drafting. | Done — `tools/lib/create-draft.sh`, `tools/lib/create-tests.sh` |

**Exit criteria:** A non-technical user can describe a skill in plain language and get a verified SKILL.md. **MET** — two end-to-end runs (cli-tool + workflow types) passed on first attempt.

---

## Phase 5: CI/CD and Registry Integration

**Why:** The auto-publish CI job is commented out. For a production release, the pipeline should be automated with certificates.

| Task | Details |
|---|---|
| Verify ClawHub API liveness | Confirm `clawdhub.com/api/v1` is accessible, add mock mode if not. |
| Uncomment auto-publish CI | Configure version detection, enable gated publish in CI. |
| Certificate-aware publishing | Published skills include security certificate. |

**Exit criteria:** PRs auto-tested, publishing includes certificates.

---

## Dependency Graph

```
Phase 1 (Housekeeping)
    |
    v
Phase 2 (Certificates) <-- vault needs this format for install-skill.sh
    |
    v
Phase 3 (CDR) <-- the core innovation, depends on certificates for output
    |
    v
Phase 4 (AI Creation) <-- reuses CDR's LLM infrastructure
    |
    v
Phase 5 (CI/CD) <-- final polish
```

---

*This roadmap covers the clawhub-forge module only. See `openclaw-vault/docs/roadmap.md` and `moltbook-pioneer/docs/roadmap.md` for the other modules. See `docs/forge-identity-and-design.md` for the full identity, architecture, and design rationale.*

*Last updated: 2026-04-03*
