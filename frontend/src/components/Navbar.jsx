import { ConnectButton } from '@mysten/dapp-kit';

export default function Navbar() {
  return (
    <nav className="sticky top-0 z-50 w-full border-b border-zinc-900/80 bg-[#050505]/70 backdrop-blur-md px-6 py-4">
      <div className="max-w-7xl mx-auto flex items-center justify-between">
        
        {/* Project Branding styled like the top left indicator in image_075458.jpg */}
        <div className="flex items-center gap-2">
          <div className="h-5 w-5 rounded bg-gradient-to-br from-pink-500 to-violet-600 flex items-center justify-center font-mono text-[10px] font-bold text-white shadow-[0_0_10px_rgba(236,72,153,0.3)]">
            G
          </div>
          <h2 className="text-sm font-bold tracking-widest text-white uppercase font-mono">
            Guardian AMM
          </h2>
        </div>

        {/* Navigation Items (Middle space if you want links later, matching the screenshot's 'Projects', 'Stack') */}
        <div className="hidden md:flex items-center gap-6 text-xs font-medium text-zinc-400 font-mono tracking-wide">
          <a href="#dashboard" className="hover:text-white transition-colors">Dashboard</a>
          <a href="#pools" className="hover:text-white transition-colors">Pools</a>
          <a href="#docs" className="hover:text-white transition-colors">Docs</a>
        </div>

        {/* Web3 Wallet Connect Trigger styled cleanly */}
        <div className="custom-wallet-connect font-mono text-xs">
          <ConnectButton />
        </div>

      </div>
    </nav>
  );
}