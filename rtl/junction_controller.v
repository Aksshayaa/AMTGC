
`timescale 1ns/1ps

module junction_controller #(
    parameter YELLOW_CYCLES = 3,
    parameter ALL_RED_CYCLES = 2
)(
    input wire clk,
    input wire reset,
    input wire emergency_override,
    input wire [2:0] density_NS,
    input wire [2:0] density_EW,

    input wire ns_green_enable,
    input wire pedestrian_hold,

    output reg ns_green_start,
    output wire b_ready,

    output reg ns_red,
    output reg ns_yellow,
    output reg ns_green,
    output reg ew_red,
    output reg ew_yellow,
    output reg ew_green,

    output reg [2:0] state
);

    localparam ALL_RED_INIT = 3'd0;
    localparam NS_GREEN_ST  = 3'd1;
    localparam NS_YELLOW_ST = 3'd2;
    localparam RED_TO_EW    = 3'd3;
    localparam EW_GREEN_ST  = 3'd4;
    localparam EW_YELLOW_ST = 3'd5;
    localparam RED_TO_NS    = 3'd6;

    reg [15:0] phase_count;
    reg [15:0] phase_duration;

    wire [3:0] ns_duration;
    wire [3:0] ew_duration;
    wire [1:0] ns_class;
    wire [1:0] ew_class;

    ml_timing_predictor ns_predictor (
        .density_A_NS(density_NS),
        .density_A_EW(density_EW),
        .green_duration(ns_duration),
        .timing_class(ns_class)
    );

    ml_timing_predictor ew_predictor (
        .density_A_NS(density_EW),
        .density_A_EW(density_NS),
        .green_duration(ew_duration),
        .timing_class(ew_class)
    );

    assign b_ready =
        ((state == ALL_RED_INIT) || (state == RED_TO_NS)) &&
        (phase_count >= ALL_RED_CYCLES);

    always @(posedge clk) begin
        if (reset || emergency_override || pedestrian_hold) begin
            state          <= ALL_RED_INIT;
            phase_count    <= 0;
            phase_duration <= ALL_RED_CYCLES;
            ns_green_start <= 0;
        end
        else begin
            ns_green_start <= 0;

            case (state)
                ALL_RED_INIT: begin
                    if (phase_count < ALL_RED_CYCLES)
                        phase_count <= phase_count + 1'b1;
                    else if (ns_green_enable) begin
                        state          <= NS_GREEN_ST;
                        phase_count    <= 0;
                        phase_duration <= ns_duration;
                        ns_green_start <= 1;
                    end
                end

                NS_GREEN_ST: begin
                    if (phase_count < phase_duration - 1'b1)
                        phase_count <= phase_count + 1'b1;
                    else begin
                        state          <= NS_YELLOW_ST;
                        phase_count    <= 0;
                        phase_duration <= YELLOW_CYCLES;
                    end
                end

                NS_YELLOW_ST: begin
                    if (phase_count < phase_duration - 1'b1)
                        phase_count <= phase_count + 1'b1;
                    else begin
                        state          <= RED_TO_EW;
                        phase_count    <= 0;
                        phase_duration <= ALL_RED_CYCLES;
                    end
                end

                RED_TO_EW: begin
                    if (phase_count < phase_duration)
                        phase_count <= phase_count + 1'b1;
                    else begin
                        state          <= EW_GREEN_ST;
                        phase_count    <= 0;
                        phase_duration <= ew_duration;
                    end
                end

                EW_GREEN_ST: begin
                    if (phase_count < phase_duration - 1'b1)
                        phase_count <= phase_count + 1'b1;
                    else begin
                        state          <= EW_YELLOW_ST;
                        phase_count    <= 0;
                        phase_duration <= YELLOW_CYCLES;
                    end
                end

                EW_YELLOW_ST: begin
                    if (phase_count < phase_duration - 1'b1)
                        phase_count <= phase_count + 1'b1;
                    else begin
                        state          <= RED_TO_NS;
                        phase_count    <= 0;
                        phase_duration <= ALL_RED_CYCLES;
                    end
                end

                RED_TO_NS: begin
                    if (phase_count < phase_duration)
                        phase_count <= phase_count + 1'b1;
                    else if (ns_green_enable) begin
                        state          <= NS_GREEN_ST;
                        phase_count    <= 0;
                        phase_duration <= ns_duration;
                        ns_green_start <= 1;
                    end
                end

                default: begin
                    state          <= ALL_RED_INIT;
                    phase_count    <= 0;
                    phase_duration <= ALL_RED_CYCLES;
                    ns_green_start <= 0;
                end
            endcase
        end
    end

    always @(*) begin
        ns_red    = 1'b1;
        ns_yellow = 1'b0;
        ns_green  = 1'b0;
        ew_red    = 1'b1;
        ew_yellow = 1'b0;
        ew_green  = 1'b0;

        if (!emergency_override && !pedestrian_hold) begin
            case (state)
                NS_GREEN_ST: begin
                    ns_red   = 1'b0;
                    ns_green = 1'b1;
                end

                NS_YELLOW_ST: begin
                    ns_red    = 1'b0;
                    ns_yellow = 1'b1;
                end

                EW_GREEN_ST: begin
                    ew_red   = 1'b0;
                    ew_green = 1'b1;
                end

                EW_YELLOW_ST: begin
                    ew_red    = 1'b0;
                    ew_yellow = 1'b1;
                end

                default: begin
                    // Both directions remain red.
                end
            endcase
        end
    end

endmodule
