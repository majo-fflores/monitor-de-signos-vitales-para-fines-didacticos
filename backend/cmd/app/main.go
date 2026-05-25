package main

import (
	"log"
	"net/http"
	"sist-inteligentes/cmd/database"
	"sist-inteligentes/internal/users"

	"github.com/labstack/echo/v5"
	"github.com/labstack/echo/v5/middleware"
)

func main() {
	// Inicializar Base de Datos
	database.InitDB()

	// Migrar modelos
	if err := database.DB.AutoMigrate(&users.User{}); err != nil {
		log.Fatalf("Error al realizar la auto-migración: %v", err)
	}

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

	// Rutas de API para Usuarios
	e.POST("/users", users.CreateUser)
	e.GET("/users", users.GetUsers)
	e.GET("/users/:id", users.GetUser)

	// Iniciar servidor en el puerto 8080
	if err := e.Start(":8080"); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Error al iniciar el servidor: %v", err)
	}
}
