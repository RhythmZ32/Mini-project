`timescale 1ns / 1ps

module tb_uart_tx_top;

    reg        clk;
    reg        rst_n;
    reg        tx_start;
    reg  [7:0] tx_data;
    wire       tx;
    wire       tx_active;
    wire       tx_done;

    // Tạo xung clock 50MHz (Chu kỳ 20ns)
    always #10 clk = ~clk;

    // Instantiation UART Top module
    uart_tx_top #(
        .CLK_FREQ(50000000),
        .BAUD_RATE(115200)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_active(tx_active),
        .tx_done(tx_done)
    );

    initial begin
        clk      = 0;
        rst_n    = 0;
        tx_start = 0;
        tx_data  = 8'h00;

        // Reset he thong
        #100;
        rst_n = 1;
        #100;

        // truyen 8'h41 (01000001), 2 bit 1 => Even Parity bit = 0
        tx_data  = 8'h41;
        tx_start = 1;
        #20;
        tx_start = 0;

        // Cho den khi truyen xong khung tin
        wait(tx_done);
        #1000;

        $display("Hoan thanh truyen du lieu qua UART TX thanh cong!");
        $finish;
    end

endmodule
