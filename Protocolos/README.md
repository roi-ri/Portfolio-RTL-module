# Protocols Summary 

---------
# I2C

#### Brief data 

- For short distance data communication 
- Synchronous master-slave protocol 
  - Both master and slave can send/revceive data
- Just 2 wires are used (SCL & SDA)

 #### Behavior 

- IDLE state SDA and SCL are both high
- *Start Condition* occures when a node: 
  - First pulls SDA low
  - Then pulls SCL low
- This claims the bus 
  - Node is now the master 
  - Prevents any other nodes from taking control of the bus 
  - Reduces risk of contention 
- Master that has sized the bus also starts the clock 

- Each I2C node on a bus must have a unique, fixed address
  - Normaly 7 bits long, MSB first
  - 10 bits addresses also supported, but these are uncommon 
- Adresses may be hard coded
- adress may be (partially) configurable via external address lines or jumpers

#### Timing relationship between SDA and SCL 
- SDA does not change between clock rising edge and clock falling edge 
- During *data transmission*, SDA onli tansitions while SCL is *low*
  - An SDA transition when SCL is *hich*, indicates a *start or stop* condition. 

#### READ/WRITE bit 

- Read/Write bit follos the slave address
- Set by master to indicate desired operation 
  - 0 -> master wants to write data to slave 
  - 1 -> master whats to read data to slave 
- Often interpreted and/or decoded as part of the addres byte 


#### Acknowledge bit (ACK)

- Sent by the receiver of a byte of data
  - 0-> acknowledgement (ACK)
  - 1-> negative acknowledge (NACK)
- Recall that I2C is IDLE high
  - Lack of response = NACK
- ACK after data byte(s) confirms receipt of data
- ACK after slave address confirms that
  - A slave with that addres is on the bus 
  - the slave is ready to read/write data (sepending on R/W bit)
  
#### Data Byte(s)
- Data byte contains the information being transferred between master an slave 
  - Memory or register contents, address, etc.
-  Always 8 bit long. MSB first. 
-  Always followed by an ACK bit 
   -  Set to 0 by the reciever if data has been recieved properly

####  Multiple data bytes 

- In many cases, multiple data bytes are sent in one I2C frame 
  - Each data byte is followed by an ACK bit
- Biyes may be all "data" or some may represent an internal address, etc.
  - Ex: first byte is a register location and second byte is the thada to be written to that register
  
#### Stop condition 

- Stop condition indicates the end of data bytes 
  - First SCL returns (and remains) high 
  - Then, SDA returns (and remains) high 
- Recall that for *data* bytes, SDA only transitions when clock is *low*
  - SDA transitions when SCL *High = stop condition*
- Bus becomes IDLE 
  - No clock signal 
  - Any node can now use the start condition to claim the bus and begin a new communication 

#### Open drain 

- Each line (SDA and SDL) is connected to voltage ($V_{cc}$ or $V_{DD}$) via "pull up" resistor 
  - One resistor per line (not per device)
- Each I2C device contains logic that can open an close a drain 
- When drain is "closed", the line is pulled low (connected to ground)
- WHen drain is "open", the line is pulled high (connected to voltage)
- I2C lines are high in the IDLE state
  - Sometimes called an "open drain" system 
  
#### Pull up resistor values 

- Pulling down a line is usually much faster than pulling up a line 
  - Pull-up time is a function of bus capacitance and values of pull-up resistors 
- Values of pull-up resistors are a compromise 
  - *Higher resistances* increase the time needed to pull up the line and thus *limit bus speed*
  - *Lower resistances* allow faster communications, but *require higher power*
- Typicall pull-up resistor values are in the range of $1k\Omega - 10k\Omega$
  
#### Modes/Speed

- I2C Can operate at different bus speeds 
  - Referred to as "modes"
- Table shows max speed for each mode 
    - Hardware is specified as compliant to standart, fast, or fast plus if it can (theoretically) achieve these speeds
- *High speed mode* devices are backwards compatible to lower speeds
  - Transmit a special sequence to switch the bus to HS mode
- *Ultra fast mode* is unidirectional (write only)
  
| I2C Mode          | Speed     |
|--------------------|-----------|
| Standard Mode      | 100 kbps  |
| Fast Mode          | 400 kbps  |
| Fast Mode Plus     | 1 Mbps    |
| High Speed Mode    | 3.4 Mbps  |
| Ultra Fast Mode    | 5 Mbps    |


