
`timescale 1ns/1ps

module tb_ped_arbiter;

    reg clk;
    reg reset;
    reg emergency_override;

    reg ped_req_A;
    reg ped_req_B;
    reg ped_done_A;
    reg ped_done_B;

    wire ped_grant_A;
    wire ped_grant_B;

    ped_arbiter dut (
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

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        emergency_override = 0;
        ped_req_A = 0;
        ped_req_B = 0;
        ped_done_A = 0;
        ped_done_B = 0;

        repeat (2) @(negedge clk);
        reset = 0;

        // Test 1: Request A
        ped_req_A = 1;
        @(negedge clk);
        if (!ped_grant_A)
            $display("FAIL: A was not granted");
        else
            $display("PASS: A was granted");

        // Finish A's service
        ped_done_A = 1;
        @(negedge clk);
        ped_done_A = 0;
        ped_req_A = 0;

        // Test 2: Request B
        ped_req_B = 1;
        @(negedge clk);
        if (!ped_grant_B)
            $display("FAIL: B was not granted");
        else
            $display("PASS: B was granted");

        // Finish B's service
        ped_done_B = 1;
        @(negedge clk);
        ped_done_B = 0;
        ped_req_B = 0;

        // Test 3: Simultaneous requests
        ped_req_A = 1;
        ped_req_B = 1;
        @(negedge clk);

        if (ped_grant_A && ped_grant_B)
            $display("FAIL: Both junctions granted together");
        else if (ped_grant_A || ped_grant_B)
            $display("PASS: Only one junction granted");
        else
            $display("FAIL: No junction granted");

        // Test 4: Emergency override
        emergency_override = 1;
        #1;
        if (!ped_grant_A && !ped_grant_B)
            $display("PASS: Grants disabled during emergency");
        else
            $display("FAIL: Grant active during emergency");

        $display("Pedestrian arbiter test sequence completed");
        #10;
        $finish;
    end

    initial begin
        $monitor("t=%0t A_req=%b B_req=%b A_grant=%b B_grant=%b",
                 $time, ped_req_A, ped_req_B,
                 ped_grant_A, ped_grant_B);
    end

endmodule
