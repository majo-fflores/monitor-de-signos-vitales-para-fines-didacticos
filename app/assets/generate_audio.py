import os
import math
import struct
import wave

def generate_intermittent_beep(filename, freq=1000, duration=4.8, beep_len=0.15, silence_len=0.15, volume=0.5, rate=44100):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as w:
        # Mono, 2 bytes por muestra, 44100 Hz
        w.setparams((1, 2, rate, 0, 'NONE', 'not compressed'))
        
        beep_samples = int(beep_len * rate)
        silence_samples = int(silence_len * rate)
        cycle_samples = beep_samples + silence_samples
        
        # Envolvente de 10ms (0.01s) de fade-in y fade-out para evitar clics / pops
        fade_samples = min(int(0.01 * rate), beep_samples // 2)
        
        total_samples = int(duration * rate)
        for i in range(total_samples):
            pos_in_cycle = i % cycle_samples
            if pos_in_cycle < beep_samples:
                # Generar el tono senoidal
                val_sin = math.sin(2.0 * math.pi * freq * i / rate)
                
                # Aplicar fade-in y fade-out lineal en los bordes del beep
                factor = 1.0
                if pos_in_cycle < fade_samples:
                    factor = pos_in_cycle / fade_samples
                elif pos_in_cycle > (beep_samples - fade_samples):
                    factor = (beep_samples - pos_in_cycle) / fade_samples
                
                val = int(32767.0 * volume * val_sin * factor)
            else:
                val = 0
            w.writeframes(struct.pack('h', val))
    print(f"Generado con loop y fade continuo: {filename}")

# Definir la ruta relativa de salida
audio_dir = os.path.join(os.path.dirname(__file__), 'audio')

# 1. Alarma Clásica: Pitido intermitente estándar (1000 Hz, beeps de 0.15s, silencios de 0.15s, 16 ciclos exactos = 4.8s)
generate_intermittent_beep(
    os.path.join(audio_dir, 'alarma_clasica.wav'),
    freq=1000,
    duration=4.8,
    beep_len=0.15,
    silence_len=0.15,
    volume=0.4
)

# 2. Alarma Urgente: Pitido rápido y agudo (1500 Hz, beeps de 0.08s, silencios de 0.08s, 30 ciclos exactos = 4.8s)
generate_intermittent_beep(
    os.path.join(audio_dir, 'alarma_urgente.wav'),
    freq=1500,
    duration=4.8,
    beep_len=0.08,
    silence_len=0.08,
    volume=0.5
)

# 3. Alarma Suave: Tono más grave y lento (500 Hz, beeps de 0.4s, silencios de 0.3s, 7 ciclos exactos = 4.9s)
generate_intermittent_beep(
    os.path.join(audio_dir, 'alarma_suave.wav'),
    freq=500,
    duration=4.9,
    beep_len=0.4,
    silence_len=0.3,
    volume=0.3
)
