import Hero from '../components/Hero';
import Dashboard from '../components/Dashboard';

export default function Home() {
  return (
    <main className="w-full min-h-screen flex flex-col items-center justify-start pb-12">
      {/* Structural layout block ensuring both elements stack perfectly aligned */}
      <div className="w-full">
        <Hero />
        <Dashboard />
      </div>
    </main>
  );
}