"""Configuration file for Sphinx."""
import os
import sys

sys.path.insert(0, os.path.abspath("../../src"))

# -- Project information -----------------------------------------------------
project = "ska-pre-commit-hooks"
copyright = "2024, SKAO"
author = "Callan Gray <callan.gray@icrar.org>"


# The version info for the project you're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.
#
# The short X.Y.Z version.
version = "0.2.0"
# The full version, including alpha/beta/rc pre-release tags.
release = "0.2.0"

# -- General configuration ------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
#
# needs_sphinx = '1.0'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.intersphinx",
    "sphinx_autodoc_typehints",
]

exclude_patterns = []

# -- Options for HTML output ----------------------------------------------

html_css_files = [
    "css/custom.css",
]

html_theme = "ska_ser_sphinx_theme"
html_theme_options = {}

autodoc_mock_imports = []


# -- Extension configuration -------------------------------------------------

# Example configuration for intersphinx: refer to the Python standard library.
intersphinx_mapping = {"python": ("https://docs.python.org/3.10", None)}
