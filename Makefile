include .make/base.mk
include .make/python.mk

DOCS_SPHINXOPTS = -n -W --keep-going
PYTHON_LINE_LENGTH = 88

docs-pre-build:
	poetry config virtualenvs.create false
	poetry install --no-root --only docs

.PHONY: docs-pre-build

shell-test:
	bash tests/unit/run_shunit2.sh
