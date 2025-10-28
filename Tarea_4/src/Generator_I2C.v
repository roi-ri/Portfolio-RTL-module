module Generator_I2C(
    input  wire         clk,
    input  wire         reset,      // active-LOW
    input  wire         RNW,        // 1 = read, 0 = write
    input  wire [6:0]   I2C_ADDR,
    input  wire [15:0]  WR_DATA,
    input  wire         START_STB,
    input  wire         SDA_IN,

    output reg  [15:0]  RD_DATA,
    output reg          SDA_OUT,
    output reg          SDA_OE,
    output reg          SCL
);

    // Parámetros de estado
    localparam
        S_IDLE           = 13'b0000000000001,
        S_START          = 13'b0000000000010,
        S_SEND_ADDR      = 13'b0000000000100,
        S_WAIT_ACK_ADDR  = 13'b0000000001000,
        S_WRITE_BYTE1    = 13'b0000000010000,
        S_WAIT_ACK1      = 13'b0000000100000,
        S_WRITE_BYTE2    = 13'b0000001000000,
        S_WAIT_ACK2      = 13'b0000010000000,
        S_READ_BYTE1     = 13'b0000100000000,
        S_ACK_AFTER_R1   = 13'b0001000000000,
        S_READ_BYTE2     = 13'b0010000000000,
        S_NACK_AFTER_R2  = 13'b0100000000000,
        S_STOP_WAIT      = 13'b1000000000000;


    reg [1:0]    clk_div;
    reg          scl_enable;

    reg [12:0]   state, next_state;
    reg [7:0]    shift_reg;
    reg [15:0]   write_buf;
    reg [15:0]   read_buf;
    reg [2:0]    bit_cnt, bit_cnt_next;
    reg          rnw_latched;
    reg          rnw_latched_next;
    
    reg          scl_prev;
    wire         scl_posedge = (!scl_prev) && SCL;
    wire         scl_negedge = scl_prev && (!SCL);

    reg          waiting_ack, waiting_ack_next;
    reg [3:0]    stop_counter, stop_counter_next;

    // Señales de salida para el control de SDA y SCL
    reg SDA_OE_next, SDA_OUT_next;
    reg scl_enable_next;


    reg [7:0]    shift_reg_next;
    reg [15:0]   write_buf_next;
    reg [15:0]   read_buf_next;
    reg [15:0]   RD_DATA_next;



    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            clk_div     <= 2'd0;
            SCL         <= 1'b1;
            scl_prev    <= 1'b1;
            scl_enable  <= 1'b0;
            state       <= S_IDLE;
            SDA_OUT     <= 1'b1;
            SDA_OE      <= 1'b0;
            RD_DATA     <= 16'd0;
            write_buf   <= 16'd0;
            read_buf    <= 16'd0;
            shift_reg   <= 8'd0;
            bit_cnt     <= 3'd0;
            rnw_latched <= 1'b0;
            waiting_ack <= 1'b0;
            stop_counter<= 4'd0;
        end else begin

            scl_enable  <= scl_enable_next;
            state       <= next_state;

            if ((!SCL) || (state == S_IDLE && next_state == S_START)) begin
                SDA_OE      <= SDA_OE_next;
                SDA_OUT     <= SDA_OUT_next;
            end else begin
                SDA_OE      <= SDA_OE;  // hold while SCL high
                SDA_OUT     <= SDA_OUT;
            end

            bit_cnt     <= bit_cnt_next;
            waiting_ack <= waiting_ack_next;
            stop_counter<= stop_counter_next;
            rnw_latched <= rnw_latched_next;

     
            shift_reg   <= shift_reg_next;
            write_buf   <= write_buf_next;
            read_buf    <= read_buf_next;
            RD_DATA     <= RD_DATA_next;
        end
    end


    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            clk_div <= 2'd0;
            SCL <= 1'b1;
            scl_prev <= 1'b1;
        end else begin
            if (scl_enable) begin
                clk_div <= clk_div + 1'b1;
                if (clk_div == 2'd1) begin
                    SCL <= ~SCL;
                    clk_div <= 2'd0;
                end
            end else begin
                clk_div <= 2'd0;
                SCL <= 1'b1;
            end
            scl_prev <= SCL;
        end
    end

 \
    always @(*) begin
        // Defaults
        next_state = state;
        SDA_OE_next = SDA_OE;
        SDA_OUT_next = SDA_OUT;
        bit_cnt_next = bit_cnt;
        waiting_ack_next = waiting_ack;
        scl_enable_next = scl_enable;
        stop_counter_next = stop_counter;
        rnw_latched_next = rnw_latched;

        // Defaults para los buffers/outputs _next
        shift_reg_next = shift_reg;
        write_buf_next = write_buf;
        read_buf_next = read_buf;
        RD_DATA_next = RD_DATA;

        case (state)
            S_IDLE: begin
                SDA_OE_next = 1'b0;
                SDA_OUT_next = 1'b1;
                waiting_ack_next = 1'b0;
                scl_enable_next = 1'b0;
                if (START_STB) begin
                    shift_reg_next = {I2C_ADDR, RNW}; 
                    write_buf_next = WR_DATA;
                    rnw_latched_next = RNW;
                    bit_cnt_next = 3'd7;
                    read_buf_next = 16'd0;
                    SDA_OE_next = 1'b1;
                    SDA_OUT_next = 1'b0; 
                    scl_enable_next = 1'b1;
                    next_state = S_START;
                end
            end

            S_START: begin
                scl_enable_next = 1'b1;
                SDA_OE_next = 1'b1;
                SDA_OUT_next = 1'b0;
                bit_cnt_next = bit_cnt;
                next_state = S_SEND_ADDR;
            end

            S_SEND_ADDR: begin
   
                if (scl_negedge) begin
                    SDA_OE_next = 1'b1;
                    SDA_OUT_next = shift_reg[bit_cnt]; 
                    if (bit_cnt == 3'd0) begin
                        waiting_ack_next = 1'b1;
                    end else begin
                        bit_cnt_next = bit_cnt - 1'b1;
                    end
                end
                if (scl_posedge && waiting_ack) begin
                    SDA_OE_next = 1'b0; 
                    next_state = S_WAIT_ACK_ADDR;
                end
            end

            S_WAIT_ACK_ADDR: begin
                if (scl_posedge) begin
                    if (SDA_IN == 1'b0) begin
                        bit_cnt_next = 3'd7;
                        waiting_ack_next = 1'b0;
                        if (rnw_latched) begin
                            next_state = S_READ_BYTE1;
                        end else begin
                            next_state = S_WRITE_BYTE1;
                        end
                    end else begin
                        next_state = S_STOP_WAIT;
                    end
                end
            end


            S_WRITE_BYTE1: begin
                if (scl_negedge) begin
                    if (!waiting_ack) begin
                        SDA_OE_next = 1'b1;
                        SDA_OUT_next = write_buf[15 - (7 - bit_cnt)]; 
                        if (bit_cnt == 3'd0) begin
                            waiting_ack_next = 1'b1;
                        end else begin
                            bit_cnt_next = bit_cnt - 1'b1;
                        end
                    end
                end
                if (scl_posedge && waiting_ack) begin
                    SDA_OE_next = 1'b0;
                    next_state = S_WAIT_ACK1;
                end
            end

            S_WAIT_ACK1: begin
                if (scl_posedge) begin
                    if (SDA_IN == 1'b0) begin
                        bit_cnt_next = 3'd7;
                        waiting_ack_next = 1'b0;
                        next_state = S_WRITE_BYTE2;
                    end else begin
                        next_state = S_STOP_WAIT;
                    end
                end
            end

            S_WRITE_BYTE2: begin
                if (scl_negedge) begin
                    if (!waiting_ack) begin
                        SDA_OE_next = 1'b1;
                        SDA_OUT_next = write_buf[7 - (7 - bit_cnt)]; 
                        if (bit_cnt == 3'd0) begin
                            waiting_ack_next = 1'b1;
                        end else begin
                            bit_cnt_next = bit_cnt - 1'b1;
                        end
                    end
                end
                if (scl_posedge && waiting_ack) begin
                    SDA_OE_next = 1'b0;
                    next_state = S_WAIT_ACK2;
                end
            end

            S_WAIT_ACK2: begin
                if (scl_posedge) begin
                    waiting_ack_next = 1'b0;
                    next_state = S_STOP_WAIT;
                end
            end


            S_READ_BYTE1: begin
                if (scl_negedge) begin
                    SDA_OE_next = 1'b0;
                end
                if (scl_posedge) begin
                    read_buf_next[15 - (7 - bit_cnt)] = SDA_IN;
                    if (bit_cnt == 3'd0) begin
                        bit_cnt_next = 3'd7;
                        next_state = S_ACK_AFTER_R1;
                    end else begin
                        bit_cnt_next = bit_cnt - 1'b1;
                    end
                end
            end

            S_ACK_AFTER_R1: begin
                if (scl_negedge) begin
                    SDA_OUT_next = 1'b0;
                    SDA_OE_next = 1'b1; 
                end
                if (scl_posedge) begin
                    SDA_OE_next = 1'b0;
                    next_state = S_READ_BYTE2;
                end
            end

            S_READ_BYTE2: begin
                if (scl_negedge) begin
                    SDA_OE_next = 1'b0;
                end
                if (scl_posedge) begin
                    read_buf_next[7 - (7 - bit_cnt)] = SDA_IN;
                    if (bit_cnt == 3'd0) begin
                        RD_DATA_next = read_buf_next; 
                        bit_cnt_next = 3'd7;
                        next_state = S_NACK_AFTER_R2;
                    end else begin
                        bit_cnt_next = bit_cnt - 1'b1;
                    end
                end
            end

            S_NACK_AFTER_R2: begin
                if (scl_negedge) begin
                    SDA_OUT_next = 1'b1;
                    SDA_OE_next = 1'b1; 
                end
                if (scl_posedge) begin
                    SDA_OE_next = 1'b0;
                    next_state = S_STOP_WAIT;
                end
            end

            S_STOP_WAIT: begin
                scl_enable_next = 1'b0;
                SDA_OUT_next = 1'b1;
                SDA_OE_next = 1'b0;
                stop_counter_next = 4'd0;
                next_state = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end

endmodule

