"""Configuration file for Sphinx."""
import os
import sys

sys.path.insert(0, os.path.abspath("../../src"))

project = "ska-pre-commit-hooks"
copyright = "2024, SKAO"
author = "Callan Gray <callan.gray@@icrar.org>"
release = "0.0.1"

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.intersphinx",
    "sphinx_autodoc_typehints",
]

exclude_patterns = []

html_css_files = [
    'css/custom.css',
]

html_theme = "ska_ser_sphinx_theme"
html_theme_options = {}

# autodoc_mock_imports = [
# ]

intersphinx_mapping = {'python': ('https://docs.python.org/3.10', None)}

nitpicky = True

# nitpick_ignore = [
# ]
