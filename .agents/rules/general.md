# Reglas de Desarrollo: DataVital

Este documento define las mejores prácticas y convenciones obligatorias para el desarrollo del monitor multiparamétrico **DataVital**.

## Técnicas

*   **Componentes Funcionales (Functional Components)**: Utilizar siempre componentes funcionales de React (`const Component = () => {}`). No usar componentes de clase.
*   **Custom Hooks**: Toda la lógica compleja, especialmente la relacionada con la adquisición de datos de los sensores, debe extraerse a Custom Hooks (ej. `useECGData`, `useAlarms`).
*   **Inmutabilidad**: Mantener la inmutabilidad de los datos en el estado (`useState`, `useReducer`). No mutar arrays u objetos directamente.
*   **Tipado Estricto y Buenas Prácticas (TypeScript)**: 
    *   **Prohibición de `any`**: Está **ESTRICTAMENTE PROHIBIDO** el uso de `any` en todo el proyecto. Si un tipo es desconocido temporalmente, usar `unknown` y realizar aserciones de tipo (Type Guards).
    *   **Interfaces y Types**: Todo debe estar fuertemente tipado. Preferir `interface` para la definición de objetos y entidades, y `type` para uniones, tuplas y tipos primitivos.
    *   **Retorno de Funciones**: Es obligatorio tipar explícitamente el valor de retorno de todas las funciones y Custom Hooks, ya que mejora la inferencia y previene errores silenciosos.
    *   **Tipos Genéricos Nombrados**: Fomentar el uso de Genéricos en utilidades compartidas y hooks. Sin embargo, está prohibido nombrarlos con una simple letra como `<T>`, `<U>` o `<V>`. Se deben utilizar nombres descriptivos (ej. `<TSensorData>`, `<TResponsePayload>`) para mejorar la legibilidad y el contexto.

## Performance (Tiempo Real Blando)

*   **Memoización**: Dado el flujo constante de datos, es crítico optimizar las re-renderizaciones. Utilizar `React.memo` en componentes de presentación (como las gráficas de alta frecuencia).
*   **Gestión de Dependencias**: Tener especial cuidado con los arrays de dependencias en `useMemo` y `useCallback` para no generar renders innecesarios o ciclos infinitos.
*   **Renderizado de Gráficas**: Las actualizaciones de los canvas o librerías de gráficos deben estar desacopladas del estado general de React siempre que sea posible, utilizando referencias (`useRef`) para el pintado directo.

## Arquitectura

*   **SOLID y DRY**: Seguir los principios SOLID. No repetir código (DRY), abstrayendo la lógica común en `src/shared`.
*   **Separación de Preocupaciones**: Mantener una separación clara entre la lógica de adquisición de datos (Servicios/Hooks) y la presentación (Componentes UI). Los componentes UI deben ser lo más *tontos* (dumb components) posible.

## UX Médica

*   **Alta Visibilidad**: Asegurar un alto contraste utilizando la paleta de colores del tema.
*   **Tipografía Monoespaciada**: Usar *siempre* tipografía monoespaciada (`font-mono`) para los valores numéricos y lecturas en tiempo real. Esto evita el salto horizontal de los números ("jitter").
*   **Feedback de Alarmas**: El feedback ante situaciones de alarma debe ser inmediato y muy visible (ej. parpadeo de color rojo, sonidos).

## Gestión de Color (Regla Estricta)

*   **Variables CSS**: Está **estrictamente prohibido** hardcodear colores en los componentes (ej. `bg-[#ff0000]` o `text-gray-900`).
*   **Uso del Tema**: Todos los colores deben usar las clases de Tailwind que referencian al tema definido en `tailwind.config.js` y `index.css` (ej. `bg-background`, `text-primary`, `bg-destructive`).

## Estado Global y Resiliencia

*   **Zustand sobre Context API**: Para la gestión de estados globales que cambian con alta frecuencia (como configuraciones de sensores o triggers de alarmas) se **debe utilizar Zustand**. Está estrictamente prohibido usar `React Context` para datos en tiempo real debido a las cascadas de renderizado que provoca en toda la aplicación.
*   **Resiliencia de WebSockets**: La capa de servicios (`src/core/websocket`) debe implementar mecanismos de reconexión automática (backoff exponencial) ante caídas del hardware. La UI debe reaccionar claramente a los 4 estados de red: `connecting`, `connected`, `error` y `disconnected`.

## Calidad de Código y CI Local

*   **Pre-Commit Hooks obligatorios**: Nadie puede comitear código roto. Existe una validación estricta configurada que impedirá cualquier `git commit` si el código no pasa el formateo, el linter (sin `any`, sin arrays de dependencias rotos) y el chequeo estricto de tipos de TypeScript (`typecheck`).
