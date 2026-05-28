# ==============================================================================
# DATA VITAL - FRONTEND (FLUTTER) RECIPES
# ==============================================================================

# Instalar todas las dependencias pub.dev de la aplicación
front-get:
    cd app && flutter pub get

# Generar código reactivo e inmutable (Riverpod, Generated parts)
front-gen:
    cd app && dart run build_runner build --delete-conflicting-outputs

# Observar cambios en tiempo real y regenerar código automáticamente
front-watch:
    cd app && dart run build_runner watch --delete-conflicting-outputs

# ═══════════════════════════════════════════════════════════════
#  EJECUCIÓN DE DISPOSITIVOS ESPECÍFICOS (-d target)
# ═══════════════════════════════════════════════════════════════

# Ejecutar la aplicación en Escritorio Nativo Linux
front-run-linux:
    cd app && flutter run -d linux

# Ejecutar la aplicación en Escritorio Nativo Windows
front-run-windows:
    cd app && flutter run -d windows

# Ejecutar la aplicación en el navegador Chrome local
front-run-chrome:
    cd app && flutter run -d chrome

# Ejecutar la aplicación como Servidor Web Local (ideal para STR sobre red local)
front-run-web:
    cd app && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8000

# ═══════════════════════════════════════════════════════════════
#  AUDITORÍA, SANEADO Y CALIDAD
# ═══════════════════════════════════════════════════════════════

# Ejecutar el analizador de código estático (Linter de Dart 3)
front-lint:
    cd app && flutter analyze

# Formatear estéticamente todo el código de Dart
front-format:
    cd app && dart format .

# Aplicar correcciones automáticas de importaciones y sintaxis sugeridas por Dart
front-fix:
    cd app && dart fix --apply

# Limpiar caché profunda de Flutter y reinstalar dependencias
front-clean:
    cd app && flutter clean && flutter pub get

# Ejecutar las pruebas unitarias y de widgets
front-test:
    cd app && flutter test

# ═══════════════════════════════════════════════════════════════
#  COMPILACIÓN Y DISTRIBUCIÓN MULTIPLATAFORMA
# ═══════════════════════════════════════════════════════════════

# Compilar ejecutable binario nativo para Linux (Desktop release)
front-build-linux:
    cd app && flutter build linux --release

# Compilar ejecutable binario nativo para Windows (Desktop release, ofuscado)
front-build-windows:
    cd app && flutter build windows --release --obfuscate --split-debug-info=build/windows/symbols

# Compilar ejecutable binario para Android (APK release)
front-build-apk:
    cd app && flutter build apk --release

# Compilar bundle estático optimizado para producción Web
front-build-web:
    cd app && flutter build web --release
