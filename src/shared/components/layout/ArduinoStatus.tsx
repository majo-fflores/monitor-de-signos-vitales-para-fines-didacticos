export function ArduinoStatus() {
  return (
    <div className="flex items-center gap-3 px-3 py-2 sm:px-4 rounded-xl bg-emerald-500/10 border border-emerald-500/20 dark:border-emerald-500/30 transition-all duration-300">
      <div className="relative flex h-3 w-3">
        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
        <span className="relative inline-flex rounded-full h-3 w-3 bg-emerald-500"></span>
      </div>
      <span className="text-sm font-semibold text-emerald-600 dark:text-emerald-400 hidden sm:block">
        Arduino Conectado
      </span>
    </div>
  );
}
