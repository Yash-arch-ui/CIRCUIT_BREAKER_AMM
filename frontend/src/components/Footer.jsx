export default function Footer() {
  return (
    <footer className="w-full border-t border-zinc-900/80 bg-[#050505]/40 backdrop-blur-sm mt-16 px-6 py-6">
      <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4 text-xs font-mono text-zinc-500">
        
        <div className="flex items-center gap-2">
          <span className="h-1.5 w-1.5 rounded-full bg-sky-400 shadow-[0_0_8px_rgba(56,189,248,0.5)]" />
          <p className="tracking-wide">
            Built on <span className="text-zinc-300 font-medium">Sui Testnet</span>
          </p>
        </div>

        <div className="text-center sm:text-right tracking-tight text-[11px] text-zinc-600">
          Circuit Breaker AMM &copy; {new Date().getFullYear()} — Secure Core Architecture
        </div>

      </div>
    </footer>
  );
}