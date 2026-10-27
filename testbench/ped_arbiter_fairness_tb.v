`timescale 1ns/1ps


module tb_ped_arbiter_fairness;

reg clk, reset, emergency_override;
reg ped_req_A, ped_req_B;
reg ped_done_A, ped_done_B;

wire ped_grant_A, ped_grant_B;

integer errors;
integer completed;
reg [1:0] grant_order [0:3];

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

task complete_current;
begin
wait (ped_grant_A || ped_grant_B);
@(negedge clk);

if (ped_grant_A) begin
grant_order[completed] = 2'd1;
ped_done_A = 1'b1;
end
else begin
grant_order[completed] = 2'd2;
ped_done_B = 1'b1;
end

completed = completed + 1;

@(negedge clk);
ped_done_A = 1'b0;
ped_done_B = 1'b0;
end
endtask

initial begin
errors = 0;
completed = 0;
reset = 1;
emergency_override = 0;
ped_req_A = 0;
ped_req_B = 0;
ped_done_A = 0;
ped_done_B = 0;

repeat (3) @(negedge clk);
reset = 0;

@(negedge clk);
ped_req_A = 1;
ped_req_B = 1;

@(negedge clk);
ped_req_A = 0;
ped_req_B = 0;

complete_current();
complete_current();

if (grant_order[0] == 2'd1 &&
grant_order[1] == 2'd2)
$display("PASS: Initial simultaneous requests served A then B");
else if (grant_order[0] == 2'd2 &&
grant_order[1] == 2'd1)
$display("PASS: Both simultaneous requests served without starvation");
else begin
$display("FAIL: Unexpected initial service order");
errors = errors + 1;
end

@(negedge clk);
ped_req_A = 1;
ped_req_B = 1;

@(negedge clk);
ped_req_A = 0;
ped_req_B = 0;

complete_current();
complete_current();

if (grant_order[2] != grant_order[3])
$display("PASS: Priority alternates across completed services");
else begin
$display("FAIL: Service priority did not alternate");
errors = errors + 1;
end

if (!ped_grant_A && !ped_grant_B) begin
$display("INFO: Arbiter returned to idle");
end

if (errors == 0)
$display("ALL PEDESTRIAN FAIRNESS TESTS PASSED");
else
$display("PEDESTRIAN FAIRNESS TESTS FAILED: %0d errors",
errors);

$finish;
end

initial begin
#3000;
$display("FAIL: Fairness test timed out");
$finish;
end

endmodule