`timescale 1ns/1ps

module green_wave_density_tb;

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
    wire ped_grant_A, ped_grant_B;

    integer test_num;
    integer errors;
    integer cycles;
    integer delay_cycles;
    integer found_A;
    integer found_B;
    integer i;

    reg [2:0] test_A_NS [0:4];
    reg [2:0] test_A_EW [0:4];
    reg [2:0] test_B_NS [0:4];
    reg [2:0] test_B_EW [0:4];

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

    always #5 clk = ~clk;

    task reset_test;
        begin
            @(negedge clk);
            reset = 1'b1;
            emergency_override = 1'b0;
            ped_req_A = 1'b0;
            ped_req_B = 1'b0;
            ped_done_A = 1'b0;
            ped_done_B = 1'b0;

            repeat (3) @(negedge clk);
            reset = 1'b0;
        end
    endtask

    task check_conflicting_greens;
        begin
            if (A_ns_green && A_ew_green) begin
                $display("ERROR: Junction A has conflicting green signals.");
                errors = errors + 1;
            end

            if (B_ns_green && B_ew_green) begin
                $display("ERROR: Junction B has conflicting green signals.");
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        emergency_override = 0;

        density_A_NS = 0;
        density_A_EW = 0;
        density_B_NS = 0;
        density_B_EW = 0;

        ped_req_A = 0;
        ped_req_B = 0;
        ped_done_A = 0;
        ped_done_B = 0;

        errors = 0;

        // Five different traffic-density combinations.
        test_A_NS[0] = 1; test_A_EW[0] = 1;
        test_B_NS[0] = 1; test_B_EW[0] = 1;

        test_A_NS[1] = 3; test_A_EW[1] = 2;
        test_B_NS[1] = 4; test_B_EW[1] = 1;

        test_A_NS[2] = 7; test_A_EW[2] = 0;
        test_B_NS[2] = 2; test_B_EW[2] = 6;

        test_A_NS[3] = 0; test_A_EW[3] = 7;
        test_B_NS[3] = 6; test_B_EW[3] = 3;

        test_A_NS[4] = 6; test_A_EW[4] = 5;
        test_B_NS[4] = 7; test_B_EW[4] = 7;

        $display("==========================================");
        $display(" AMTGC GREEN-WAVE DENSITY TEST");
        $display(" WAVE_DELAY = 5");
        $display("==========================================");

        for (test_num = 0; test_num < 5; test_num = test_num + 1) begin

            reset_test();

            density_A_NS = test_A_NS[test_num];
            density_A_EW = test_A_EW[test_num];
            density_B_NS = test_B_NS[test_num];
            density_B_EW = test_B_EW[test_num];

            found_A = 0;
            found_B = 0;
            cycles = 0;
            delay_cycles = -1;

            $display("");
            $display("Test %0d: A(NS,EW)=(%0d,%0d), B(NS,EW)=(%0d,%0d)",
                     test_num + 1,
                     density_A_NS, density_A_EW,
                     density_B_NS, density_B_EW);

            // Wait for A's NS green-start pulse.
            while ((found_A == 0) && (cycles < 500)) begin
                @(posedge clk);
                #1;
                cycles = cycles + 1;
                check_conflicting_greens();

                if (A_ns_green_start) begin
                    found_A = 1;
                    $display("  A NS green-start detected at cycle %0d", cycles);
                end
            end

            if (!found_A) begin
                $display("  ERROR: A NS green-start was not detected.");
                errors = errors + 1;
            end
            else begin
                // Count until B's NS green actually becomes active.
                // Check after each rising edge to avoid missing the transition.
                cycles = 0;

                while ((found_B == 0) && (cycles < 500)) begin
                    @(posedge clk);
                    #1;
                    cycles = cycles + 1;
                    check_conflicting_greens();

                    if (B_ns_green) begin
                        found_B = 1;
                        delay_cycles = cycles;
                    end
                end

                if (!found_B) begin
                    $display("  ERROR: B NS green did not become active.");
                    errors = errors + 1;
                end
                else begin
                    $display("  Measured A-start to B-green delay: %0d clock cycles",
                             delay_cycles);

                    // Report the measured delay rather than assuming that
                    // WAVE_DELAY guarantees an exact start-to-start offset.
                    if (delay_cycles >= 5) begin
                        $display("  PASS: B NS green followed A's start.");
                    end
                    else begin
                        $display("  ERROR: B NS green started fewer than 5 cycles later.");
                        errors = errors + 1;
                    end
                end
            end

            // Allow the test to finish cleanly before the next reset.
            repeat (2) @(negedge clk);
        end

        $display("");
        $display("==========================================");
        $display("Density combinations tested: 5");
        $display("Errors: %0d", errors);

        if (errors == 0)
            $display("GREEN-WAVE DENSITY TEST PASSED");
        else
            $display("GREEN-WAVE DENSITY TEST FAILED");

        $display("==========================================");

        $finish;
    end

    initial begin
        #100000;
        $display("ERROR: Global watchdog timeout.");
        $finish;
    end

endmodule
