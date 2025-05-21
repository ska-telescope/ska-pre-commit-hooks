include .make/base.mk
include .make/python.mk

DOCS_SPHINXOPTS = -n -W --keep-going
PYTHON_LINE_LENGTH = 88

docs-pre-build:
	poetry config virtualenvs.create false
	poetry install --no-root --only docs

.PHONY: docs-pre-build

bash-test:
	bash tests/unit/test_lint_branch_name.sh
	bash tests/unit/test_lint_commit_msg.sh
