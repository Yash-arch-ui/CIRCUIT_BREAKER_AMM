import PoolCard from '../components/PoolCard';
import SwapCard from '../components/SwapCard';
import StatusCard from '../components/StatusCard';
import AddLiquidityCard from '../components/AddLiquidityCard';
import RemoveLiquidityCard from '../components/RemoveLiquidityCard';

export default function Dashboard() {
  return (
    <div className="w-full min-h-screen bg-[#0a0a0a] text-white px-6 py-8 select-none">
      
      <div className="mb-10 max-w-[1280px] mx-auto">
        <span className="text-[#ff2a7a] text-xs font-mono tracking-widest block mb-4">// LIVE PORTAL MONITOR</span>
        <h2 className="text-white text-2xl font-bold tracking-tight mb-6">System Overview</h2>
        
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <StatusCard />
          <PoolCard />
        </div>
      </div>
      <div className="max-w-[1280px] mx-auto">
        <span className="text-[#ff2a7a] text-xs font-mono tracking-widest block mb-4">// LIQUIDITY HUB ACTIONS</span>
        <h2 className="text-white text-2xl font-bold tracking-tight mb-6">Execute Operations</h2>
        
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 items-start">
          <SwapCard />
          <AddLiquidityCard />
          <RemoveLiquidityCard />
        </div>
      </div>

    </div>
  );
}