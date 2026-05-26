# Importar comandos del backend desde la carpeta just
import 'just/backend.just'

# Listar todos los comandos disponibles por defecto
default:
    @just --list
