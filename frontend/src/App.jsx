import Navbar from './components/Navbar';
import Footer from './components/Footer';
import Home from './pages/Home';

export default function App() {
  return (
    <div className="min-h-screen relative overflow-x-hidden">
      <Navbar />
      <Home />
      <Footer />
    </div>
  );
}