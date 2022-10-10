%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256, uint256_neg

using Bool = felt;
using Address = felt;

@contract_interface
namespace Bid {
    func get_balance(address: Address) -> (balance: felt) {
    }

    func get_transfer_fact(address: Address) -> (transered: Bool) {
    }

    func get_fact_bid(address: Address) -> (bidded: Bool) {
    }

    func get_bid_amount(address: Address) -> (bid_amount: felt) {
    }

    func get_winner() -> (address: Address, bid_amount: felt) {
    }

    func deposit(address: Address, bid_amount: Uint256) {
    }

    func bid(address: Address, bid_amount: Uint256) {
    }
}

const addr1 = 1;
const addr2 = 2;

@external
func test_init_setup{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
) {
    alloc_locals;
    
    local bid_contract_address: felt;
    %{ ids.bid_contract_address = deploy_contract("./contracts/bid.cairo", []).contract_address %}
    %{print("bid_contract_address: ",ids.bid_contract_address)%}

    let (winner_address, winner_bid_amount) = Bid.get_winner(bid_contract_address);
    assert winner_address = FALSE;
    assert winner_bid_amount = FALSE;

    Bid.deposit(bid_contract_address, addr1, Uint256(1000,0));
    Bid.deposit(bid_contract_address, addr2, Uint256(10, 0));

    let (bal1) = Bid.get_balance(bid_contract_address, addr1);
    assert bal1 = 1000;
    let (bal2) = Bid.get_balance(bid_contract_address, addr2);
    assert bal2 = 10;

    Bid.bid(bid_contract_address, addr1, Uint256(1000, 0));

    let (winner_address, winner_bid_amount) = Bid.get_winner(bid_contract_address);
    assert winner_address = addr1;
    assert winner_bid_amount = 1000;

    return ();
}

@external
func test_bid_under_available_funds_fail{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
) {
    alloc_locals;
    
    local bid_contract_address: felt;
    %{ ids.bid_contract_address = deploy_contract("./contracts/bid.cairo", []).contract_address %}
    %{print("bid_contract_address: ",ids.bid_contract_address)%}

    let (winner_address, winner_bid_amount) = Bid.get_winner(bid_contract_address);
    assert winner_address = FALSE;
    assert winner_bid_amount = FALSE;

    Bid.deposit(bid_contract_address, addr1, Uint256(1000,0));
    Bid.deposit(bid_contract_address, addr2, Uint256(10, 0));

    let (bal1) = Bid.get_balance(bid_contract_address, addr1);
    assert bal1 = 1000;
    let (bal2) = Bid.get_balance(bid_contract_address, addr2);
    assert bal2 = 10;

    Bid.bid(bid_contract_address, addr1, Uint256(1000, 0));

    let (winner_address, winner_bid_amount) = Bid.get_winner(bid_contract_address);
    assert winner_address = addr1;
    assert winner_bid_amount = 1000;

    %{ expect_revert() %}
    Bid.bid(bid_contract_address, addr2, Uint256(1000, 0));

    return ();
}

@external
func test_bid_under_minimal_amount_fail{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
) {
    alloc_locals;
    
    local bid_contract_address: felt;
    %{ ids.bid_contract_address = deploy_contract("./contracts/bid.cairo", []).contract_address %}
    %{print("bid_contract_address: ",ids.bid_contract_address)%}

    let (winner_address, winner_bid_amount) = Bid.get_winner(bid_contract_address);
    assert winner_address = FALSE;
    assert winner_bid_amount = FALSE;

    Bid.deposit(bid_contract_address, addr1, Uint256(1000,0));
    Bid.deposit(bid_contract_address, addr2, Uint256(10, 0));

    let (bal1) = Bid.get_balance(bid_contract_address, addr1);
    assert bal1 = 1000;
    let (bal2) = Bid.get_balance(bid_contract_address, addr2);
    assert bal2 = 10;

    Bid.bid(bid_contract_address, addr1, Uint256(1000, 0));

    let (winner_address, winner_bid_amount) = Bid.get_winner(bid_contract_address);
    assert winner_address = addr1;
    assert winner_bid_amount = 1000;

    %{ expect_revert() %}
    Bid.bid(bid_contract_address, addr2, Uint256(10, 0));

    return ();
}

@external
func test_deposit_2_times_fail{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
) {
    alloc_locals;
    
    local bid_contract_address: felt;
    %{ ids.bid_contract_address = deploy_contract("./contracts/bid.cairo", []).contract_address %}
    %{print("bid_contract_address: ",ids.bid_contract_address)%}

    Bid.deposit(bid_contract_address, addr1, Uint256(1000,0));
    Bid.deposit(bid_contract_address, addr2, Uint256(10, 0));

    let (bal1) = Bid.get_balance(bid_contract_address, addr1);
    assert bal1 = 1000;
    let (bal2) = Bid.get_balance(bid_contract_address, addr2);
    assert bal2 = 10;

    %{ expect_revert() %}
    Bid.deposit(bid_contract_address, addr2, Uint256(10, 0));

    return ();
}

@external
func test_bid_2_times_fail{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
) {
    alloc_locals;
    
    local bid_contract_address: felt;
    %{ ids.bid_contract_address = deploy_contract("./contracts/bid.cairo", []).contract_address %}
    %{print("bid_contract_address: ",ids.bid_contract_address)%}

    Bid.deposit(bid_contract_address, addr1, Uint256(1000,0));
    Bid.deposit(bid_contract_address, addr2, Uint256(10, 0));

    let (bal1) = Bid.get_balance(bid_contract_address, addr1);
    assert bal1 = 1000;
    let (bal2) = Bid.get_balance(bid_contract_address, addr2);
    assert bal2 = 10;

    Bid.bid(bid_contract_address, addr1, Uint256(1000,0));

    let (bid1) = Bid.get_bid_amount(bid_contract_address, addr1);
    assert bal1 = 1000;

    %{ expect_revert() %}
    Bid.bid(bid_contract_address, addr1, Uint256(10, 0));

    return ();
}

@external
func test_WIN{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
) {
    alloc_locals;
    
    local bid_contract_address: felt;
    %{ ids.bid_contract_address = deploy_contract("./contracts/bid.cairo", []).contract_address %}
    %{print("bid_contract_address: ",ids.bid_contract_address)%}

    let (winner_address, winner_bid_amount) = Bid.get_winner(bid_contract_address);
    assert winner_address = FALSE;
    assert winner_bid_amount = FALSE;

    Bid.deposit(bid_contract_address, addr1, Uint256(1000,0));
    Bid.deposit(bid_contract_address, addr2, Uint256(10, 0));

    let (bal1) = Bid.get_balance(bid_contract_address, addr1);
    assert bal1 = 1000;
    let (bal2) = Bid.get_balance(bid_contract_address, addr2);
    assert bal2 = 10;

    Bid.bid(bid_contract_address, addr1, Uint256(1000, 0));

    let (winner_address, winner_bid_amount) = Bid.get_winner(bid_contract_address);
    assert winner_address = addr1;
    assert winner_bid_amount = 1000;

    let (winner_bid) = uint256_neg(Uint256(1, 0));
    Bid.bid(bid_contract_address, addr2, winner_bid);
    let (winner_address, winner_bid_amount) = Bid.get_winner(bid_contract_address);
    %{print("ids.winner_bid_amount: ",ids.winner_bid_amount)%}
    assert winner_address = addr2;


    return ();
}