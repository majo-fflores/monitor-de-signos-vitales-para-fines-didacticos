// ============================================================
//  Monitor Integrado ESP32
//  - AD8232  : ECG + detección de electrodos → GPIO36
//  - HW-827  : Frecuencia cardíaca (BPM)     → GPIO34
//  - MQ-135  : CO2 (PPM)                     → GPIO14
//  - OLED    : Pantalla SSD1306 128x64 I2C
// ============================================================

#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <PulseSensorPlayground.h>

// ---- Pantalla OLED ----
#define SCREEN_WIDTH  128
#define SCREEN_HEIGHT 64
#define OLED_ADDRESS  0x3C
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire);

// ---- Pines ----
#define ECG_PIN       36   // AD8232 OUTPUT  → GPIO36 (VP)
#define HRM_PIN       34   // HW-827 señal   → GPIO34
#define MQ135_PIN     14   // MQ-135 AO      → GPIO14
#define LO_MINUS_PIN  33   // AD8232 LO-     → GPIO33
#define LO_PLUS_PIN   32   // AD8232 LO+     → GPIO32

// ---- Umbrales ----
#define HRM_THRESHOLD   2200   // Umbral PulseSensor para ESP32 (ADC 0-4095)
#define MQ135_THRESHOLD 1000   // Alerta CO2 a partir de 1000 ppm
#define BPM_LOW          50    // BPM mínimo normal
#define BPM_HIGH        100    // BPM máximo normal

// ---- Intervalos ----
#define DISPLAY_INTERVAL  1000   // OLED cada 1 segundo
#define JSON_INTERVAL       10   // JSON cada 10ms
#define HRM_INTERVAL      2000   // HW-827 cada 2 segundos

// ---- PulseSensor ----
PulseSensorPlayground pulseSensor;

// ---- Variables globales ----
int  currentBPM   = 0;
int  currentPPM   = 0;
bool leadsOff     = false;
bool leadsWereOff = false;

// ---- Variables HW-827 ----
int  lastDetectedBPM = 0;
bool beatDetectedInWindow = false;

// ---- Temporización ----
unsigned long lastDisplayUpdate = 0;
unsigned long lastJsonUpdate    = 0;
unsigned long lastHRMUpdate     = 0;

// ---- Prototipos ----
void configurarPantalla();
void configurarSensores();
bool electrodosDesconectados();
void leerHW827();
void actualizarHW827Cada2Segundos();
void leerMQ135();
void mostrarDatos();
void enviarJSON(int ecgValue);
void enviarJSONNullECG();

// ============================================================
void setup() {
  Serial.begin(115200);

  pinMode(LO_MINUS_PIN, INPUT);
  pinMode(LO_PLUS_PIN,  INPUT);
  pinMode(MQ135_PIN,    INPUT);

  analogReadResolution(12);

  configurarPantalla();
  configurarSensores();

  Serial.println("{\"status\":\"Monitor iniciado\"}");
}

// ============================================================
void loop() {
  unsigned long ahora = millis();

  // --- 1. Chequear electrodos AD8232 ---
  leadsOff = electrodosDesconectados();

  if (leadsOff) {
    leadsWereOff = true;
  } else {
    if (leadsWereOff) {
      leadsWereOff = false;
      display.clearDisplay();
    }
  }

  // --- 2. Leer HW-827 constantemente, pero actualizar BPM cada 2 segundos ---
  leerHW827();
  actualizarHW827Cada2Segundos();

  // --- 3. JSON cada 10ms ---
  if (ahora - lastJsonUpdate >= JSON_INTERVAL) {
    lastJsonUpdate = ahora;

    leerMQ135();

    if (leadsOff) {
      enviarJSONNullECG();
    } else {
      int ecgValue = analogRead(ECG_PIN);
      enviarJSON(ecgValue);
    }
  }

  // --- 4. Actualizar OLED cada 1 segundo ---
  if (ahora - lastDisplayUpdate >= DISPLAY_INTERVAL) {
    lastDisplayUpdate = ahora;
    mostrarDatos();
  }
}

// ============================================================
//  FUNCIONES
// ============================================================

void configurarPantalla() {
  if (!display.begin(SSD1306_SWITCHCAPVCC, OLED_ADDRESS)) {
    Serial.println("{\"status\":\"Error OLED\"}");
    return;
  }

  delay(500);
  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print("Iniciando...");
  display.display();
  delay(1000);
}

void configurarSensores() {
  pulseSensor.analogInput(HRM_PIN);
  pulseSensor.setThreshold(HRM_THRESHOLD);

  if (pulseSensor.begin()) {
    Serial.println("{\"status\":\"HW-827 listo\"}");
  } else {
    Serial.println("{\"status\":\"Error HW-827\"}");
  }
}

bool electrodosDesconectados() {
  return digitalRead(LO_MINUS_PIN) == HIGH || digitalRead(LO_PLUS_PIN) == HIGH;
}

// Esta función se ejecuta todo el tiempo para no perder latidos
void leerHW827() {
  if (pulseSensor.sawStartOfBeat()) {
    lastDetectedBPM = pulseSensor.getBeatsPerMinute();
    beatDetectedInWindow = true;
  }
}

// Esta función actualiza el valor visible/enviado cada 2 segundos
void actualizarHW827Cada2Segundos() {
  unsigned long ahora = millis();

  if (ahora - lastHRMUpdate >= HRM_INTERVAL) {
    lastHRMUpdate = ahora;

    if (beatDetectedInWindow) {
      currentBPM = lastDetectedBPM;
    } else {
      currentBPM = 0;
    }

    beatDetectedInWindow = false;
    lastDetectedBPM = 0;
  }
}

void leerMQ135() {
  int raw = analogRead(MQ135_PIN);

  // Mapeo aproximado, no calibrado.
  // El MQ-135 no entrega PPM reales directamente.
  currentPPM = map(raw, 0, 4095, 350, 5000);
}

void enviarJSON(int ecgValue) {
  // JSON AD8232
  Serial.print("{\"sensor\":\"AD8232\",\"ecg\":");
  Serial.print(ecgValue);
  Serial.println(",\"leads_off\":false}");

  // JSON HW-827
  Serial.print("{\"sensor\":\"HW827\",\"bpm\":");
  Serial.print(currentBPM);
  Serial.print(",\"alerta\":");
  Serial.print((currentBPM > 0 && (currentBPM < BPM_LOW || currentBPM > BPM_HIGH)) ? "true" : "false");
  Serial.println("}");

  // JSON MQ-135
  Serial.print("{\"sensor\":\"MQ135\",\"co2_ppm\":");
  Serial.print(currentPPM);
  Serial.print(",\"alerta\":");
  Serial.print(currentPPM > MQ135_THRESHOLD ? "true" : "false");
  Serial.println("}");
}

void enviarJSONNullECG() {
  // JSON AD8232 desconectado
  Serial.println("{\"sensor\":\"AD8232\",\"ecg\":null,\"leads_off\":true}");

  // JSON HW-827 sigue funcionando
  Serial.print("{\"sensor\":\"HW827\",\"bpm\":");
  Serial.print(currentBPM);
  Serial.print(",\"alerta\":");
  Serial.print((currentBPM > 0 && (currentBPM < BPM_LOW || currentBPM > BPM_HIGH)) ? "true" : "false");
  Serial.println("}");

  // JSON MQ-135 sigue funcionando
  Serial.print("{\"sensor\":\"MQ135\",\"co2_ppm\":");
  Serial.print(currentPPM);
  Serial.print(",\"alerta\":");
  Serial.print(currentPPM > MQ135_THRESHOLD ? "true" : "false");
  Serial.println("}");
}

void mostrarDatos() {
  display.clearDisplay();

  // --- Línea divisoria ---
  display.drawLine(0, 32, 127, 32, SSD1306_WHITE);

  // --- Mitad superior: BPM ---
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print("PULSO (BPM)");

  display.setTextSize(2);
  display.setCursor(0, 10);

  if (currentBPM > 0) {
    display.print(currentBPM);
    display.setTextSize(1);
    display.print(" bpm");
  } else {
    display.print("0");
    display.setTextSize(1);
    display.print(" bpm");
  }

  if (currentBPM > 0 && (currentBPM < BPM_LOW || currentBPM > BPM_HIGH)) {
    display.setTextSize(1);
    display.setCursor(80, 0);
    display.print("! ALERTA");
  }

  // Aviso ECG OFF sin bloquear los otros datos
  if (leadsOff) {
    display.setTextSize(1);
    display.setCursor(80, 22);
    display.print("ECG OFF");
  }

  // --- Mitad inferior: CO2 ---
  display.setTextSize(1);
  display.setCursor(0, 34);
  display.print("CO2 (PPM)");

  display.setTextSize(2);
  display.setCursor(0, 44);
  display.print(currentPPM);
  display.setTextSize(1);
  display.print(" ppm");

  if (currentPPM > MQ135_THRESHOLD) {
    display.setTextSize(1);
    display.setCursor(80, 34);
    display.print("! ALERTA");
  }

  display.display();
}