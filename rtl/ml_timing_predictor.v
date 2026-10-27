
module ml_timing_predictor (
    input  [2:0] density_A_NS,
    input  [2:0] density_A_EW,
    output reg [3:0] green_duration,
    output reg [1:0] timing_class
);

    // Timing classes:
    // 00 = SHORT  = 5 clock cycles
    // 01 = MEDIUM = 8 clock cycles
    // 10 = LONG   = 12 clock cycles

    always @(*) begin

        if (density_A_NS <= 1) begin

            if (density_A_EW <= 6)
                timing_class = 2'b00;
            else begin
                if (density_A_NS == 0)
                    timing_class = 2'b00;
                else
                    timing_class = 2'b01;
            end

        end
        else if (density_A_NS <= 4) begin

            if (density_A_EW <= 3) begin
                if (density_A_NS <= 2)
                    timing_class = 2'b00;
                else
                    timing_class = 2'b01;
            end
            else begin
                if (density_A_NS <= 3)
                    timing_class = 2'b01;
                else
                    timing_class = 2'b10;
            end

        end
        else if (density_A_NS <= 5) begin

            if (density_A_EW <= 2)
                timing_class = 2'b01;
            else
                timing_class = 2'b10;

        end
        else begin
            timing_class = 2'b10;
        end

        case (timing_class)
            2'b00: green_duration = 4'd5;
            2'b01: green_duration = 4'd8;
            2'b10: green_duration = 4'd12;
            default: green_duration = 4'd5;
        endcase

    end

endmodule
