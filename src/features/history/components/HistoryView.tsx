export function HistoryView() {
  return (
    <div className="w-full space-y-6">
      <div className="flex flex-col gap-1">
        <h2 className="text-2xl font-extrabold tracking-tight text-foreground transition-colors duration-200">
          Historial Biométrico
        </h2>
        <p className="text-sm text-muted-foreground transition-colors duration-200">
          Auditoría de registros almacenados de los pacientes.
        </p>
      </div>

      <div className="rounded-2xl bg-card border border-border shadow-md overflow-hidden transition-colors duration-200">
        <div className="p-6 border-b border-border">
          <h3 className="font-semibold text-foreground">Registros Recientes</h3>
        </div>
        <div className="p-12 text-center text-muted-foreground font-medium">
          No hay datos históricos disponibles por el momento.
        </div>
      </div>
    </div>
  );
}
