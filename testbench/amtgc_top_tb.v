`timescale 1ns/1ps

module tb_amtgc_top;

    reg clk;
    reg reset;
    reg emergency_override;

    reg [2:0] density_A_NS;
    reg [2:0] density_A_EW;
    reg [2:0] density_B_NS;
    reg [2:0] density_B_EW;

    reg ped_req_A;
    reg ped_req_B;
    reg ped_done_A;
    reg ped_done_B;

    wire A_ns_red;
    wire A_ns_yellow;
    wire A_ns_green;

    wire A_ew_red;
    wire A_ew_yellow;
    wire A_ew_green;

    wire B_ns_red;
    wire B_ns_yellow;
    wire B_ns_green;

    wire B_ew_red;
    wire B_ew_yellow;
    wire B_ew_green;

    wire A_ns_green_start;
    wire B_ns_green_permit;

    wire ped_grant_A;
    wire ped_grant_B;

    integer errors;
    integer A_started;
    integer B_started;

    amtgc_top #(
        .WAVE_DELAY(5)
    ) dut (
        .clk(clk),
        .reset(reset),
        .emergency_override(emergency_override),

        .density_A_NS(density_A_NS),
        .density_A_EW(density_A_EW),
        .density_B_NS(density_B_NS),
        .density_B_EW(density_B_EW),

        .ped_req_A(ped_req_A),
        .ped_req_B(ped_req_B),
        .ped_done_A(ped_done_A),
        .ped_done_B(ped_done_B),

        .A_ns_red(A_ns_red),
        .A_ns_yellow(A_ns_yellow),
        .A_ns_green(A_ns_green),

        .A_ew_red(A_ew_red),
        .A_ew_yellow(A_ew_yellow),
        .A_ew_green(A_ew_green),

        .B_ns_red(B_ns_red),
        .B_ns_yellow(B_ns_yellow),
        .B_ns_green(B_ns_green),

        .B_ew_red(B_ew_red),
        .B_ew_yellow(B_ew_yellow),
        .B_ew_green(B_ew_green),

        .A_ns_green_start(A_ns_green_start),
        .B_ns_green_permit(B_ns_green_permit),

        .ped_grant_A(ped_grant_A),
        .ped_grant_B(ped_grant_B)
    );

    initial
     begin
        clk = 1'b0;
    end

    always #5 clk = ~clk;

    always @(negedge clk) begin
        if (!reset) begin
            if (A_ns_green && A_ew_green)
             begin
                $display("FAIL: Junction A has conflicting green lights at time %0t", $time);
                errors = errors + 1;
            end

            if (B_ns_green && B_ew_green)
             begin
                $display("FAIL: Junction B has conflicting green lights at time %0t", $time);
                errors = errors + 1;
            end

            if (ped_grant_A && ped_grant_B) 
            begin
                $display("FAIL: Both pedestrian grants active simultaneously at time %0t", $time);
                errors = errors + 1;
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            A_started = 0;
            B_started = 0;
        end else begin
            if (A_ns_green_start)
                A_started = 1;

            if (B_ns_green)
                B_started = 1;
        end
    end

    initial
     begin
        errors = 0;
        A_started = 0;
        B_started = 0;

        reset = 1'b1;
        emergency_override = 1'b0;

        ped_req_A = 1'b0;
        ped_req_B = 1'b0;
        ped_done_A = 1'b0;
        ped_done_B = 1'b0;

        density_A_NS = 3'd5;
        density_A_EW = 3'd2;
        density_B_NS = 3'd4;
        density_B_EW = 3'd1;

        $display("==============================================");
        $display(" AMTGC TOP-LEVEL INTEGRATION TEST");
        $display("==============================================");

        repeat (3) @(negedge clk);
        reset = 1'b0;

        $display("INFO: Reset released at time %0t", $time);

        repeat (300) @(negedge clk);

        if (A_started)
         begin
            $display("PASS: Junction A NS green-start signal observed");
        end else begin
            $display("FAIL: Junction A NS green-start signal not observed");
            errors = errors + 1;
        end

        if (B_started) begin
            $display("PASS: Junction B NS green observed");
        end else begin
            $display("FAIL: Junction B NS green not observed");
            errors = errors + 1;
        end

        $display("INFO: Asserting emergency override at time %0t", $time);
        emergency_override = 1'b1;

        repeat (2) @(posedge clk);
        #1;

        // Check that both junctions are all-red.
        if (A_ns_red && A_ew_red &&
            B_ns_red && B_ew_red &&
            !A_ns_green && !A_ew_green &&
            !B_ns_green && !B_ew_green &&
            !A_ns_yellow && !A_ew_yellow &&
            !B_ns_yellow && !B_ew_yellow) begin

            $display("PASS: Both junctions entered all-red during emergency");

        end 
        else
         begin
            $display("FAIL: Both junctions were not all-red after emergency response window");
            $display("A: NS(RYG)=%b%b%b EW(RYG)=%b%b%b",
                     A_ns_red, A_ns_yellow, A_ns_green,
                     A_ew_red, A_ew_yellow, A_ew_green);
            $display("B: NS(RYG)=%b%b%b EW(RYG)=%b%b%b",
                     B_ns_red, B_ns_yellow, B_ns_green,
                     B_ew_red, B_ew_yellow, B_ew_green);
            errors = errors + 1;
        end

        @(negedge clk);
        emergency_override = 1'b0;

        $display("INFO: Emergency override released at time %0t", $time);

        repeat (30) @(negedge clk);

        $display("----------------------------------------------");

        if (errors == 0) begin
            $display("ALL AMTGC TOP-LEVEL TESTS PASSED");
        end else begin
            $display("AMTGC TOP-LEVEL TEST FAILED: %0d error(s)", errors);
        end

        $display("==============================================");

        $finish;
    end

    initial 
    begin
        #5000;
        $display("FAIL: Simulation timeout");
        $finish;
    end

    initial
     begin
        $monitor(
            "t=%0t reset=%b emergency=%b A_NS=%b%b%b A_EW=%b%b%b B_NS=%b%b%b B_EW=%b%b%b ped_grant_A=%b ped_grant_B=%b",
            $time, reset, emergency_override,
            A_ns_red, A_ns_yellow, A_ns_green,
            A_ew_red, A_ew_yellow, A_ew_green,
            B_ns_red, B_ns_yellow, B_ns_green,
            B_ew_red, B_ew_yellow, B_ew_green,
            ped_grant_A, ped_grant_B
        );
    end

endmodule
