.PHONY: help new lint lint-one scan scan-one test test-one publish stats check clean

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

test: ## Run skill behavioral tests
	@bash $(TOOLS_DIR)/skill-test.sh

test-one: ## Test single skill (SKILL=name)
	@bash $(TOOLS_DIR)/skill-test.sh $(SKILL)

publish: ## Lint + scan + test + publish (SKILL=name VERSION=x.y.z)
	@bash $(TOOLS_DIR)/skill-publish.sh "$(SKILL)" "$(VERSION)"

stats: ## Check adoption metrics from ClawHub API
	@bash $(TOOLS_DIR)/skill-stats.sh

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
