# DataVital - Frontend

DataVital es un monitor multiparamétrico de signos vitales desarrollado con fines educativos. Es una SPA (Single Page Application) construida con React y TypeScript, diseñada para consumir datos en tiempo real provenientes de un puente backend conectado a un Arduino.

## Requisitos Previos

- Node.js (v18+)
- npm

## Inicialización y Ejecución

1. Clonar el repositorio y navegar a este directorio.
2. Instalar las dependencias:
   ```bash
   npm install
   ```
3. Configurar las variables de entorno. Copiar el archivo de ejemplo y ajustar las URLs si es necesario:
   ```bash
   cp .env.example .env.local
   ```
4. Iniciar el servidor de desarrollo:
   ```bash
   npm run dev
   ```

## Comandos Útiles

El proyecto cuenta con estrictas reglas de código (pre-commit hooks) basadas en Biome y TypeScript. Puedes ejecutar estas validaciones manualmente:

- **Servidor de Desarrollo**: `npm run dev`
- **Formatear Código**: `npm run format` (Utiliza Biome para formatear todo el proyecto rápidamente).
- **Validar Linting**: `npm run lint` (Utiliza ESLint para validar reglas de React y Custom Hooks).
- **Validar Tipos**: `npm run typecheck` (Ejecuta el compilador de TypeScript para buscar errores de tipado sin compilar).
- **Construir Producción**: `npm run build`

## Reglas de Desarrollo y Arquitectura

Es **obligatorio** para todos los desarrolladores o agentes de IA que colaboren en este proyecto leer y adherirse a las reglas establecidas en:

- [Contexto del Proyecto](./agents/context.md)
- [Reglas de Desarrollo](./agents/rules/regla1.md)

Estas reglas definen la arquitectura, el manejo estricto de colores y el enfoque en el rendimiento crítico necesario para procesar señales fisiológicas en tiempo real.
