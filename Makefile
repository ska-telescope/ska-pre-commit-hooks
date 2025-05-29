include .make/base.mk
include .make/python.mk

DOCS_SPHINXOPTS = -n -W --keep-going
PYTHON_LINE_LENGTH = 88
BATS_TESTS := tests/unit/test_lint_branch_name.bats tests/unit/test_lint_commit_msg.bats tests/unit/test_lint_pre_push.bats

docs-pre-build:
	poetry config virtualenvs.create false
	poetry install --no-root --only docs

.PHONY: docs-pre-build

shell-test: bash-test

bash-test:
	BATS_SHELL=/bin/bash bats $(BATS_TESTS)

dash-test:
	BATS_SHELL=/bin/dash bats $(BATS_TESTS)

ksh-test:
	BATS_SHELL=/bin/ksh bats $(BATS_TESTS)

mksh-test:
	BATS_SHELL=/bin/mksh bats $(BATS_TESTS)
