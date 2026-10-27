
module tb_generic_timer;

    reg clk;
    reg reset;
    reg start;
    reg [15:0] duration;

    wire active;
    wire done;

    generic_timer #(
        .WIDTH(16)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .duration(duration),
        .active(active),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        start = 0;
        duration = 4;

        #20;
        reset = 0;

        @(negedge clk);
        start = 1;

        @(negedge clk);
        start = 0;

        wait(done == 1);

        $display("PASS: Timer completed.");
        $display("Simulation time = %0t", $time);

        #10;
        $finish;
    end

    initial begin
        $monitor(
            "Time=%0t reset=%b start=%b duration=%d active=%b done=%b",
            $time, reset, start, duration, active, done
        );
    end

    initial begin
        #500;
        $display("FAIL: Simulation timeout.");
        $finish;
    end

endmodule
