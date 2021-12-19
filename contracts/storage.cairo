# The "%lang" directive declares this code as a StarkNet contract.
%lang starknet

# The "%builtins" directive declares the builtins used by the contract.
# For example, the "range_check" builtin is used to compare values.
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.keccak import unsafe_keccak

# TraitId for storing in wizard_traits
const BODY = 0
const HEAD = 1
const PROP = 2
const RUNE = 3
const FAMILIAR = 4

@storage_var
func wizard_traits(wizard : felt, traitId : felt) -> (res : felt):
end

@storage_var
func wizard_stored(wizard : felt) -> (res : felt):
end

# affinities are stored as list by storing each affinity at a different Id for a trait
@storage_var
func traits_affinity_identity(trait : felt, affinityId : felt) -> (res : felt):
end

@storage_var
func traits_affinity_identity_len(trait : felt) -> (res : felt):
end

@storage_var
func traits_affinity_positive_len(trait : felt) -> (res : felt):
end

@storage_var
func traits_affinity_positive(trait : felt, affinityId : felt) -> (res : felt):
end

# stores the traits for a wizard, all traits need to be supplied, use 7777 if trait is not there
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

# reads wizard traits, returns 7777 if trait is ot present on wizard
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

# Store identity affinities by recursively increasing the affinityId when storing
@external
func store_trait_affinities_identity{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        trait : felt, length : felt, identity_len : felt, identity : felt*):
    # store once the length of the array
    if identity_len == 0:
        traits_affinity_identity_len.write(trait, length)
        return ()
    end

    traits_affinity_identity.write(trait, identity_len, identity[0])

    # store next affinity in next slot
    return store_trait_affinities_identity(
        trait=trait, length=length, identity_len=identity_len - 1, identity=identity + 1)
end

@view
func get_trait_affinities_identity{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(trait : felt) -> (
        list_len : felt, list : felt*):
    alloc_locals
    let (local length) = traits_affinity_identity_len.read(trait)
    let (local affinities) = alloc()

    # recursively read affinities into list
    read_trait_affinities_identity_rec(trait, length, affinities)

    return (length, affinities)
end

@external
func store_trait_affinities_positive{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        trait : felt, length : felt, positive_len : felt, positive : felt*):
    # store once the length of the array
    if positive_len == 0:
        traits_affinity_positive_len.write(trait, length)
        return ()
    end

    traits_affinity_positive.write(trait, positive_len, positive[0])

    return store_trait_affinities_positive(
        trait=trait, length=length, positive_len=positive_len - 1, positive=positive + 1)
end

@view
func get_trait_affinities_positive{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(trait : felt) -> (
        list_len : felt, list : felt*):
    alloc_locals
    let (local length) = traits_affinity_positive_len.read(trait)
    let (local affinities) = alloc()

    # recursively read affinities into list
    read_trait_affinities_positive_rec(trait, length, affinities)

    return (length, affinities)
end

# Internal recursive methods to read storage
func read_trait_affinities_identity_rec{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        trait : felt, list_len : felt, list : felt*):
    if list_len == 0:
        return ()
    end

    let (aff) = traits_affinity_identity.read(trait, list_len)
    [list] = aff

    return read_trait_affinities_identity_rec(trait, list_len - 1, list + 1)
end

func read_trait_affinities_positive_rec{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        trait : felt, list_len : felt, list : felt*):
    if list_len == 0:
        return ()
    end

    let (aff) = traits_affinity_positive.read(trait, list_len)
    [list] = aff

    return read_trait_affinities_positive_rec(trait, list_len - 1, list + 1)
end
