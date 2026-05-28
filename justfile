# Importar comandos del backend y frontend desde la carpeta just
import 'just/backend.just'
import 'just/frontend.just'

# Listar todos los comandos disponibles por defecto
default:
    @just --list
