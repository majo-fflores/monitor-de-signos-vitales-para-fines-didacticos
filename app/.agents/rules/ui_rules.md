# Reglas de UI, Estilo y Diseño Premium — DataVital

Este archivo define las directrices visuales, de maquetación y de diseño premium para DataVital.

---

## 1. Diseño Premium y Estilo

* **Uso de Colores del Tema**: **Nunca** hardcodees colores directos (`Color(0xFF...)` directo en widgets). Siempre utiliza la paleta semántica referenciando `Theme.of(context)` o las constantes globales de sensor definidas en `AppColors` (`lib/core/theme/app_colors.dart`).
* **Sustitución de Opacidad**:
  * **No** utilices el método `.withOpacity()` (está deprecado desde Flutter v3.44+).
  * **Siempre** utiliza `.withValues(alpha: X)` para efectos de transparencia de color.
* **Constructores `const`**: Declara como `const` todos los widgets, paddings, decoraciones y estilos de texto que no posean dependencias dinámicas de estado. Esto optimiza drásticamente el árbol de renderizado de Flutter.

---

## 2. Tipografía Médica y Tabular Figures

* **Tabular Figures en Telemetría**: Al mostrar variables numéricas que cambian rápidamente (BPM, SpO₂%, ppm de CO₂), los números de diferentes anchos pueden causar un efecto molesto de parpadeo y desplazamiento lateral en la UI (*jitter*).
* **Solución Obligatoria**: Aplica siempre la característica tipográfica `tabularFigures` en la definición de la fuente:
  ```dart
  style: TextStyle(
    fontFeatures: const [FontFeature.tabularFigures()],
    fontFamily: 'monospace', // O aplicar a GoogleFonts.outfit()
  )
  ```

---

## 3. Composición de Widgets

* **Preferir Clases sobre Métodos de Ayuda**:
  * **Nunca** crees métodos privados que devuelvan widgets (`Widget _buildHeader()`). Las funciones no participan en el ciclo de reconciliación de Flutter y fuerzan reconstrucciones completas e innecesarias de toda la página.
  * **Siempre** extrae las secciones de la UI en clases dedicadas (`StatelessWidget` o `ConsumerWidget`), idealmente clases privadas si solo se usan en el mismo archivo (ej: `class _HeaderSection extends StatelessWidget`).
* **Espaciados Responsivos y Simétricos**:
  * Utiliza el paquete `gap` (`Gap(X)`) en lugar de `SizedBox` para espaciados rápidos entre columnas y filas.
  * Utiliza paddings e indicadores de tamaño dinámicos basados en la altura y anchura real (vía `LayoutBuilder` o constraints del padre) en lugar de fijar valores estáticos que causen desbordamientos.
