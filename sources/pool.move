module circuit_breaker_amm::pool {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::clock::{Self, Clock};

    const EZeroAmount: u64 = 0;
    const EPoolPaused: u64 = 1;
    const ESlippageExceeded: u64 = 2;
    const EInsufficientLiquidity: u64 = 3;

    const THRESHOLD_BPS: u128 = 1000;
    const COOLDOWN_MS: u64 = 300_000;
    const STATE_NORMAL: u8 = 0;
    const STATE_COOLDOWN: u8 = 1;
    const BPS_DENOMINATOR: u128 = 10000;
    const FEE_BPS:u128 =30;// 0.30%

    public struct Pool<phantom X, phantom Y> has key {
        id: UID,
        reserve_x: Balance<X>,
        reserve_y: Balance<Y>,
        lp_supply: u64,
        twap_price: u128,
        state: u8,
        paused_until: u64,
    }

    public struct PoolCreated has copy, drop {
        pool_id: address,
    }

    public struct LiquidityAdded has copy, drop {
        pool_id: address,
        amount_x: u64,
        amount_y: u64,
        lp_minted: u64,
    }

    public struct LiquidityRemoved has copy, drop {
        pool_id: address,
        amount_x: u64,
        amount_y: u64,
        lp_burned: u64,
    }
    public struct SwapExecuted has copy, drop{
        pool_id: address,
        amount_in: u64,
        amount_out: u64,
    }
    public struct TWAPUpdated has copy, drop{
        pool_id: address, 
        old_twap: u128,
        new_twap: u128,
    }

    public struct CircuitBreakerTripped has copy, drop {
        pool_id: address,
        spot_price: u128,
        twap_price: u128,
        deviation_bps: u128,
        paused_until: u64,
    }

    public fun create_pool<X, Y>(ctx: &mut TxContext) {
        let pool = Pool<X, Y> {
            id: object::new(ctx),
            reserve_x: balance::zero<X>(),
            reserve_y: balance::zero<Y>(),
            lp_supply: 0,
            twap_price: 0,
            state: STATE_NORMAL,
            paused_until: 0,
        };
        let pool_id = object::uid_to_address(&pool.id);
        sui::event::emit(
    PoolCreated {
        pool_id
    }
);
        transfer::share_object(pool);
        
    }

    public fun add_liquidity<X, Y>(
        pool: &mut Pool<X, Y>,
        coin_x: Coin<X>,
        coin_y: Coin<Y>,
        clock: &Clock,
        ctx: &mut TxContext
    ): u64 {
        maybe_unpause(pool, clock);
        assert!(pool.state == STATE_NORMAL, EPoolPaused);
        let amount_x = coin::value(&coin_x);
        let amount_y = coin::value(&coin_y);
        assert!(amount_x > 0, EZeroAmount);
        assert!(amount_y > 0, EZeroAmount);
        if (pool.twap_price == 0) {
         pool.twap_price =
        ((amount_y as u128) * 1_000_000_000)
        / (amount_x as u128);
}
        let lp_to_mint = if (pool.lp_supply == 0) {
            sqrt_u128((amount_x as u128) * (amount_y as u128))
        } else {
            let reserve_x = balance::value(&pool.reserve_x);
            let reserve_y = balance::value(&pool.reserve_y);
            let lp_from_x = (amount_x as u128) * (pool.lp_supply as u128) / (reserve_x as u128);
            let lp_from_y = (amount_y as u128) * (pool.lp_supply as u128) / (reserve_y as u128);
            let lp = if (lp_from_x < lp_from_y) { lp_from_x } else { lp_from_y };
            (lp as u64)
        };

        assert!(lp_to_mint > 0, EInsufficientLiquidity);

        balance::join(&mut pool.reserve_x, coin::into_balance(coin_x));
        balance::join(&mut pool.reserve_y, coin::into_balance(coin_y));
        pool.lp_supply = pool.lp_supply + lp_to_mint;
           update_twap(pool);
        sui::event::emit(LiquidityAdded {
            pool_id: object::uid_to_address(&pool.id),
            amount_x,
            amount_y,
            lp_minted: lp_to_mint,
        });

        lp_to_mint
    }

    public fun remove_liquidity<X, Y>(
        pool: &mut Pool<X, Y>,
        lp_amount: u64,
        clock: &Clock,
        ctx: &mut TxContext
    ): (Coin<X>, Coin<Y>) {
        maybe_unpause(pool, clock);
        assert!(lp_amount > 0, EZeroAmount);
        assert!(pool.lp_supply > 0, EInsufficientLiquidity);
        assert!(lp_amount <= pool.lp_supply,EInsufficientLiquidity);

        let reserve_x = balance::value(&pool.reserve_x);
        let reserve_y = balance::value(&pool.reserve_y);

        let amount_x = (lp_amount as u128) * (reserve_x as u128) / (pool.lp_supply as u128);
        let amount_y = (lp_amount as u128) * (reserve_y as u128) / (pool.lp_supply as u128);

        assert!(amount_x > 0 && amount_y > 0, EInsufficientLiquidity);

        pool.lp_supply = pool.lp_supply - lp_amount;

        let coin_x = coin::from_balance(
            balance::split(&mut pool.reserve_x, (amount_x as u64)),
            ctx
        );
        let coin_y = coin::from_balance(
            balance::split(&mut pool.reserve_y, (amount_y as u64)),
            ctx
        );
            update_twap(pool);


        sui::event::emit(LiquidityRemoved {
            pool_id: object::uid_to_address(&pool.id),
            amount_x: (amount_x as u64),
            amount_y: (amount_y as u64),
            lp_burned: lp_amount,
        });

        (coin_x, coin_y)
    }

    public fun swap_x_for_y<X, Y>(
    pool: &mut Pool<X, Y>,
    coin_x: Coin<X>,
    min_amount_out: u64,
    clock: &Clock,
    ctx: &mut TxContext
): Coin<Y> {
    maybe_unpause(pool,clock);
    assert!(pool.state == STATE_NORMAL, EPoolPaused);

    let reserve_x = balance::value(&pool.reserve_x);
    let reserve_y = balance::value(&pool.reserve_y);
    let spot = spot_price(pool);
    let deviation = deviation_bps(spot, pool.twap_price);
    if(deviation > THRESHOLD_BPS){
        trigger_circuit_breaker(pool, clock);
        abort EPoolPaused
    };
    update_twap(pool);
    let amount_in = coin::value(&coin_x);
    assert!(amount_in > 0, EZeroAmount);
    let amount_out =
        get_amount_out(
            amount_in,
            reserve_x,
            reserve_y
        );
    assert!(
    amount_out < reserve_y,
    EInsufficientLiquidity
);
    assert!(  amount_out >= min_amount_out, ESlippageExceeded );

    balance::join(
        &mut pool.reserve_x,
        coin::into_balance(coin_x)
    );

    let coin_y = coin::from_balance(
        balance::split(
            &mut pool.reserve_y,
            amount_out
        ),
        ctx
    );

    sui::event::emit(SwapExecuted {
        pool_id: object::uid_to_address(&pool.id),
        amount_in,
        amount_out,
    });

    coin_y
}

   public fun swap_y_for_x<X, Y>(
    pool: &mut Pool<X, Y>,
    coin_y: Coin<Y>,
    min_amount_out: u64,
    clock: &Clock,
    ctx: &mut TxContext
): Coin<X> {
    maybe_unpause(pool, clock);

    assert!(pool.state == STATE_NORMAL, EPoolPaused);

    let reserve_x = balance::value(&pool.reserve_x);
    let reserve_y = balance::value(&pool.reserve_y);
    let spot = spot_price(pool);
    let deviation = deviation_bps(spot, pool.twap_price);
    if(deviation > THRESHOLD_BPS){
        trigger_circuit_breaker(pool, clock);
        abort EPoolPaused
    };
        update_twap(pool);
    let amount_in = coin::value(&coin_y);
    assert!(amount_in > 0, EZeroAmount);
    let amount_out =
        get_amount_out(
            amount_in,
            reserve_y,
            reserve_x
        );
     assert!(
    amount_out < reserve_x,
    EInsufficientLiquidity
);
    assert!(
        amount_out >= min_amount_out,
        ESlippageExceeded
    );

    balance::join(
        &mut pool.reserve_y,
        coin::into_balance(coin_y)
    );

    let coin_x = coin::from_balance(
        balance::split(
            &mut pool.reserve_x,
            amount_out
        ),
        ctx
    );

    sui::event::emit(SwapExecuted {
        pool_id: object::uid_to_address(&pool.id),
        amount_in,
        amount_out,
    });

    coin_x
}

    public fun reserve_x<X, Y>(pool: &Pool<X, Y>): u64 {
        balance::value(&pool.reserve_x)
    }

    public fun reserve_y<X, Y>(pool: &Pool<X, Y>): u64 {
        balance::value(&pool.reserve_y)
    }

    public fun lp_supply<X, Y>(pool: &Pool<X, Y>): u64 {
        pool.lp_supply
    }

    public fun twap_price<X, Y>(pool: &Pool<X, Y>): u128 {
        pool.twap_price
    }

    public fun state<X, Y>(pool: &Pool<X, Y>): u8 {
        pool.state
    }

    public fun paused_until<X, Y>(pool: &Pool<X, Y>): u64 {
        pool.paused_until
    }

    public fun is_paused<X, Y>(pool: &Pool<X, Y>, clock: &Clock): bool {
        pool.state == STATE_COOLDOWN && clock::timestamp_ms(clock) < pool.paused_until
    }

    public fun state_normal(): u8 { STATE_NORMAL }
    public fun state_cooldown(): u8 { STATE_COOLDOWN }
    public fun threshold_bps(): u128 { THRESHOLD_BPS }
    public fun cooldown_ms(): u64 { COOLDOWN_MS }
    public fun bps_denominator(): u128 { BPS_DENOMINATOR }

    fun update_twap<X,Y>(pool: &mut Pool<X, Y>){
        let old=pool.twap_price;
        let spot = spot_price(pool);
        if(old == 0){
            pool.twap_price = spot;
        }
        else{
            pool.twap_price= (old*9 + spot)/10;
        }
      sui::event::emit(
        TWAPUpdated{
            pool_id:
                object::uid_to_address(&pool.id),
            old_twap: old,
            new_twap: pool.twap_price,
        }
    );

    }
    fun trigger_circuit_breaker<X,Y>(
        pool: &mut Pool<X,Y>,
        clock: &Clock
    ){
        let spot = spot_price(pool);
        pool.state = STATE_COOLDOWN;
        pool.paused_until= clock::timestamp_ms(clock) + COOLDOWN_MS;
        sui::event::emit(CircuitBreakerTripped{
            pool_id: object::uid_to_address(&pool.id),
            spot_price: spot,
            twap_price: pool.twap_price,
            deviation_bps: deviation_bps(spot, pool.twap_price),
            paused_until: pool.paused_until,
        });


    }
    fun maybe_unpause<X,Y>(
      pool: &mut Pool<X,Y>,
    clock: &Clock
){
    if (
        pool.state == STATE_COOLDOWN &&
        clock::timestamp_ms(clock) >= pool.paused_until
    ) {
        pool.state = STATE_NORMAL;

        // RESET TWAP
        pool.twap_price = spot_price(pool);
    };
    sui::event::emit(
    TWAPUpdated {
        pool_id: object::uid_to_address(&pool.id),
        old_twap: old_twap,
        new_twap: pool.twap_price,
    }
);
        }
    
    fun spot_price<X, Y>(
    pool: &Pool<X, Y>
): u128 {
    let reserve_x = balance::value(&pool.reserve_x);
    let reserve_y = balance::value(&pool.reserve_y);

    if (reserve_x == 0 || reserve_y == 0) {
        0
    } else {
        ((reserve_y as u128) * 1_000_000_000)
            / (reserve_x as u128)
    }
}
   fun abs_diff(  a: u128, b: u128): u128 {
    if (a > b) {
        a - b
    } else {
        b - a
    }
}

    fun deviation_bps( spot: u128, twap: u128): u128{
        if(twap ==0){
            return 0;
        };

        abs_diff(spot, twap) * BPS_DENOMINATOR/twap
    }
       
    fun sqrt(x: u64): u64 {
        if (x == 0) return 0;
        let mut result = x;
        let mut y = (x + 1) / 2;
        while (y < result) {
            result = y;
            y = (y + x / y) / 2;
        };
        result
    }
    fun get_amount_out(
        amount_in: u64,
        reserve_in: u64,
        reserve_out: u64
    ): u64{
        let amount_in_with_fee= (amount_in as u128)*(10000 - FEE_BPS);

        let numerator = amount_in_with_fee * (reserve_out as u128) ;
        let denominator = (reserve_in as u128) * 10000 + amount_in_with_fee ;
        (numerator/denominator) as u64
        /*
         amountOut = (amountIn*997*reserveOut)/(reserveIn*1000+997*amountIn)
         no semicolon for returning values in move !
        */
    }
    fun sqrt_u128(x: u128): u64 {
    if (x == 0) return 0;

    let mut z = x;
    let mut y = (x + 1) / 2;

    while (y < z) {
        z = y;
        y = (x / y + y) / 2;
    };

    z as u64
}
}