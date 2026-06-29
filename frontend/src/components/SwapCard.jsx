import { useState } from 'react';
import { useCurrentAccount } from '@mysten/dapp-kit';
import { usePool } from '../hooks/usePool';
import { useSwap } from '../hooks/useSwap';

export default function SwapCard() {
  const account = useCurrentAccount();
  const { data: pool } = usePool();
  const { swap, isPending } = useSwap();
  const [amountIn, setAmountIn] = useState('');

  const handleSwap = () => {
    if (!account || !amountIn || !pool) return;

    const amountInMist = BigInt(Math.floor(Number(amountIn) * 1e9));
    const minOut = (amountInMist * pool.reserveY / pool.reserveX) * 99n / 100n;

    swap({
      coinObjectId: 'YOUR_COIN_OBJECT_ID', // fetch from wallet
      amountIn: amountInMist,
      minAmountOut: minOut,
      isXtoY: true,
    });
  };

  const isPaused = pool?.paused;

  return (
    <div className="p-6 bg-zinc-900/20 rounded-2xl border border-zinc-800/60 backdrop-blur-md hover:border-zinc-700/80 transition-all duration-300 flex flex-col justify-between min-h-[340px] w-full max-w-md mx-auto sm:mx-0">
      
      <div>
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-sm font-semibold tracking-wide text-zinc-200 uppercase font-mono">
            Execute Swap
          </h3>
          {isPaused && (
            <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider font-mono bg-red-500/10 text-red-400 border border-red-500/20 animate-pulse">
               Pool Paused
            </span>
          )}
        </div>

        <div className="space-y-4 mb-6">
          <div className="relative">
            <label className="block text-[10px] text-zinc-500 uppercase tracking-wide font-mono mb-1.5">
              Pay (Amount In)
            </label>
            <div className="relative flex items-center">
              <input
                type="number"
                value={amountIn}
                onChange={e => setAmountIn(e.target.value)}
                placeholder="0.00"
                className="w-full bg-zinc-950/50 text-white placeholder-zinc-600 border border-zinc-800/80 focus:border-pink-500/50 focus:ring-1 focus:ring-pink-500/20 rounded-xl px-4 py-3 text-lg font-medium tracking-tight font-mono outline-none transition-all"
                disabled={isPaused}
              />
              <span className="absolute right-4 text-xs font-bold text-zinc-400 font-mono tracking-wider">
                COIN X
              </span>
            </div>
          </div>
        </div>
      </div>

      <div className="border-t border-zinc-800/50 pt-4 mb-6 space-y-2 text-xs font-mono">
        <div className="flex justify-between">
          <span className="text-zinc-500">Spot Price</span>
          <span className="text-zinc-300 font-medium">
            {pool?.spotPrice ? pool.spotPrice.toFixed(6) : '0.000000'}
          </span>
        </div>
        <div className="flex justify-between">
          <span className="text-zinc-500">Reserves (X / Y)</span>
          <span className="text-zinc-400">
            {pool?.reserveX ? pool.reserveX.toString() : '0'} / {pool?.reserveY ? pool.reserveY.toString() : '0'}
          </span>
        </div>
      </div>

      <button
        onClick={handleSwap}
        disabled={isPending || !account || isPaused || !amountIn}
        className={`w-full py-3 px-4 font-semibold text-sm rounded-full tracking-wide transition-all duration-300 font-mono uppercase
          ${!account || isPaused || !amountIn
            ? 'bg-zinc-800 text-zinc-500 cursor-not-allowed border border-zinc-700/30'
            : 'bg-gradient-to-r from-pink-500 to-violet-600 text-white shadow-[0_0_25px_rgba(236,72,153,0.35)] hover:shadow-[0_0_35px_rgba(236,72,153,0.5)] hover:opacity-95 active:scale-[0.98]'
          }`}
      >
        {isPending ? (
          <div className="flex items-center justify-center gap-2">
            <svg className="animate-spin h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
            </svg>
            Signing...
          </div>
        ) : !account ? (
          'Connect Wallet'
        ) : (
          'Swap Assets →'
        )}
      </button>

    </div>
  );
}