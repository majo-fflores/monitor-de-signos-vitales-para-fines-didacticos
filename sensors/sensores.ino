/*
  Monitor de signos vitales - Arduino MEGA 2560
  Sensores:
  - AD8232 (ECG)
  - HW827 (Pulso óptico / BPM)
  - MQ135 (Calidad de aire)

  Salida por Serial en formato JSON:
  {"ecg":512,"bpm":72,"air":300,"leads_off":false}
*/

// -------- PINES --------
#define ECG_PIN    A0
#define LO_PLUS    10
#define LO_MINUS   11
#define PULSE_PIN  A1
#define MQ135_PIN  A2

// -------- TIMING --------
#define ECG_INTERVAL_MS 10
#define PULSE_INTERVAL  20
#define AIR_INTERVAL    2000

// -------- VARIABLES --------
unsigned long lastECG   = 0;
unsigned long lastPulse = 0;
unsigned long lastAir   = 0;

// BPM con HW827
int pulseThreshold = 512;
unsigned long lastBeat = 0;
bool beatDetected = false;
int prevPulseVal = 0;
int bpm = 0;

// Calidad de aire
int lastAirRaw = 0;

void setup() {
  Serial.begin(115200);

  pinMode(LO_PLUS, INPUT);
  pinMode(LO_MINUS, INPUT);
}

void ecg(unsigned long now) {
  if (now - lastECG >= ECG_INTERVAL_MS) {
    lastECG = now;

    bool leadsOff =
      digitalRead(LO_PLUS) == HIGH ||
      digitalRead(LO_MINUS) == HIGH;

    int ecgVal = analogRead(ECG_PIN);

    Serial.print("{\"ecg\":");
    Serial.print(ecgVal);

    Serial.print(",\"bpm\":");
    Serial.print(bpm);

    Serial.print(",\"air\":");
    Serial.print(lastAirRaw);

    Serial.print(",\"leads_off\":");
    Serial.print(leadsOff ? "true" : "false");

    Serial.println("}");
  }
}

void pulsoOptico(unsigned long now) {
  if (now - lastPulse >= PULSE_INTERVAL) {
    lastPulse = now;

    int pulseVal = analogRead(PULSE_PIN);

    // Detección de latido por flanco ascendente
    if (pulseVal > pulseThreshold && prevPulseVal <= pulseThreshold) {
      if (!beatDetected) {
        beatDetected = true;

        unsigned long intervalo = now - lastBeat;

        if (lastBeat != 0 &&
            intervalo > 300 &&
            intervalo < 2000) {
          bpm = 60000 / intervalo;
        }

        lastBeat = now;
      }
    }
    else if (pulseVal < pulseThreshold) {
      beatDetected = false;
    }

    prevPulseVal = pulseVal;
  }
}

void calidadAire(unsigned long now) {
  if (now - lastAir >= AIR_INTERVAL) {
    lastAir = now;

    lastAirRaw = analogRead(MQ135_PIN);
  }
}

void loop() {
  unsigned long now = millis();

  pulsoOptico(now);
  calidadAire(now);
  ecg(now);
}