# ==============================================================================
# DATA VITAL - DISTRIBUCIÓN Y EMPAQUETADO FINAL
# ==============================================================================

# Empaquetar la aplicación completa (Backend + Frontend) en un AppImage nativo de Linux
build-linux-appimage:
    @echo "Compilando Backend (Go)..."
    mkdir -p build/linux/dist/app
    cd backend && go build -o ../build/linux/dist/datavital-backend ./cmd/app
    @echo "Compilando Frontend (Flutter)..."
    cd app && flutter build linux --release
    cp -r app/build/linux/x64/release/bundle/* build/linux/dist/app/
    @echo "Preparando estructura AppDir..."
    echo '#!/bin/bash' > build/linux/dist/AppRun
    echo 'DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"' >> build/linux/dist/AppRun
    echo '"$DIR/datavital-backend" &' >> build/linux/dist/AppRun
    echo 'BACKEND_PID=$!' >> build/linux/dist/AppRun
    echo 'sleep 1' >> build/linux/dist/AppRun
    echo '"$DIR/app/DataVital"' >> build/linux/dist/AppRun
    echo 'kill $BACKEND_PID' >> build/linux/dist/AppRun
    chmod +x build/linux/dist/AppRun
    echo -e "[Desktop Entry]\nType=Application\nName=DataVital\nExec=AppRun %F\nIcon=DataVital\nCategories=Utility;" > build/linux/dist/DataVital.desktop
    cp app/web/icons/Icon-maskable-512.png build/linux/dist/DataVital.png
    mkdir -p build/linux/dist/usr/share/applications
    cp build/linux/dist/DataVital.desktop build/linux/dist/usr/share/applications/
    mkdir -p build/linux/dist/usr/share/icons/hicolor/512x512/apps
    cp app/web/icons/Icon-maskable-512.png build/linux/dist/usr/share/icons/hicolor/512x512/apps/DataVital.png
    @echo "Generando AppImage..."
    wget -qO appimagetool https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x appimagetool
    ARCH=x86_64 ./appimagetool build/linux/dist/ build/linux/DataVital-linux-x86_64.AppImage
    rm -f appimagetool
    @echo "¡AppImage generado exitosamente en build/linux/DataVital-linux-x86_64.AppImage!"

# Compilar Backend + Frontend y ensamblar la distribución para Windows
build-windows-exe:
    @echo "═══════════════════════════════════════════════════════════"
    @echo " DataVital - Build Windows (Backend + Frontend)"
    @echo "═══════════════════════════════════════════════════════════"
    @echo ""
    @echo "[1/4] Compilando Backend (Go con CGO)..."
    mkdir -p build/windows/dist
    cd backend && CGO_ENABLED=1 go build -ldflags="-H windowsgui" -o ../build/windows/dist/datavital-backend.exe ./cmd/app
    @echo "[2/4] Compilando Frontend (Flutter Windows release)..."
    cd app && flutter build windows --release --obfuscate --split-debug-info=build/windows/symbols
    @echo "[3/4] Ensamblando distribución..."
    cp -r app/build/windows/x64/runner/Release/* build/windows/dist/
    @echo "[4/4] Verificando archivos..."
    @test -f build/windows/dist/DataVital.exe && echo "   ✓ DataVital.exe" || (echo "   ✗ DataVital.exe NO ENCONTRADO" && exit 1)
    @test -f build/windows/dist/datavital-backend.exe && echo "   ✓ datavital-backend.exe" || (echo "   ✗ datavital-backend.exe NO ENCONTRADO" && exit 1)
    @echo ""
    @echo "═══════════════════════════════════════════════════════════"
    @echo " ¡Build exitoso! Distribución en: build/windows/dist/"
    @echo "═══════════════════════════════════════════════════════════"

# Generar el instalador completo de Windows con Inno Setup (requiere Inno Setup 6)
build-windows-installer: build-windows-exe
    @echo ""
    @echo "[+] Generando instalador con Inno Setup..."
    @ISCC_PATH=""; \
    for p in "/c/Program Files (x86)/Inno Setup 6/ISCC.exe" "/c/Program Files/Inno Setup 6/ISCC.exe" "${LOCALAPPDATA}/Programs/Inno Setup 6/ISCC.exe" "/c/Users/luka-/AppData/Local/Programs/Inno Setup 6/ISCC.exe"; do \
        if [ -f "$p" ]; then \
            ISCC_PATH="$p"; \
            break; \
        fi; \
    done; \
    if [ -z "$ISCC_PATH" ]; then \
        if command -v ISCC.exe >/dev/null 2>&1; then \
            ISCC_PATH="ISCC.exe"; \
        else \
            echo "Error: No se encontró el compilador ISCC.exe de Inno Setup 6 en rutas comunes."; \
            exit 1; \
        fi; \
    fi; \
    "$ISCC_PATH" app/windows/installer.iss
    @echo ""
    @echo "═══════════════════════════════════════════════════════════"
    @echo " ¡Instalador generado exitosamente!"
    @echo " Archivo: build/windows/dist/DataVital-Installer.exe"
    @echo "═══════════════════════════════════════════════════════════"

# Empaquetar ejecutable para Android (A Implementar)
build-android-apk:
    @echo "Comando para generar el APK (Próximamente)"

