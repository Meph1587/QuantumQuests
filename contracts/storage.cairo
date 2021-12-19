# [StarkNet](https://starkware.co/product/starknet/) is a permissionless decentralized ZK-Rollup operating
# as an L2 network over Ethereum, where any dApp can achieve
# unlimited scale for its computation, without compromising
# Ethereum's composability and security.
#
# This is a simple StarkNet contract.
# Note that you won't be able to use the playground to compile and run it,
# but you can deploy it on the [StarkNet Planets Alpha network](https://medium.com/starkware/starknet-planets-alpha-on-ropsten-e7494929cb95)!
#
# 1. Click on "Deploy" to deploy the contract.
#    For more information on how to write Cairo contracts see the
#    ["Hello StarkNet" tutorial](https://cairo-lang.org/docs/hello_starknet).
# 2. Click on the contract address in the output pane to open
#    [Voyager](https://voyager.online/) - the StarkNet block explorer.
# 3. Wait for the page to load the information
#    (it may take a few minutes until a block is created).
# 4. In the "STATE" tab, you can call the "add()" transaction.

# The "%lang" directive declares this code as a StarkNet contract.
%lang starknet

# The "%builtins" directive declares the builtins used by the contract.
# For example, the "range_check" builtin is used to compare values.
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.keccak import unsafe_keccak

# Positions in Traits Storage Var
const BODY = 0
const HEAD = 1
const PROP = 2
const RUNE = 3
const FAMILIAR = 4

@storage_var
func wizard_stored(wizard : felt) -> (res : felt):
end

@storage_var
func wizard_traits(wizard : felt, traitId : felt) -> (res : felt):
end

@external
func store_wizard_traits{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        wizard : felt, body : felt, head : felt, prop : felt, rune : felt, familiar : felt):
    wizard_traits.write(wizard, BODY, body)
    wizard_traits.write(wizard, HEAD, head)
    wizard_traits.write(wizard, PROP, prop)
    wizard_traits.write(wizard, RUNE, rune)
    wizard_traits.write(wizard, FAMILIAR, familiar)

    wizard_stored.write(wizard, 1)

    return ()
end

@view
func get_wizard_traits{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        wizard : felt) -> (body : felt, head : felt, prop : felt, rune : felt, familiar : felt):
    let (b) = wizard_traits.read(wizard, BODY)
    let (h) = wizard_traits.read(wizard, HEAD)
    let (p) = wizard_traits.read(wizard, PROP)
    let (r) = wizard_traits.read(wizard, RUNE)
    let (f) = wizard_traits.read(wizard, FAMILIAR)
    return (b, h, p, r, f)
end

@view
func has_traits_stored{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        wizard : felt) -> (res : felt):
    let (r) = wizard_stored.read(wizard)
    return (r)
end
