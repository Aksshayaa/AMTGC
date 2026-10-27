"""Check that the AMTGC submission deliverables exist and that internal links resolve.

Usage (from repo root):  python3 scripts/check_deliverables.py
Exit code 1 if any check fails. Read-only: modifies nothing.
"""
import pathlib, re, subprocess, sys

root = pathlib.Path(__file__).resolve().parent.parent
fails = []

def check(ok, msg):
    print(("PASS " if ok else "FAIL ") + msg)
    if not ok:
        fails.append(msg)

for f in ["README.md", "docs/AMTGC_Technical_Report.pdf", "docs/AMTGC_Technical_Report.md",
          "docs/BUG_LOG.md", "docs/ASSUMPTIONS.md", "docs/SELF_ATTESTATION_CHECKLIST.md",
          "docs/SCREENSHOT_CHECKLIST.md", "docs/DEMO_VIDEO_SCRIPT.md", "scripts/run_all.do",
          *[f"rtl/{m}.v" for m in ["amtgc_top", "junction_controller", "ml_timing_predictor",
                                   "green_wave_coordinator", "ped_arbiter", "generic_timer"]]]:
    p = root / f
    check(p.is_file() and p.stat().st_size > 0, f"{f} exists and is non-empty")

for tb in sorted((root / "testbench").glob("*.v")):
    check(tb.stat().st_size > 0, f"{tb.relative_to(root)} is non-empty")

# Relative links and image paths in README and docs/*.md must resolve.
for md in [root / "README.md", *sorted((root / "docs").glob("*.md"))]:
    for target in re.findall(r'(?:\]\(|src=")([^)"#]+)', md.read_text()):
        if target.startswith(("http", "mailto")):
            continue
        check((md.parent / target).exists(), f"{md.relative_to(root)} -> {target}")

# Screenshots the docs promise (proposed names; adjust to the assignment's required names).
for s in ["modelsim_compilation.png", "ml_timing_sweep test passed.png",
          "green_wave_density test passed.png", "ped_arbiter_fairness final test.png",
          "pedestrian_integration final test.png", "amtgc_stress_test transcript.png",
          "green wave timing final test passed.png", "junction_controller_final test.png", "project_structure.png"]:
    check((root / "screenshots" / s).is_file(), f"screenshots/{s} captured")

check(any((root / "sim_logs").glob("*.log")) if (root / "sim_logs").exists() else False,
      "sim_logs/*.log from scripts/run_all.do present")

diff = subprocess.run(["git", "-C", str(root), "status", "--porcelain", "rtl"], capture_output=True, text=True).stdout
check(diff.strip() == "", "rtl/ unchanged versus last commit")

print(f"\n{len(fails)} check(s) failed")
sys.exit(1 if fails else 0)
