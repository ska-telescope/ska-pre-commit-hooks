# ska-pre-commit-hooks

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![Documentation Status](https://readthedocs.org/projects/ska-telescope-ska-pre-commit-hooks/badge/?version=latest)](https://developer.skao.int/projects/ska-pre-commit-hooks/en/latest/?badge=latest)

SKA [pre-commit](https://pre-commit.com/) hooks for git developer workflows.

pre-commit is a configurable Python tool useful for identifying simple issues when committing changes and before submission to code review. This repository provides a central location for pre-commit hook definitions for developers to choose from in ska Python projects. pre-commit works for all available git hooks (not just limited to pre-commit):
* commit-msg
* post-checkout
* post-commit
* post-merge
* post-rewrite
* pre-commit
* pre-merge-commit
* pre-push
* pre-rebase
* prepare-commit-msg

For further documentation check the repository `docs` folder and the [SKA development portal](https://developer.skatelescope.org/projects/ska-pre-commit-hooks/en/latest/index.html "SKA Developer Portal: ska-pre-commit-hooks documentation")

## Repository Setup Instructions

To add hooks support to an SKA Python repository:

1. Checkout the Python repository on a local machine.

2. Add the following to a `.pre-commit-config.yaml` file in the root project directory:

```yaml
repos:
- repo: https://gitlab.com/ska-telescope/templates/ska-pre-commit-hooks
  rev: 6618b44aa664df4826bdffcbd48c320e5ed7c4dc
  hooks:
  # python lint
  - id: isort
    args: ['--check-only']
  - id: black
    args: ['--check']
  - id: flake8
  - id: pylint
  # jira ticket
  - id: branch ticket id
  - id: commit msg ticket id
default_install_hook_types:
- pre-commit
- commit-msg
```

2. Install or add `pre-commit` as a package dependency:

```bash
poetry add pre-commit
poetry install
```

3. Test selected pre-commit passes for all files:

```bash
pre-commit run --all-files
```

4. Add the pre-commit badge to the README [![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)

5. Commit and submit the merge request for developers to opt into git hooks.

## Opt-in to pre-commit hooks in development

Install hooks for a cloned repo on developer environments wishing to use pre-commit hooks:

### Install hooks

```bash
pre-commit install
```

`git commit` will now automatically run hooks for staged changes and commit messages.

### Example

```sh
>>> git commit -m "ABC-123 commit message"
poetry isort.............................................................Passed
poetry black.............................................................Passed
poetry flake8............................................................Passed
poetry pylint............................................................Passed
branch ticket ID.........................................................Passed
commit message ticket ID.................................................Passed
[abc-123 88dfe4c] ABC-123 commit message
 1 file changed, 1 insertion(+), 1 deletion(-)
```

For a detailed description of pre-commit use cases see https://pre-commit.com

## Opt-out of pre-commit hooks in development

Commit hooks can be explicity skipped by using the `--no-verify` option.

### Example

```sh
>>> git commit -m "unchecked commit" --no-verify
[abc-123 88dfe4c] unchecked commit
 1 file changed, 1 insertion(+), 1 deletion(-)
```
### Uninstall hooks

To opt-out from git hook integration, pre-commit hooks can be uninstalled for a cloned repo:

```bash
pre-commit uninstall
```
