import { create } from 'zustand';

type DataPoint = { name: string; value: [number, number] };

interface VitalSignsState {
  ecgData: DataPoint[];
  spo2Data: DataPoint[];
  heartRate: number;
  spo2Level: number;
  co2Level: number;
  startSimulation: () => void;
  stopSimulation: () => void;
}

export const useVitalSignsStore = create<VitalSignsState>((set) => {
  let intervalId: ReturnType<typeof setInterval> | null = null;
  let angle = 0;
  let spo2Angle = 0;

  return {
    ecgData: [],
    spo2Data: [],
    heartRate: 72,
    spo2Level: 98,
    co2Level: 35,

    startSimulation: () => {
      if (intervalId) return;

      let now = new Date().getTime();
      const initialEcg: DataPoint[] = [];
      const initialSpo2: DataPoint[] = [];

      // Llenamos el arreglo inicial (ventana de 10 segundos aprox a 100ms)
      for (let i = 0; i < 100; i++) {
        initialEcg.push({ name: now.toString(), value: [now, 0] });
        initialSpo2.push({ name: now.toString(), value: [now, 50] });
        now += 100;
      }

      set({ ecgData: initialEcg, spo2Data: initialSpo2 });

      intervalId = setInterval(() => {
        const currentNow = new Date().getTime();

        // Simulación de ECG (Onda rítmica con pico QRS)
        angle += 0.5;
        const ecgBase = Math.sin(angle) * 10;
        const qrs = Math.random() > 0.92 ? 80 : 0;
        const ecgValue = ecgBase + qrs;

        // Simulación de SpO2 (Curva pletismográfica más suave, onda dicrota)
        spo2Angle += 0.25;
        // Combinamos dos senoides para simular el pulso y la muesca dicrota
        const spo2Value = Math.sin(spo2Angle) * 30 + Math.cos(spo2Angle * 2) * 10 + 50;

        // Variación leve en los KPIs numéricos
        const newHr = 70 + Math.floor(Math.random() * 5);
        const newSpo2 = 97 + Math.floor(Math.random() * 4); // 97-100%

        set((state) => {
          const newEcg = [...state.ecgData];
          newEcg.shift();
          newEcg.push({ name: currentNow.toString(), value: [currentNow, ecgValue] });

          const newSpo2Arr = [...state.spo2Data];
          newSpo2Arr.shift();
          newSpo2Arr.push({ name: currentNow.toString(), value: [currentNow, spo2Value] });

          return {
            ecgData: newEcg,
            spo2Data: newSpo2Arr,
            heartRate: newHr,
            spo2Level: newSpo2,
          };
        });
      }, 100);
    },

    stopSimulation: () => {
      if (intervalId) {
        clearInterval(intervalId);
        intervalId = null;
      }
    },
  };
});
