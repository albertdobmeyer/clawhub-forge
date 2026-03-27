# ClawHub-Forge Roadmap

**Updated:** 2026-03-27
**Current state:** 25 published skills, 87-pattern scanner, zero-trust verifier, gated publishing pipeline, 168 behavioral test assertions. Most mature of the three modules.
**Cross-reference:** See `docs/trifecta.md` in the lobster-trapp root for how this module fits with openclaw-vault and moltbook-pioneer.

---

## Phase 1: Housekeeping

**Why:** Small issues that erode trust in an otherwise solid codebase.

| Task | Details |
|---|---|
| Remove duplicate `docs/security-report.md` | Keep `docs/research/security-report.md` (more discoverable path). Delete `docs/security-report.md`. |
| Create `.devcontainer/setup.sh` | Referenced in `devcontainer.json` but doesn't exist. Causes VS Code devcontainer setup to fail. |
| Complete Gear → Shell terminology | Update any references to "Gear 1/2/3" to use "Hard/Split/Soft Shell" per `GLOSSARY.md`. |
| Fix `coding-agent` skill exclusion | Either add tests and include in publish pipeline, or remove from `skills/` if it's not production-ready. |

**Exit criteria:** No duplicate files. DevContainer works on fresh clone. Terminology consistent.

---

## Phase 2: Trust File Generation

**Why:** The zero-trust verifier supports `.trust` files (SHA-256 hashes) for fast-path verification of our own skills. No `.trust` files exist yet — every verification run re-scans everything from scratch.

| Task | Details |
|---|---|
| Run full verify on all 25 skills | Generate `.trust` files for each passing skill |
| Document `.trust` file lifecycle | When to regenerate, what invalidates a trust file |
| Add `make trust-all` target | Regenerate trust files for all skills in one command |

**Exit criteria:** All 25 skills have `.trust` files. Subsequent `make verify` runs are fast for unchanged skills.

---

## Phase 3: Vault Integration — Skill Installation Path

**Why:** This is the most important cross-module gap. Forge vets skills, vault runs them — but there's no documented or automated workflow for getting a forge-vetted skill into the vault.

| Task | Details |
|---|---|
| Document manual skill transfer | How to copy a forge-vetted skill into the vault container's workspace |
| Design clearance report format | A machine-readable output from `make scan` + `make verify` that vault can consume |
| Build `make export SKILL=name` | Packages a vetted skill with its scan report for transfer to vault |
| Coordinate with vault Phase 5a | Define the vault-side acceptance mechanism |

**Exit criteria:** A user can forge a skill, export it with clearance, and load it into the vault. The workflow is documented end-to-end.

---

## Phase 4: Scanner Improvements

**Why:** The scanner works but has room for operational improvement.

| Task | Details |
|---|---|
| Verify scanner against real ClawHub skills | Download a sample of live ClawHub skills and run the scanner. Confirm detection rates. |
| Add `--update-patterns` mechanism | Way to add new patterns from threat intel without editing source |
| Pattern sharing with pioneer | Investigate shared pattern format between forge's 87 patterns and pioneer's 30 patterns |
| Registry API liveness check | Confirm `clawdhub.com/api/v1` is accessible. Add `--dry-run` mode with fixture data if not. |

**Exit criteria:** Scanner tested against real-world skills. Pattern update mechanism documented.

---

## Phase 5: CI/CD Pipeline

**Why:** The auto-publish CI job is commented out. For a production release, the pipeline should be automated.

| Task | Details |
|---|---|
| Uncomment and configure CI publish job | Lint → scan → test → publish in CI |
| Add GitHub Actions workflow | Run `make test-all` and `make scan-all` on PR |
| Protect main branch | Require passing CI before merge |

**Exit criteria:** PRs are automatically tested. Publishing is gated by CI.

---

## Dependency Graph

```
Phase 1 (Housekeeping)
    ↓
Phase 2 (Trust files)
    ↓
Phase 3 (Vault integration) ← depends on vault Phase 5a
    ↓
Phase 4 (Scanner improvements)
    ↓
Phase 5 (CI/CD)
```

---

*This roadmap covers the clawhub-forge module only. See `openclaw-vault/docs/roadmap.md` and `moltbook-pioneer/docs/roadmap.md` for the other modules.*
