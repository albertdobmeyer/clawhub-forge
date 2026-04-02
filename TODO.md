# ClawHub-Forge — TODO

Current actionable items from Phase 1 (Housekeeping). See `docs/roadmap.md` for the full 5-phase plan and `docs/forge-identity-and-design.md` for the authoritative design.

---

## Phase 1: Housekeeping

- [ ] Remove duplicate `docs/security-report.md` — keep `docs/research/security-report.md`
- [ ] Create `.devcontainer/setup.sh` — referenced in `devcontainer.json` but missing
- [ ] Fix `coding-agent` skill — add tests and include in pipeline, or mark as draft
- [ ] Generate `.trust` files for all 25 skills — run `make verify-all`, generate SHA-256 hashes
- [ ] Add `make trust-all` Makefile target — regenerate trust files in one command

## Upcoming (Phase 2+)

- [ ] Build security certificate system (`skill-certify.sh`, `skill-export.sh`)
- [ ] Build Content Disarm & Reconstruction pipeline (CDR — the core innovation)
- [ ] Build AI-assisted skill creation wizard
- [ ] Verify ClawHub API liveness, configure CI auto-publish

---

*Last updated: 2026-04-02*
