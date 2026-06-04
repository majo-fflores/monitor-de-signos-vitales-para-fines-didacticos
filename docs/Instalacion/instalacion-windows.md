# Guia de Instalacion de Arduino IDE en Windows

Esta guia detalla los pasos para configurar un entorno de Arduino funcional en Windows, incluyendo los drivers necesarios para placas clonadas y ESP32/ESP8266.

## 1. Instalacion del IDE
1. Descargar el instalador (.exe) desde la web oficial: arduino.cc/en/software.
2. Ejecutar el instalador y aceptar todas las solicitudes de instalacion de drivers de Windows.
3. Al finalizar, abrir el IDE. Las placas oficiales (Uno, Mega) deberian reconocerse automaticamente.

## 2. Instalacion de Drivers (Para ESP32, ESP8266 y clones)
Si al conectar la placa no aparece ningun puerto en Herramientas > Puerto, es necesario instalar el driver del chip puente USB-Serie.

### A. Chip CP2102 / CP2104 (Silicon Labs)
Comun en placas ESP32 y NodeMCU de alta calidad.
1. Descargar "CP210x Windows Drivers" de la web de Silicon Labs.
2. Descomprimir y ejecutar CP210xVCPInstaller_x64.exe.
3. Reiniciar el equipo si es necesario.

### B. Chip CH340 / CH341 (WCH)
Comun en placas baratas y NodeMCU V3.
1. Descargar CH341SER.EXE de la web de WCH (wch-ic.com).
2. Ejecutar y pulsar el boton "Install".
3. Aparecera un mensaje de "Driver install success!".

## 3. Configuracion de Placas en el IDE
Para habilitar placas ESP:
1. Ir a Archivo > Preferencias.
2. En "Gestor de URLs Adicionales de Tarjetas" añadir:
   - ESP32: https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   - ESP8266: https://arduino.esp8266.com/stable/package_esp8266com_index.json
3. Ir a Herramientas > Placa > Gestor de tarjetas, buscar "esp32" o "esp8266" e instalar.

## 4. Solucion a problemas comunes
- El puerto no aparece: Probar con otro cable USB. Muchos cables micro-USB son "solo carga" y no tienen hilos de datos.
- Error de subida (Connecting...): Si el IDE se queda intentando conectar, mantener presionado el boton "BOOT" de la placa hasta que empiece el porcentaje de carga.
- Error de puerto ocupado: Cerrar otros programas que puedan estar usando el puerto (como monitores serie externos).
- Triangulo amarillo en Administrador de dispositivos: Indica que el driver no se instalo bien. Reinstalar el driver CH340 o CP2102 segun corresponda.

## Carpetas de interes en Windows
- Documentos\Arduino: Carpeta por defecto para tus proyectos y librerias.
- %LocalAppData%\Arduino15: Carpeta oculta donde se guardan los indices de placas y cores instalados.
