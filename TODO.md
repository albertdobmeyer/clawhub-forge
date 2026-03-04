# ClawHub-Forge — TODO

Tracked gaps from the 2026-03-03 audit. See `docs/vision-and-status.md` in lobster-trapp for the high-level roadmap.

---

## DevContainer Setup Script Missing

- [ ] `.devcontainer/setup.sh` — Referenced in `devcontainer.json` `postCreateCommand` but the file doesn't exist. Opening this repo in a devcontainer will fail at the post-create step. Create the script or update devcontainer.json to remove the reference.

---

## CI: Auto-Publish Job

- [ ] `.github/workflows/skill-ci.yml` has a commented-out auto-publish step with `# TODO: detect changed skills and auto-publish`. Implement or remove.

---

## No .trust Files Exist

- [ ] No skill has been through the full publish gate (`lint → scan → verify → test → publish`). The `.trust` hash-pinning system is implemented in `skill-verify.sh` and `trust-manifest.sh` but has zero real-world artifacts. Consider publishing at least one skill end-to-end to validate the pipeline.

---

## Registry API Dependency

- [ ] `tools/skill-stats.sh` and `tools/registry-explore.sh` call `clawdhub.com/api/v1` — this endpoint may not be live. No offline or mock mode exists for local development/testing. Consider adding `--dry-run` or mock fixtures.

---

## Coding-Agent Skill

- [ ] `skills/coding-agent/` is excluded from publish (hardcoded `continue` in publish script) and has no test file. Either complete it or mark it explicitly as draft/experimental.
