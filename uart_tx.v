`timescale 1ns / 1ps

module uart_tx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    input  wire       baud_tick,
    output reg        tx,
    output reg        tx_active,
    output reg        tx_done
);

    // Ma hoa cac trang thai FSM
    localparam STATE_IDLE   = 3'b000;
    localparam STATE_START  = 3'b001;
    localparam STATE_DATA   = 3'b010;
    localparam STATE_PARITY = 3'b011;
    localparam STATE_STOP   = 3'b100;

    reg [2:0] state, next_state;
    reg [2:0] bit_index;
    reg [7:0] data_reg;
    reg       parity_bit;

    // Tinh Parity chan (Even Parity) dung XOR reduction operator
    wire calculated_parity = ^tx_data;

    // Thanh ghi cap nhat trang thai va du lieu
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= STATE_IDLE;
            bit_index  <= 3'd0;
            data_reg   <= 8'd0;
            parity_bit <= 1'b0;
        end else begin
            state <= next_state;

            if (state == STATE_IDLE && tx_start) begin
                data_reg   <= tx_data;
                parity_bit <= calculated_parity;
                bit_index  <= 3'd0;
            end else if (state == STATE_DATA && baud_tick) begin
                if (bit_index == 3'd7) begin
                    bit_index <= 3'd0;
                end else begin
                    bit_index <= bit_index + 1'b1;
                end
            end
        end
    end

    // Logic chuyen trang thai va ngo ra kombinatorial
    always @(*) begin
        next_state = state;
        tx         = 1'b1;
        tx_active  = 1'b0;
        tx_done    = 1'b0;

        case (state)
            STATE_IDLE: begin
                tx = 1'b1;
                if (tx_start) begin
                    next_state = STATE_START;
                end
            end

            STATE_START: begin
                tx        = 1'b0;
                tx_active = 1'b1;
                if (baud_tick) begin
                    next_state = STATE_DATA;
                end
            end

            STATE_DATA: begin
                tx        = data_reg[bit_index];
                tx_active = 1'b1;
                if (baud_tick) begin
                    if (bit_index == 3'd7) begin
                        next_state = STATE_PARITY;
                    end
                end
            end

            STATE_PARITY: begin
                tx        = parity_bit;
                tx_active = 1'b1;
                if (baud_tick) begin
                    next_state = STATE_STOP;
                end
            end

            STATE_STOP: begin
                tx        = 1'b1;
                tx_active = 1'b1;
                if (baud_tick) begin
                    tx_done    = 1'b1;
                    next_state = STATE_IDLE;
                end
            end

            default: next_state = STATE_IDLE;
        endcase
    end

endmodule
