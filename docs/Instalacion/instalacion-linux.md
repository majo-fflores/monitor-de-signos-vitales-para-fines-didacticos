# Guia de Instalacion de Arduino IDE en Linux (Arch y Ubuntu)

Esta guia detalla los pasos para configurar un entorno de Arduino funcional, explicando el motivo de cada accion y donde realizarla.

## 1. Instalacion de paquetes
Es necesario instalar el entorno de desarrollo y las herramientas de comunicacion para las placas.

### Arch Linux:
Ejecutar en terminal:
paru -S arduino-ide-bin arduino-cli python-pyserial esptool

### Ubuntu / Debian:
1. Descargar el IDE desde arduino.cc/en/software.
2. Ejecutar en terminal:
   sudo apt update && sudo apt install python3-serial esptool

**Por que**: `python-pyserial` y `esptool` son obligatorios para que el sistema pueda enviar el codigo a placas como ESP32 y ESP8266.

## 2. Permisos de Hardware (Grupos)
Para que el usuario pueda usar los puertos USB sin necesidad de usar sudo constantemente.

### Arch Linux:
sudo usermod -aG uucp,lock,tty $USER

### Ubuntu / Debian:
sudo usermod -aG dialout,tty $USER

**Donde**: Se ejecuta una sola vez en la terminal.
**Por que**: Por seguridad, Linux bloquea el acceso directo a hardware serial. Al añadir tu usuario a estos grupos (`uucp/dialout` para el puerto, `lock` para bloqueo de archivos y `tty` para terminales seriales), el sistema te da permiso para "hablar" con la placa.
**Nota**: Debes reiniciar el equipo para que los cambios de grupo se apliquen correctamente.

## 3. Desactivar el servicio BRLTTY
BRLTTY es un servicio para pantallas Braille que suele confundir a los Arduinos con dispositivos Braille y bloquea su puerto USB.

### Comandos para cualquier distro:
sudo systemctl mask brltty.service
sudo systemctl mask brltty-udev.service

**Por que**: Evita que el sistema "secuestre" el puerto apenas conectas la placa, lo que suele causar el error de "Puerto no encontrado" o "Dispositivo ocupado".

## 4. Solucion para Wayland (Segmentation Fault)
Si el IDE no abre o se cierra solo en entornos como Niri, GNOME Wayland o Hyprland.

**Solucion**: Forzar el uso de X11 para la plataforma Ozone de Electron.
**Donde**: Editar el archivo lanzador (desktop entry).
Archivo: `/usr/share/applications/arduino-ide-v2.desktop`
Cambiar la linea `Exec` a:
`Exec=arduino-ide --ozone-platform=x11 %U`

**Por que**: Actualmente, el motor Electron del IDE tiene problemas de estabilidad nativos en algunos compositores Wayland. Forzar X11 (via XWayland) soluciona el cierre repentino.

## 5. Configuracion de placas adicionales (ESP32 / ESP8266)
Para programar placas que no son de la marca oficial Arduino.

### Pasos en el IDE:
1. Abrir: Archivo -> Preferencias.
2. En el campo "Gestor de URLs Adicionales de Tarjetas", pegar estas direcciones:
   - ESP32: https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   - ESP8266: https://arduino.esp8266.com/stable/package_esp8266com_index.json

### Alternativa: Gestion por Terminal (CLI)
1. **Actualizar el indice**: `arduino-cli core update-index`
2. **Instalar nucleos**:
   - `arduino-cli core install esp32:esp32`
   - `arduino-cli core install esp8266:esp8266`

## Solucion de problemas
- Error de subida en ESP32: Si se queda en "Connecting...", mantén pulsado el boton BOOT de la placa hasta que veas el progreso de carga (%).
- Cable USB: Si el puerto no aparece, prueba con otro cable. Muchos son solo para carga.

## Carpetas de interes
- ~/.arduino15/: Configuracion interna y cores.
- ~/Arduino/: Tus programas y librerias.
