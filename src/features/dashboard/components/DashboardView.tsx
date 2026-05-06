export function DashboardView() {
  return (
    <div className="w-full space-y-6">
      <div className="flex flex-col gap-1">
        <h2 className="text-2xl font-extrabold tracking-tight text-foreground transition-colors duration-200">
          Dashboard Principal
        </h2>
        <p className="text-sm text-muted-foreground transition-colors duration-200">
          Vista general del monitoreo de signos vitales y condiciones ambientales.
        </p>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        <div className="rounded-2xl bg-card p-6 border border-border shadow-md transition-colors duration-200 flex flex-col justify-between h-40">
          <span className="text-sm font-semibold text-muted-foreground">Frecuencia Cardíaca</span>
          <span className="text-5xl font-extrabold text-foreground font-mono">
            -- <span className="text-xs font-semibold text-muted-foreground">LPM</span>
          </span>
        </div>
        <div className="rounded-2xl bg-card p-6 border border-border shadow-md transition-colors duration-200 flex flex-col justify-between h-40">
          <span className="text-sm font-semibold text-muted-foreground">Presión Arterial</span>
          <span className="text-5xl font-extrabold text-foreground font-mono">
            --/-- <span className="text-xs font-semibold text-muted-foreground">mmHg</span>
          </span>
        </div>
        <div className="rounded-2xl bg-card p-6 border border-border shadow-md transition-colors duration-200 flex flex-col justify-between h-40">
          <span className="text-sm font-semibold text-muted-foreground">Nivel de CO₂</span>
          <span className="text-5xl font-extrabold text-foreground font-mono">
            -- <span className="text-xs font-semibold text-muted-foreground">ppm</span>
          </span>
        </div>
      </div>
    </div>
  );
}
