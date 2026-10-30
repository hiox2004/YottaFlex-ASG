import pytest

from claimsgen import claims, engine, masterdata, policies


@pytest.fixture(scope="session")
def built():
    master = masterdata.generate(1.0)
    pol = policies.generate(master, 1.0)
    tables, planted = claims.generate(master, pol, 1.0)
    base = {**master, **pol, **tables}
    return {**base, **engine.run(base)}, planted


@pytest.fixture(scope="session")
def data(built):
    return built[0]


@pytest.fixture(scope="session")
def planted(built):
    return built[1]
