# Proyecto I2C – Tarea 4

**Estudiante:** Rodrigo E. Sánchez Araya – C37259  
**Profesor:** Enrique Coen Alfaro  
**Fecha:** Octubre 2025  

---

## 📘 Resumen
Este proyecto implementa y verifica un sistema de comunicación basado en el protocolo **I2C**, compuesto por dos módulos principales desarrollados en **Verilog**:

- **Generator I2C (Maestro):** encargado de generar las señales de reloj (SCL) y datos (SDA).
- **Slave I2C (Esclavo):** receptor de datos y encargado de responder mediante señales de confirmación (ACK/NACK).

El sistema fue validado mediante simulaciones funcionales, demostrando un comportamiento estable, sincronizado y conforme al estándar I2C durante operaciones de lectura, escritura, reinicio y direccionamiento no coincidente.

---

## 🧩 Descripción Arquitectónica

### 🔹 Módulo Generator I2C (Maestro)
Implementa la lógica de control del bus I2C, generando las condiciones de inicio (*Start*) y parada (*Stop*), y manejando las fases de transmisión:

- **FSM principal:** controla los estados *Idle, Start, Address Transmission, ACK Wait, Data Transmission* y *Stop*.  
- **Registros internos:** almacenan los bytes a enviar.  
- **Generador de reloj:** divide la frecuencia del sistema para producir la señal SCL.  
- **Lógica combinacional:** determina el valor de SDA según el estado actual y los datos.

Este módulo orquesta la comunicación, garantizando la temporización correcta entre maestro y esclavo.

### 🔹 Módulo Slave I2C (Esclavo)
Funciona como receptor y transmisor de datos según las órdenes del maestro:

- **FSM interna:** regula el comportamiento ante cambios en SCL y SDA.  
- **Estados principales:** *Idle, Address Recognition, ACK Generation, Data Reception, Data Transmission* y *Stop Detection*.  
- **Registros:** almacenan la dirección y datos temporales.  
- **Lógica triestado:** controla el acceso a la línea SDA según el protocolo.

Su arquitectura modular facilita la integración con microcontroladores u otros sistemas digitales compatibles con I2C.

---

## 🔗 Interacción entre Módulos
El maestro y el esclavo se comunican a través de las líneas **SCL** y **SDA** compartidas.  
El **Generator I2C** inicia la comunicación, mientras que el **Slave I2C** responde cuando su dirección coincide, confirmando los bytes con ACK.  
Este diseño modular permite múltiples dispositivos en el mismo bus, manteniendo compatibilidad con el estándar I2C.

---

## 🧠 Diagramas ASM
Se diseñaron dos diagramas ASM (Algorithmic State Machine):

- **Figura 1:** flujo del generador de transacciones (maestro).  
- **Figura 2:** flujo del esclavo.  

Ambos muestran las transiciones entre estados, condiciones de inicio/parada, y las señales SDA/SCL correspondientes al ciclo completo de comunicación.

---

## 🧪 Plan de Pruebas

| # | Descripción | Objetivo | Resultado |
|---|--------------|-----------|-----------|
| **1** | Transacción de escritura (WRITE) | Validar envío de datos del maestro al esclavo con RNW = 0. | ✅ Exitoso: correcta transmisión y ACK. |
| **2** | Transacción de lectura (READ) | Verificar lectura de datos del esclavo con RNW = 1. | ✅ Exitoso: datos sincronizados y estables. |
| **3** | Reset durante transacción | Comprobar recuperación ante reinicio del sistema. | ✅ Exitoso: el bus se restablece al estado inactivo. |
| **4** | Dirección no coincidente | Validar que el esclavo ignore direcciones distintas. | ✅ Exitoso: el esclavo permanece en alta impedancia. |

---

## ⚙️ Instrucciones de Ejecución


### Comandos:
- `make` → Compila y genera los ejecutables, abre las formas de onda.  
- `make clean-all` → Limpia los archivos generados.  

---

## 📊 Resultados
Las simulaciones en **GTKWave** mostraron una comunicación estable y sincronizada entre maestro y esclavo.  
El reloj SCL fue configurado al **25% de la frecuencia del CLK**, ajustando los tiempos de prueba.

### Resultados individuales:
- **Prueba 1:** correcta transmisión del bit RNW=0 y generación de ACK.  
- **Prueba 2:** lectura de datos RNW=1 con sincronización adecuada.  
- **Prueba 3:** reset exitoso, el sistema vuelve a estado Idle.  
- **Prueba 4:** dirección no coincidente ignorada correctamente.

---

## 🧾 Conclusiones
- Se comprobó experimentalmente el funcionamiento del protocolo **I2C** mediante diseño digital secuencial.  
- Las simulaciones confirmaron la correcta sincronización entre **SCL** y **SDA**, y el cumplimiento del protocolo.  
- El proyecto fortaleció los conceptos de **FSM**, controladores secuenciales y transmisión serial.

---

## 💡 Recomendaciones
- Documentar cada simulación en **GTKWave** resaltando las señales relevantes.  
- Mantener una codificación modular y comentada en Verilog.  
- Ampliar las pruebas con múltiples esclavos o condiciones de error.  
- Implementar una versión física en **FPGA** para validar el comportamiento en tiempo real.

---

## 🧰 Herramientas Utilizadas
- **Lenguaje:** Verilog HDL  
- **Simulador:** GTKWave  
- **Automatización:** Makefile  

---

**Autor:** Rodrigo E. Sánchez Araya – *C37259*  
**Curso:** Electrónica Digital – UCR  
**Octubre 2025**
