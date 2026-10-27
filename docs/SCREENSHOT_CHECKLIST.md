# AMTGC — Screenshot Checklist

The assignment document defines the **exact mandatory screenshot filenames**, and that document is not in the repository. The list below is based on the generic guidance ("ModelSim compilation, simulation output, waveform verification, correct state transitions, project structure") and on the files already present. **Before capturing, check each filename against the assignment document and rename the targets to match it.**

The working machine used for these documents has no ModelSim, so no new screenshots were captured. Every item that needs ModelSim is **BLOCKED here** and must be captured on the Windows PC that has ModelSim 2020.1.

## A. Existing screenshots (reviewed 27 Oct 2026)

| File | Shows | Matches committed RTL? | Status |
|---|---|---|---|
| `screenshots/amtgc_top_level_simulation.png` | `tb_amtgc_top` waveform, `errors = 0`, emergency pulse | Consistent; transcript not visible | PARTIAL (re-capture with transcript recommended) |
| `screenshots/junction_controller_test.png` | Full 7-state cycle + emergency | **No**: earlier RTL revision (BUG-02) | Kept for reference; superseded by `junction_controller_final test.png` |
| `screenshots/ml_timimg_predictor test.png` | 9 directed vectors, `errors = 0` | Values match RTL; bench file is now empty (BUG-01) | PARTIAL |
| `screenshots/ped_arbiter test pass.png` | Grants A, B, simultaneous, emergency | **No**: earlier RTL revision (BUG-03) | PARTIAL (re-capture) |
| ~~`screenshots/green_wave_timing_test_passed.png`~~ | `measured_delay = 7`, `errors = 1` (fail) | **No**: earlier RTL | Deleted in commit `82e9f6f`; superseded |
| `screenshots/system_architecture.png` | Conceptual block diagram | Partly (shows a shared predictor and a timer in use) | PARTIAL (accurate version: `docs/figures/amtgc_architecture.png`) |
| `screenshots/FSM diagram.png` | Conceptual FSM | **No** (6 states; hold semantics wrong; OBS-06) | PARTIAL (accurate version: `docs/figures/junction_fsm.png`) |

Do **not** delete or rename these until you know the required names. If the assignment requires specific names, save new captures under those names and decide separately whether to keep the old ones.

## B. ModelSim captures of the final RTL (added 28 Oct 2026, commit 7f5983b)

| File | Shows | Status |
|---|---|---|
| `ml_timing_sweep test passed.png` + `ml_timing_sweep transcript.png` | 64/64, `Errors: 0`, PASSED | COMPLETE |
| `green_wave_density test passed.png` | `delay_cycles = 5` in all 5 tests, `errors = 0` | COMPLETE (transcript not included; optional) |
| `ped_arbiter_fairness final test.png` + `… transcript.png` | Final arbiter (`pending_*` visible), PASSED | COMPLETE |
| `pedestrian_integration final test.png` + `… transcript.png` | All-red during grants, emergency drops grant, PASSED | COMPLETE |
| `amtgc_stress_test transcript.png` | 8 emergency checks, 100 random samples, PASSED | COMPLETE (waveform optional) |
| `green wave timing final test passed.png` | `measured_delay = 5`, `errors = 0` | COMPLETE (commit 82e9f6f) |
| `junction_controller_final test.png` | Final ports connected; 010→011→100, emergency → 000, 001→…→101; `errors = 0` | COMPLETE (state 110 is outside the zoom window; *Zoom Full* would show all 7) |

## C. Still missing (capture in ModelSim)

| # | Suggested filename | Commands | Must show | Priority |
|---|---|---|---|---|
| M3 | `modelsim_compilation.png` | `vlib work`; `vlog -timescale 1ns/1ps rtl/*.v` | `Errors: 0` | Should |
| M4 | `amtgc_top_level_transcript.png` | after `run -all` of `tb_amtgc_top` | `ALL AMTGC TOP-LEVEL TESTS PASSED` | Should |
| M5 | `project_structure.png` | VS Code Explorer with folders expanded | repo tree | Should (a rendered listing is in `docs/figures/project_structure.png`) |

## D. Capture procedure (ModelSim GUI)

1. `cd` to the repository root in ModelSim (`File → Change Directory`).
2. `vlib work` then `vlog -timescale 1ns/1ps rtl/*.v testbench/<bench>.v`.
3. `vsim work.<top>`, then `add wave -r /*` (or add only the signals listed above), then `run -all`.
4. `Wave → Zoom Full`, set bus radix to *Unsigned* for `state`, `*_cycle` and `measured_delay`. Place cursors on the key edges.
5. Keep the **Transcript** pane visible with the PASS line, so the screenshot shows both the waveform and the verdict.
6. Use `Win + Shift + S`, save as PNG under the exact filename into `screenshots/`, then open the file to confirm that it is readable.
