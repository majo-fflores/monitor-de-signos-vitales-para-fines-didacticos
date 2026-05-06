export function SettingsView() {
  return (
    <div className="w-full space-y-6">
      <div className="flex flex-col gap-1">
        <h2 className="text-2xl font-extrabold tracking-tight text-foreground transition-colors duration-200">
          Configuración de Sistema
        </h2>
        <p className="text-sm text-muted-foreground transition-colors duration-200">
          Ajustes de umbrales médicos, configuración de puertos y calibración de sensores.
        </p>
      </div>

      <div className="rounded-2xl bg-card border border-border shadow-md p-6 transition-colors duration-200">
        <h3 className="font-semibold text-foreground mb-4">Umbrales de Alerta</h3>
        <p className="text-sm text-muted-foreground">
          La configuración de umbrales biométricos estará disponible próximamente.
        </p>
      </div>
    </div>
  );
}
