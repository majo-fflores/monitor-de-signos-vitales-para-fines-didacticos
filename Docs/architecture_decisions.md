# Decisiones de Arquitectura: DataVital

Este documento detalla el razonamiento detrás de la elección de librerías clave en el stack tecnológico del proyecto DataVital.

## Gráficos y Visualización de Datos: Apache ECharts

Para la visualización de datos de signos vitales (ECG, SpO2, Capnografía, etc.) se evaluaron múltiples opciones, y se seleccionó **Apache ECharts** (`echarts-for-react`) por las siguientes razones críticas para el contexto de monitorización médica simulada:

1. **Rendimiento en Alta Frecuencia (Canvas vs SVG):** Las curvas fisiológicas, especialmente el Electrocardiograma (ECG), generan cientos de puntos por segundo. Librerías basadas puramente en SVG (como Recharts o Victory) sufrirían una grave degradación de rendimiento y sobrecarga del DOM al intentar renderizar y actualizar estos puntos en tiempo real. ECharts utiliza **Canvas** (y opcionalmente WebGL), lo que permite un renderizado de alto rendimiento sin bloquear el hilo principal de React.
2. **Barrido Continuo (Streaming):** ECharts cuenta con mecanismos nativos muy eficientes para gráficos de series temporales dinámicas (efecto de *scrolling* o *barrido* continuo), que es la forma estándar de visualizar ondas biomédicas en monitores de pacientes reales.
3. **Versatilidad de Componentes:** Más allá de las gráficas de línea para ondas, ECharts incluye un robusto ecosistema de gráficos tipo "Gauge" (velocímetros) y de progreso, los cuales son ideales para mostrar KPIs como el nivel actual de SpO2 o Frecuencia Cardíaca en el dashboard principal.
4. **Independencia del Ecosistema:** Al no estar amarrado estrictamente a los ciclos de vida y renderizado interno de React, proporciona un control más fino sobre las optimizaciones de dibujo intensivo.

## Gestor de Estado Global: Zustand

En el manejo del estado global, especialmente para los datos entrantes del hardware (via WebSocket o Polling) y la gestión de alarmas, se optó por **Zustand** sobre opciones como Redux o Context API.

1. **Minimización de Re-renders Innecesarios:** En un sistema de monitoreo en tiempo real, el estado cambia decenas de veces por segundo. React Context provocaría re-renders en cascada de todos los componentes suscritos, lo cual es fatal para el rendimiento de la UI (particularmente con gráficos). Zustand permite la selección atómica de estado (e.g., `useStore(state => state.heartRate)`), de modo que solo el componente que necesita ese dato se vuelve a renderizar.
2. **Suscripciones Transitorias (Transient Updates):** Zustand permite actualizar el DOM o instanciar objetos mutables (como los que requiere ECharts) sin necesidad de pasar por el ciclo normal de renderizado de React (`useStore.subscribe()`), ideal para alimentar los gráficos de alta frecuencia directamente.
3. **Simplicidad y Boilerplate Reducido:** A diferencia de Redux Toolkit, Zustand no requiere actions, reducers, ni providers complejos para configurar la store. Dada la naturaleza didáctica del proyecto, simplifica drásticamente el flujo de datos.
4. **Soporte de TypeScript:** Excelente inferencia de tipos inmediata (out-of-the-box), encajando perfectamente con las definiciones de las interfaces biomédicas del sistema.
