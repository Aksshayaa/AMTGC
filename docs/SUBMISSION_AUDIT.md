# AMTGC — Submission Audit (27 Oct 2026)

Re-run `python3 scripts/check_deliverables.py` after each change. At the time of writing it reports 10 failing checks, all of them pending manual items.

## 1. Requirements checklist

| # | Requirement (source) | Location | Status |
|---|---|---|---|
| R1 | Read the project-specific assignment document | — (not in the repository) | **BLOCKED**: provide the document |
| R2 | Prescribed folder structure (assignment) | Existing `rtl/ testbench/ ml/ screenshots/` kept; `docs/` and `scripts/` added | PARTIAL: cannot be compared with the prescribed structure |
| R3 | Technical report with the mandatory sections (guidance) | `docs/AMTGC_Technical_Report.pdf` (14 pp, A4) + `.md` source | PARTIAL: complete; results need updating after re-simulation; author review needed |
| R4 | Mandatory ModelSim screenshots with the specified filenames (guidance) | `screenshots/`, `docs/SCREENSHOT_CHECKLIST.md` | **BLOCKED** here (no ModelSim); 3 of 5 existing waveforms are from older RTL |
| R5 | README (guidance) | `README.md` | COMPLETE: rewritten to match the repository |
| R6 | Bug log (guidance) | `docs/BUG_LOG.md` | COMPLETE: 5 bugs, 8 observations |
| R7 | Assumptions document (guidance) | `docs/ASSUMPTIONS.md` | COMPLETE |
| R8 | Self-attestation checklist (guidance) | `docs/SELF_ATTESTATION_CHECKLIST.md` | PARTIAL: author must complete and sign |
| R9 | Demo video, 2–5 min, MP4/WebM/MOV, ≤ 100 MB (rules) | `docs/DEMO_VIDEO_SCRIPT.md` | PARTIAL: script only, not recorded |
| R10 | Compiles and simulates; meaningful scenarios; state transitions; waveform analysis (guidance) | `testbench/`, `sim_logs/iverilog/`, report §7–§12 | PARTIAL: Icarus regression on the final RTL, 9/11 pass after the BUG-02 fix; T6 fails from a bench defect (BUG-03), and T12 fails only in Icarus (BUG-06; passes in ModelSim). ModelSim captures exist for 5 benches |
| R11 | Public GitHub repository (rules) | `github.com/Aksshayaa/AMTGC` | **NOT READY**: repository is PRIVATE (checked with `gh repo view`) |
| R12 | Clean, professional repository (guidance) | — | PARTIAL: see §4 |

## 2. Integrity checks

- The RTL in `rtl/` is unchanged (`git status` shows only `README.md` modified, plus the new `docs/` and `scripts/` directories).
- No testbench, screenshot or other existing file was modified, renamed or deleted.
- No commits or pushes were made.
- The report PDF opens (14 pages), all figure paths and section cross-references resolve, and all README links resolve.

## 3. Evidence gaps

- The final RTL was simulated with **Icarus Verilog 13.0** (`scripts/run_iverilog.sh`), not ModelSim. The assignment's ModelSim evidence still has to be produced on a machine that has ModelSim.
- The old failing `green_wave_timing_test_passed.png` was removed in commit `82e9f6f`. The new ModelSim capture `green wave timing final test passed.png` shows `measured_delay = 5`, `errors = 0`.

## 4. Repository hygiene (decisions for the author)

| Item | Recommendation |
|---|---|
| `work/`, `vsim.wlf` committed | Remove from git and add a `.gitignore` (`work/`, `*.wlf`, `transcript`, `sim_logs/`), unless the assignment requires them |
| `testbench/*.bak` (6 files) | Delete after restoring `ml_timing_predictor_tb.v` (BUG-01) |
| `testbench/README.md` duplicates an older project README | Replace it with a short bench index, or delete it |
| Screenshot names contain spaces and a typo (`ml_timimg_predictor test.png`) | Rename to the assignment's required names (this audit renamed nothing) |
| `docs/AMTGC_Technical_Report.html` | Build intermediate; keep it or delete it |

## 5. Steps before submission

1. Obtain the assignment document. Align folder names, report filename and screenshot filenames with it.
2. Fix the testbenches: BUG-01 (restore from `.bak`), BUG-02 (connect ports), BUG-03 (wait-based checks), BUG-06 (stress-bench race). Re-run `bash scripts/run_iverilog.sh` to check.
3. On the ModelSim PC, run `vsim -c -do scripts/run_all.do` and keep `sim_logs/`.
4. Capture screenshots S1–S11 (`docs/SCREENSHOT_CHECKLIST.md`).
5. Update report §10 and §12, the README status table and the bug-log statuses with the real results. Then run `python3 docs/build_report.py`.
6. Record the video and watch it back.
7. Complete the self-attestation checklist and sign it.
8. Commit and push, make the repository public, and open the link in an incognito window.

**Verdict: NOT READY — MANDATORY ITEMS REMAIN**
