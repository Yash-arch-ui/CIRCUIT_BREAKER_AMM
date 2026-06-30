module circuit_breaker_amm::token_y {
    use sui::coin::{Self, TreasuryCap};
    use sui::tx_context::TxContext; // ADDED: Explicit TxContext import
    use std::option;

    /// The One-Time Witness (OTW) for TOKEN_Y
    public struct TOKEN_Y has drop {}

    fun init(witness: TOKEN_Y, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency(
            witness,
            9, 
            b"TKY", 
            b"Token Y", 
            b"Circuit Breaker AMM Asset Y", 
            option::none(), 
            ctx
        );
        sui::transfer::public_freeze_object(metadata);
        
        sui::transfer::public_transfer(treasury_cap, ctx.sender());
    }

    public entry fun mint(
        cap: &mut TreasuryCap<TOKEN_Y>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext
    ) {
        let coin = coin::mint(cap, amount, ctx);
        sui::transfer::public_transfer(coin, recipient);
    }
}