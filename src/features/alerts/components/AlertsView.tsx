export function AlertsView() {
  return (
    <div className="w-full space-y-6">
      <div className="flex flex-col gap-1">
        <h2 className="text-2xl font-extrabold tracking-tight text-foreground transition-colors duration-200">
          Alertas de Monitoreo
        </h2>
        <p className="text-sm text-muted-foreground transition-colors duration-200">
          Notificaciones y advertencias críticas de sensores vitales y ambientales.
        </p>
      </div>

      <div className="rounded-2xl bg-destructive/5 border border-destructive/20 p-6 shadow-sm flex items-center justify-between transition-colors duration-200">
        <div className="flex flex-col gap-1">
          <span className="font-semibold text-destructive">Sistema de Alarmas Operativo</span>
          <span className="text-xs text-muted-foreground">
            Monitoreando umbrales normales de salud y ambiente.
          </span>
        </div>
        <span className="px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-500 border border-emerald-500/20">
          Estable
        </span>
      </div>
    </div>
  );
}
