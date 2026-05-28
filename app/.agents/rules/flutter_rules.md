# Guía de Reglas de Desarrollo — DataVital (Agentes AI)

Este directorio define las directrices, estándares de diseño y reglas de rendimiento específicas para el desarrollo en **DataVital**. 

Para evitar saturación de contexto y mantener las instrucciones legibles y enfocadas, las reglas han sido segmentadas en archivos de especialidad altamente cohesivos:

---

## 🗂️ Índice de Reglas de Agente

1. 🏗️ **[Reglas de Arquitectura y Estructura](file:///home/lk/Proyectos/STR/DataVital/app/.agents/rules/architecture_rules.md)**: Estructura Feature-First, importaciones directas (sin barrel files) y distribución de archivos.
2. 🎛️ **[Reglas de Gestión de Estado (Riverpod)](file:///home/lk/Proyectos/STR/DataVital/app/.agents/rules/riverpod_rules.md)**: Lectura de providers (`watch` vs `read`), reconstrucciones selectivas utilizando `.select()` y optimización ante alta frecuencia.
3. 🎨 **[Reglas de UI, Estilo y Diseño Premium](file:///home/lk/Proyectos/STR/DataVital/app/.agents/rules/ui_rules.md)**: Uso de HSL y AppColors (sin hardcoding), reemplazo de opacidad obsoleta, tipografía sin vibraciones (*Tabular Figures*) y preferencia de clases de Widget sobre métodos.
4. 🩺 **[Reglas del Dominio Clínico y Tiempo Real](file:///home/lk/Proyectos/STR/DataVital/app/.agents/rules/datavital_domain_rules.md)**: Rangos fisiológicos de bioseñales, arquitectura de red WebSocket, procesamiento por lotes (*batch rendering* a 80ms) y persistencia del simulador.

---

> [!IMPORTANT]
> **Antes de realizar cualquier modificación en el frontend**, lee y aplica estrictamente la directriz correspondiente a la feature que estás editando. Tu código final siempre debe pasar el comando `flutter analyze` con **cero advertencias o errores**.
