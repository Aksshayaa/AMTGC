
`timescale 1ns/1ps

module tb_junction_controller;

    reg clk;
    reg reset;
    reg emergency_override;

    reg [2:0] density_NS;
    reg [2:0] density_EW;

    wire ns_red, ns_yellow, ns_green;
    wire ew_red, ew_yellow, ew_green;
    wire [2:0] state;

    integer errors;

    junction_controller dut (
        .clk(clk),
        .reset(reset),
        .emergency_override(emergency_override),
        .density_NS(density_NS),
        .density_EW(density_EW),
        .ns_red(ns_red),
        .ns_yellow(ns_yellow),
        .ns_green(ns_green),
        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green),
        .state(state)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // Check that the two directions never have green simultaneously.
    always @(negedge clk) begin
        if (!reset) begin
            if (ns_green && ew_green) begin
                $display("FAIL: Both directions are green!");
                errors = errors + 1;
            end

            if (emergency_override &&
                !(ns_red && ew_red &&
                  !ns_green && !ew_green &&
                  !ns_yellow && !ew_yellow)) begin
                $display("FAIL: Emergency is not all red!");
                errors = errors + 1;
            end
        end
    end

    initial begin
        errors = 0;
        reset = 1;
        emergency_override = 0;
        density_NS = 3'd1;
        density_EW = 3'd1;

        // Reset
        repeat (2) @(negedge clk);
        reset = 0;

        // Allow the FSM to run through several phases.
        repeat (40) @(negedge clk);

        // Trigger emergency while the controller is operating.
        emergency_override = 1;
        @(negedge clk);

        if (!(ns_red && ew_red &&
              !ns_green && !ew_green &&
              !ns_yellow && !ew_yellow)) begin
            $display("FAIL: Emergency all-red check");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Emergency all-red check");
        end

        emergency_override = 0;

        // Allow safe recovery and another green phase.
        repeat (20) @(negedge clk);

        if (errors == 0)
            $display("ALL JUNCTION CONTROLLER TESTS PASSED");
        else
            $display("JUNCTION CONTROLLER TESTS FAILED: %0d", errors);

        $finish;
    end

    initial begin
        $monitor(
            "t=%0t state=%0d NS(RYG)=%b%b%b EW(RYG)=%b%b%b",
            $time, state,
            ns_red, ns_yellow, ns_green,
            ew_red, ew_yellow, ew_green
        );
    end

    initial begin
        #2000;
        $display("FAIL: Simulation timeout");
        $finish;
    end

endmodule
