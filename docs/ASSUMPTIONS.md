# AMTGC — Assumptions and Interpretations

## 1. Requirement sources available

The project-specific assignment document is **not in the repository** and was not available when this file was written (27 Oct 2026). The only requirement text available was the generic submission guidance. It asks for:

| Explicit requirement (from submission guidance) | Where met |
|---|---|
| Follow the prescribed folder structure | **Cannot be confirmed**: the prescribed structure is in the missing assignment document. |
| Technical report: overview, architecture, RTL design, FSM design, verification methodology, simulation results, challenges, conclusions | `docs/AMTGC_Technical_Report.pdf` |
| Mandatory ModelSim/project screenshots with specified filenames | `screenshots/`. The specified filenames are unknown; see `docs/SCREENSHOT_CHECKLIST.md`. |
| Demonstration video, 2–5 min, MP4/WebM/MOV, ≤ 100 MB | Script in `docs/DEMO_VIDEO_SCRIPT.md`; recording not yet made |
| README, Bug Log, Assumptions Document, Self-Attestation Checklist | `README.md`, `docs/BUG_LOG.md`, this file, `docs/SELF_ATTESTATION_CHECKLIST.md` |
| Public, accessible GitHub repository | Repository is currently **private** |
| Verification: correct functionality, meaningful scenarios, waveform analysis, correct state transitions | `testbench/`, report §7–§12 |

Everything below is an assumption or interpretation, not a stated requirement. If the assignment document contradicts any item, the document wins.

## 2. Assumptions

| ID | Assumption / interpretation | Reason | Related spec | Impact on design | Verification implication | Confirmation needed? |
|---|---|---|---|---|---|---|
| A-01 | No target clock frequency. All durations are in clock cycles. The 10 ns testbench period is a simulation convenience only. | No frequency appears in the RTL or the available guidance | None found | Green durations of 5, 8 and 12 cycles have no real-time meaning | Timing results are reported in cycles only. No STA was run. | Yes, if the assignment specifies seconds or a clock |
| A-02 | Reset is active-high and synchronous. | As implemented in every sequential block | None found | Reset takes effect on the next `posedge clk` | Benches hold reset for ≥ 2 edges | No (describes the RTL) |
| A-03 | `emergency_override` is level-sensitive. It must force all-red immediately and suppress pedestrian grants. | Implemented combinationally plus a synchronous FSM reset | Guidance mentions "emergency override" only via the README | Lamps go red in the same cycle | Benches check at `#1` after assertion | Yes, if a minimum yellow is required before red on override |
| A-04 | Density inputs are 3-bit levels (0–7) with no physical unit. | Port width in RTL; dataset range 0–7 | None found | Predictor thresholds are integers | Sweep covers all 64 pairs | Yes, if the inputs should model sensor counts |
| A-05 | All inputs are synchronous to `clk` and glitch-free. | No synchronisers in RTL | None found | Real asynchronous buttons would need synchronisers or debouncing | Benches drive inputs on `negedge` | Yes, for any hardware use |
| A-06 | Crossing duration is set externally by `ped_done_A/B`. `PED_SERVICE_CYCLES` is not used. | As implemented | None found | No minimum or maximum crossing time is enforced | Benches assert `ped_done` manually | Yes, if a fixed crossing time is required |
| A-07 | A pedestrian request is registered on the rising edge of `ped_req_X`. Holding the button does not re-request. | As implemented | None found | One press gives one service | Benches pulse or raise requests | No |
| A-08 | "Green wave" means Junction B's NS green starts `WAVE_DELAY` cycles after Junction A's NS green-start pulse, measured at the lamp output. It applies only to the NS direction, A → B. | Coordinator code and `green_wave_timing_tb.v` pass window of 5–6 cycles | None found | Junction B's NS phase is slaved to A's | T9 and T10 measure this offset | Yes |
| A-09 | The "AI/ML" component is a fixed decision tree hard-coded as combinational logic. No on-chip learning. | `ml/decision_tree_rules.txt` equals the RTL; no training script in the repo | Project title | Model is fixed at design time | 95.31 % agreement with the dataset is reported | Yes, if the assignment expects a trained-model workflow to be shown |
| A-10 | Junction A's NS green is always enabled (`ns_green_enable = 1'b1`), so A is the master and B the follower. | As implemented in `amtgc_top` | None found | B cannot run faster than A | — | No |
| A-11 | Yellow = 3 cycles and all-red clearance = 2 (effectively 3) cycles are illustrative values. | Parameter defaults | None found | Fixed by parameters | — | Yes, if specific values are required |
| A-12 | Report, logs and supporting documents go under `docs/`. Screenshots stay in the existing `screenshots/` folder. | The existing README already reserves a `docs/` folder; no other structure is known | Missing assignment document | None on the RTL | — | **Yes: check against the assignment's prescribed structure and filenames** |
| A-13 | Simulator: ModelSim Intel FPGA Edition 2020.1. | Version string in `work/_info` | README | `scripts/run_all.do` uses ModelSim commands | — | No |
