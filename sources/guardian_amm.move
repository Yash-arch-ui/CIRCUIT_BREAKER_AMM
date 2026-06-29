module circuit_breaker_amm::circuit_breaker {
    use circuit_breaker_amm::oracle::PriceOracle;

    const EPRICE_VOLATILITY_LIMIT_EXCEEDED: u64 = 401;

    /// Verifies that execution spot changes do not exceed a strict 10% band variance vs reference feed
    public fun check_price_stability(spot_price: u64, oracle: &PriceOracle) {
        let ref_price = circuit_breaker_amm::oracle::get_reference_price(oracle);
        let max_allowed_deviation = ref_price / 10; 

        let deviation = if (spot_price > ref_price) {
            spot_price - ref_price
        } else {
            ref_price - spot_price
        };

        assert!(deviation <= max_allowed_deviation, EPRICE_VOLATILITY_LIMIT_EXCEEDED);
    }
}