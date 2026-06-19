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

	// Si no está definida en el .env, usamos ~/.datavital/gorm.db
	if dbPath == "" {
		home, err := os.UserHomeDir()
		if err == nil {
			configDir := home + "/.datavital"
			os.MkdirAll(configDir, 0755)
			dbPath = configDir + "/gorm.db"
		} else {
			dbPath = "gorm.db"
		}
	}

	var err error
	// Abrimos la base de datos con la ruta resuelta
	DB, err = gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		log.Fatalf("Error al conectar a la base de datos (%s): %v", dbPath, err)
	}

	log.Printf("Conexión a la base de datos establecida en: %s", dbPath)
}
