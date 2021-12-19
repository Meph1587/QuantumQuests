from starkware.crypto.signature.signature import (
    pedersen_hash, private_to_stark_key, get_random_private_key)
import os
import pytest


from starkware.starknet.testing.starknet import Starknet

# The path to the contract source code.
CONTRACT_FILE = os.path.join(
    os.path.dirname(__file__), "..", "contracts", "storage.cairo")


def generate_keypair():
    private_key = get_random_private_key() % 2**128
    public_key = private_to_stark_key(private_key)
    return (private_key, public_key)

# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.


@pytest.mark.asyncio
async def test_store_traits():
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(CONTRACT_FILE)

    r = await contract.has_traits_stored(777).call()

    assert r.result.res == 0

    r = await contract.get_wizard_traits(777).call()

    assert r.result == (0,0,0,0,0)

    # Store Wizard Traits
    await contract.store_wizard_traits(wizard=777,body=1,head=2,prop=3,rune=4,familiar=5).invoke()

    r = await contract.get_wizard_traits(777).call()

    assert r.result == (1,2,3,4,5)

    r = await contract.has_traits_stored(777).call()

    assert r.result.res == 1

    # Store trait affinities
    await contract.store_trait_affinities_identity(trait=1, length=8, identity=[1,2,3,4,5,6,7,8]).invoke()

    r = await contract.get_trait_affinities_identity(1).call()

    assert r.result.list == [1,2,3,4,5,6,7,8]


    await contract.store_trait_affinities_positive(trait=1, length=8, positive=[8,7,6,5,4,3,2,1]).invoke()

    r = await contract.get_trait_affinities_positive(1).call()

    assert r.result.list == [8,7,6,5,4,3,2,1]
