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

# Empaquetar ejecutable para Windows (A Implementar)
build-windows-exe:
    @echo "Comando para compilar el instalador Inno Setup de Windows (Próximamente)"

# Empaquetar ejecutable para Android (A Implementar)
build-android-apk:
    @echo "Comando para generar el APK (Próximamente)"
