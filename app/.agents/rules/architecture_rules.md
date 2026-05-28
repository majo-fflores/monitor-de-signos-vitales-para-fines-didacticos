# Reglas de Arquitectura y Estructura — DataVital (Flutter)

Este archivo define las convenciones de organización de archivos e infraestructura del proyecto.

---

## 1. Arquitectura Feature-First

El proyecto sigue una estructura **Feature-First** con una separación estricta de responsabilidades por módulos funcionales:

```text
lib/
├── main.dart                     # Entrada de la App + ProviderScope
├── core/                         # Infraestructura global compartida (solo lectura)
│   ├── constants/                # Constantes globales (no de UI)
│   ├── router/                   # Configuración central de GoRouter
│   └── theme/                    # AppColors, AppTheme y estilos base
├── features/                     # Características aisladas de la app
│   ├── dashboard/                # Panel principal
│   │   └── widgets/              # Widgets exclusivos de este feature
│   ├── settings/                 # Configuraciones
│   └── history/                  # Historiales y reportes
└── shared/                       # Componentes compartidos reutilizados por 2 o más features
    ├── providers/                # Proveedores globales de estado (ej: vital_signs_provider)
    └── widgets/                  # Widgets comunes (layouts, chips de estado, etc.)
```

### Reglas Clave:
* **`core/` es de solo infraestructura**: No debe contener lógica de negocio, providers del dominio, ni widgets de UI interactivos.
* **Módulos aislados**: Los widgets específicos de una característica de la app deben vivir dentro de `features/<nombre>/widgets/`. No los expongas en `shared/` a menos que sean consumidos literalmente por dos o más módulos diferentes.
* **Código compartido**: Si un widget o proveedor es común y consumido por múltiples features, pertenece a `shared/`.

---

## 2. Convenciones de Importación

* **Sin Barrel Files**: **Nunca** crees o utilices archivos `index.dart` que agrupen y re-exporten directorios completos (barrel files). Esto causa dependencias circulares complejas y dificulta la detección de ciclos de compilación estática.
* **Importaciones directas**: Importa siempre el archivo concreto de forma explícita.
* **Importaciones relativas vs paquete**:
  * Para archivos dentro del mismo feature, utiliza **rutas relativas** (ej: `import 'vital_kpi_card.dart';` o `import '../widgets/badge.dart';`).
  * Para infraestructura global (`core/`) o compartida (`shared/`), utiliza **importaciones absolutas** del paquete (ej: `import 'package:datavital_flutter/core/theme/app_colors.dart';`).
