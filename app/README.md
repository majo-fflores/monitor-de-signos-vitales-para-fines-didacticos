# DataVital - Frontend Multiplataforma

DataVital es un monitor multiparamétrico de signos vitales diseñado con fines educativos y didácticos. Sirve como interfaz de visualización en tiempo real para entender el funcionamiento de biosensores y el procesamiento de señales fisiológicas (como electrocardiografía y oximetría de pulso).

Esta aplicación está construida con **Flutter** y **Dart**, y soporta compilaciones nativas para **Web**, **Android**, **iOS** y **Desktop (Linux, macOS, Windows)**.

---

## 🚀 Instalación y Configuración del Entorno

Sigue las instrucciones según tu sistema operativo para dejar tu entorno listo para ejecutar y compilar la aplicación:

###  Windows (Host para compilar .exe)
1. **Descargar el SDK**: Descarga el archivo zip de Flutter desde la [web oficial de Flutter](https://docs.flutter.dev/get-started/install/windows) y extráelo en una carpeta local (ej: `C:\development\flutter`).
2. **Configurar el PATH**:
   * Busca *"Editar las variables de entorno del sistema"* en el menú Inicio de Windows.
   * Haz clic en *Variables de entorno*.
   * En *Variables de usuario*, busca la variable `Path`, selecciónala y haz clic en *Editar*.
   * Añade una nueva línea con la ruta completa a la carpeta bin del SDK (ej: `C:\development\flutter\bin`).
3. **Instalar Herramientas de Compilación C++**:
   * Descarga e instala [Visual Studio Community](https://visualstudio.microsoft.com/es/downloads/).
   * Durante la instalación, selecciona obligatoriamente la carga de trabajo: **"Desarrollo para el escritorio con C++"** (Desktop development with C++). Esto es necesario para compilar el binario nativo de Windows.
4. **Verificar**: Abre una terminal (PowerShell o CMD) y corre:
   ```bash
   flutter doctor
   ```

### 🐧 Linux (Host para compilar binario de Linux)
1. **Instalar dependencias del sistema**:
   * **Arch Linux / CachyOS**:
     ```bash
     sudo pacman -S curl git unzip xz zip mesa libglu flutter
     ```
   * **Ubuntu / Debian**:
     ```bash
     sudo apt update
     sudo apt install -y clang cmake dbus-1-dev libgtk-3-dev liblzma-dev ninja-build pkg-config unzip xz-utils zip
     ```
2. **Configurar el PATH**:
   * **Fish shell**:
     ```fish
     fish_add_path /usr/bin/flutter # Si lo instalaste vía pacman
     # O si descargaste el SDK manualmente:
     fish_add_path ~/development/flutter/bin
     ```
   * **Bash (`~/.bashrc`) / Zsh (`~/.zshrc`)**:
     ```bash
     echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
     source ~/.bashrc
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
    flutter run -d linux     # Para compilar y ejecutar nativo en Linux
    flutter run -d windows   # Para compilar y ejecutar nativo en Windows
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

### 📖 Generación de Documentación Automática
*   **Generar Documentación en HTML (para el API y clases del código)**:
    ```bash
    dart doc .
    ```
    *Este comando escanea todos los comentarios de documentación de tres barras (`///`) y genera un sitio web estático interactivo en la carpeta `doc/api/` con la referencia completa y cruzada de clases, métodos, widgets y proveedores del proyecto.*

    Para ejecutar la documentación localmente:
    ```bash
    npx serve doc/api
    # o bien abrirlo de forma directa:
    xdg-open doc/api/index.html
    ```

### Compilación para Producción (Distribución)
*   **Compilar para Linux Desktop (Nativo)**:
    ```bash
    flutter build linux --release
    ```
    *Genera la carpeta `build/linux/x64/release/bundle/`. Para distribuirla debes comprimir toda esa carpeta (debe llevar el ejecutable `datavital_flutter` junto con las carpetas de soporte `lib/` y `data/`).*

*   **Compilar para Windows Desktop (Nativo)**:
    ```bash
    flutter build windows --release
    ```
    *Genera la carpeta `build\windows\x64\runner\Release\`. Al igual que en Linux, debes comprimir toda la carpeta (contiene el archivo `.exe` junto a los archivos `.dll` y la carpeta `data/` de soporte).*

*   **Compilar para la Web (Genera archivos SPA optimizados en `build/web`)**:
    ```bash
    flutter build web --release
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
