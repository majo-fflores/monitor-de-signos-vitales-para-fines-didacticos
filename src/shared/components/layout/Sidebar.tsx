import { SidebarLogo } from './SidebarLogo';
import { SidebarNav } from './SidebarNav';

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

export function Sidebar({ isOpen, onClose }: SidebarProps) {
  return (
    <aside
      className={`
        bg-sidebar border-r border-sidebar-border flex flex-col items-center py-8 gap-8 min-h-screen shrink-0 transition-all duration-300 z-40
        fixed top-0 left-0 h-full md:sticky md:flex w-24
        ${isOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'}
      `}
    >
      <SidebarLogo />
      <SidebarNav onClose={onClose} />
    </aside>
  );
}
