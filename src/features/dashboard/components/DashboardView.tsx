import { useEffect } from 'react';
import ReactECharts from 'echarts-for-react';
import { useVitalSignsStore } from '../../../shared/store/useVitalSignsStore';

export function DashboardView() {
  const { ecgData, spo2Data, heartRate, spo2Level, co2Level, startSimulation, stopSimulation } =
    useVitalSignsStore();

  useEffect(() => {
    startSimulation();
    // Limpiar el intervalo cuando el componente se desmonte
    return () => stopSimulation();
  }, [startSimulation, stopSimulation]);

  const baseAxisConfig = {
    splitLine: { show: true, lineStyle: { color: '#333', type: 'dashed' } },
    axisLabel: { show: false },
    axisTick: { show: false },
    axisLine: { show: false },
  };

  const ecgOption = {
    animation: false,
    tooltip: { show: false },
    xAxis: { type: 'time', ...baseAxisConfig },
    yAxis: { type: 'value', min: -30, max: 100, ...baseAxisConfig },
    series: [
      {
        type: 'line',
        showSymbol: false,
        data: ecgData,
        lineStyle: { color: '#10b981', width: 2 },
        smooth: true,
      },
    ],
    grid: { top: 10, right: 10, bottom: 10, left: 10 },
    backgroundColor: '#000',
  };

  const spo2Option = {
    animation: false,
    tooltip: { show: false },
    xAxis: { type: 'time', ...baseAxisConfig },
    yAxis: { type: 'value', min: 0, max: 100, ...baseAxisConfig },
    series: [
      {
        type: 'line',
        showSymbol: false,
        data: spo2Data,
        lineStyle: { color: '#3b82f6', width: 2 },
        smooth: true,
        areaStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(59, 130, 246, 0.4)' },
              { offset: 1, color: 'rgba(59, 130, 246, 0)' },
            ],
          },
        },
      },
    ],
    grid: { top: 10, right: 10, bottom: 10, left: 10 },
    backgroundColor: '#000',
  };

  return (
    <div className="w-full space-y-6">
      <div className="flex flex-col gap-1">
        <h2 className="text-2xl font-extrabold tracking-tight text-foreground transition-colors duration-200">
          Dashboard
        </h2>
        <p className="text-sm text-muted-foreground transition-colors duration-200">
          Visualización en tiempo real gestionada por store global de estado.
        </p>
      </div>

      <div className="grid gap-6 md:grid-cols-4">
        {/* Panel Izquierdo: Gráficas de Ondas */}
        <div className="md:col-span-3 space-y-4">
          <div className="rounded-2xl bg-card border border-border shadow-md overflow-hidden">
            <div className="px-4 py-2 bg-black flex justify-between items-center border-b border-zinc-800">
              <span className="text-xs font-bold text-[#10b981]">ECG (AD8232)</span>
              <span className="text-xs font-bold text-zinc-500">100mm/s</span>
            </div>
            <div className="h-64 bg-black p-2">
              <ReactECharts
                option={ecgOption}
                notMerge={true}
                lazyUpdate={true}
                style={{ height: '100%', width: '100%' }}
              />
            </div>
          </div>

          <div className="rounded-2xl bg-card border border-border shadow-md overflow-hidden">
            <div className="px-4 py-2 bg-black flex justify-between items-center border-b border-zinc-800">
              <span className="text-xs font-bold text-[#3b82f6]">SpO2 Oximetría (MAX30100)</span>
            </div>
            <div className="h-40 bg-black p-2">
              <ReactECharts
                option={spo2Option}
                notMerge={true}
                lazyUpdate={true}
                style={{ height: '100%', width: '100%' }}
              />
            </div>
          </div>
        </div>

        {/* Panel Derecho: KPI / Tarjetas de Signos Vitales */}
        <div className="space-y-4">
          <div className="rounded-2xl bg-card p-6 border-l-4 border-[#10b981] shadow-md flex flex-col h-32 justify-center transition-all duration-300">
            <span className="text-xs font-bold text-[#10b981] uppercase tracking-wider mb-2">
              Frecuencia Cardíaca
            </span>
            <div className="flex items-baseline gap-2">
              <span className="text-5xl font-extrabold text-foreground font-mono">{heartRate}</span>
              <span className="text-sm font-semibold text-muted-foreground">LPM</span>
            </div>
          </div>

          <div className="rounded-2xl bg-card p-6 border-l-4 border-[#3b82f6] shadow-md flex flex-col h-32 justify-center transition-all duration-300">
            <span className="text-xs font-bold text-[#3b82f6] uppercase tracking-wider mb-2">
              Saturación SpO2
            </span>
            <div className="flex items-baseline gap-2">
              <span className="text-5xl font-extrabold text-foreground font-mono">{spo2Level}</span>
              <span className="text-sm font-semibold text-muted-foreground">%</span>
            </div>
          </div>

          <div className="rounded-2xl bg-card p-6 border-l-4 border-[#eab308] shadow-md flex flex-col h-32 justify-center">
            <span className="text-xs font-bold text-[#eab308] uppercase tracking-wider mb-2">
              Nivel CO2 (MQ-135)
            </span>
            <div className="flex items-baseline gap-2">
              <span className="text-5xl font-extrabold text-foreground font-mono">{co2Level}</span>
              <span className="text-sm font-semibold text-muted-foreground">ppm</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
