.PHONY: help new lint lint-one scan scan-one scan-json scan-sarif scan-summary scan-strict test test-one test-tools publish stats stats-trend stats-rank check check-all self-test verify verify-skill verify-all verify-report explore report clean

SHELL := /bin/bash
SKILLS_DIR := skills
TOOLS_DIR := tools
TESTS_DIR := tests

help: ## Show available commands
	@echo ""
	@echo "  clawhub-forge workbench"
	@echo "  ====================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
	@echo ""

new: ## Scaffold new skill from template (SKILL=name TYPE=cli-tool|workflow|language-ref)
	@bash $(TOOLS_DIR)/skill-new.sh "$(SKILL)" "$(or $(TYPE),cli-tool)"

lint: ## Lint all skills (frontmatter + structure + content)
	@bash $(TOOLS_DIR)/skill-lint.sh $(SKILLS_DIR)

lint-one: ## Lint single skill (SKILL=name)
	@bash $(TOOLS_DIR)/skill-lint.sh $(SKILLS_DIR)/$(SKILL)

scan: ## Offline security scan all skills
	@bash $(TOOLS_DIR)/skill-scan.sh $(SKILLS_DIR)

scan-one: ## Scan single skill (SKILL=name)
	@bash $(TOOLS_DIR)/skill-scan.sh $(SKILLS_DIR)/$(SKILL)

scan-json: ## Scan all skills, JSON output
	@bash $(TOOLS_DIR)/skill-scan.sh --json $(SKILLS_DIR)

scan-sarif: ## Scan all skills, SARIF 2.1.0 output
	@bash $(TOOLS_DIR)/skill-scan.sh --sarif $(SKILLS_DIR)

scan-summary: ## Scan all skills, one-line summary output
	@bash $(TOOLS_DIR)/skill-scan.sh --summary $(SKILLS_DIR)

scan-strict: ## Scan with --strict (HIGH findings block)
	@bash $(TOOLS_DIR)/skill-scan.sh --strict $(SKILLS_DIR)

self-test: ## Run scanner self-test (known-bad/clean/allowlisted)
	@bash $(TESTS_DIR)/scanner-self-test/run.sh

verify-skill: ## Zero-trust verify single skill (SKILL=name)
	@bash $(TOOLS_DIR)/skill-verify.sh $(SKILLS_DIR)/$(SKILL)

verify-all: ## Zero-trust verify all skills
	@bash $(TOOLS_DIR)/skill-verify.sh $(SKILLS_DIR)

verify-report: ## Verify with per-line report (SKILL=name)
	@bash $(TOOLS_DIR)/skill-verify.sh --report $(SKILLS_DIR)/$(SKILL)

test: ## Run skill behavioral tests
	@bash $(TOOLS_DIR)/skill-test.sh

test-one: ## Test single skill (SKILL=name)
	@bash $(TOOLS_DIR)/skill-test.sh $(SKILL)

test-tools: ## Run tool behavioral tests
	@bash $(TESTS_DIR)/_framework/tool-runner.sh

publish: ## Lint + scan + test + publish (SKILL=name VERSION=x.y.z)
	@bash $(TOOLS_DIR)/skill-publish.sh "$(SKILL)" "$(VERSION)"

stats: ## Check adoption metrics from ClawHub API
	@bash $(TOOLS_DIR)/skill-stats.sh

stats-trend: ## Stats with growth deltas vs previous snapshots
	@bash $(TOOLS_DIR)/skill-stats.sh --trend

stats-rank: ## Our skills ranked against registry top 50
	@bash $(TOOLS_DIR)/skill-stats.sh --rank

explore: ## Browse registry top skills (QUERY=term SORT=downloads|trending|installs LIMIT=n)
	@bash $(TOOLS_DIR)/registry-explore.sh $(if $(QUERY),"$(QUERY)") $(if $(SORT),--sort=$(SORT)) $(if $(LIMIT),--limit=$(LIMIT))

verify: ## 12-point workbench health verification
	@bash $(TOOLS_DIR)/workbench-verify.sh

check: ## Full pipeline: lint + scan + test
	@echo ""
	@echo "=== Running full pipeline ==="
	@echo ""
	@bash $(TOOLS_DIR)/skill-lint.sh $(SKILLS_DIR)
	@echo ""
	@bash $(TOOLS_DIR)/skill-scan.sh $(SKILLS_DIR)
	@echo ""
	@bash $(TOOLS_DIR)/skill-test.sh
	@echo ""
	@echo "=== Pipeline complete ==="

check-all: ## Full pipeline + self-test + tool tests
	@echo ""
	@echo "=== Running full pipeline + all tests ==="
	@echo ""
	@bash $(TOOLS_DIR)/skill-lint.sh $(SKILLS_DIR)
	@echo ""
	@bash $(TOOLS_DIR)/skill-scan.sh $(SKILLS_DIR)
	@echo ""
	@bash $(TOOLS_DIR)/skill-test.sh
	@echo ""
	@bash $(TESTS_DIR)/scanner-self-test/run.sh
	@echo ""
	@bash $(TESTS_DIR)/_framework/tool-runner.sh
	@echo ""
	@echo "=== All checks complete ==="

report: ## Pipeline value report — what the workbench catches
	@bash $(TOOLS_DIR)/pipeline-report.sh

clean: ## Remove generated cache files
	@rm -rf .workbench-cache
	@echo "Cache cleaned."
