# Comunicación SPI Maestro–Esclavos en Verilog  
### Proyecto Protocolo SPI — Rodrigo E. Sánchez Araya (C37259)

## 🧩 Resumen

En este proyecto se implementó y verificó un sistema de comunicación digital basado en el protocolo **SPI** (Serial Peripheral Interface), compuesto por tres módulos principales:

- **Master_SPI** – Dispositivo maestro encargado de generar las señales de control y sincronización.
- **Slave_1_SPI** – Primer dispositivo esclavo, responsable de recibir y transmitir datos hacia el maestro.
- **Slave_2_SPI** – Segundo esclavo, diseñado para conexión en cadena (*Daisy Chain*), capaz de retransmitir datos hacia el maestro o al siguiente nodo.

El sistema fue desarrollado en **Verilog HDL** y validado mediante simulaciones funcionales en **GTKWave**, verificando la correcta transmisión y recepción de datos a través de las líneas **MOSI**, **MISO**, **SCK** y **CS**.  
Se implementaron los **cuatro modos estándar del protocolo SPI (0–3)**, ajustando dinámicamente la polaridad (**CKP**) y la fase (**CPH**) del reloj.

## ⚙️ Descripción Arquitectónica

### 🔸 Módulo `Master_SPI`
Implementa la lógica de control principal del protocolo SPI.  
Su función es generar las señales:
- **SCK:** reloj serial con 25% de la frecuencia del sistema.  
- **CS:** selección de esclavo.  
- **MOSI:** línea de transmisión de datos.

Está estructurado en torno a una **Máquina de Estados Finita (FSM)** que gestiona los estados *Idle*, *Mode Selection*, *Send Data*, *Receive Data* y *Send/Receive Data*.  
El maestro se adapta a los cuatro modos SPI según las combinaciones de `CKP` y `CPH`, garantizando la compatibilidad con diferentes dispositivos esclavos.

### 🔹 Módulo `Slave_1_SPI`
Funciona como esclavo sincronizado con la señal `SCK` del maestro.  
Recibe información por la línea `MOSI`, envía datos por `MISO`, y responde a la activación de la línea `CS`.  
Opera en los cuatro modos SPI, ajustando el muestreo de datos según la configuración de polaridad y fase.  
Utiliza registros internos (`data_in`, `data_to_send_SLAVE`) y un contador de bits (`bit_cont`) para el control de transferencia.

### 🔹 Módulo `Slave_2_SPI`
Estructura similar al `Slave_1_SPI`, pero diseñado para operar en **configuración Daisy Chain**.  
Recibe datos del esclavo anterior y los reenvía al maestro, manteniendo la coherencia del flujo de bits y la sincronización de reloj.

### 🔸 Interacción entre módulos
El sistema se compone de un maestro y dos esclavos conectados mediante las líneas compartidas `MOSI`, `MISO`, `SCK` y `CS`.  
La comunicación es completamente **síncrona**, donde el maestro transmite un bit por flanco de reloj, y los esclavos responden coordinadamente, preservando la integridad de los datos.

## 🧪 Plan de Pruebas

Se realizaron **cuatro pruebas funcionales**, una por cada modo de operación del protocolo SPI.

| # | Modo | CKP | CPH | Descripción | Resultado |
|---|------|-----|-----|--------------|------------|
| 1 | Modo 0 | 0 | 0 | Captura en flanco ascendente, reloj inactivo en bajo. | ✅ Exitoso |
| 2 | Modo 1 | 1 | 0 | Captura en flanco descendente, reloj inactivo en alto. | ✅ Exitoso |
| 3 | Modo 2 | 0 | 1 | Captura en flanco descendente, reloj inactivo en bajo. | ✅ Exitoso |
| 4 | Modo 3 | 1 | 1 | Captura en flanco ascendente, reloj inactivo en alto. | ✅ Exitoso |

Cada prueba se ejecutó en simulación con un periodo ajustado del reloj `SCK` (¼ del `CLK`) para mejorar la observación temporal en GTKWave.  
En todos los casos se validó la transmisión de los datos `00000111` (7) y `00000010` (2), y la recepción de `00000101` (5) y `00001001` (9).

## 🧰 Instrucciones de Uso

**Estructura de directorios:**
```
📁 Modules/Protocolo_SPI/
├── Makefile
├── README.md
└── src/
    ├── Master_SPI.v
    ├── Slave_1_SPI.v
    ├── Slave_2_SPI.v
    ├── tester.v
    └── testbench.v
```

**Ejecución:**
```bash
make           # Compila y simula el proyecto
make waves     # Abre las formas de onda en GTKWave
make clean-all # Limpia archivos generados
```

## 📈 Resultados

Las simulaciones demostraron:
- Sincronización completa entre maestro y esclavos.
- Transmisión estable y sin errores lógicos.
- Adaptabilidad total a los cuatro modos SPI.
- Coordinación correcta entre `SCK`, `MOSI`, `MISO` y `CS`.

Las señales fueron coloreadas en GTKWave para facilitar su análisis:  
🟧 **Master**, 🟣 **Slave 1**, 🟩 **Slave 2**.

## 🧩 Conclusiones

El sistema desarrollado permitió comprender de manera práctica el funcionamiento del protocolo **SPI**, la sincronización maestro–esclavo y el diseño de controladores secuenciales en hardware digital.  
Los resultados obtenidos demostraron la correcta implementación multi–modo y la estabilidad del sistema frente a cambios de polaridad y fase del reloj.

## 💡 Recomendaciones

- Documentar las simulaciones en **GTKWave**, resaltando las fases de envío y recepción.  
- Mantener una codificación modular y comentada en los archivos **Verilog**.  
- Realizar pruebas adicionales con más esclavos en cadena para evaluar la escalabilidad.  
- Implementar el diseño en **FPGA** para validar su comportamiento en tiempo real.

**Autor:** Rodrigo E. Sánchez Araya — *C37259*  
**Profesor:** Enrique Coen Alfaro  
**Curso:** IE0408 – Laboratorio de Electrónica II  
**Fecha:** Octubre 2025
