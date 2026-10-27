
`timescale 1ns/1ps

module ped_arbiter (
    input wire clk,
    input wire reset,
    input wire emergency_override,

    input wire ped_req_A,
    input wire ped_req_B,

    input wire ped_done_A,
    input wire ped_done_B,

    output reg ped_grant_A,
    output reg ped_grant_B
);

    localparam IDLE     = 2'd0;
    localparam SERVING_A = 2'd1;
    localparam SERVING_B = 2'd2;

    reg [1:0] ped_state;
    reg next_priority;

    reg pending_A;
    reg pending_B;

    reg ped_req_A_d;
    reg ped_req_B_d;

    always @(posedge clk) begin
        if (reset) begin
            ped_state    <= IDLE;
            next_priority <= 1'b0; // A wins the first tie
            pending_A    <= 1'b0;
            pending_B    <= 1'b0;
            ped_req_A_d  <= 1'b0;
            ped_req_B_d  <= 1'b0;
        end
        else
         begin
            ped_req_A_d <= ped_req_A;
            ped_req_B_d <= ped_req_B;

            if (ped_req_A && !ped_req_A_d)
                pending_A <= 1'b1;

            if (ped_req_B && !ped_req_B_d)
                pending_B <= 1'b1;

            if (emergency_override) 
            begin
                ped_state <= IDLE;
            end
            else
             begin
                case (ped_state)

                    IDLE: begin
                        if (pending_A && pending_B)
                         begin
                            if (next_priority == 1'b0)
                                ped_state <= SERVING_A;
                            else
                                ped_state <= SERVING_B;
                        end
                        else if (pending_A)
                         begin
                            ped_state <= SERVING_A;
                        end
                        else if (pending_B)
                         begin
                            ped_state <= SERVING_B;
                        end
                    end

                    SERVING_A: begin
                        if (ped_done_A) 
                        begin
                            ped_state     <= IDLE;
                            pending_A     <= 1'b0;
                            next_priority <= 1'b1;
                        end
                    end

                    SERVING_B: begin
                        if (ped_done_B) 
                        begin
                            ped_state     <= IDLE;
                            pending_B     <= 1'b0;
                            next_priority <= 1'b0;
                        end
                    end

                    default: begin
                        ped_state <= IDLE;
                    end

                endcase
            end
        end
    end

    always @(*) begin
        ped_grant_A = 1'b0;
        ped_grant_B = 1'b0;

        if (!reset && !emergency_override)
         begin
            if (ped_state == SERVING_A)
                ped_grant_A = 1'b1;
            else if (ped_state == SERVING_B)
                ped_grant_B = 1'b1;
        end
    end

endmodule
