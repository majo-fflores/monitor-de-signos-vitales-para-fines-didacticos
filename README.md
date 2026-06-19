# DataVital

Plataforma didactica para el monitoreo, adquisicion y visualizacion de bioseñales en tiempo real. Combina sensores biomedicos, un backend local y una aplicacion de escritorio multiplataforma.

> **Aviso**: Este sistema es exclusivamente academico. No debe usarse para diagnostico, monitoreo clinico ni toma de decisiones medicas.

---

## Arquitectura

```text
Sensores -> Microcontrolador -> microSD (datalogger)
                    |
                    v
            Backend (Go + Echo)
                    |
                    v
              SQLite (local)
                    |
                    v
          App DataVital (Flutter)
```

| Capa | Tecnologia | Responsabilidad |
|------|-----------|-----------------|
| Firmware | Arduino / ESP32 | Adquisicion de sensores, registro en SD, OLED, alarma fisica |
| Backend | Go 1.26, Echo v5, GORM | API REST, WebSocket, comunicacion con firmware, persistencia |
| Base de datos | SQLite | Pacientes, sesiones, mediciones, umbrales, eventos de alarma |
| Frontend | Flutter (Dart 3), Riverpod, GoRouter | Dashboard en tiempo real, historial, configuracion, alertas |

---

## Requisitos previos

- [Go](https://go.dev/dl/) >= 1.26
- [Flutter](https://docs.flutter.dev/get-started/install) >= 3.12 (canal stable)
- [Just](https://github.com/casey/just#installation) (command runner)
- [Inno Setup 6](https://jrsoftware.org/isinfo.php) (solo para generar el instalador de Windows)

---

## Inicio rapido

```bash
# 1. Clonar el repositorio
git clone https://github.com/UNTDF-Sistemas-de-Tiempo-Real/DataVital.git
cd DataVital

# 2. Configurar el backend
just setup

# 3. Instalar dependencias del frontend
just front-get

# 4. Generar codigo de Riverpod
just front-gen

# 5. Ejecutar backend y frontend
just run-backend          # Terminal 1
just front-run-windows    # Terminal 2 (o front-run-linux)
```

---

## Estructura del proyecto

```text
DataVital/
├── app/                   # Aplicacion Flutter (frontend)
│   ├── lib/
│   │   ├── core/          # Tema, router, constantes
│   │   ├── features/      # Modulos funcionales
│   │   │   ├── alerts/    # Sistema de alarmas
│   │   │   ├── dashboard/ # Visualizacion en tiempo real
│   │   │   ├── history/   # Historial de mediciones
│   │   │   ├── sessions/  # Sesiones de monitoreo
│   │   │   ├── settings/  # Configuracion de umbrales
│   │   │   └── users/     # Gestion de usuarios/pacientes
│   │   └── shared/        # Providers, widgets y utilidades comunes
│   ├── windows/           # Configuracion nativa Windows e instalador
│   └── pubspec.yaml
├── backend/               # Servidor Go con Echo
│   ├── cmd/app/           # Punto de entrada principal
│   ├── internal/          # Logica de negocio (users, sensors)
│   └── .env.example       # Variables de entorno de referencia
├── sensors/               # Firmware y sketches de sensores (pendiente)
├── docs/                  # Documentacion tecnica y anteproyecto
├── just/                  # Archivos de recetas Just
│   ├── backend.just
│   └── frontend.just
└── justfile               # Punto de entrada de Just
```

---

## Comandos Just

### Backend

| Comando | Descripcion |
|---------|-------------|
| `just run-backend` | Ejecuta el backend en modo desarrollo |
| `just build` | Compila el backend |
| `just setup` | Copia `.env.example`, compila y descarga dependencias |
| `just tidy` | Organiza y limpia dependencias de Go |
| `just test` | Ejecuta las pruebas del backend |
| `just clean` | Elimina el binario compilado |

### Frontend

| Comando | Descripcion |
|---------|-------------|
| `just front-get` | Instala dependencias de pub.dev |
| `just front-gen` | Genera codigo de build_runner (Riverpod) |
| `just front-watch` | Observa cambios y regenera codigo automaticamente |
| `just front-run-windows` | Ejecuta en escritorio nativo Windows |
| `just front-run-linux` | Ejecuta en escritorio nativo Linux |
| `just front-run-chrome` | Ejecuta en navegador Chrome |
| `just front-run-web` | Ejecuta como servidor web en `0.0.0.0:8000` |
| `just front-lint` | Analisis estatico de codigo |
| `just front-format` | Formatea codigo Dart |
| `just front-fix` | Aplica correcciones automaticas de Dart |
| `just front-clean` | Limpia cache y reinstala dependencias |
| `just front-test` | Ejecuta pruebas unitarias y de widgets |

### Compilacion

| Comando | Descripcion |
|---------|-------------|
| `just front-build-windows` | Compila release para Windows (ofuscado) |
| `just front-build-linux` | Compila release para Linux |
| `just front-build-apk` | Compila APK para Android |
| `just front-build-web` | Compila bundle de produccion web |
| `just build-linux-appimage` | Compila Backend y Frontend, y genera AppImage para Linux |

---

## Generacion del instalador (Windows)

El instalador se genera con [Inno Setup 6](https://jrsoftware.org/isinfo.php) a partir del archivo `app/windows/installer.iss`.

1. Compilar la aplicacion:
   ```bash
   just front-build-windows
   ```
2. Abrir **Inno Setup Compiler**, cargar `app/windows/installer.iss` y presionar `Ctrl+F9`.
   - Alternativa por consola (si ISCC esta en el PATH): `ISCC app/windows/installer.iss`

El instalador listo para distribuir se genera en:

```text
app/build/windows/x64/runner/Release/DataVital-Installer.exe
```

Este unico archivo `.exe` contiene todo lo necesario para instalar la aplicacion. Es el archivo que se comparte con los usuarios finales.

---

## Variables de entorno

Copiar `backend/.env.example` a `backend/.env` y configurar:

| Variable | Descripcion | Valor por defecto |
|----------|-------------|-------------------|
| `PORT` | Puerto del servidor HTTP | (requerido) |
| `DB_PATH` | Ruta del archivo SQLite | `./cmd/database/gorm.db` |

---

## Documentacion adicional

- [Documentacion tecnica completa](docs/docs.md) -- Sensores, protocolo de comunicacion, modelo de dominio, plan de pruebas
- [Diagrama de modelo de dominio](docs/diagram.plantuml)
- [Anteproyecto (PDF)](docs/Monitor%20de%20Signos%20Vitales%20para%20fines%20did%C3%A1cticos%20-%20Anteproyecto.pdf)
- [README del frontend](app/README.md)
- [README del backend](backend/README.md)

---

## Licencia

Proyecto academico desarrollado en el marco de la materia Sistemas de Tiempo Real -- UNTDF.
