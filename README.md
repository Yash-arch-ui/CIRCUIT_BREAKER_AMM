Circuit Breaker AMM
A production-ready Automated Market Maker (AMM) on Sui Move featuring an on-chain Circuit Breaker mechanism that protects liquidity providers and traders from extreme price manipulation, oracle attacks, flash-loan exploits, and sudden market shocks.
Unlike traditional AMMs that blindly execute swaps, Circuit Breaker AMM continuously monitors price deviations and automatically pauses trading when abnormal conditions are detected.

🚀 Problem
Most AMMs follow the constant product formula:
x×y=kx \times y = kx×y=k
While simple and efficient, they have a major weakness:


Flash-loan attacks can manipulate prices.
Thin liquidity pools can be drained rapidly.
Extreme volatility causes massive slippage.
LPs suffer impermanent loss during abnormal events.
Retail traders receive poor execution during price shocks.
Existing AMMs typically continue operating even during obvious manipulation attempts.

💡 Solution
Circuit Breaker AMM introduces an additional security layer on top of the traditional AMM model.
The protocol:
Tracks a TWAP (Time Weighted Average Price).
Computes the current spot price after swaps.
Measures deviation between spot and TWAP.
Automatically triggers a circuit breaker when deviation exceeds a predefined threshold.
Pauses trading for a cooldown period.
Resumes normal operation once markets stabilize.
This prevents attackers from extracting value through rapid price manipulation.

🔥 Core Features
✅ Constant Product AMM
Uses:
x×y=kx \times y = kx×y=k
for swap execution.
Supports:


Add Liquidity
Remove Liquidity
Swap X → Y
Swap Y → X



✅ Slippage Protection
Users specify:
min_amount_out
Transaction automatically reverts if output falls below expectations.
Protects traders from:


Front-running
MEV
Sudden liquidity changes



✅ Circuit Breaker
Every swap updates:
Spot Price
TWAP
Deviation %


If:
Deviation > Threshold
then:
Pool State = COOLDOWN
and swaps are disabled.

✅ Automatic Recovery
After cooldown:
STATE_COOLDOWN    ↓STATE_NORMAL
Pool resumes operation automatically.

✅ Fully On-Chain
No off-chain bots.
No external keepers.
No centralized intervention.
All protection logic runs entirely on-chain.

🏗 Architecture
                 +----------------+                 |     Trader     |                 +--------+-------+                          |                          |                          ▼              +----------------------+              |     Swap Request     |              +----------+-----------+                         |                         ▼          +-----------------------------+          | Constant Product Execution |          +-------------+---------------+                        |                        ▼          +-----------------------------+          | Update Spot Price          |          +-------------+---------------+                        |                        ▼          +-----------------------------+          | Update TWAP                |          +-------------+---------------+                        |                        ▼          +-----------------------------+          | Deviation Calculation      |          +-------------+---------------+                        |             deviation > threshold ?                        |             +----------+---------+             |                    |            YES                  NO             |                    |             ▼                    ▼ +-------------------+    Continue Trading | Trigger Breaker   | +---------+---------+           |           ▼ +-------------------+ | Pool Cooldown     | +-------------------+

📦 Smart Contract Features
Pool Creation
create_pool<X,Y>()
Creates a shared liquidity pool.

Liquidity Provision
add_liquidity()
LP tokens are minted proportionally.

Liquidity Withdrawal
remove_liquidity()
Burn LP shares and withdraw assets.

Swaps
swap_x_for_y()swap_y_for_x()
Uses fee-adjusted constant product formula.

TWAP Updates
update_twap()
Maintains long-term price reference.

Circuit Breaker Trigger
trigger_circuit_breaker()
Pauses pool when deviation becomes dangerous.

📊 Example
Initial Pool:
1000 SUI1000 USDC
Price:
1 SUI = 1 USDC
Attacker executes massive trade:
500 SUI -> USDC
Spot price becomes:
1.55 USDC
TWAP remains:
1.00 USDC
Deviation:
55%
Threshold:
10%
Result:
Circuit Breaker ActivatedPool Paused
Attack impact contained.

🛡 Security Benefits
Flash Loan Resistance
Large manipulations trigger protection instantly.

Oracle Manipulation Protection
Spot prices are validated against historical averages.

LP Protection
Reduces losses caused by abnormal market activity.

Trader Protection
Prevents execution during unstable conditions.

Market Stability
Introduces controlled trading halts similar to traditional financial markets.

⚙️ Configuration
THRESHOLD_BPS = 1000
10% deviation threshold.

COOLDOWN_MS = 300000
5 minute cooldown period.

FEE_BPS = 30
0.30% swap fee.
