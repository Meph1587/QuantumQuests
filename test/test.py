from starkware.crypto.signature.signature import (
    pedersen_hash, private_to_stark_key, get_random_private_key)
import os
import pytest


from starkware.starknet.testing.starknet import Starknet

# The path to the contract source code.
CONTRACT_FILE = os.path.join(
    os.path.dirname(__file__), "..", "contracts", "tester.cairo")


def generate_keypair():
    private_key = get_random_private_key() % 2**128
    public_key = private_to_stark_key(private_key)
    return (private_key, public_key)

# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.


@pytest.mark.asyncio
async def test_add():
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(CONTRACT_FILE)

    c = await contract.add(x=10, y=15).call()

    assert c.result.res == 25


@pytest.mark.asyncio
async def test_get_balance():
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(CONTRACT_FILE)

    (private_key, public_key) = generate_keypair()

    c = await contract.balanceOf(owner=public_key).call()

    assert c.result.res == 0


@pytest.mark.asyncio
async def test_increment_balance():
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(CONTRACT_FILE)

    (private_key, public_key) = generate_keypair()

    # Invoke increment() twice.
    await contract.increment(owner=public_key, amount=15).invoke()

    c = await contract.balanceOf(owner=public_key).call()

    assert c.result.res == 15

    await contract.increment(owner=public_key, amount=15).invoke()

    c = await contract.balanceOf(owner=public_key).call()

    assert c.result.res == 30
