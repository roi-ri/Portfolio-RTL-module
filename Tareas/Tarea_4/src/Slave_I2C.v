module Slave_I2C (
    input  wire        clk,
    input  wire        reset,           
    input  wire        SCL,
    input  wire        SDA_bus,       
    input  wire [15:0] RD_DATA,        
    output reg         SDA_drive,      
    output reg [15:0]  WR_DATA         
);

    // Dirección del esclavo
    localparam SLAVE_ADDR = 7'b0111011;

    // Definición de los estados de la máquina de estados
    localparam
        IDLE                        = 8'b00000001,
        READ_ADDR_RNW               = 8'b00001000,
        WRITE                       = 8'b00100000,
        RECEIVE_DATA                = 8'b01000000,
        SEND_DATA_CPU               = 8'b10000000,
        READ                        = 8'b00010000;

    // Registros internos de la máquina de estados
    reg [12:0]   state, next_state;
    reg [7:0]    shift_reg, shift_reg_next;
    reg [15:0]   write_buf, write_buf_next;
    reg [15:0]   read_buf, read_buf_next;
    reg [2:0]    bit_cnt, bit_cnt_next;
    reg          rnw_latched, rnw_latched_next;
    
    reg          scl_prev;
    wire         scl_posedge = (!scl_prev) && SCL;
    wire         scl_negedge = scl_prev && (!SCL);

    reg          waiting_ack, waiting_ack_next;
    reg [3:0]    stop_counter, stop_counter_next;


    reg [15:0]   RD_DATA_next;
    reg          drive_out, drive_out_next;
    reg [15:0]   WR_BUF, WR_BUF_next;


    reg          addr_match, addr_match_next;
    reg          sending_ack, sending_ack_next;
    reg  [1:0]   byte_state, byte_state_next;

    // Detección de flancos en la señal SDA para el manejo de START y STOP
    reg sda_prev;
    wire bus_level = SDA_bus; 

    // Condiciones de START y STOP
    wire start_cond = (scl_prev == 1'b1) && (sda_prev == 1'b1) && (bus_level == 1'b0) && (SCL == 1'b1);
    wire stop_cond  = (scl_prev == 1'b1) && (sda_prev == 1'b0) && (bus_level == 1'b1) && (SCL == 1'b1);

 
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= IDLE;
            drive_out <= 1'b1;
            SDA_drive <= 1'b1; 
            WR_DATA <= 16'd0;
            WR_BUF <= 16'd0;
            shift_reg <= 8'd0;
            bit_cnt <= 3'd7;
            read_buf <= 16'd0;
            rnw_latched <= 1'b0;
            addr_match <= 1'b0;
            sending_ack <= 1'b0;
            byte_state <= 2'd0;
            sda_prev <= 1'b1;
            scl_prev <= 1'b1;
        end else begin
            
            sda_prev <= bus_level;
            scl_prev <= SCL;

            
            state <= next_state;
            shift_reg <= shift_reg_next;
            write_buf <= write_buf_next;
            read_buf <= read_buf_next;
            bit_cnt <= bit_cnt_next;
            rnw_latched <= rnw_latched_next;
            addr_match <= addr_match_next;
            sending_ack <= sending_ack_next;
            byte_state <= byte_state_next;

           
            if (!SCL) begin
                drive_out <= drive_out_next;
            end else begin
                drive_out <= drive_out; // hold while SCL high
            end
            SDA_drive <= drive_out; // reflect current drive_out to output pin

            WR_BUF <= WR_BUF_next;
            WR_DATA <= WR_BUF; 
            RD_DATA_next <= RD_DATA; 
        end
    end

   
    always @(*) begin
    
        next_state = state;
        shift_reg_next = shift_reg;
        write_buf_next = write_buf;
        read_buf_next = read_buf;
        bit_cnt_next = bit_cnt;
        rnw_latched_next = rnw_latched;
        addr_match_next = addr_match;
        sending_ack_next = sending_ack;
        byte_state_next = byte_state;
        drive_out_next = drive_out;
        WR_BUF_next = WR_BUF;
        RD_DATA_next = RD_DATA; 

        case (state)
            IDLE: begin
                drive_out_next = 1'b1;
                bit_cnt_next = 3'd7;
                addr_match_next = 1'b0;
                sending_ack_next = 1'b0;
                byte_state_next = 2'd0;
                if (start_cond) begin
                    shift_reg_next = 8'd0;
                    bit_cnt_next = 3'd7;
                    sending_ack_next = 1'b0;
                    next_state = READ_ADDR_RNW;
                end
            end

            READ_ADDR_RNW: begin
                if (scl_posedge && !sending_ack) begin
                   
                    shift_reg_next[bit_cnt] = bus_level;
                    if (bit_cnt == 3'd0) begin
                        sending_ack_next = 1'b1;
                    end else begin
                        bit_cnt_next = bit_cnt - 1'b1;
                    end
                end

                if (scl_negedge && sending_ack) begin
                    if (shift_reg_next[7:1] == SLAVE_ADDR) begin
                        drive_out_next = 1'b0; 
                        rnw_latched_next = shift_reg_next[0];
                        addr_match_next = 1'b1;
                        read_buf_next = RD_DATA; 
                    end else begin
                        drive_out_next = 1'b1; 
                        addr_match_next = 1'b0;
                    end
                end

                if (scl_posedge && sending_ack) begin
                    sending_ack_next = 1'b0;
                    bit_cnt_next = 3'd7;
                    drive_out_next = 1'b1;
                    if (addr_match) begin
                        if (rnw_latched) begin
                            next_state = READ;
                            byte_state_next = 2'd1;
                        end else begin
                            next_state = WRITE;
                            byte_state_next = 2'd1;
                        end
                    end else begin
                        next_state = IDLE;
                    end
                end

                if (stop_cond) next_state = IDLE;
            end

            WRITE: begin
                if (scl_posedge && !sending_ack) begin
                 
                    if (byte_state == 2'd1) begin
                        write_buf_next[15 - (7 - bit_cnt)] = bus_level;
                    end else if (byte_state == 2'd2) begin
                        write_buf_next[7 - (7 - bit_cnt)] = bus_level;
                    end

                    if (bit_cnt == 3'd0) begin
                        sending_ack_next = 1'b1;
                    end else begin
                        bit_cnt_next = bit_cnt - 1'b1;
                    end
                end

                if (scl_negedge && sending_ack) begin
                    drive_out_next = 1'b0; // ACK
                end

                if (scl_posedge && sending_ack) begin
                    sending_ack_next = 1'b0;
                    bit_cnt_next = 3'd7;
                    drive_out_next = 1'b1; // release after ACK
                    if (byte_state == 2'd1) begin
                        byte_state_next = 2'd2;
                    end else if (byte_state == 2'd2) begin
                        WR_BUF_next = write_buf_next;
                        next_state = RECEIVE_DATA;
                    end
                end

                if (stop_cond) next_state = IDLE;
            end

            RECEIVE_DATA: begin

                next_state = SEND_DATA_CPU;
            end

            SEND_DATA_CPU: begin
                drive_out_next = 1'b1; // ensure release
                if (stop_cond) begin
                    next_state = IDLE;
                end
            end

            READ: begin
                if (scl_negedge && !sending_ack) begin
                   
                    drive_out_next = (read_buf_next[15 - (7 - bit_cnt)] == 1'b0) ? 1'b0 : 1'b1;
                    if (bit_cnt == 3'd0) begin
                        sending_ack_next = 1'b1;
                    end else begin
                        bit_cnt_next = bit_cnt - 1'b1;
                    end
                end

                if (scl_negedge && sending_ack) begin
                    drive_out_next = 1'b1; 
                end

                if (scl_posedge && sending_ack) begin
                    sending_ack_next = 1'b0;
                    bit_cnt_next = 3'd7;
                    if (bus_level == 1'b0) begin  
                        if (byte_state == 2'd1) begin
                            byte_state_next = 2'd2;
                        end else begin
                            next_state = SEND_DATA_CPU;
                        end
                    end else begin
                        next_state = IDLE;
                    end
                end

                if (stop_cond) next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end
endmodule
