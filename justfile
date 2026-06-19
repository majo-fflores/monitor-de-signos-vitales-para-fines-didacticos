set shell := ["C:\\Program Files\\Git\\bin\\sh.exe", "-cu"]

# Importar comandos del backend y frontend desde la carpeta just
import 'just/backend.just'
import 'just/frontend.just'
import 'just/build.just'

# Listar todos los comandos disponibles por defecto
default:
    @just --list
