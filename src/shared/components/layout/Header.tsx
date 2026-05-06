import { Menu } from 'lucide-react';
import { ArduinoStatus } from './ArduinoStatus';
import { LiveClock } from './LiveClock';
import { ThemeToggle } from './ThemeToggle';

interface HeaderProps {
  onMenuClick?: () => void;
}

export function Header({ onMenuClick }: HeaderProps) {
  return (
    <header className="h-20 bg-card border-b border-border px-4 sm:px-8 flex items-center justify-between shrink-0 transition-colors duration-200">
      {/* Menu Hamburger, Title & Status Container */}
      <div className="flex items-center gap-3">
        {/* Hamburger Menu (Mobile Only) */}
        <button
          onClick={onMenuClick}
          className="p-2 -ml-1 rounded-lg text-muted-foreground hover:text-foreground hover:bg-sidebar-accent md:hidden transition-colors focus:outline-none focus:ring-2 focus:ring-ring"
          aria-label="Abrir menú"
        >
          <Menu className="w-5 h-5" />
        </button>

        {/* Title & Arduino Status */}
        <div className="flex items-center gap-3">
          <h1 className="text-lg sm:text-xl font-extrabold text-foreground tracking-tight leading-none transition-colors duration-200">
            DataVital
          </h1>
          <ArduinoStatus />
        </div>
      </div>

      {/* Interactive Controls & Status Widgets */}
      <div className="flex items-center gap-3 sm:gap-6">
        <div className="hidden md:block">
          <LiveClock />
        </div>
        <ThemeToggle />
      </div>
    </header>
  );
}
