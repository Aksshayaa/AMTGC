# AMTGC — Demonstration Video Script and Shot List

**Target length:** 3:45 (the allowed range is 2:00–5:00) · **Format:** MP4 (H.264 + AAC) · **Max size:** 100 MB
**Status:** script ready. **The video has not been recorded.**

## Before recording

- [ ] Fix BUG-02 and BUG-03 (or decide not to show those benches), then run `vsim -c -do scripts/run_all.do` and confirm the PASS lines in `sim_logs/`.
- [ ] Open, in this order: VS Code at the repo root, `docs/figures/amtgc_architecture.png`, `docs/figures/junction_fsm.png`, ModelSim with `cd` at the repo root.
- [ ] Set the screen to 1920×1080. Use a VS Code font size of at least 16 and the ModelSim wave font at its largest readable size.
- [ ] Close notifications, and use a headset or external microphone.
- [ ] Record with OBS Studio (Windows), using Display Capture and the microphone at 30 fps.

## Script

| Time | Screen / on-screen action | Narration (speak at a natural pace) |
|---|---|---|
| **0:00–0:25** | Title slide or README title in VS Code preview | "Hi, I'm Aksshaya Rajaselvam. This is AMTGC, an adaptive multi-junction traffic grid controller written in Verilog and verified in ModelSim. It controls two connected four-way junctions. It sizes each green light from traffic density, it coordinates a green wave from junction A to junction B, it serves pedestrians fairly, and it gives an emergency override absolute priority." |
| **0:25–0:55** | `docs/figures/amtgc_architecture.png`, then the VS Code Explorer showing `rtl/`, `testbench/`, `ml/`, `docs/` | "Here's the top level. Each junction is an instance of the same junction controller, with two decision-tree predictors inside it, one for north–south and one for east–west. Junction A runs freely. The green-wave coordinator watches A's green-start pulse and gives B a one-cycle permit. The pedestrian arbiter grants one crossing at a time, and while a crossing or an emergency is active, the top level forces every lamp to red. The RTL is in `rtl`, the testbenches are in `testbench`, and the decision-tree rules and dataset are in `ml`." |
| **0:55–1:45** | `docs/figures/junction_fsm.png`, then `rtl/junction_controller.v`: scroll to the `localparam` states, the `case (state)` block and the output `always @(*)` | "Each junction controller is a seven-state FSM: an initial all-red state, then north–south green, yellow and all-red clearance, then east–west green, yellow and clearance. A phase counter times each state. The green duration is latched when the green starts, so changing densities only affect the next cycle. The lamp outputs come from a separate combinational block that defaults to all-red, so no state can ever show two greens. Emergency and pedestrian hold gate that block directly, so the lamps go red in the same clock cycle." Then open `ml_timing_predictor.v`: "The predictor is the decision tree from `ml/decision_tree_rules.txt` written as comparators. It picks a short, medium or long green of 5, 8 or 12 cycles. It agrees with the labelled dataset on about 95 percent of the rows." |
| **1:45–2:30** | ModelSim: type `vsim -c -do scripts/run_all.do` (or run it beforehand and show the result). Then show `sim_logs/` and run `findstr "PASS FAIL" sim_logs\*.log` | "The design is checked bottom-up: unit benches for each module, then integration, green-wave, pedestrian and a randomised stress bench. This script compiles everything and runs all the benches. Here are the results." **Read out the actual PASS/FAIL lines. Do not claim a pass that is not on screen.** |
| **2:30–3:15** | ModelSim GUI: `vsim work.tb_green_wave_timing`, then `add wave -r /*`, then `run -all`, then Zoom Full. Place cursors on `A_ns_green_start` and B's NS green. Then `vsim work.tb_amtgc_top`, `run -all`, and zoom on the emergency pulse. | "This is the green-wave timing test. Here A starts its north–south green, and here B's north–south green comes on. The measured delay is [read value] cycles, and the target is five. Now the top-level test: these are the twelve lamp outputs cycling normally, and when emergency override goes high here, every red goes high and every green and yellow drops in the same cycle." |
| **3:15–3:45** | `docs/AMTGC_Technical_Report.pdf` → Section 13 (Limitations), then `docs/BUG_LOG.md` | "To sum up, the design meets its safety properties by construction, and the simulations show adaptive timing, coordination, pedestrian service and emergency override working. It's a simulation-only design: it hasn't been synthesised or tested on hardware, and the bug log records the open issues, such as two older testbenches that need updating. The full details are in the technical report. Thanks for watching." |

## After recording

1. Watch the whole video once and check that the audio is clear and the waveform text is readable.
2. Check the length (2:00–5:00) and the file size (≤ 100 MB).
3. If the file is too large, compress it:

```bash
ffmpeg -i amtgc_demo_raw.mp4 -c:v libx264 -preset slow -crf 26 -vf "scale=1920:-2,fps=30" -c:a aac -b:a 128k -movflags +faststart amtgc_demo.mp4
```

4. Upload it in the submission form. Note that the video cannot be replaced after submission.
