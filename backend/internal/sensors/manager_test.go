package sensors

import (
	"fmt"
	"testing"
	"time"
)

// mockDataSource es un origen de datos predecible para realizar pruebas
type mockDataSource struct {
	packets []ArduinoPacket
	index   int
}

func (m *mockDataSource) ReadPacket() (ArduinoPacket, error) {
	if m.index >= len(m.packets) {
		time.Sleep(100 * time.Millisecond)
		return ArduinoPacket{}, fmt.Errorf("no hay mas datos")
	}
	
	p := m.packets[m.index]
	m.index++
	return p, nil
}

func (m *mockDataSource) Close() error {
	return nil
}

func TestManagerSession(t *testing.T) {
	// 1. Arrange: Configuramos un mock con los paquetes exactos que queremos probar
	mockSource := &mockDataSource{
		packets: []ArduinoPacket{
			{Type: "bpm", Value: 82},
			{Type: "spo2", Value: 97},
			{Type: "ecg", Value: 0.76},
			{Type: "bpm", Value: 85}, // Mandamos un segundo BPM para comprobar
		},
	}

	manager := NewManager(mockSource)

	// Iniciamos la goroutine de lectura de forma independiente
	go manager.StartBackgroundListening()

	// 2. Act: Iniciamos la sesión para que comience a guardar los datos en memoria
	manager.StartSession()

	// Le damos a la goroutine 50 milisegundos para que tenga tiempo de 
	// procesar los 4 paquetes que enviamos por el mock (los cuales lee al instante)
	time.Sleep(50 * time.Millisecond)

	// Finalizamos la sesión y obtenemos el resultado
	sessionData := manager.StopSession()

	// 3. Assert: Comprobamos que todos los datos hayan sido guardados de la forma esperada
	if sessionData == nil {
		t.Fatalf("se esperaba SessionData pero se obtuvo nil")
	}

	// Comprobar los BPM (Deberían ser 2 muestras)
	if len(sessionData.BPM) != 2 {
		t.Errorf("se esperaban 2 muestras de BPM, se obtuvieron %d", len(sessionData.BPM))
	} else {
		if sessionData.BPM[0].Value != 82 {
			t.Errorf("primer BPM incorrecto, esperado 82, obtenido %f", sessionData.BPM[0].Value)
		}
		if sessionData.BPM[1].Value != 85 {
			t.Errorf("segundo BPM incorrecto, esperado 85, obtenido %f", sessionData.BPM[1].Value)
		}
	}

	// Comprobar la muestra de SpO2
	if len(sessionData.SpO2) != 1 {
		t.Errorf("se esperaba 1 muestra de SpO2, se obtuvieron %d", len(sessionData.SpO2))
	} else if sessionData.SpO2[0].Value != 97 {
		t.Errorf("SpO2 incorrecto, esperado 97, obtenido %f", sessionData.SpO2[0].Value)
	}

	// Comprobar la muestra de ECG
	if len(sessionData.ECG) != 1 {
		t.Errorf("se esperaba 1 muestra de ECG, se obtuvieron %d", len(sessionData.ECG))
	} else if sessionData.ECG[0].Value != 0.76 {
		t.Errorf("ECG incorrecto, esperado 0.76, obtenido %f", sessionData.ECG[0].Value)
	}

	// Comprobar que a cada uno se le ha asignado un timestamp mayor a cero
	if sessionData.BPM[0].Timestamp == 0 {
		t.Errorf("se esperaba un timestamp mayor a 0")
	}
}
