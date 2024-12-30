import React, { useState } from 'react';
import { Menu, X, Wallet } from 'lucide-react';

const Navbar = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [isConnected, setIsConnected] = useState(false);

  const toggleMenu = () => setIsOpen(!isOpen);

  const handleConnect = () => {
    setIsConnected(!isConnected);
  };

  return (
    <nav className="bg-gradient-to-r from-blue-900 via-purple-900 to-indigo-900 fixed w-full top-0 left-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex-shrink-0">
            <span className="text-white text-xl font-bold">Scholarship Fund</span>
          </div>

          <div className="hidden md:block">
            <div className="ml-10 flex items-center space-x-8">
              <a href="#" className="text-gray-100 hover:text-white hover:bg-white/10 px-3 py-2 rounded-md text-sm font-medium transition-colors">
                Home
              </a>
              <a href="#" className="text-gray-100 hover:text-white hover:bg-white/10 px-3 py-2 rounded-md text-sm font-medium transition-colors">
                Schools
              </a>
              <a href="#" className="text-gray-100 hover:text-white hover:bg-white/10 px-3 py-2 rounded-md text-sm font-medium transition-colors">
                Apply
              </a>
              <a href="#" className="text-gray-100 hover:text-white hover:bg-white/10 px-3 py-2 rounded-md text-sm font-medium transition-colors">
                DAO
              </a>
            </div>
          </div>

          <div className="hidden md:block">
            <button
              onClick={handleConnect}
              className="flex items-center px-4 py-2 rounded-lg bg-gradient-to-r from-blue-500 to-indigo-500 hover:from-blue-600 hover:to-indigo-600 text-white font-medium transition-all shadow-lg hover:shadow-xl"
            >
              <Wallet className="w-4 h-4 mr-2" />
              {isConnected ? 'Connected' : 'Connect Wallet'}
            </button>
          </div>

          <div className="md:hidden flex items-center">
            <button
              onClick={toggleMenu}
              className="inline-flex items-center justify-center p-2 rounded-md text-gray-100 hover:text-white hover:bg-white/10 focus:outline-none transition-colors"
            >
              {isOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>
        </div>
      </div>

      {isOpen && (
        <div className="md:hidden bg-gradient-to-r from-blue-900 via-purple-900 to-indigo-900 shadow-lg">
          <div className="px-2 pt-2 pb-3 space-y-1">
            <a href="#" className="text-gray-100 hover:text-white hover:bg-white/10 block px-3 py-2 rounded-md text-base font-medium transition-colors">
              Home
            </a>
            <a href="#" className="text-gray-100 hover:text-white hover:bg-white/10 block px-3 py-2 rounded-md text-base font-medium transition-colors">
              Schools
            </a>
            <a href="#" className="text-gray-100 hover:text-white hover:bg-white/10 block px-3 py-2 rounded-md text-base font-medium transition-colors">
              Apply
            </a>
            <a href="#" className="text-gray-100 hover:text-white hover:bg-white/10 block px-3 py-2 rounded-md text-base font-medium transition-colors">
              DAO
            </a>
            <button
              onClick={handleConnect}
              className="flex items-center w-full px-4 py-2 rounded-lg bg-gradient-to-r from-blue-500 to-indigo-500 hover:from-blue-600 hover:to-indigo-600 text-white font-medium transition-all shadow-lg hover:shadow-xl"
            >
              <Wallet className="w-4 h-4 mr-2" />
              {isConnected ? 'Connected' : 'Connect Wallet'}
            </button>
          </div>
        </div>
      )}
    </nav>
  );
};

export default Navbar;