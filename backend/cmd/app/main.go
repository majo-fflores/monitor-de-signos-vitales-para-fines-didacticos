package main

import (
	"backend/cmd/database"
	"backend/internal/air"
	"backend/internal/bpm"
	"backend/internal/ecg"
	"backend/internal/sensors"
	"backend/internal/sessions"
	"backend/internal/spo2"
	"backend/internal/users"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
	"github.com/labstack/echo/v5"
	"github.com/labstack/echo/v5/middleware"
)

func main() {
	// Cargar variables de entorno desde el archivo .env si existe
	if err := godotenv.Load(); err != nil {
		log.Println("Aviso: No se pudo cargar el archivo .env, usando variables del entorno del sistema")
	}

	// Inicializar Base de Datos
	database.InitDB()

	// Migrar modelos
	if err := database.DB.AutoMigrate(
		&users.User{},
		&sessions.Session{},
		&bpm.BpmMeasurement{},
		&ecg.EcgMeasurement{},
		&air.AirMeasurement{},
		&spo2.Spo2Measurement{},
	); err != nil {
		log.Fatalf("Error al realizar la auto-migración: %v", err)
	}

	// ─── ¡ACÁ TIENE QUE IR! ──────────────────────────────────────────
	// Inicializar la capa de servicio de usuarios (fuera del bloque de error)
	users.ServiceInstance = users.NewService(database.DB)
	spo2.ServiceInstance = spo2.NewSpo2Service(database.DB)
	ecg.ServiceInstance = ecg.NewEcgService(database.DB)
	bpm.ServiceInstance = bpm.NewBpmService(database.DB)
	air.ServiceInstance = air.NewAirService(database.DB)
	sessions.ServiceInstance = sessions.NewSessionService(database.DB)

	serialPort := os.Getenv("SERIAL_PORT")
	if serialPort == "" {
		serialPort = "/dev/ttyUSB0"
	}

	source, err := sensors.NewSerialArduino(serialPort)
	if err != nil {
		log.Printf("Aviso: No se pudo abrir el puerto serial %s: %v. Usando Arduino simulado.", serialPort, err)
		source = sensors.NewSimulatedArduino()
	}
	sensors.GlobalManager = sensors.NewManager(source)
	go sensors.GlobalManager.StartBackgroundListening()
	// ─────────────────────────────────────────────────────────────────

	// Inicializar servidor Echo
	e := echo.New()

	// Middlewares
	e.Use(middleware.RequestLogger())
	e.Use(middleware.Recover())

	// Ruta raíz para verificación simple
	e.GET("/", func(c *echo.Context) error {
		return c.JSON(http.StatusOK, map[string]string{
			"message": "Servidor Go con Echo y GORM funcionando correctamente!",
		})
	})

	// Rutas de API para Usuarios usando la función limpia
	users.RegisterUserRoutes(e)

	// Rutas de API para Sensores (WebSockets y otros)
	sensors.RegisterSensorRoutes(e)

	spo2.RegisterSpo2Routes(e)

	ecg.RegisterEcgRoutes(e)
	bpm.RegisterBpmRoutes(e)
	air.RegisterAirRoutes(e)

	sessions.RegisterSessionRoutes(e)

	// Iniciar servidor en el puerto configurado
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Servidor corriendo en el puerto: %s", port)
	if err := e.Start(":" + port); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Error al iniciar el servidor: %v", err)
	}
}
