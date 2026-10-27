
`timescale 1ns/1ps

module green_wave_coordinator #(
    parameter WAVE_DELAY = 5
)(
    input wire clk,
    input wire reset,
    input wire emergency_override,
    input wire a_ns_green_start,
    input wire b_ready,
    output reg b_ns_green_permit
);

    reg waiting_for_b;
    reg [15:0] delay_count;

    localparam integer COUNT_TARGET =
        (WAVE_DELAY > 2) ? WAVE_DELAY - 3 : 0;

    always @(posedge clk) begin
        if (reset || emergency_override) begin
            waiting_for_b     <= 1'b0;
            delay_count       <= 0;
            b_ns_green_permit <= 1'b0;
        end
        else begin
            b_ns_green_permit <= 1'b0;

            if (a_ns_green_start && !waiting_for_b) begin
                waiting_for_b <= 1'b1;
                delay_count   <= 0;
            end
            else if (waiting_for_b) begin
                if (delay_count < COUNT_TARGET)
                    delay_count <= delay_count + 1'b1;

                if ((delay_count >= COUNT_TARGET) && b_ready) begin
                    b_ns_green_permit <= 1'b1;
                    waiting_for_b     <= 1'b0;
                    delay_count       <= 0;
                end
            end
        end
    end

endmodule
