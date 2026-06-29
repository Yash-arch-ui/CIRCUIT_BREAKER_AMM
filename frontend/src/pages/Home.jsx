import Hero from '../components/Hero';
import Dashboard from './Dashboards'; // Points directly to the file in the same folder

export default function Home() {
  return (
    <main className="w-full min-h-screen block pb-12 bg-[#0a0a0a]">
      <div className="w-full">
        <Hero />
        <Dashboard />
      </div>
    </main>
  );
}