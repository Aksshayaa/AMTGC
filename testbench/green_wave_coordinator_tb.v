
`timescale 1ns/1ps

module tb_green_wave_coordinator;

    reg clk;
    reg reset;
    reg emergency_override;
    reg a_ns_green_start;
    reg b_ready;

    wire b_ns_green_permit;

    integer errors;

    green_wave_coordinator #(
        .WAVE_DELAY(5)
    ) dut (
        .clk(clk),
        .reset(reset),
        .emergency_override(emergency_override),
        .a_ns_green_start(a_ns_green_start),
        .b_ready(b_ready),
        .b_ns_green_permit(b_ns_green_permit)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        errors = 0;
        reset = 1;
        emergency_override = 0;
        a_ns_green_start = 0;
        b_ready = 0;

        // Reset the coordinator
        repeat (2) @(negedge clk);
        reset = 0;

        // Test 1: Start Junction A's NS green
        @(negedge clk);
        a_ns_green_start = 1;
        @(negedge clk);
        a_ns_green_start = 0;

        // B is not ready, so no permit should appear.
        repeat (7) begin
            @(negedge clk);
            if (b_ns_green_permit !== 1'b0) begin
                $display("FAIL: Permit asserted while B was not ready");
                errors = errors + 1;
            end
        end

        // Test 2: Make B ready after the delay has elapsed.
        b_ready = 1;
        @(negedge clk);

        if (b_ns_green_permit !== 1'b1) begin
            $display("FAIL: Permit not issued when B became ready");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Permit issued when B was ready");
        end

        // Permit should be a one-cycle pulse.
        @(negedge clk);
        if (b_ns_green_permit !== 1'b0) begin
            $display("FAIL: Permit did not return low");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Permit is a one-cycle pulse");
        end

        // Test 3: Emergency cancels pending coordination.
        b_ready = 0;
        @(negedge clk);
        a_ns_green_start = 1;
        @(negedge clk);
        a_ns_green_start = 0;

        emergency_override = 1;
        @(negedge clk);

        if (b_ns_green_permit !== 1'b0) begin
            $display("FAIL: Permit active during emergency");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Emergency suppresses permit");
        end

        emergency_override = 0;
        repeat (2) @(negedge clk);

        if (errors == 0)
            $display("ALL GREEN-WAVE TESTS PASSED");
        else
            $display("GREEN-WAVE TESTS FAILED: %0d errors", errors);

        $finish;
    end

    initial begin
        $monitor(
            "t=%0t A_start=%b B_ready=%b permit=%b emergency=%b",
            $time, a_ns_green_start, b_ready,
            b_ns_green_permit, emergency_override
        );
    end

    initial begin
        #1000;
        $display("FAIL: Simulation timeout");
        $finish;
    end

endmodule
