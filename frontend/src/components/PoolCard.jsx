import { usePool } from '../hooks/usePool';

export default function PoolCard() {
  const { data: pool, isLoading } = usePool();

  if (isLoading) {
    return (
      <div className="p-6 bg-zinc-900/20 rounded-2xl border border-zinc-800/60 backdrop-blur-md flex items-center justify-center min-h-[220px]">
        <div className="flex items-center gap-3 text-zinc-400 text-sm">
          <svg className="animate-spin h-4 w-4 text-pink-500" fill="none" viewBox="0 0 24 24">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
          </svg>
          Loading pool...
        </div>
      </div>
    );
  }

  const totalLiquidity = pool
    ? Number(pool.reserveX) + Number(pool.reserveY)
    : 0;

  return (
    <div className="p-6 bg-zinc-900/20 rounded-2xl border border-zinc-800/60 backdrop-blur-md hover:border-zinc-700/80 transition-all duration-300 flex flex-col justify-between min-h-[220px] group">
      <div>
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-sm font-semibold tracking-wide text-zinc-200 uppercase font-mono">
            Pool Information
          </h3>
          <span className="text-[10px] font-mono text-zinc-500 uppercase tracking-wider">
            v4-Core
          </span>
        </div>

        <div className="mb-4">
          <div className="text-3xl font-semibold tracking-tight text-transparent bg-clip-text bg-gradient-to-r from-pink-500 to-violet-400">
            {totalLiquidity.toLocaleString()}
          </div>
          <div className="text-[11px] text-zinc-500 font-mono tracking-wider uppercase mt-0.5">
            Total Combined Liquidity
          </div>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-y-3 gap-x-2 border-t border-zinc-800/50 pt-3 text-xs font-mono">
        <div>
          <span className="block text-[10px] text-zinc-500 uppercase tracking-wide">Reserve X</span>
          <span className="text-zinc-300 font-medium">{pool?.reserveX?.toString() || '0'}</span>
        </div>
        <div>
          <span className="block text-[10px] text-zinc-500 uppercase tracking-wide">Reserve Y</span>
          <span className="text-zinc-300 font-medium">{pool?.reserveY?.toString() || '0'}</span>
        </div>
        <div>
          <span className="block text-[10px] text-zinc-500 uppercase tracking-wide">LP Supply</span>
          <span className="text-zinc-400">{pool?.lpSupply?.toString() || '0'}</span>
        </div>
        <div>
          <span className="block text-[10px] text-zinc-500 uppercase tracking-wide">Conversion Rate</span>
          <span className="text-zinc-400 text-[11px]">
            1 X = {pool?.spotPrice ? pool.spotPrice.toFixed(4) : '0.0000'} Y
          </span>
        </div>
      </div>
    </div>
  );
}