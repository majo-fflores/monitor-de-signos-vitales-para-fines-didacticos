# Reglas de Gestión de Estado con Riverpod — DataVital

Este archivo define cómo se gestiona y optimiza el estado con `flutter_riverpod`.

---

## 1. Reglas fundamentales de lectura

1. **`ref.watch()`**: Utilízalo **únicamente** dentro del método `build()` de un widget (usando `ConsumerWidget` o `ConsumerStatefulWidget`) o en la definición de otro proveedor.
2. **`ref.read()`**: Utilízalo **únicamente** dentro de callbacks de eventos (ej: `onPressed`, `onTap`, handlers de timers/sockets). **Nunca** llames a `ref.read` dentro de un método `build()`, ya que no se suscribirá a cambios.
3. **`ref.listen()`**: Úsalo para disparar efectos secundarios en la UI que no requieran redibujado directo (como mostrar un `SnackBar`, un diálogo de alerta, o realizar una navegación).
4. **Guardado de referencias**: **Nunca** guardes la referencia `ref` en variables de instancia de widgets de forma persistente.

---

## 2. Optimización y Rendimiento de Reconstrucciones

En aplicaciones de bioseñales y tiempo real de alta frecuencia (como esta), la optimización del rendimiento en los rebuilds de Riverpod es crítica:

* **Suscripción Selectiva (`.select()`)**:
  * **Nunca** observes un estado complejo completo si solo necesitas una de sus propiedades.
  * **Correcto**:
    ```dart
    final nivelCo2 = ref.watch(notificadorSignosVitalesProvider.select((s) => s.nivelCo2));
    ```
  * **Incorrecto**:
    ```dart
    final estado = ref.watch(notificadorSignosVitalesProvider);
    // Redibujará el widget cada vez que cambie el pulso cardiaco (BPM) o SpO2, 
    // aunque este widget solo muestre el nivel de CO2.
    ```
* **Separación de Lógica y UI**: No realices cálculos médicos o lógicas complejas de formateo directamente en el método `build()` de los widgets. Delega los valores calculados a proveedores intermedios (`Provider`).

---

## 3. Organización de Proveedores

* **Proveedores Globales/Compartidos**: Los proveedores que representen el estado general del sistema (sensores, bioseñales del paciente, estado de conexión WebSocket) pertenecen a `lib/shared/providers/`.
* **Proveedores de Feature**: Lógicas de configuración o filtros de visualización locales viven en `lib/features/<feature>/providers/`.
