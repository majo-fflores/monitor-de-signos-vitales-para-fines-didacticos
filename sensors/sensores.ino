/*
  Monitor de signos vitales - Arduino MEGA 2560
  Sensores: AD8232 (ECG/QRS), HW827 (Pulso óptico), MQ-135 (Calidad de aire - COMENTADO)

  CONEXIONES:
  - AD8232 OUTPUT → A0
  - AD8232 LO+    → Pin 10  (digital input)
  - AD8232 LO-    → Pin 11  (digital input)
  - HW827 Signal  → A1
  - MQ-135 A0     → A2      (directo, sin divisor — el Mega trabaja a 5V)

  NOTA: El Mega usa ADC de 10 bits → valores de 0 a 1023 (no 4095 como el ESP32)
*/

// -------- PINES --------
#define ECG_PIN    A0
#define LO_PLUS    10
#define LO_MINUS   11
#define PULSE_PIN  A1
#define MQ135_PIN  A2

// -------- TIMING --------
#define ECG_INTERVAL_MS  15    // ~250 Hz para ver bien el QRS
#define PULSE_INTERVAL   20   // 50 Hz para pulso óptico
#define AIR_INTERVAL  2000

// -------- VARIABLES --------
unsigned long lastECG   = 0;
unsigned long lastPulse = 0;
unsigned long lastAir   = 0;

// BPM con HW827
int           pulseThreshold = 512;   // mitad del rango 10-bit (0-1023)
unsigned long lastBeat       = 0;
bool          beatDetected   = false;
int           prevPulseVal   = 0;
int           bpm            = 0;

// AIR
int   lastAirRaw     = 0;
float lastAirVoltage = 0.0f;

void setup() {
  Serial.begin(115200);

  // Wire.begin(); // Disponible en pines SDA=20, SCL=21 si se agrega pantalla OLED

  pinMode(LO_PLUS,  INPUT);
  pinMode(LO_MINUS, INPUT);

  // No imprimir texto libre: cada linea del serial debe ser un JSON valido.
}

void ecg(unsigned long now) {
  if (now - lastECG >= ECG_INTERVAL_MS) {
    lastECG = now;

    bool leadsOff = digitalRead(LO_PLUS) == HIGH || digitalRead(LO_MINUS) == HIGH;
    int ecgVal = analogRead(ECG_PIN);  // 0 a 1023

    Serial.print("{\"time_ms\":");
    Serial.print(now);
    Serial.print(",\"ecg\":");
    Serial.print(ecgVal);
    Serial.print(",\"bpm\":");
    Serial.print(bpm);
    Serial.print(",\"air_raw\":");
    Serial.print(lastAirRaw);
    Serial.print(",\"air_voltage\":");
    Serial.print(lastAirVoltage, 2);
    Serial.print(",\"leads_off\":");
    Serial.print(leadsOff ? "true" : "false");
    Serial.println("}");
  }
}

void pulsoOptico(unsigned long now) {
  if (now - lastPulse >= PULSE_INTERVAL) {
    lastPulse = now;

    int pulseVal = analogRead(PULSE_PIN);  // 0 a 1023

    // Detección de latido por flanco ascendente
    if (pulseVal > pulseThreshold && prevPulseVal <= pulseThreshold) {
      if (!beatDetected) {
        beatDetected = true;
        unsigned long intervalo = now - lastBeat;
        if (lastBeat != 0 && intervalo > 300 && intervalo < 2000) {  // 30-200 BPM válido
          bpm = 60000 / intervalo;
        }
        lastBeat = now;
      }
    } else if (pulseVal < pulseThreshold) {
      beatDetected = false;
    }
    prevPulseVal = pulseVal;
  }
}

void calidadAire(unsigned long now) {
  if (now - lastAir >= AIR_INTERVAL) {
    lastAir = now;
  
    int   rawADC  = analogRead(MQ135_PIN);           // 0 a 1023
    lastAirRaw = rawADC;
    float voltage = rawADC * (5.0f / 1023.0f);       // referencia 5V en Mega
    lastAirVoltage = voltage;
  
    // Serial.print(">>> MQ135 raw: ");
    // Serial.print(rawADC);
    // Serial.print(" | Voltaje: ");
    // Serial.print(voltage, 2);
    // Serial.println("V");
  }
}

void loop() {
  unsigned long now = millis();

  ecg(now);
  pulsoOptico(now);
  calidadAire(now);

  // El BPM se imprime junto con el ECG para no mezclar texto suelto en el Serial Plotter.
}
