module circuit_breaker_amm::token_x {
    use sui::coin::{Self, TreasuryCap};
    use sui::tx_context::TxContext; // ADDED: Explicit TxContext import
    use std::option;
    public struct TOKEN_X has drop {}

    fun init(witness: TOKEN_X, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency(
            witness,
            9, 
            b"TKX", 
            b"Token X", 
            b"Circuit Breaker AMM Asset X", 
            option::none(), 
            ctx
        );
        sui::transfer::public_freeze_object(metadata);
        sui::transfer::public_transfer(treasury_cap, ctx.sender());
    }

    public entry fun mint(
        cap: &mut TreasuryCap<TOKEN_X>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext
    ) {
        let coin = coin::mint(cap, amount, ctx);
        sui::transfer::public_transfer(coin, recipient);
    }
}