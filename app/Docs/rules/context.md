# Contexto y Arquitectura: DataVital

Este documento define la arquitectura, convenciones obligatorias y el diseño de la interfaz para el monitor de signos vitales **DataVital**.

---

## 🎨 1. Gestión de Color y Diseño Visual
Todos los colores del proyecto están definidos de forma inmutable en [app_colors.dart](file:///home/lk/Proyectos/STR/DataVital---Frontend/lib/core/theme/app_colors.dart) y en [app_theme.dart](file:///home/lk/Proyectos/STR/DataVital---Frontend/lib/core/theme/app_theme.dart).

### Reglas Estrictas:
*   **Prohibido Hardcodear Colores**: Todos los elementos deben usar referencias de colores provistas por el tema a través de `Theme.of(context).colorScheme` o los colores semánticos definidos en `ColoresSensores`.
*   **Contraste y Visibilidad**: Diseñado bajo un look estelar con alto contraste. Fondo completamente negro para las pantallas oscuras de los gráficos médicos para mejorar la visibilidad.

---

## ⚡ 2. Prevención de Jittering y Tiempo Real
El flujo continuo de señales fisiológicas de alta frecuencia (~10 FPS) requiere optimización especial de rendering:

*   **Evitar Jittering Horizontal**: Las lecturas numéricas de signos vitales actualizadas dinámicamente deben usar obligatoriamente la propiedad `FontFeature.tabularFigures()` y tipografía monoespaciada (`fontFamily: 'monospace'`). Esto fuerza a todos los dígitos a ocupar exactamente el mismo ancho, previniendo que los textos "tiemblen" lateralmente.
*   **Cero Retardo de Animaciones**: Los gráficos basados en `fl_chart` deben establecer su duración en `Duration.zero` para reflejar instantáneamente los puntos fisiológicos sin latencia agregada por interpolación del framework.
*   **Suscripciones Selectivas**: Utilizar selectores de Riverpod `ref.watch(provider.select((s) => s.campo))` para asegurar que los componentes de la interfaz solo se reconstruyan ante variaciones de sus respectivos signos vitales, evitando cascadas innecesarias.

---

## 📱 3. Responsive Adaptativo
La aplicación debe adaptar su interfaz según la pantalla del dispositivo:
*   **Breakpoint**: `< 600px` de ancho se considera dispositivo móvil.
*   **Layout Adaptativo**:
    *   **Desktop/Tablet**: Sidebar (`AppSidebar`) fija de 96px a la izquierda de la pantalla. Reloj superior a la derecha en el Header.
    *   **Mobile**: La sidebar se convierte en un `Drawer` interactivo desplegable a través de un botón hamburguesa a la izquierda del Header. Las tarjetas KPI se compactan en una sola columna vertical.
