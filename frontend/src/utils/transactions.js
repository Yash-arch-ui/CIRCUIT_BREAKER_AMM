import { Transaction } from '@mysten/sui/transactions';
import { PACKAGE_ID, POOL_ID, COIN_X_TYPE, COIN_Y_TYPE } from './constants';

export function buildSwapTx({ coinObjectId, amountIn, minAmountOut, isXtoY }) {
  const tx = new Transaction();
  
  const [splitCoin] = tx.splitCoins(tx.object(coinObjectId), [tx.pure.u64(amountIn)]);
  
  tx.moveCall({
    target: `${PACKAGE_ID}::pool::swap`, 
    typeArguments: isXtoY
      ? [COIN_X_TYPE, COIN_Y_TYPE]
      : [COIN_Y_TYPE, COIN_X_TYPE],
    arguments: [
      tx.object(POOL_ID),
      splitCoin,
      tx.pure.u64(minAmountOut),
      tx.object('0x6'), 
    ],
  });
  
  return tx;
} 

export function buildAddLiquidityTx({ coinXObjectId, coinYObjectId, amountX, amountY }) {
  const tx = new Transaction();
  
  // Explicitly wrap liquidity amounts with tx.pure.u64
  const [splitX] = tx.splitCoins(tx.object(coinXObjectId), [tx.pure.u64(amountX)]);
  const [splitY] = tx.splitCoins(tx.object(coinYObjectId), [tx.pure.u64(amountY)]);

  tx.moveCall({
    target: `${PACKAGE_ID}::pool::add_liquidity`, 
    typeArguments: [COIN_X_TYPE, COIN_Y_TYPE],
    arguments: [
      tx.object(POOL_ID), 
      splitX, 
      splitY
    ],
  });

  return tx;
}
export function buildRemoveLiquidityTx({ lpCoinObjectId, lpAmount }) {
  const tx = new Transaction();
  const [splitLP] = tx.splitCoins(tx.object(lpCoinObjectId), [tx.pure.u64(lpAmount)]);

  tx.moveCall({
    target: `${PACKAGE_ID}::pool::remove_liquidity`,
    typeArguments: [COIN_X_TYPE, COIN_Y_TYPE],
    arguments: [tx.object(POOL_ID), splitLP],
  });
  return tx;
}