# Reporte Tarea 2

**Estudiante:** Rodrigo E. Sánchez Araya. C37259  
**Profesor:** Enrique Coen Alfaro  
**Fecha:** Septiembre 2025

## Resumen

Se implementó la etapa de síntesis del diseño utilizado en la tarea 1, generando versiones sintetizadas del controlador utilizando celdas CMOS y considerando retardos de propagación. Esto permitió evaluar el comportamiento del circuito a nivel de puertas lógicas y verificar su funcionalidad bajo condiciones más cercanas a la implementación física. La síntesis facilitó la generación de netlists optimizados y archivos listos para una posterior implementación en hardware, asegurando que la lógica diseñada en RTL se mantiene correcta y eficiente tras la conversión a nivel de celdas.

## Descripción Arquitectónica

Se mantiene el planteamiento arquitectónico planteado para la tarea 1.

### Diagrama ASM

En el diagrama ASM se muestra la distribución de toma de decisiones a lo largo del transcurso del programa así como las salidas que se generarán dada una cierta combinación de entradas o condiciones internas.

## Plan de Pruebas

1. **Prueba 1. Depósito simple**
   - **RESULTADO:** Exitoso para simulación default, fallido para la síntesis Default, fallido síntesis con librería CMOS y exitoso para la prueba con retardo.

2. **Prueba 2. Retiro simple**
   - **RESULTADO:** Exitoso para simulación default, síntesis Default, síntesis con librería CMOS y con retardo.

3. **Prueba 3. Fondos insuficientes**
   - **RESULTADO:** Exitoso para simulación default, síntesis Default, síntesis con librería CMOS y con retardo.

4. **Prueba 4. PIN incorrecto**
   - **RESULTADO:** Exitoso para simulación default, síntesis Default, síntesis con librería CMOS y con retardo.

5. **Prueba 5. Realizar 1 depósito y retiro seguidos**
   - **RESULTADO:** Exitoso para todas las simulaciones. Ver tiempos: Del segundo 920 al 1255 en GTKWave.

6. **Prueba 6. Reinicio de CONT_ERRORES**
   - **RESULTADO:** Exitoso para todas las simulaciones. Ver tiempos: Del segundo 1255 al 1880 en GTKWave.

7. **Prueba 7. Reset forzado durante una operación**
   - **RESULTADO:** Exitoso para todas las simulaciones. Ver tiempos: Del segundo 1880 al 2280 en GTKWave.

## Estructura del Proyecto

```
Directorio/Carpeta
├── Makefile
├── src/
│   ├── Controlador.v
│   ├── testbench.v
│   ├── Controlador.ys
│   └── tester.v
└── Archivos_Sintesis/
    ├── cmos_cells.v
    ├── cmos_cells_ret.v
    └── cmos_cells.lib
```

## Instrucciones de Utilización

### Comandos de Ejecución

```bash
# Entrar al directorio del proyecto
cd /Sist.Digitales2/Tarea2

# 1. Simulación RTL original
make all

# 2. Simulación de síntesis CMOS (ejecuta primero Yosys con Controlador.ys)
make cmos

# 3. Simulación de síntesis por defecto (ejecuta Yosys read_verilog, synth y write_verilog)
make def

# 4. Simulación de síntesis con retardos (ejecuta primero Yosys con Controlador.ys)
make ret

# 5. Limpiar archivos de simulación
make clean

# 6. Limpiar archivos de síntesis
make clean-synth

# 7. Limpieza completa
make clean-all
```

### Targets del Makefile

- **`make all`** o **`make`**: Simulación RTL original
- **`make cmos`**: Simulación de síntesis CMOS
- **`make def`**: Simulación de síntesis por defecto
- **`make ret`**: Simulación de síntesis con retardos
- **`make clean`**: Elimina archivos de simulación y temporales
- **`make clean-synth`**: Elimina archivos de síntesis generados
- **`make clean-all`**: Limpieza completa (simulación + síntesis)

## Evaluación del Diseño

### Síntesis por defecto de Yosys

| Elemento      | Cantidad |
|---------------|----------|
| $and          | 373      |
| $logic_not    | 87       |
| $mux          | 95       |
| $not          | 551      |
| $or           | 364      |
| $xor          | 198      |

### Síntesis utilizando librería cmos_cells.lib

| Elemento | Cantidad |
|----------|----------|
| DFF      | 103      |
| NAND     | 864      |
| NOR      | 816      |
| NOT      | 299      |

### Retardo de propagación

Se logra apreciar el retardo entre las entradas y salidas del sistema. El diseño está hecho para dar salidas cada flanco del reloj positivo, por ende se compara el reloj con una salida (ej: BALANCE_STB) para medir los retardos de propagación.

Los retardos configurados en `cmos_cells_ret.v` son:
- **BUF**: 0.2ns
- **NOT**: 0.1ns  
- **NAND**: 0.3ns
- **NOR**: 0.3ns
- **DFF**: 0.5ns

## Conclusiones

El plan de pruebas permitió validar el funcionamiento del sistema al utilizar distintos mecanismos de síntesis, sometiendo a pruebas el archivo generado por Yosys.

La síntesis con Yosys, tanto por defecto como utilizando la librería `cmos_cells.lib` y considerando retardos, permitió analizar el comportamiento del diseño a nivel de puertas lógicas y celdas CMOS. Se observó una optimización en el número de celdas y una correcta propagación de señales, lo que facilita una futura implementación física del sistema.

### Recomendaciones

- Es recomendable documentar cuidadosamente cada prueba en GTKWave y mantener un registro de los tiempos de simulación para facilitar la evaluación de retardos y comportamiento del sistema.
- Mantener consistencia en la codificación y nombres de señales y variables, lo que facilita la comprensión del diseño y la detección de errores durante la síntesis y la depuración.

## Archivos Importantes

- **`Controlador.v`**: Código RTL principal del controlador
- **`Controlador.ys`**: Script de síntesis para Yosys
- **`cmos_cells_ret.v`**: Librería de celdas CMOS con retardos
- **`testbench.v`**: Banco de pruebas principal
- **`Makefile`**: Automatización de compilación y simulación