# AMTGC - batch regression for ModelSim / QuestaSim.
# Run from the repository root:
#   vsim -c -do scripts/run_all.do
# One log per testbench is written to sim_logs/<top>.log.
# Does not modify any RTL or testbench file.

onerror {resume}
file mkdir sim_logs
if {[file exists work]} { vdel -lib work -all }
vlib work

transcript file sim_logs/compile.log
# -timescale gives a default to files without a `timescale directive
# (generic_timer.v, ml_timing_predictor.v, generic_timer_tb.v).
vlog -timescale 1ns/1ps rtl/generic_timer.v rtl/ml_timing_predictor.v \
     rtl/junction_controller.v rtl/green_wave_coordinator.v \
     rtl/ped_arbiter.v rtl/amtgc_top.v

# testbench file -> top-level module name inside it
# (testbench/ml_timing_predictor_tb.v is empty in this commit and is skipped; see docs/BUG_LOG.md BUG-01)
set benches {
    generic_timer_tb            tb_generic_timer
    ml_timing_sweep_tb          ml_timing_sweep_tb
    junction_controller_tb      tb_junction_controller
    green_wave_coordinator_tb   tb_green_wave_coordinator
    ped_arbiter_tb              tb_ped_arbiter
    ped_arbiter_fairness_tb     tb_ped_arbiter_fairness
    amtgc_top_tb                tb_amtgc_top
    green_wave_timing_tb        tb_green_wave_timing
    green_wave_density_tb       green_wave_density_tb
    pedestrian_integration_tb   tb_pedestrian_integration
    amtgc_stress_tb             amtgc_stress_tb
}

foreach {file top} $benches {
    transcript file sim_logs/$top.log
    vlog -timescale 1ns/1ps testbench/$file.v
    vsim -c -onfinish stop work.$top
    run -all
    quit -sim
}

transcript file sim_logs/compile_tail.log
echo "Regression finished. Inspect sim_logs/*.log for PASS/FAIL lines."
quit -f
