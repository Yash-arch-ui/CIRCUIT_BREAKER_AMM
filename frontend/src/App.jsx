import Navbar from '../src/components/Navbar';
import Footer from '../src/components/Footer';
import Home from '../src/pages/Home';

export default function App() {
  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white flex flex-col justify-between">
      <Navbar />
      <Home />
      <Footer />
    </div>
  );
}