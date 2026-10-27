
module generic_timer #(
    parameter WIDTH = 16
)(
    input clk,
    input reset,
    input start,
    input [WIDTH-1:0] duration,

    output reg active,
    output reg done
);

    reg [WIDTH-1:0] count;
    reg [WIDTH-1:0] target;

    always @(posedge clk) begin
        if (reset) begin
            count  <= 0;
            target <= 0;
            active <= 0;
            done   <= 0;
        end
        else begin
            done <= 0;

            if (start && !active) begin
                count <= 0;

                if (duration == 0) begin
                    target <= 0;
                    active <= 0;
                    done   <= 1;
                end
                else begin
                    target <= duration;
                    active <= 1;
                end
            end
            else if (active) begin
                if (count == target - 1'b1) begin
                    count  <= 0;
                    active <= 0;
                    done   <= 1;
                end
                else begin
                    count <= count + 1'b1;
                end
            end
        end
    end

endmodule
