.PHONY: help new lint lint-one scan scan-one scan-json scan-sarif scan-summary test test-one publish stats stats-trend stats-rank check self-test verify explore report clean

SHELL := /bin/bash
SKILLS_DIR := skills
TOOLS_DIR := tools
TESTS_DIR := tests

help: ## Show available commands
	@echo ""
	@echo "  clawhub-lab workbench"
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

self-test: ## Run scanner self-test (known-bad/clean/allowlisted)
	@bash $(TESTS_DIR)/scanner-self-test/run.sh

test: ## Run skill behavioral tests
	@bash $(TOOLS_DIR)/skill-test.sh

test-one: ## Test single skill (SKILL=name)
	@bash $(TOOLS_DIR)/skill-test.sh $(SKILL)

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

clean: ## Remove generated cache files
	@rm -rf .workbench-cache
	@echo "Cache cleaned."
