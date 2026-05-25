# DataVital — Reglas de Desarrollo Flutter para Agentes

> Este documento define las convenciones, buenas prácticas y restricciones que **todo agente** debe seguir al generar o modificar código en este proyecto.
> Última actualización: Mayo 2025.

---

## 1. Stack Tecnológico

| Categoría             | Herramienta / Paquete          | Versión mínima |
| --------------------- | ------------------------------ | -------------- |
| Framework             | Flutter                        | 3.12+          |
| Lenguaje              | Dart                           | 3.12+          |
| Estado global         | `flutter_riverpod`             | 2.6+           |
| Routing               | `go_router`                    | 14+            |
| Gráficos real-time    | `fl_chart`                     | 0.70+          |
| Iconos                | `lucide_icons`                 | 0.257+         |
| Tipografía            | `google_fonts` (Inter)         | 6.2+           |
| SVG                   | `flutter_svg`                  | 2.0+           |
| Persistencia local    | `shared_preferences`           | 2.5+           |
| Linting               | `flutter_lints`, `riverpod_lint`, `custom_lint` | — |
| Code generation       | `riverpod_generator`, `build_runner` | 2.6+ / 2.4+ |

**No** introduzcas dependencias nuevas sin justificación explícita del usuario.

---

## 2. Arquitectura — Feature-First

El proyecto sigue el patrón **Feature-First** con separación clara de responsabilidades.

### Estructura de directorios

```
lib/
├── main.dart                     # Entry point + ProviderScope
├── core/                         # Infraestructura compartida global
│   ├── constants/                # Valores constantes de la app
│   ├── router/                   # GoRouter + rutas (app_router.dart)
│   └── theme/                    # AppColors, AppTheme, breakpoints
├── features/                     # Módulos de funcionalidad aislados
│   ├── dashboard/
│   │   └── widgets/              # Widgets exclusivos de dashboard
│   ├── alerts/
│   ├── history/
│   └── settings/
└── shared/                       # Código reutilizable entre features
    ├── providers/                # Proveedores de estado globales
    └── widgets/                  # Widgets compartidos (layout, shell)
```

### Reglas de arquitectura

- **core/** solo contiene infraestructura: temas, rutas, constantes. **No** debe contener lógica de negocio ni widgets de UI.
- **features/** es la unidad de organización principal. Cada feature contiene su propia carpeta `widgets/` y, opcionalmente, `models/`, `providers/` y `services/`.
- **shared/** contiene código que es reutilizado por **dos o más features**. Si un widget solo lo usa una feature, va dentro de esa feature.
- **Nunca** crees barrel files (`index.dart` que re-exporta todo). Dart no los necesita y generan importaciones circulares.
- Las importaciones **siempre** deben ser relativas al paquete: `import 'package:datavital_flutter/core/theme/app_colors.dart';`.

---

## 3. Convenciones de Nomenclatura

### Archivos y directorios

| Elemento              | Convención            | Ejemplo                        |
| --------------------- | --------------------- | ------------------------------ |
| Archivos `.dart`      | `snake_case`          | `vital_kpi_card.dart`          |
| Directorios           | `snake_case`          | `vital_signs/`                 |
| Clases de Widget      | `PascalCase`          | `VitalKpiCard`                 |
| Proveedores Riverpod  | `camelCase`           | `vitalSignsProvider`           |
| Variables y funciones | `camelCase`           | `heartRate`, `calculateBpm()`  |
| Constantes            | `camelCase` o `kName` | `defaultPadding`, `kMaxRetries`|
| Enums                 | `PascalCase` + `camelCase` valores | `SensorType.ecg`      |
| Archivos de test      | `<nombre>_test.dart`  | `vital_kpi_card_test.dart`     |

### Nomenclatura de Widgets

- Los widgets de vista (pantalla completa) terminan en `View`: `DashboardView`, `SettingsView`.
- Los widgets reutilizables terminan en `Card`, `Tile`, `Button`, `Dialog`, `Sheet`, etc., según su función visual.
- Los widgets de layout se nombran descriptivamente: `MainLayout`, `AppSidebar`.

---

## 4. Estado con Riverpod

### Reglas fundamentales

1. **`ref.watch()`** solo dentro del método `build()` de un widget o de otro provider.
2. **`ref.read()`** solo dentro de callbacks (`onPressed`, `onTap`, event handlers).
3. **`ref.listen()`** para side effects (mostrar SnackBars, navegar).
4. **Nunca** almacenes `ref` en una variable de instancia del widget.
5. Usa `ConsumerWidget` o `ConsumerStatefulWidget` en lugar de `StatelessWidget`/`StatefulWidget` cuando necesites acceder a providers.

### Creación de providers

```dart
// ✅ Correcto: Provider simple para valor computado
final bpmProvider = Provider<int>((ref) {
  final signs = ref.watch(vitalSignsProvider);
  return signs.heartRate;
});

// ✅ Correcto: StateNotifierProvider para estado mutable
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// ❌ Incorrecto: Lógica de negocio dentro de un widget
class DashboardView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // NO hagas cálculos complejos aquí, delega al provider
  }
}
```

### Organización de providers

- Los providers **globales** (tema, conexión Arduino, signos vitales) van en `lib/shared/providers/`.
- Los providers **específicos de una feature** van en `lib/features/<feature>/providers/`.
- Un archivo = un provider (o un grupo cohesivo muy relacionado).

---

## 5. Widgets y UI

### Constructores `const`

```dart
// ✅ Siempre usar const donde sea posible
class VitalKpiCard extends ConsumerWidget {
  const VitalKpiCard({super.key, required this.title});
  final String title;
  // ...
}

// En el build de otro widget:
const VitalKpiCard(title: 'Frecuencia Cardíaca'),  // ← const en la instancia también
```

### Composición de widgets

- **Widgets pequeños y enfocados**: Si un método `build()` supera ~80 líneas, extrae sub-widgets en clases privadas (`_HeaderSection`, `_ChartArea`).
- **No uses funciones para construir widgets** (`Widget _buildHeader()` → crea una clase `_Header` en su lugar). Las funciones no participan en el framework de reconciliación de Flutter.
- **Siempre usa `const` en widgets hijo** que no dependan de estado dinámico.
- **Siempre define `Key`** en widgets dentro de listas o que puedan reordenarse.

### Espaciado y layout

- Usa el paquete `gap` para espaciado: `const Gap(16)` en lugar de `SizedBox(height: 16)`.
- Prefiere `Padding` con `EdgeInsets.symmetric()` o `EdgeInsets.only()` sobre `.all()` cuando no aplica a todos los lados.
- Usa los breakpoints definidos en `lib/core/constants/` para decisiones de layout responsivo.

### Colores y temas

- **Nunca** uses colores hardcodeados (`Color(0xFF...)` directo en un widget). Siempre referencia `AppColors` o `Theme.of(context)`.
- Usa `Theme.of(context).colorScheme` para colores semánticos del Material.
- Para colores de sensores específicos de la app, usa `AppColors` definidos en `lib/core/theme/app_colors.dart`.
- **No** uses `.withOpacity()` — está deprecado desde Flutter 3.44. Usa `.withValues(alpha: 0.5)`.

### Tipografía

- Usa `google_fonts` con la familia `Inter` como fuente principal.
- Para displays numéricos (BPM, SpO2%), aplica `fontFeatures: [FontFeature.tabularFigures()]` para evitar jitter visual.
- Referencia estilos de texto desde `Theme.of(context).textTheme`.

---

## 6. Navegación con GoRouter

### Reglas

- Toda la configuración de rutas está centralizada en `lib/core/router/app_router.dart`.
- Usa `ShellRoute` para layouts persistentes (sidebar, header) que no se reconstruyen al navegar.
- Los paths son en **minúsculas y con guiones**: `/vital-signs`, `/alert-history`.
- Para navegación programática, usa `context.go()` para reemplazar y `context.push()` para apilar.
- **No** uses `Navigator.push()` directamente; siempre GoRouter.

---

## 7. Rendimiento

### Reglas críticas

1. **`const` en todas partes**: Widgets, listas, maps, EdgeInsets, TextStyle — todo lo que pueda ser `const`, debe serlo.
2. **RepaintBoundary**: Envuelve widgets que se repintan frecuentemente (gráficos real-time) en `RepaintBoundary` para aislar el repintado.
3. **ListView.builder()**: Nunca uses `ListView(children: [...])` para listas largas o dinámicas. Usa siempre `.builder()` o `.separated()`.
4. **Evita rebuilds innecesarios**:
   - Extrae sub-widgets en clases separadas en lugar de métodos.
   - Usa `select()` en Riverpod para observar solo la propiedad que necesitas: `ref.watch(provider.select((s) => s.heartRate))`.
5. **Imágenes**: Usa `flutter_svg` para vectores. Para rasters, especifica `cacheWidth`/`cacheHeight` para evitar decodificación innecesaria.
6. **Dispose de recursos**: En `StatefulWidget`, siempre cancela Timers, StreamSubscriptions y AnimationControllers en `dispose()`.
7. **Evita `late` innecesario**: Solo usa `late` cuando la inicialización diferida es realmente necesaria y estás seguro de que el valor se inicializará antes de ser accedido.

---

## 8. Manejo de Errores

```dart
// ✅ Correcto: Manejo explícito de errores
try {
  await repository.fetchVitalSigns();
} on SocketException catch (e) {
  // Error de red específico
  _showConnectionError(e.message);
} on FormatException catch (e) {
  // Error de parsing
  _logParsingError(e);
} catch (e, stackTrace) {
  // Fallback genérico
  debugPrint('Error inesperado: $e\n$stackTrace');
}

// ❌ Incorrecto: catch vacío o silencioso
try {
  await repository.fetchVitalSigns();
} catch (_) {} // NUNCA hagas esto
```

### Reglas

- **Nunca** silencies excepciones con `catch (_) {}`.
- Usa `debugPrint()` en lugar de `print()` para depuración (controlado por modo de compilación).
- Para logging en producción, usa un paquete como `logger` o un servicio centralizado.
- Los providers asíncronos deben usar `AsyncValue` para representar estados de carga, éxito y error.

---

## 9. Testing

### Estructura de tests

```
test/
├── core/
│   └── theme/
│       └── app_colors_test.dart
├── features/
│   └── dashboard/
│       └── widgets/
│           └── vital_kpi_card_test.dart
└── shared/
    └── providers/
        └── vital_signs_provider_test.dart
```

### Reglas

- La estructura de `test/` debe ser un **espejo** de `lib/`.
- Cada archivo nuevo en `lib/` debe tener su correspondiente `_test.dart`.
- Usa `ProviderContainer` para testear providers en aislamiento.
- Usa `pumpWidget` con `ProviderScope.overrides` para testear widgets que dependen de providers.
- Los nombres de test deben ser descriptivos en español: `'debería mostrar el BPM actual cuando hay datos'`.

---

## 10. Dart — Buenas Prácticas Generales

### Inmutabilidad y null safety

```dart
// ✅ Preferir inmutabilidad
final heartRate = 72;          // No reasignable
const maxBpm = 200;            // Constante en tiempo de compilación

// ✅ Null safety estricto
String? nullableValue;
final length = nullableValue?.length ?? 0;  // Manejo explícito

// ❌ Evitar force unwrap sin contexto seguro
final length = nullableValue!.length;  // Solo si estás 100% seguro
```

### Colecciones

```dart
// ✅ Spread operator en lugar de addAll
final combined = [...listA, ...listB];

// ✅ Collection if/for
final widgets = [
  const Header(),
  if (showChart) const EcgChart(),
  for (final alert in alerts) AlertTile(alert: alert),
];
```

### Funciones

- Prefiere **expression bodies** (`=>`) para getters y funciones de una línea.
- Usa **named parameters** para funciones con más de 2 argumentos.
- Usa **trailing commas** en todo: listas de argumentos, listas de widgets, maps.
- Usa `required` para parámetros nombrados obligatorios.

---

## 11. Formato y Linting

### Comandos obligatorios antes de cada commit

```bash
# Formatear código (línea máxima 80 caracteres)
dart format .

# Análisis estático
flutter analyze

# Ejecutar tests
flutter test
```

### Reglas de linting activas

El proyecto usa `flutter_lints` + `riverpod_lint` + `custom_lint`. Reglas clave:

- `avoid_print` — Usar `debugPrint()` o `log()`.
- `prefer_const_constructors` — Marcar como `const` todo lo posible.
- `prefer_const_literals_to_create_immutables` — `const [1, 2, 3]` en vez de `[1, 2, 3]`.
- `sized_box_for_whitespace` — Usa `Gap()` o `SizedBox` con dimensiones explícitas.
- `use_key_in_widget_constructors` — Todo widget público debe aceptar `Key`.

**El código debe pasar `flutter analyze` sin issues antes de considerarse terminado.**

---

## 12. Documentación del Código

### Comentarios

```dart
/// Widget que muestra un KPI de signos vitales en formato tarjeta.
///
/// Acepta un [title] descriptivo y muestra el valor actual junto con
/// un indicador de tendencia basado en los últimos 10 segundos de datos.
class VitalKpiCard extends ConsumerWidget {
  // ...
}
```

### Reglas

- Usa `///` (doc comments) para clases, métodos y propiedades públicas.
- Usa `//` para comentarios inline explicando **por qué**, no **qué**.
- No comentes código obvio: `final name = 'John'; // asigna nombre` ← **NO**.
- Comenta decisiones técnicas no evidentes: `// Usamos Timer.periodic en vez de Stream para evitar backpressure en señales de alta frecuencia`.
- Toda clase pública debe tener al menos una línea de doc comment.

---

## 13. Git y Control de Versiones

### Mensajes de commit

Usar formato [Conventional Commits](https://www.conventionalcommits.org/) en español:

```
feat: agregar gráfico de SpO2 con gradiente de área
fix: corregir jitter visual en display numérico de BPM
refactor: extraer sub-widgets del dashboard en clases privadas
docs: actualizar README con instrucciones de instalación
style: aplicar dart format al módulo de alertas
test: agregar tests unitarios para VitalSignsProvider
chore: actualizar dependencias de Riverpod a 2.6.1
```

### Reglas

- **Un commit = un cambio lógico**. No mezclar features con refactors.
- No incluir archivos generados (`*.g.dart`, `*.freezed.dart`) — deben estar en `.gitignore`.
- Los archivos de plataforma (`android/`, `ios/`, `web/`) solo se modifican cuando es estrictamente necesario.

---

## 14. Seguridad

- **Nunca** hardcodees credenciales, API keys, tokens o URLs sensibles en el código fuente.
- Usa variables de entorno o archivos de configuración excluidos de git (`.env`, `--dart-define`).
- Para conexiones WebSocket con el Arduino, valida siempre los datos recibidos antes de procesarlos.
- Sanitiza cualquier input del usuario antes de mostrarlo o almacenarlo.

---

## 15. Accesibilidad (a11y)

- Usa `Semantics` widgets para dar contexto a lectores de pantalla.
- Todo `IconButton` o icono interactivo debe tener `tooltip` definido.
- Asegura suficiente contraste de color (ratio mínimo 4.5:1 para texto normal).
- Usa `ExcludeSemantics` para widgets puramente decorativos.
- Los textos importantes no deben depender solo del color para transmitir información.

---

## 16. Reglas Específicas de DataVital

### Dominio médico

- Los valores de signos vitales siempre se validan contra rangos fisiológicos:
  - FC: 30–250 BPM
  - SpO2: 70–100%
  - Temperatura: 30–45°C
- Los umbrales de alerta (zona roja/amarilla/verde) se definen en `core/constants/` y **nunca** se hardcodean en widgets.
- Los datos del paciente son sensibles: cumplir con principios HIPAA / protección de datos de salud.

### Comunicación con Arduino

- La conexión WebSocket se gestiona desde un provider centralizado en `shared/providers/`.
- El parsing de datos del Arduino se hace en un servicio dedicado, no en la UI.
- Siempre implementa reconexión automática con backoff exponencial.
- Los datos crudos del sensor se transforman a unidades médicas estándar antes de llegar a los widgets.

---

## Resumen de Principios

| #  | Principio                                    |
| -- | -------------------------------------------- |
| 1  | **const everything** — Si puede ser const, es const |
| 2  | **Feature-First** — El código vive junto a su feature |
| 3  | **Sin barrel files** — Importaciones directas al archivo |
| 4  | **Riverpod para todo el estado** — Sin setState global |
| 5  | **GoRouter para toda la navegación** — Sin Navigator directo |
| 6  | **AppColors para todos los colores** — Sin hardcoded colors |
| 7  | **flutter analyze = 0 issues** — Siempre limpio |
| 8  | **Tests como espejo de lib/** — Estructura paralela |
| 9  | **Doc comments en todo lo público** — `///` obligatorio |
| 10 | **Conventional Commits en español** — Mensajes claros |
