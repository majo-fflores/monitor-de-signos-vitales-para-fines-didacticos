# DataVital - Frontend Multiplataforma

DataVital es un monitor multiparamétrico de signos vitales diseñado con fines educativos y didácticos. Sirve como interfaz de visualización en tiempo real para entender el funcionamiento de biosensores y el procesamiento de señales fisiológicas (como electrocardiografía y oximetría de pulso).

Esta aplicación está construida con **Flutter** y **Dart**, y soporta compilaciones nativas para **Web**, **Android**, **iOS** y **Desktop (Linux, macOS, Windows)**.

---

## 🚀 Instalación de Flutter

Sigue estos pasos para configurar tu entorno y poder ejecutar la aplicación:

### Método Recomendado (Arch Linux / CachyOS)
Instala las dependencias y el SDK de Flutter directamente con el gestor de paquetes de tu sistema:
```bash
# 1. Instalar dependencias del sistema y el SDK de Flutter
sudo pacman -S curl git unzip xz zip mesa libglu flutter

# 2. Agregar el SDK al PATH de tu shell (si aplica)
fish_add_path /usr/bin/flutter
```

### Método Manual (Vía VS Code)
1.  Abre VS Code e instala la extensión oficial de **Flutter** desde el marketplace.
2.  Presiona `Ctrl + Shift + P` para abrir la paleta de comandos.
3.  Escribe `Flutter: New Project` y presiona Enter.
4.  Selecciona la opción **Download SDK** (Descargar SDK) en el aviso emergente y elige una ruta local conveniente (por ejemplo, `~/development/`).
5.  Una vez finalizada la descarga, haz clic en **Add SDK to PATH** en la notificación para registrar el entorno automáticamente.
6.  Si utilizas Fish shell, agrega la ruta manualmente:
    ```fish
    fish_add_path ~/development/flutter/bin
    ```

---

## 🛠️ Comandos Útiles

A continuación se listan los comandos principales para desarrollar, auditar y compilar el proyecto:

### Desarrollo y Ejecución
*   **Instalar Dependencias**:
    ```bash
    flutter pub get
    ```
*   **Ejecutar en Modo Desarrollo (Hot Reload habilitado)**:
    ```bash
    flutter run -d chrome    # Para ejecutar en el navegador
    # O también:
    flutter run -d linux     # Para compilar de forma nativa en Linux
    flutter run -d android   # Para ejecutar en un dispositivo o emulador Android
    ```

### Auditoría y Calidad (Análisis Estático)
*   **Analizar el Código (Buscar Errores, Warnings y Buenas Prácticas)**:
    ```bash
    flutter analyze
    ```
    *Este comando actúa como nuestro linter y typechecker estricto. Debe dar siempre un reporte limpio (`No issues found!`) antes de realizar commits.*

### Generación de Código Reactivo
*   **Generar Archivos Reactivos de Riverpod (`g.dart`)**:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
    *Se utiliza cuando creas o modificas anotaciones `@riverpod` en los proveedores para autogenerar las clases de soporte correspondientes.*

### Compilación para Producción
*   **Compilar para la Web (Genera archivos SPA optimizados en `build/web`)**:
    ```bash
    flutter build web --release
    ```
*   **Compilar para Linux Desktop Nativo (Genera archivos en `build/linux`)**:
    ```bash
    flutter build linux --release
    ```
*   **Compilar para Android (Genera un App Bundle `.aab` optimizado para Google Play)**:
    ```bash
    flutter build appbundle
    ```

---

## 🏗️ Estructura del Código Fuente

El código se organiza bajo el directorio `/lib` siguiendo la convención moderna **Feature-First** (por Funcionalidades):

```text
lib/
├── core/
│   ├── theme/             # Colores (app_colors.dart) y ThemeData (app_theme.dart)
│   ├── router/            # Enrutador declarativo GoRouter (app_router.dart)
│   └── constants/         # Breakpoints responsivos para diseño adaptativo
├── features/
│   ├── dashboard/         # Tablero en tiempo real con widgets KPI y curvas biométricas
│   ├── alerts/            # Sistema y vistas de alertas
│   ├── history/           # Auditoría de registros históricos
│   └── settings/          # Umbrales y configuración de biosensores
└── shared/
    ├── providers/         # Gestión de estados reactivos y simulación biométrica (Riverpod)
    └── widgets/           # Shell Layout unificado (MainLayout, Sidebar, Header, etc.)
```
