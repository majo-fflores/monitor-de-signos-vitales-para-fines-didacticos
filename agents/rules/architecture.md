# Arquitectura: Feature-Based

Este proyecto sigue una arquitectura **Feature-Based** (Basada en Funcionalidades). Esto significa que el código se organiza por módulos funcionales del dominio (ej. `ecg`, `oximetry`) en lugar de agruparse por tipo técnico (todos los componentes juntos, todos los hooks juntos).

## Estructura de Directorios

La carpeta `src/` se divide en las siguientes áreas principales:

- `/features`: Contiene los dominios principales de la aplicación.
- `/shared`: Contiene código reutilizable a través de diferentes features.
- `/core`: Contiene la configuración global e infraestructura.
- `/assets`: Contiene recursos estáticos como imágenes y estilos globales.

## Anatomía de una Feature

Cada feature bajo `src/features/` es un ecosistema autónomo. Debe exponer una interfaz pública (a través de su `index.ts`) y ocultar sus detalles internos. 

Ejemplo de estructura para la feature `ecg`:

```text
src/features/ecg/
├── components/          # Componentes UI exclusivos de esta feature
│   ├── EcgChart.tsx
│   └── EcgWidget.tsx
├── hooks/               # Custom Hooks con la lógica de negocio de la feature
│   └── useEcgData.ts
├── services/            # Llamadas a API, WebSockets o lógica externa
│   └── ecgWebSocket.ts
├── types/               # Interfaces y tipos de TypeScript de la feature
│   └── ecg.types.ts
└── index.ts             # Archivo de barril (Barrel File) que exporta lo público
```

### Reglas para crear archivos en una Feature

1. **`components/`**: Los componentes aquí solo deben ser usados dentro de esta feature o exportados en el `index.ts` si otra feature los necesita.
2. **`hooks/`**: Deben encapsular el estado y la lógica. Los componentes de UI solo deben llamar a estos hooks.
3. **`services/`**: Se encargan de la capa de red o infraestructura pura (ej. un manejador de WebSocket para el ECG).
4. **`types/`**: Todas las interfaces de dominio para esta feature.
5. **`index.ts`**: Es el único punto de entrada válido. **Regla de oro**: Una feature externa no puede importar directamente desde `features/ecg/components/...`. Debe hacerlo desde `features/ecg`.

## ¿Qué va en `/shared`?

Si un componente, hook o utilidad se usa en **más de una feature**, debe moverse a `src/shared/`.
Ejemplos: 
- Un componente `<Card />` genérico.
- Un hook `useWebSocket()` genérico que luego es usado por `ecg` y `oximetry`.

## ¿Qué va en `/core`?

El núcleo que inicializa la aplicación:
- Clientes HTTP/WebSocket globales.
- Proveedores de Contexto raíz (`ThemeProvider`, `StoreProvider`).
- Constantes globales de la aplicación.
