# Reglas de Dominio y Tiempo Real — DataVital

Este archivo define los rangos fisiológicos, las reglas de procesamiento de bioseñales de alta frecuencia y las optimizaciones de hardware.

---

## 1. Rangos Fisiológicos y Límites Clínicos

Al validar o alertar sobre bioseñales, las constantes de rangos deben alinearse estrictamente a límites fisiológicos válidos:

| Biosenal | Rango Válido | Estado Seguro / Excelente | Estado Crítico / Alerta |
| :--- | :--- | :--- | :--- |
| **Frecuencia Cardíaca (BPM)** | `30` - `250` BPM | `60` - `100` BPM | `< 50` o `> 120` BPM |
| **Saturación SpO₂** | `70` - `100` % | `>= 95` % | `< 90` % |
| **Dióxido de Carbono CO₂ (MQ-135)** | `300` - `1500` ppm | `< 600` ppm | `> 1000` ppm |

---

## 2. Tiempo Real, WebSockets e Isolates

El hardware (backend local que simula o lee del Arduino) transmite a alta frecuencia (múltiples paquetes por segundo). Para garantizar un rendimiento óptimo en Flutter:

* **Background Net Isolate**: Toda la lógica de red (conexión TCP, sockets de red y reconexión automática por backoff exponencial) se ejecuta en un hilo de fondo dedicado (**Dart Isolate**). La UI no realiza tareas de parsing directo de red.
* **Procesamiento por Lotes (Batch Rendering)**: 
  * En lugar de reconstruir la interfaz del dashboard por cada paquete recibido (12+ veces por segundo), los datos se acumulan en un acumulador intermedio y se refresca el estado en lotes (*batch*) cada **80ms**.
  * Respeta siempre esta estrategia de acumulación temporal para evitar sobrecargar la GPU del móvil.

---

## 3. Estado de Conexión y Simulador

* **Preferencia del usuario**: La preferencia sobre si usar datos reales vía WebSocket o simulación local se lee de disco mediante `SharedPreferences` al inicio de la app.
* **WebSocket URL**: Se compone dinámicamente de forma configurable a través de los campos Host y Puerto en el panel de configuración, resolviendo por defecto a `ws://localhost:8080/ws/sensors` en entornos de desarrollo local.
