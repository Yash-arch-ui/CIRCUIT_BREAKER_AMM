import PoolCard from '../components/PoolCard';
import SwapCard from '../components/SwapCard';
import StatusCard from '../components/StatusCard';

export default function Dashboard() {
  return (
    <div className="max-w-7xl mx-auto px-6 py-12">
      {/* Dynamic Subheading matching the layout of image_075458.jpg */}
      <div className="mb-8 text-left">
        <span className="text-xs font-mono tracking-widest text-pink-500 uppercase block mb-2">
          // LIVE PORTAL DEMO
        </span>
        <h1 className="text-3xl font-bold text-white tracking-tight">
          System Overview
        </h1>
      </div>

      {/* Grid container styling out your Cards into sleek Bento slots */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <StatusCard />
        <PoolCard />
        <SwapCard />
      </div>
    </div>
  );
}