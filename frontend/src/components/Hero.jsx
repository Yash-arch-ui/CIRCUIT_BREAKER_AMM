export default function Hero() {
  return (
    <div className="max-w-7xl mx-auto px-6 pt-16 pb-8 text-left">
      {/* Small pink subtag matching the '// FEATURED WORK' from image_075458.jpg */}
      <span className="text-xs font-mono tracking-widest text-pink-500 uppercase block mb-3 animate-fade-in">
        // PROTOCOL ARCHITECTURE
      </span>
      
      {/* Main Title Banner */}
      <h1 className="text-4xl sm:text-5xl font-bold text-white tracking-tight mb-4 max-w-4xl bg-gradient-to-r from-white via-white to-zinc-400 bg-clip-text text-transparent">
        Guardian AMM
      </h1>
      
      {/* Subtext Paragraph */}
      <p className="text-zinc-400 text-sm sm:text-base max-w-2xl leading-relaxed font-normal">
        Protecting DeFi from flash crashes with an automatic, oracle-less 
        <span className="text-pink-500/90 font-mono text-xs px-1.5 py-0.5 bg-pink-500/5 rounded border border-pink-500/10 mx-1">
          EMA-based
        </span> 
        circuit breaker embedded directly into the pool core.
      </p>
    </div>
  );
}