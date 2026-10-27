
`timescale 1ns/1ps

module tb_green_wave_timing;

    reg clk;
    reg reset;
    reg emergency_override;

    reg [2:0] density_A_NS, density_A_EW;
    reg [2:0] density_B_NS, density_B_EW;

    wire A_ns_red, A_ns_yellow, A_ns_green;
    wire A_ew_red, A_ew_yellow, A_ew_green;
    wire B_ns_red, B_ns_yellow, B_ns_green;
    wire B_ew_red, B_ew_yellow, B_ew_green;

    wire A_ns_green_start;
    wire B_ns_green_permit;

    integer cycle_count;
    integer a_start_cycle;
    integer b_start_cycle;
    integer measured_delay;
    integer errors;
    reg a_seen;
    reg b_seen;
    reg previous_b_green;

    amtgc_top #(.WAVE_DELAY(5)) dut (
        .clk(clk),
        .reset(reset),
        .emergency_override(emergency_override),

        .density_A_NS(density_A_NS),
        .density_A_EW(density_A_EW),
        .density_B_NS(density_B_NS),
        .density_B_EW(density_B_EW),

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
        .B_ns_green_permit(B_ns_green_permit)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        cycle_count = 0;
        a_start_cycle = -1;
        b_start_cycle = -1;
        measured_delay = -1;
        errors = 0;
        a_seen = 0;
        b_seen = 0;
        previous_b_green = 0;

        reset = 1;
        emergency_override = 0;

        density_A_NS = 3'd5;
        density_A_EW = 3'd2;
        density_B_NS = 3'd4;
        density_B_EW = 3'd1;

        $display("======================================");
        $display(" GREEN-WAVE TIMING TEST");
        $display(" Configured WAVE_DELAY = 5 clock cycles");
        $display("======================================");

        repeat (3) @(negedge clk);
        reset = 0;

        // Allow enough time for both junctions to operate.
        repeat (300) @(negedge clk);

        if (!a_seen) begin
            $display("FAIL: Junction A green-start pulse was not detected");
            errors = errors + 1;
        end

        if (!b_seen) begin
            $display("FAIL: Junction B NS green was not detected");
            errors = errors + 1;
        end

        if (a_seen && b_seen) begin
            measured_delay = b_start_cycle - a_start_cycle;

            $display("A NS green-start cycle = %0d", a_start_cycle);
            $display("B NS green-start cycle = %0d", b_start_cycle);
            $display("Measured start-to-start delay = %0d cycles",
                     measured_delay);

            if (measured_delay >= 5 && measured_delay <= 6)
                $display("PASS: Green-wave delay is within 5-6 cycles");
            else begin
                $display("CHECK REQUIRED: Delay is outside the 5-6 cycle target");
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display("GREEN-WAVE TIMING TEST PASSED");
        else
            $display("GREEN-WAVE TIMING TEST NEEDS FIXING: %0d issue(s)",
                     errors);

        $finish;
    end

    // Measure the first A green-start pulse and the first
    // B north-south green activation on the same clock count.
    always @(posedge clk) begin
        if (reset) begin
            cycle_count = 0;
            a_seen = 0;
            b_seen = 0;
            previous_b_green = 0;
            a_start_cycle = -1;
            b_start_cycle = -1;
        end
        else begin
            cycle_count = cycle_count + 1;

            if (A_ns_green_start && !a_seen) begin
                a_seen = 1;
                a_start_cycle = cycle_count;
            end

            if (B_ns_green && !previous_b_green && !b_seen) begin
                b_seen = 1;
                b_start_cycle = cycle_count;
            end

            previous_b_green = B_ns_green;
        end
    end

    // Watch for conflicting greens during normal operation.
    always @(negedge clk) begin
        if (!reset && !emergency_override) begin
            if (A_ns_green && A_ew_green) begin
                $display("FAIL: Conflicting greens at Junction A");
                errors = errors + 1;
            end

            if (B_ns_green && B_ew_green) begin
                $display("FAIL: Conflicting greens at Junction B");
                errors = errors + 1;
            end
        end
    end

    initial begin
        #5000;
        $display("FAIL: Timing test timed out");
        $finish;
    end

endmodule
