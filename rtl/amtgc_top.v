`timescale 1ns/1ps

module amtgc_top #(
    parameter WAVE_DELAY = 5,
    parameter PED_SERVICE_CYCLES = 5
)(
    input wire clk,
    input wire reset,
    input wire emergency_override,

input wire [2:0] density_A_NS,
    input wire [2:0] density_A_EW,
    input wire [2:0] density_B_NS,
    input wire [2:0] density_B_EW,

input wire ped_req_A,
    input wire ped_req_B,
    input wire ped_done_A,
    input wire ped_done_B,

output wire A_ns_red,
    output wire A_ns_yellow,
    output wire A_ns_green,
    output wire A_ew_red,
    output wire A_ew_yellow,
    output wire A_ew_green,

output wire B_ns_red,
    output wire B_ns_yellow,
    output wire B_ns_green,
    output wire B_ew_red,
    output wire B_ew_yellow,
    output wire B_ew_green,

output wire A_ns_green_start,
    output wire B_ns_green_permit,

output wire ped_grant_A,
    output wire ped_grant_B
);

wire ped_active;
    wire B_ready;
    wire [2:0] A_state;
    wire [2:0] B_state;

wire a_nr, a_ny, a_ng, a_er, a_ey, a_eg;
    wire b_nr, b_ny, b_ng, b_er, b_ey, b_eg;

    assign ped_active = ped_grant_A | ped_grant_B;

    junction_controller junction_A (
        .clk(clk),
        .reset(reset),
        .emergency_override(emergency_override),
        .density_NS(density_A_NS),
        .density_EW(density_A_EW),
        .ns_green_enable(1'b1),
        .pedestrian_hold(ped_active),
        .ns_green_start(A_ns_green_start),
        .b_ready(),
        .ns_red(a_nr),
        .ns_yellow(a_ny),
        .ns_green(a_ng),
        .ew_red(a_er),
        .ew_yellow(a_ey),
        .ew_green(a_eg),
        .state(A_state)
    );

    ped_arbiter pedestrian_arbiter (
        .clk(clk),
        .reset(reset),
        .emergency_override(emergency_override),
        .ped_req_A(ped_req_A),
        .ped_req_B(ped_req_B),
        .ped_done_A(ped_done_A),
        .ped_done_B(ped_done_B),
        .ped_grant_A(ped_grant_A),
        .ped_grant_B(ped_grant_B)
    );

    green_wave_coordinator #(
        .WAVE_DELAY(WAVE_DELAY)
    ) wave_coordinator (
        .clk(clk),
        .reset(reset),
        .emergency_override(emergency_override | ped_active),
        .a_ns_green_start(A_ns_green_start),
        .b_ready(B_ready),
        .b_ns_green_permit(B_ns_green_permit)
    );

    junction_controller junction_B (
        .clk(clk),
        .reset(reset),
        .emergency_override(emergency_override),
        .density_NS(density_B_NS),
        .density_EW(density_B_EW),
        .ns_green_enable(B_ns_green_permit),
        .pedestrian_hold(ped_active),
        .ns_green_start(),
        .b_ready(B_ready),
        .ns_red(b_nr),
        .ns_yellow(b_ny),
        .ns_green(b_ng),
        .ew_red(b_er),
        .ew_yellow(b_ey),
        .ew_green(b_eg),
        .state(B_state)
    );

    assign A_ns_red    = (emergency_override || ped_active) ? 1'b1 : a_nr;
    assign A_ns_yellow = (emergency_override || ped_active) ? 1'b0 : a_ny;
    assign A_ns_green  = (emergency_override || ped_active) ? 1'b0 : a_ng;
    assign A_ew_red    = (emergency_override || ped_active) ? 1'b1 : a_er;
    assign A_ew_yellow = (emergency_override || ped_active) ? 1'b0 : a_ey;
    assign A_ew_green  = (emergency_override || ped_active) ? 1'b0 : a_eg;

    assign B_ns_red    = (emergency_override || ped_active) ? 1'b1 : b_nr;
    assign B_ns_yellow = (emergency_override || ped_active) ? 1'b0 : b_ny;
    assign B_ns_green  = (emergency_override || ped_active) ? 1'b0 : b_ng;
    assign B_ew_red    = (emergency_override || ped_active) ? 1'b1 : b_er;
    assign B_ew_yellow = (emergency_override || ped_active) ? 1'b0 : b_ey;
    assign B_ew_green  = (emergency_override || ped_active) ? 1'b0 : b_eg;

endmodule