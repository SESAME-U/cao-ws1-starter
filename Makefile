.PHONY: help check azure-up azure-down local-up local-down ping collections vault-pass lint run test clean

VAULT_PASS_FILE ?= $(HOME)/.cao_ws1_vault_pass
LAB_PYTHON ?= $(if $(wildcard $(HOME)/.local/share/cao-ws1/venv/bin/python),$(HOME)/.local/share/cao-ws1/venv/bin/python,python3)

help:
	@echo "make check          verify the toolbox"
	@echo "make azure-up       Azure path: create web1 and db1 in one virtual network"
	@echo "make local-up       no-Azure path: start web1 and db1 containers"
	@echo "make ping           ansible all -m ping"
	@echo "make collections    install the collections listed in requirements.yml"
	@echo "make vault-pass     write the workshop vault password to ~/.cao_ws1_vault_pass"
	@echo "make lint           run ansible-lint like the autograder"
	@echo "make run            run playbooks/site.yml (extra options: ARGS=\"-e x=y\")"
	@echo "make test           run the autograder checks against fresh local containers"
	@echo "make azure-down     delete the Azure resource group (do this before you leave)"
	@echo "make local-down     remove the local containers"

check:
	@bash scripts/check.sh

azure-up:
	@bash targets/azure-up.sh

azure-down:
	@bash targets/azure-down.sh

local-up:
	@bash targets/local-up.sh

local-down:
	@bash targets/local-down.sh

ping:
	ansible all -m ping

collections:
	ansible-galaxy collection install -r requirements.yml

vault-pass:
	@umask 077; printf '%s\n' "sesame-cao-ws1" > $(VAULT_PASS_FILE)
	@echo "Wrote $(VAULT_PASS_FILE) (mode 600). Workshop password only: never do this with a real one."

lint:
	ansible-lint --project-dir . -c tests/ansible-lint.yml playbooks/site.yml roles/

run:
	ansible-playbook playbooks/site.yml $(ARGS)

# Same checks as the autograder, on fresh local containers (needs Docker).
# Note: this replaces the web1 and db1 containers of the local path.
test:
	@$(LAB_PYTHON) tests/check_structure.py
	@ansible-lint -q --project-dir . -c tests/ansible-lint.yml playbooks/site.yml roles/ && echo "OK: ansible-lint"
	@bash tests/ci-targets.sh
	@LAB_PYTHON="$(LAB_PYTHON)" bash tests/check_playbook.sh converge
	@LAB_PYTHON="$(LAB_PYTHON)" bash tests/check_playbook.sh idempotent
	@LAB_PYTHON="$(LAB_PYTHON)" bash tests/check_playbook.sh handlers
	@LAB_PYTHON="$(LAB_PYTHON)" bash tests/check_playbook.sh vault
	@$(MAKE) --no-print-directory clean

clean:
	rm -f inventory/ci.ini .ci_key .ci_key.pub .ci_vault_pass
