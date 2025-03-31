"""Package versioning tests."""

from importlib.metadata import version
from importlib.util import module_from_spec, spec_from_file_location

PACKAGE_VER = version("ska-pre-commit-hooks")


def test_doc_version():
    """Test sphinx config version matches package version."""
    spec = spec_from_file_location("conf", "docs/src/conf.py")
    assert spec
    assert spec.loader
    conf = module_from_spec(spec)
    assert conf
    spec.loader.exec_module(conf)
    assert conf.version == PACKAGE_VER
    assert conf.release == PACKAGE_VER


def test_cicd_version():
    """Test CICD version matches package version."""
    with open(".release", encoding="utf-8") as file:
        lines = file.readlines()
        assert f"release={PACKAGE_VER}\n" in lines
        assert f"tag={PACKAGE_VER}\n" in lines
