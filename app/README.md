# DataVital - Frontend

## Tecnologias Usadas

* Flutter (Dart)
* Riverpod (State Management)
* GoRouter (Navigation)
* fl_chart (Data Visualization)
* SharedPreferences (Local Storage)

## Estructura de Carpetas

```text
lib/
├── core/                  # Configuracion global de la aplicacion (theme, router, constants)
├── features/              # Funcionalidades de la aplicacion
│   ├── alerts/            # Modulo de alertas de bioseñales
│   ├── dashboard/         # Modulo de visualizacion en tiempo real
│   ├── history/           # Modulo de historial clinico
│   ├── sessions/          # Modulo de sesiones de medicion
│   ├── settings/          # Modulo de configuracion de umbrales
│   └── users/             # Modulo de gestion de usuarios/pacientes
└── shared/                # Recursos y logica compartida
    ├── providers/         # Providers globales (Riverpod)
    ├── utils/             # Helpers compartidos (pdf, etc)
    └── widgets/           # Widgets comunes y layout de la interfaz
```

## Comandos Just


| Comando | Descripcion |
|---------|-------------|
| `just front-get` | Instala las dependencias del proyecto |
| `just front-gen` | Genera codigo reactivo de build_runner |
| `just front-watch` | Observa cambios y regenera codigo en tiempo real |
| `just front-run-linux` | Ejecuta la aplicacion en modo nativo Linux |
| `just front-run-windows` | Ejecuta la aplicacion en modo nativo Windows |
| `just front-run-chrome` | Ejecuta la aplicacion en navegador Chrome |
| `just front-run-web` | Ejecuta la aplicacion como servidor web local en puerto 8000 |
| `just front-lint` | Analiza el codigo estaticamente (linter) |
| `just front-format` | Formatea el codigo Dart |
| `just front-fix` | Aplica correcciones automaticas de Dart |
| `just front-clean` | Limpia la cache de Flutter y reinstala dependencias |
| `just front-test` | Ejecuta las pruebas unitarias y de widgets |
| `just front-build-linux` | Compila ejecutable nativo para Linux |
| `just front-build-windows` | Compila ejecutable nativo para Windows (ofuscado) |
| `just front-build-apk` | Compila la APK para Android |
| `just front-build-web` | Compila el bundle de produccion Web |

## Generación del Instalador (Inno Setup)

Para compilar el instalador `.exe` independiente en Windows:

1. Compila la app ejecutando `just front-build-windows`.
2. Abre la aplicación **Inno Setup Compiler** en Windows, carga el archivo installer.iss y presiona **Compile** (Ctrl+F9).
   * *O por consola con:* `ISCC app/windows/installer.iss` (si tienes el compilador de Inno Setup en el PATH).

El instalador `DataVital-Installer.exe` se generará en la carpeta `build/windows/x64/runner/Release/`.
