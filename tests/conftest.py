import pytest

from claimsgen import claims, masterdata, policies


@pytest.fixture(scope="session")
def built():
    master = masterdata.generate(1.0)
    pol = policies.generate(master, 1.0)
    tables, planted = claims.generate(master, pol, 1.0)
    return {**master, **pol, **tables}, planted


@pytest.fixture(scope="session")
def data(built):
    return built[0]


@pytest.fixture(scope="session")
def planted(built):
    return built[1]
