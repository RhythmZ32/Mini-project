`timescale 1ns / 1ps

module baud_rate_gen #(
    parameter CLK_FREQ  = 50000000,
    parameter BAUD_RATE = 115200
)(
    input  wire clk,
    input  wire rst_n,
    output reg  baud_tick
);

    localparam MAX_COUNT = CLK_FREQ / BAUD_RATE;
    localparam CNT_WIDTH = $clog2(MAX_COUNT);

    reg [CNT_WIDTH-1:0] count_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_reg <= 0;
            baud_tick <= 1'b0;
        end else begin
            if (count_reg == MAX_COUNT - 1) begin
                count_reg <= 0;
                baud_tick <= 1'b1;
            end else begin
                count_reg <= count_reg + 1'b1;
                baud_tick <= 1'b0;
            end
        end
    end

endmodule
