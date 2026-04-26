[![Licencia](https://img.shields.io/badge/Licencia-MIT-green.svg)](LICENSE)
# Sistemas_Digitales_2-IE0523

En este repositorio se almacena el trabajo realizado en el curso **IE-0523 Sistemas Digitales II**.  
Los proyectos principales se encuentran en el directorio [`Tareas`](Tareas), donde cada tarea incluye su código fuente en Verilog, banco de pruebas, Makefile y documentación específica.

## Estructura general

| Directorio | Descripción |
|------------|-------------|
| [`Tareas`](Tareas) | Proyectos y entregas principales desarrolladas durante el curso. |
| [`Clases`](Clases) | Ejemplos, apuntes y pruebas realizadas durante las clases. |
| [`Protocolos`](Protocolos) | Documentación de apoyo sobre protocolos de comunicación. |

## Módulos principales desarrollados

| Tarea | Módulo | Ruta | Descripción |
|-------|--------|------|-------------|
| Tarea 1 | `Controlador` | [`Tareas/Tarea_1/src/Controlador.v`](Tareas/Tarea_1/src/Controlador.v) | Controlador de cajero automático implementado como máquina de estados finita. Procesa depósitos y retiros, valida PIN, maneja intentos incorrectos, bloqueo, fondos insuficientes y actualización de balance. |
| Tarea 2 | `Controlador` sintetizable | [`Tareas/Tarea_2/src/Controlador.v`](Tareas/Tarea_2/src/Controlador.v) | Versión del controlador utilizada para simulación RTL y síntesis con Yosys. Permite comparar el comportamiento original con implementaciones sintetizadas por defecto, con celdas CMOS y con retardos de propagación. |
| Tarea 2 | Script de síntesis `Controlador.ys` | [`Tareas/Tarea_2/src/Controlador.ys`](Tareas/Tarea_2/src/Controlador.ys) | Script de Yosys para leer, sintetizar y generar netlists del controlador usando la biblioteca de celdas definida para la tarea. |
| Tarea 4 | `Generator_I2C` | [`Tareas/Tarea_4/src/Generator_I2C.v`](Tareas/Tarea_4/src/Generator_I2C.v) | Módulo maestro I2C encargado de generar las condiciones de inicio/parada, la señal `SCL`, la transmisión de dirección/datos y la coordinación de ACK/NACK. |
| Tarea 4 | `Slave_I2C` | [`Tareas/Tarea_4/src/Slave_I2C.v`](Tareas/Tarea_4/src/Slave_I2C.v) | Módulo esclavo I2C que reconoce dirección, recibe o transmite datos y controla la línea `SDA` mediante lógica triestado según el protocolo. |
| Tarea 5 | `Master` | [`Tareas/Tarea_5/src/Master.v`](Tareas/Tarea_5/src/Master.v) | Módulo maestro SPI que genera `SCK`, `CS` y `MOSI`, y controla la comunicación síncrona en los cuatro modos del protocolo SPI mediante `CKP` y `CPH`. |
| Tarea 5 | `Slave_1` | [`Tareas/Tarea_5/src/Slave_1.v`](Tareas/Tarea_5/src/Slave_1.v) | Primer esclavo SPI. Recibe datos desde `MOSI`, transmite por `MISO` y sincroniza el muestreo de bits con la configuración de reloj del maestro. |
| Tarea 5 | `Slave_2` | [`Tareas/Tarea_5/src/Slave_2.v`](Tareas/Tarea_5/src/Slave_2.v) | Segundo esclavo SPI diseñado para una conexión tipo Daisy Chain, capaz de recibir, desplazar y reenviar datos dentro de la cadena. |

## Bancos de prueba y simulación

Cada tarea incluye archivos de verificación para ejecutar simulaciones funcionales:

| Tarea | Banco de pruebas | Tester | Makefile |
|-------|------------------|--------|----------|
| Tarea 1 | [`Tareas/Tarea_1/src/testbench.v`](Tareas/Tarea_1/src/testbench.v) | [`Tareas/Tarea_1/src/tester.v`](Tareas/Tarea_1/src/tester.v) | [`Tareas/Tarea_1/Makefile`](Tareas/Tarea_1/Makefile) |
| Tarea 2 | [`Tareas/Tarea_2/src/testbench.v`](Tareas/Tarea_2/src/testbench.v) | [`Tareas/Tarea_2/src/tester.v`](Tareas/Tarea_2/src/tester.v) | [`Tareas/Tarea_2/Makefile`](Tareas/Tarea_2/Makefile) |
| Tarea 4 | [`Tareas/Tarea_4/src/testbench.v`](Tareas/Tarea_4/src/testbench.v) | [`Tareas/Tarea_4/src/tester.v`](Tareas/Tarea_4/src/tester.v) | [`Tareas/Tarea_4/Makefile`](Tareas/Tarea_4/Makefile) |
| Tarea 5 | [`Tareas/Tarea_5/src/testbench.v`](Tareas/Tarea_5/src/testbench.v) | [`Tareas/Tarea_5/src/tester.v`](Tareas/Tarea_5/src/tester.v) | [`Tareas/Tarea_5/Makefile`](Tareas/Tarea_5/Makefile) |

Para más detalles sobre arquitectura, pruebas y resultados de simulación, consultar el `README.md` dentro de cada tarea.
