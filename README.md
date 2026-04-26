[![Licencia](https://img.shields.io/badge/Licencia-MIT-green.svg)](LICENSE)

Los proyectos principales se encuentran en el directorio [`Modules`](Modules), donde cada caso incluye su código fuente en Verilog, banco de pruebas, Makefile y documentación específica.

## Estructura general

| Directorio | Descripción |
|------------|-------------|
| [`Modules`](Modules) | Casos principales desarrollados durante el curso. |
| [`Protocolos`](Protocolos) | Documentación de apoyo sobre protocolos de comunicación. |

## Módulos principales desarrollados

| Caso | Módulo | Ruta | Descripción |
|------|--------|------|-------------|
| Controlador de cajero automático | `Controlador` | [`Modules/Controlador_Cajero_Automatico/src/Controlador.v`](Modules/Controlador_Cajero_Automatico/src/Controlador.v) | Controlador de cajero automático implementado como máquina de estados finita. Procesa depósitos y retiros, valida PIN, maneja intentos incorrectos, bloqueo, fondos insuficientes y actualización de balance. |
| Síntesis del controlador de cajero | `Controlador` sintetizable | [`Modules/Sintesis_Controlador_Cajero/src/Controlador.v`](Modules/Sintesis_Controlador_Cajero/src/Controlador.v) | Versión del controlador utilizada para simulación RTL y síntesis con Yosys. Permite comparar el comportamiento original con implementaciones sintetizadas por defecto, con celdas CMOS y con retardos de propagación. |
| Síntesis del controlador de cajero | Script de síntesis `Controlador.ys` | [`Modules/Sintesis_Controlador_Cajero/src/Controlador.ys`](Modules/Sintesis_Controlador_Cajero/src/Controlador.ys) | Script de Yosys para leer, sintetizar y generar netlists del controlador usando la biblioteca de celdas definida para el caso. |
| Protocolo I2C | `Generator_I2C` | [`Modules/Protocolo_I2C/src/Generator_I2C.v`](Modules/Protocolo_I2C/src/Generator_I2C.v) | Módulo maestro I2C encargado de generar las condiciones de inicio/parada, la señal `SCL`, la transmisión de dirección/datos y la coordinación de ACK/NACK. |
| Protocolo I2C | `Slave_I2C` | [`Modules/Protocolo_I2C/src/Slave_I2C.v`](Modules/Protocolo_I2C/src/Slave_I2C.v) | Módulo esclavo I2C que reconoce dirección, recibe o transmite datos y controla la línea `SDA` mediante lógica triestado según el protocolo. |
| Protocolo SPI | `Master_SPI` | [`Modules/Protocolo_SPI/src/Master_SPI.v`](Modules/Protocolo_SPI/src/Master_SPI.v) | Módulo maestro SPI que genera `SCK`, `CS` y `MOSI`, y controla la comunicación síncrona en los cuatro modos del protocolo SPI mediante `CKP` y `CPH`. |
| Protocolo SPI | `Slave_1_SPI` | [`Modules/Protocolo_SPI/src/Slave_1_SPI.v`](Modules/Protocolo_SPI/src/Slave_1_SPI.v) | Primer esclavo SPI. Recibe datos desde `MOSI`, transmite por `MISO` y sincroniza el muestreo de bits con la configuración de reloj del maestro. |
| Protocolo SPI | `Slave_2_SPI` | [`Modules/Protocolo_SPI/src/Slave_2_SPI.v`](Modules/Protocolo_SPI/src/Slave_2_SPI.v) | Segundo esclavo SPI diseñado para una conexión tipo Daisy Chain, capaz de recibir, desplazar y reenviar datos dentro de la cadena. |

## Bancos de prueba y simulación

Cada caso incluye archivos de verificación para ejecutar simulaciones funcionales:

| Caso | Banco de pruebas | Tester | Makefile |
|------|------------------|--------|----------|
| Controlador de cajero automático | [`Modules/Controlador_Cajero_Automatico/src/testbench.v`](Modules/Controlador_Cajero_Automatico/src/testbench.v) | [`Modules/Controlador_Cajero_Automatico/src/tester.v`](Modules/Controlador_Cajero_Automatico/src/tester.v) | [`Modules/Controlador_Cajero_Automatico/Makefile`](Modules/Controlador_Cajero_Automatico/Makefile) |
| Síntesis del controlador de cajero | [`Modules/Sintesis_Controlador_Cajero/src/testbench.v`](Modules/Sintesis_Controlador_Cajero/src/testbench.v) | [`Modules/Sintesis_Controlador_Cajero/src/tester.v`](Modules/Sintesis_Controlador_Cajero/src/tester.v) | [`Modules/Sintesis_Controlador_Cajero/Makefile`](Modules/Sintesis_Controlador_Cajero/Makefile) |
| Protocolo I2C | [`Modules/Protocolo_I2C/src/testbench.v`](Modules/Protocolo_I2C/src/testbench.v) | [`Modules/Protocolo_I2C/src/tester.v`](Modules/Protocolo_I2C/src/tester.v) | [`Modules/Protocolo_I2C/Makefile`](Modules/Protocolo_I2C/Makefile) |
| Protocolo SPI | [`Modules/Protocolo_SPI/src/testbench.v`](Modules/Protocolo_SPI/src/testbench.v) | [`Modules/Protocolo_SPI/src/tester.v`](Modules/Protocolo_SPI/src/tester.v) | [`Modules/Protocolo_SPI/Makefile`](Modules/Protocolo_SPI/Makefile) |

Para más detalles sobre arquitectura, pruebas y resultados de simulación, consultar el `README.md` dentro de cada caso.
