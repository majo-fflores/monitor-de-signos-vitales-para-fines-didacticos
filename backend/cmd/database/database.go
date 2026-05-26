package database

import (
	"log"
	"os"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

// InitDB inicializa la conexión con SQLite usando una ruta configurable.
func InitDB() {
	// Intentamos leer la ruta desde las variables de entorno (.env)
	dbPath := os.Getenv("DB_PATH")

	// Si no está definida en el .env, usamos "gorm.db" por defecto en la raíz
	if dbPath == "" {
		dbPath = "gorm.db"
	}

	var err error
	// Abrimos la base de datos con la ruta resuelta
	DB, err = gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		log.Fatalf("Error al conectar a la base de datos (%s): %v", dbPath, err)
	}

	log.Printf("Conexión a la base de datos establecida en: %s", dbPath)
}
