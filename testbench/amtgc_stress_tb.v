`timescale 1ns/1ps

module amtgc_stress_tb;

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

    wire A_ns_red, A_ns_yellow, A_ns_green;
    wire A_ew_red, A_ew_yellow, A_ew_green;
    wire B_ns_red, B_ns_yellow, B_ns_green;
    wire B_ew_red, B_ew_yellow, B_ew_green;

    wire A_ns_green_start;
    wire B_ns_green_permit;
    wire ped_grant_A;
    wire ped_grant_B;

    integer errors;
    integer emergency_tests;
    integer reset_tests;
    integer random_tests;
    integer repeated_emergencies;
    integer i;
    integer seed;
    integer random_value;

    // Device under test
    amtgc_top #(
        .WAVE_DELAY(5),
        .PED_SERVICE_CYCLES(5)
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

    // 10 ns clock
    initial begin
        clk = 1'b0;
    end

    always #5 clk = ~clk;

    // Shared safety checks
    always @(negedge clk) begin
        if (!reset) begin

            if (A_ns_green && A_ew_green) begin
                $display("FAIL: Conflicting green at Junction A, time=%0t", $time);
                errors = errors + 1;
            end

            if (B_ns_green && B_ew_green) begin
                $display("FAIL: Conflicting green at Junction B, time=%0t", $time);
                errors = errors + 1;
            end

            if (ped_grant_A && ped_grant_B) begin
                $display("FAIL: Simultaneous pedestrian grants, time=%0t", $time);
                errors = errors + 1;
            end

            if (emergency_override) begin
                if (!(A_ns_red && A_ew_red &&
                      B_ns_red && B_ew_red &&
                      !A_ns_green && !A_ns_yellow &&
                      !A_ew_green && !A_ew_yellow &&
                      !B_ns_green && !B_ns_yellow &&
                      !B_ew_green && !B_ew_yellow)) begin
                    $display("FAIL: Emergency all-red violation, time=%0t", $time);
                    errors = errors + 1;
                end
            end
        end
    end

    // Main test sequence
    initial begin
        errors = 0;
        emergency_tests = 0;
        reset_tests = 0;
        random_tests = 0;
        repeated_emergencies = 0;
        seed = 32'h13572468;

        reset = 1'b1;
        emergency_override = 1'b0;

        ped_req_A = 1'b0;
        ped_req_B = 1'b0;
        ped_done_A = 1'b0;
        ped_done_B = 1'b0;

        density_A_NS = 3'd3;
        density_A_EW = 3'd2;
        density_B_NS = 3'd4;
        density_B_EW = 3'd1;

        $display("========================================");
        $display("AMTGC STRESS TEST STARTED");
        $display("========================================");

        // Initial reset
        repeat (3) @(negedge clk);
        reset = 1'b0;

        // Allow the initial all-red state to settle
        @(negedge clk);

        // Test emergency during initial all-red
        emergency_override = 1'b1;
        #1;

        if (A_ns_red && A_ew_red &&
            B_ns_red && B_ew_red &&
            !A_ns_green && !A_ns_yellow &&
            !A_ew_green && !A_ew_yellow &&
            !B_ns_green && !B_ns_yellow &&
            !B_ew_green && !B_ew_yellow) begin
            $display("PASS: Emergency response during all-red");
        end else begin
            $display("FAIL: Emergency response during all-red");
            errors = errors + 1;
        end

        emergency_tests = emergency_tests + 1;

        repeat (2) @(negedge clk);
        emergency_override = 1'b0;
        repeat (5) @(negedge clk);

        // Test emergency during four visible traffic phases
        check_phase(1);  // North-south green
        check_phase(2);  // North-south yellow
        check_phase(3);  // East-west green
        check_phase(4);  // East-west yellow

        // Test reset during normal operation
        repeat (5) @(negedge clk);
        reset = 1'b1;

        repeat (2) @(negedge clk);

        if (A_ns_red && A_ew_red &&
            B_ns_red && B_ew_red) begin
            $display("PASS: Reset produces all-red outputs");
        end else begin
            $display("FAIL: Reset did not produce all-red outputs");
            errors = errors + 1;
        end

        reset_tests = reset_tests + 1;
        reset = 1'b0;

        repeat (20) @(negedge clk);

        // Test three emergency assertion/release cycles
        for (i = 0; i < 3; i = i + 1) begin
            @(negedge clk);
            emergency_override = 1'b1;
            #1;

            if (A_ns_red && A_ew_red &&
                B_ns_red && B_ew_red &&
                !A_ns_green && !A_ew_green &&
                !B_ns_green && !B_ew_green) begin
                $display("PASS: Repeated emergency event %0d", i + 1);
            end else begin
                $display("FAIL: Repeated emergency event %0d", i + 1);
                errors = errors + 1;
            end

            emergency_tests = emergency_tests + 1;
            repeated_emergencies = repeated_emergencies + 1;

            repeat (2) @(negedge clk);
            emergency_override = 1'b0;
            repeat (5) @(negedge clk);
        end

        // Randomized traffic-density inputs
        $display("INFO: Running 100 randomized density samples");

        for (i = 0; i < 100; i = i + 1) begin
            @(negedge clk);

            random_value = $random(seed);
            density_A_NS = random_value & 7;

            random_value = $random(seed);
            density_A_EW = random_value & 7;

            random_value = $random(seed);
            density_B_NS = random_value & 7;

            random_value = $random(seed);
            density_B_EW = random_value & 7;

            random_tests = random_tests + 1;
        end

        repeat (20) @(negedge clk);

        $display("----------------------------------------");
        $display("Emergency checks: %0d", emergency_tests);
        $display("Reset checks: %0d", reset_tests);
        $display("Repeated emergencies: %0d", repeated_emergencies);
        $display("Random density samples: %0d", random_tests);

        if (errors == 0) begin
            $display("AMTGC STRESS TEST PASSED");
        end else begin
            $display("AMTGC STRESS TEST FAILED: %0d error(s)", errors);
        end

        $display("========================================");
        $finish;
    end

    // Wait for a visible phase and test emergency response.
    // Phase 1 = NS green, 2 = NS yellow,
    // Phase 3 = EW green, 4 = EW yellow.
    task check_phase;
        input [2:0] phase_id;
        integer ticks;
        reg found;
        begin
            ticks = 0;
            found = 1'b0;

            while ((ticks < 300) && (found == 1'b0)) begin
                @(negedge clk);

                case (phase_id)
                    1: if (A_ns_green === 1'b1)  found = 1'b1;
                    2: if (A_ns_yellow === 1'b1) found = 1'b1;
                    3: if (A_ew_green === 1'b1)  found = 1'b1;
                    4: if (A_ew_yellow === 1'b1) found = 1'b1;
                    default: found = 1'b0;
                endcase

                ticks = ticks + 1;
            end

            if (found == 1'b1) begin
                $display("INFO: Traffic phase %0d observed", phase_id);

                emergency_override = 1'b1;
                #1;

                if (A_ns_red && A_ew_red &&
                    B_ns_red && B_ew_red &&
                    !A_ns_green && !A_ns_yellow &&
                    !A_ew_green && !A_ew_yellow &&
                    !B_ns_green && !B_ns_yellow &&
                    !B_ew_green && !B_ew_yellow) begin
                    $display("PASS: Emergency response during phase %0d", phase_id);
                end else begin
                    $display("FAIL: Emergency response during phase %0d", phase_id);
                    errors = errors + 1;
                end

                emergency_tests = emergency_tests + 1;

                repeat (2) @(negedge clk);
                emergency_override = 1'b0;
                repeat (3) @(negedge clk);
            end else begin
                $display("FAIL: Traffic phase %0d not observed within timeout", phase_id);
                errors = errors + 1;
            end
        end
    endtask

    // Simulation watchdog
    initial begin
        #50000;
        $display("FAIL: Stress test watchdog timeout");
        $finish;
    end

endmodule