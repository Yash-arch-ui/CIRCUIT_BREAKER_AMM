module circuit_breaker_amm::pool {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};

    public struct LPCoin has drop {}

    public struct Pool<phantom X, phantom Y> has key, store {
        id: UID,
        balance_x: Balance<X>,
        balance_y: Balance<Y>,
        lp_supply: balance::Supply<LPCoin>,
    }

    public entry fun create_pool<X, Y>(ctx: &mut TxContext) {
        let pool = Pool<X, Y> {
            id: object::new(ctx),
            balance_x: balance::zero(),
            balance_y: balance::zero(),
            lp_supply: balance::create_supply(LPCoin {}),
        };
        sui::transfer::share_object(pool);
    }

    public entry fun add_liquidity<X, Y>(
        pool: &mut Pool<X, Y>,
        coin_x: Coin<X>,
        coin_y: Coin<Y>,
        ctx: &mut TxContext
    ) {
        let amt_x = coin::value(&coin_x);
        let amt_y = coin::value(&coin_y);

        balance::join(&mut pool.balance_x, coin::into_balance(coin_x));
        balance::join(&mut pool.balance_y, coin::into_balance(coin_y));

        let lp_to_mint = amt_x + amt_y; 
        let lp_balance = balance::increase_supply(&mut pool.lp_supply, lp_to_mint);
        
        sui::transfer::public_transfer(coin::from_balance(lp_balance, ctx), ctx.sender());
    }

    public entry fun remove_liquidity<X, Y>(
        pool: &mut Pool<X, Y>,
        lp_coin: Coin<LPCoin>,
        ctx: &mut TxContext
    ) {
        let lp_amt = coin::value(&lp_coin);
        balance::decrease_supply(&mut pool.lp_supply, coin::into_balance(lp_coin));

        let amt_x = lp_amt / 2;
        let amt_y = lp_amt / 2;

        let coin_x = coin::from_balance(balance::split(&mut pool.balance_x, amt_x), ctx);
        let coin_y = coin::from_balance(balance::split(&mut pool.balance_y, amt_y), ctx);

        sui::transfer::public_transfer(coin_x, ctx.sender());
        sui::transfer::public_transfer(coin_y, ctx.sender());
    }

    /* internal package layer access hooks for swap module routing */
    public fun borrow_balances<X, Y>(pool: &Pool<X, Y>): (u64, u64) {
        (balance::value(&pool.balance_x), balance::value(&pool.balance_y))
    }

    public(package) fun deposit_x<X, Y>(pool: &mut Pool<X, Y>, bal: Balance<X>) {
        balance::join(&mut pool.balance_x, bal);
    }

    public(package) fun deposit_y<X, Y>(pool: &mut Pool<X, Y>, bal: Balance<Y>) {
        balance::join(&mut pool.balance_y, bal);
    }

    public(package) fun withdraw_x<X, Y>(pool: &mut Pool<X, Y>, amt: u64): Balance<X> {
        balance::split(&mut pool.balance_x, amt)
    }

    public(package) fun withdraw_y<X, Y>(pool: &mut Pool<X, Y>, amt: u64): Balance<Y> {
        balance::split(&mut pool.balance_y, amt)
    }
}