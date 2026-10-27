#!/usr/bin/env bash
# AMTGC regression with Icarus Verilog (cross-check; ModelSim remains the reference flow: scripts/run_all.do).
# Usage from repo root:  bash scripts/run_iverilog.sh
# Logs: sim_logs/iverilog/<top>.log + summary.txt. Build files go to a temp dir. Modifies no source file.
set -u
cd "$(dirname "$0")/.."
out=sim_logs/iverilog; build=$(mktemp -d); mkdir -p "$out"
iverilog -V 2>&1 | head -1 > "$out/tool_version.txt"
benches="generic_timer_tb:tb_generic_timer ml_timing_sweep_tb:ml_timing_sweep_tb
junction_controller_tb:tb_junction_controller green_wave_coordinator_tb:tb_green_wave_coordinator
ped_arbiter_tb:tb_ped_arbiter ped_arbiter_fairness_tb:tb_ped_arbiter_fairness amtgc_top_tb:tb_amtgc_top
green_wave_timing_tb:tb_green_wave_timing green_wave_density_tb:green_wave_density_tb
pedestrian_integration_tb:tb_pedestrian_integration amtgc_stress_tb:amtgc_stress_tb"
: > "$out/summary.txt"
for pair in $benches; do
  f=${pair%%:*}; top=${pair##*:}; log=$out/$top.log
  { echo "# iverilog -g2005 -s $top rtl/*.v testbench/$f.v"
    iverilog -g2005 -s "$top" -o "$build/$top.vvp" rtl/*.v "testbench/$f.v" 2>&1 && timeout 60 vvp -n "$build/$top.vvp" 2>&1
    echo "# exit=$?"; } > "$log"
  fails=$(grep -cE '^ *(FAIL|ERROR)' "$log")
  printf '%-28s FAIL/ERROR lines: %s\n' "$top" "$fails" | tee -a "$out/summary.txt"
done
echo "(testbench/ml_timing_predictor_tb.v skipped: empty file, BUG-01)" | tee -a "$out/summary.txt"
rm -rf "$build"
