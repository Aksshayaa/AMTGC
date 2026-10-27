# AMTGC — Self-Attestation Checklist

The author must complete this checklist. Items are ticked only where evidence in the repository supports them; the review on 27 Oct 2026 left all others unticked. The declaration at the end must be completed **by the author personally**.

> The assignment document defines the exact filename and location for this checklist. Check that `docs/SELF_ATTESTATION_CHECKLIST.md` matches them before submitting.

## Repository and structure

- [ ] Folder structure matches the structure prescribed in the assignment document. *(Prescribed structure not available for comparison: see `docs/ASSUMPTIONS.md` A-12.)*
- [x] RTL sources are in `rtl/` (6 modules). Evidence: `rtl/*.v`
- [x] Testbenches are in `testbench/`. Evidence: `testbench/*.v`
- [ ] Every testbench file listed in the README is non-empty. *(BUG-01: `ml_timing_predictor_tb.v` is empty.)*
- [ ] Build artefacts and `.bak` files are removed, or deliberately kept. *(See `docs/SUBMISSION_AUDIT.md` §4.)*

## Design

- [x] RTL implementation is complete for all six modules. Evidence: `rtl/`, report §4
- [x] FSM design is documented with a state diagram and a transition table. Evidence: report §5, `docs/figures/junction_fsm.svg`

## Verification

- [ ] All RTL compiles without errors in ModelSim on the final commit. *(No compile log saved; capture `sim_logs/compile.log`.)*
- [x] All testbenches run on the final RTL with **Icarus Verilog**, with logs saved. Evidence: `sim_logs/iverilog/`
- [ ] All testbenches run on the final commit **in ModelSim**, with logs saved. *(Run `scripts/run_all.do`.)*
- [ ] Every testbench passes meaningfully. *(Icarus: 9/11 pass; T6 fails from a bench defect, BUG-03; T12 fails only in Icarus, BUG-06, and passes in ModelSim.)*
- [ ] FSM state transitions are shown on the current RTL. *(Fig. 4 shows an earlier revision.)*
- [x] Waveform analysis is written up in the report. Evidence: report §10
- [x] Green-wave timing is re-verified on the current RTL: `measured_delay = 5`. Evidence: `sim_logs/iverilog/tb_green_wave_timing.log` *(ModelSim capture still to do)*

## Deliverables

- [ ] All mandatory screenshots are captured with the exact required filenames. *(See `docs/SCREENSHOT_CHECKLIST.md`.)*
- [x] Technical report exists in PDF with an editable source. Evidence: `docs/AMTGC_Technical_Report.pdf`, `.md`
- [ ] Technical report has been reviewed by the author, and results are updated after re-simulation.
- [x] README is updated. Evidence: `README.md`
- [x] Bug log exists. Evidence: `docs/BUG_LOG.md`
- [x] Assumptions document exists. Evidence: `docs/ASSUMPTIONS.md`
- [ ] Demonstration video is recorded, 2–5 min, MP4/WebM/MOV, ≤ 100 MB, and watched back. *(Script: `docs/DEMO_VIDEO_SCRIPT.md`.)*
- [ ] GitHub repository is **public** and opens in a private/incognito browser window without login. *(Currently private.)*
- [ ] All changes are committed and pushed, and GitHub shows the final files.

## Final review

- [ ] Re-read the assignment document and confirmed every mandatory item.
- [ ] All submitted links tested while logged out.
- [ ] Understood that the submission is one-time and cannot be changed.

## Author declaration (complete personally)

I declare that the design, testbenches and results in this repository are my own work. Any assistance is acknowledged, and the results reported are those I obtained.

Name: ______________________  Signature: ______________________  Date: ____________
