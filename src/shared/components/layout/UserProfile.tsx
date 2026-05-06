import { User, ChevronDown } from 'lucide-react';

export function UserProfile() {
  return (
    <button className="flex items-center gap-3 px-3 py-2 rounded-xl hover:bg-accent focus:outline-none focus:ring-2 focus:ring-ring border border-transparent hover:border-border transition-all duration-200">
      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#00d4ff] to-[#0099ff] flex items-center justify-center shadow-md shadow-cyan-500/10 shrink-0">
        <User className="w-5 h-5 text-white" />
      </div>
      <div className="text-left hidden sm:block">
        <div className="text-sm font-semibold text-foreground leading-tight transition-colors duration-200">
          Usuario
        </div>
        <div className="text-[11px] text-muted-foreground leading-none mt-0.5 font-medium transition-colors duration-200">
          Administrador
        </div>
      </div>
      <ChevronDown className="w-4 h-4 text-muted-foreground shrink-0 hidden sm:block" />
    </button>
  );
}
