function App() {
  return (
    <div className="flex min-h-screen items-center justify-center p-4">
      <div className="rounded-xl bg-card p-8 shadow-lg border">
        <h1 className="text-3xl font-bold tracking-tight text-primary">DataVital</h1>
        <p className="mt-2 text-muted-foreground">
          Monitor multiparamétrico de signos vitales (Educativo)
        </p>

        <div className="mt-6 grid gap-4 md:grid-cols-2">
          <div className="rounded-lg bg-secondary p-4">
            <h2 className="font-semibold">Sensores Activos</h2>
            <div className="mt-2 text-4xl font-mono text-accent-foreground">0</div>
          </div>
          <div className="rounded-lg bg-destructive/10 p-4 border border-destructive/20">
            <h2 className="font-semibold text-destructive">Sistema de Alarmas</h2>
            <div className="mt-2 text-sm text-destructive">Inactivo</div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
