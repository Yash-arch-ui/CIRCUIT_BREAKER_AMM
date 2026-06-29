module circuit_breaker_amm::swap {
    use sui::coin::{Self, Coin};
    use circuit_breaker_amm::pool::{Self, Pool};
    use circuit_breaker_amm::oracle::PriceOracle;
    use circuit_breaker_amm::circuit_breaker;

    const ESLIPPAGE_LIMIT_HIT: u64 = 501;

    public entry fun swap_x_to_y<X, Y>(
        pool: &mut Pool<X, Y>,
        coin_in: Coin<X>,
        min_amount_out: u64,
        oracle: &PriceOracle,
        ctx: &mut TxContext
    ) {
        let amount_in = coin::value(&coin_in);
        let (res_x, res_y) = pool::borrow_balances(pool);

        let new_x = res_x + amount_in;
        let amount_out = (res_y * amount_in) / new_x;
        assert!(amount_out >= min_amount_out, ESLIPPAGE_LIMIT_HIT);

        let spot_price = (amount_in * 1_000_000_000) / amount_out;
        circuit_breaker::check_price_stability(spot_price, oracle);

        pool::deposit_x(pool, coin::into_balance(coin_in));
        let bal_out = pool::withdraw_y(pool, amount_out);
        
        sui::transfer::public_transfer(coin::from_balance(bal_out, ctx), ctx.sender());
    }

    public entry fun swap_y_to_x<X, Y>(
        pool: &mut Pool<X, Y>,
        coin_in: Coin<Y>,
        min_amount_out: u64,
        oracle: &PriceOracle,
        ctx: &mut TxContext
    ) {
        let amount_in = coin::value(&coin_in);
        let (res_x, res_y) = pool::borrow_balances(pool);

        let new_y = res_y + amount_in;
        let amount_out = (res_x * amount_in) / new_y;
        assert!(amount_out >= min_amount_out, ESLIPPAGE_LIMIT_HIT);

        let spot_price = (amount_in * 1_000_000_000) / amount_out;
        circuit_breaker::check_price_stability(spot_price, oracle);

        pool::deposit_y(pool, coin::into_balance(coin_in));
        let bal_out = pool::withdraw_x(pool, amount_out);
        
        sui::transfer::public_transfer(coin::from_balance(bal_out, ctx), ctx.sender());
    }
}