
`timescale 1ns/1ps

module ml_timing_sweep_tb;

    reg [2:0] density_A_NS;
    reg [2:0] density_A_EW;

    wire [3:0] green_duration;
    wire [1:0] timing_class;

    integer ns;
    integer ew;
    integer errors;
    integer tests;

    ml_timing_predictor dut (
        .density_A_NS(density_A_NS),
        .density_A_EW(density_A_EW),
        .green_duration(green_duration),
        .timing_class(timing_class)
    );

    initial begin
        errors = 0;
        tests = 0;

        $display("====================================");
        $display("ML TIMING PREDICTOR DENSITY SWEEP");
        $display("====================================");

        for (ns = 0; ns < 8; ns = ns + 1) begin
            for (ew = 0; ew < 8; ew = ew + 1) begin

                density_A_NS = ns;
                density_A_EW = ew;

                #1;
                tests = tests + 1;

                case (timing_class)
                    2'b00: begin
                        if (green_duration !== 4'd5) begin
                            $display(
                                "FAIL: NS=%0d EW=%0d CLASS=SHORT DURATION=%0d",
                                ns, ew, green_duration
                            );
                            errors = errors + 1;
                        end
                    end

                    2'b01: begin
                        if (green_duration !== 4'd8) begin
                            $display(
                                "FAIL: NS=%0d EW=%0d CLASS=MEDIUM DURATION=%0d",
                                ns, ew, green_duration
                            );
                            errors = errors + 1;
                        end
                    end

                    2'b10: begin
                        if (green_duration !== 4'd12) begin
                            $display(
                                "FAIL: NS=%0d EW=%0d CLASS=LONG DURATION=%0d",
                                ns, ew, green_duration
                            );
                            errors = errors + 1;
                        end
                    end

                    default: begin
                        $display(
                            "FAIL: Invalid timing class at NS=%0d EW=%0d",
                            ns, ew
                        );
                        errors = errors + 1;
                    end
                endcase

                if ((green_duration < 5) ||
                    (green_duration > 12)) begin
                    $display(
                        "FAIL: Timing outside limits at NS=%0d EW=%0d",
                        ns, ew
                    );
                    errors = errors + 1;
                end

            end
        end

        $display("------------------------------------");
        $display("Density combinations tested: %0d", tests);
        $display("Errors: %0d", errors);

        if ((errors == 0) && (tests == 64))
            $display("ML TIMING SWEEP PASSED");
        else
            $display("ML TIMING SWEEP FAILED");

        $display("====================================");
        $finish;
    end

endmodule
