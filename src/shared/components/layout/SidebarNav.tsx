import { LayoutDashboard, History, Bell, Settings } from 'lucide-react';
import { NavLink } from 'react-router-dom';

interface NavItem {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  path: string;
}

interface SidebarNavProps {
  onClose?: () => void;
}

export function SidebarNav({ onClose }: SidebarNavProps) {
  const navItems: NavItem[] = [
    { icon: LayoutDashboard, label: 'Dashboard', path: '/' },
    { icon: History, label: 'Historial', path: '/historial' },
    { icon: Bell, label: 'Alertas', path: '/alertas' },
    { icon: Settings, label: 'Configuración', path: '/configuracion' },
  ];

  return (
    <nav className="flex flex-col gap-4 flex-1">
      {navItems.map((item) => (
        <NavLink
          key={item.label}
          to={item.path}
          onClick={onClose}
          className={({ isActive }) =>
            `w-14 h-14 rounded-2xl flex items-center justify-center transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-ring ${
              isActive
                ? 'bg-sidebar-primary/10 text-sidebar-primary shadow-[0_0_20px_rgba(0,212,255,0.15)] dark:bg-primary/20 dark:text-primary'
                : 'text-muted-foreground hover:text-foreground hover:bg-sidebar-accent'
            }`
          }
          title={item.label}
        >
          <item.icon className="w-5 h-5" />
        </NavLink>
      ))}
    </nav>
  );
}
