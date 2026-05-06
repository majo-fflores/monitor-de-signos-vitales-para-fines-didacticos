# Contexto del Proyecto: DataVital

## Propósito

**DataVital** es un sistema funcional de monitoreo de signos vitales diseñado con fines estrictamente **educativos y didácticos**. Sirve como interfaz de visualización para entender el funcionamiento de los biosensores y el procesamiento de señales fisiológicas. No es un dispositivo de uso clínico diagnóstico real.

## Arquitectura

*   **Frontend**: Single Page Application (SPA) construida con React, TypeScript y Vite.
*   **Comunicación**: El sistema consume datos en tiempo real de un Backend (mediante API REST para configuraciones y WebSockets para el flujo de datos en tiempo real). El backend actúa como puente de comunicación serial/inalámbrica con el hardware de adquisición (Arduino/Microcontrolador).

## Listado de Sensores y Uso

El sistema está preparado para monitorizar las siguientes variables fisiológicas provenientes del hardware:

1.  **AD8232**: Adquisición de señales eléctricas del corazón para la visualización de la curva de Electrocardiografía (ECG).
2.  **MAX30100 / HW-827**: Sensor óptico para medir la saturación de oxígeno en sangre ($SpO_2$) y la frecuencia cardíaca mediante Oximetría de pulso.
3.  **MQ-135**: Sensor de gases configurado para la detección de $CO_2$ en el aire exhalado, utilizado para simular la Capnografía.
4.  **LM386 / Sensor de Presión**: Usado para detectar las variaciones mecánicas/sonoras y calcular la frecuencia respiratoria.
5.  **Sensores de Temperatura (ej. DS18B20 o Termistores)**: Monitorización continua de la temperatura corporal.

## Requisitos Críticos

1.  **Visualización en Tiempo Real**: Curvas fisiológicas (ondas como ECG y pletismografía) deben mostrarse fluidas y sin latencia perceptible.
2.  **Datalogger**: Registro histórico de los valores mínimos y máximos de cada parámetro en la sesión actual.
3.  **Sistema de Alarmas**: Alarmas visuales y lógicas configurables (umbrales superior e inferior) para cada signo vital.
4.  **Silenciador de Alarmas**: Botón de acción rápida para silenciar o suspender el feedback de la alarma de manera temporal durante 30 segundos.
