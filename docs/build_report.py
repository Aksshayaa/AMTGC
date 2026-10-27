"""Build docs/AMTGC_Technical_Report.pdf from the Markdown source.

Usage (from repo root):  python3 docs/build_report.py
Needs: python-markdown, google-chrome (headless print-to-PDF).
"""
import pathlib, shutil, subprocess, markdown

here = pathlib.Path(__file__).resolve().parent
src = here / "AMTGC_Technical_Report.md"
html_path = here / "AMTGC_Technical_Report.html"
pdf_path = here / "AMTGC_Technical_Report.pdf"

CSS = """
@page { size: A4; margin: 20mm 18mm 20mm 18mm;
  @bottom-center { content: "Page " counter(page) " of " counter(pages); font: 9pt Helvetica, Arial, sans-serif; color: #555; }
  @top-right { content: "AMTGC Technical Report"; font: 8.5pt Helvetica, Arial, sans-serif; color: #888; } }
@page :first { @bottom-center { content: none; } @top-right { content: none; } }
body { font: 10.5pt/1.5 "Liberation Serif", "Times New Roman", serif; color: #111; }
h1, h2, h3 { font-family: "Liberation Sans", Helvetica, Arial, sans-serif; color: #0f2a4a; }
h2 { font-size: 15pt; border-bottom: 1.5px solid #0f2a4a; padding-bottom: 3px; margin-top: 26px; break-after: avoid; }
h3 { font-size: 12pt; margin-top: 18px; break-after: avoid; }
code { font: 9pt "Liberation Mono", monospace; background: #f3f4f6; padding: 0 2px; }
pre { background: #f6f8fa; border: 1px solid #e5e7eb; padding: 8px; font-size: 8.6pt; line-height: 1.35; white-space: pre-wrap; break-inside: avoid; }
pre code { background: none; padding: 0; }
table { border-collapse: collapse; width: 100%; margin: 8px 0 4px; font-size: 9pt; break-inside: auto; }
th, td { border: 1px solid #cbd5e1; padding: 3px 5px; vertical-align: top; text-align: left; }
th { background: #e2e8f0; }
tr { break-inside: avoid; }
figure { margin: 14px 0; text-align: center; break-inside: avoid; }
figure img { max-width: 100%; max-height: 13cm; border: 1px solid #ddd; }
figcaption, .caption { font: italic 9pt "Liberation Sans", Arial, sans-serif; color: #333; text-align: center; margin-top: 4px; }
blockquote { border-left: 4px solid #d97706; background: #fffbeb; margin: 10px 0; padding: 6px 12px; }
.title-page { height: 245mm; display: flex; flex-direction: column; justify-content: center; break-after: page; }
.title-page h1 { font-size: 26pt; line-height: 1.2; margin: 6px 0 4px; border: none; }
.tp-kicker { font: bold 11pt Helvetica, Arial, sans-serif; color: #b45309; letter-spacing: .5px; text-transform: uppercase; }
.tp-sub { font: 14pt Helvetica, Arial, sans-serif; color: #334155; margin-bottom: 36px; }
.tp-meta td { border: none; border-bottom: 1px solid #e5e7eb; font-size: 10.5pt; padding: 6px 4px; }
.tp-meta td:first-child { font-weight: bold; width: 32%; color: #0f2a4a; }
.toc-page { break-after: page; }
.toc ul { list-style: none; padding-left: 14px; } .toc > ul { padding-left: 0; }
.toc a { color: #111; text-decoration: none; }
a { color: #1d4ed8; }
"""

body = markdown.markdown(src.read_text(), extensions=["tables", "fenced_code", "toc", "md_in_html"],
                         extension_configs={"toc": {"toc_depth": "2-3"}})
html_path.write_text(f"<!doctype html><html><head><meta charset='utf-8'><title>AMTGC Technical Report</title>"
                     f"<style>{CSS}</style></head><body>{body}</body></html>")
chrome = shutil.which("google-chrome-stable") or shutil.which("google-chrome") or shutil.which("chromium")
subprocess.run([chrome, "--headless", "--disable-gpu", "--no-pdf-header-footer", "--allow-file-access-from-files",
                f"--print-to-pdf={pdf_path}", html_path.as_uri()], check=True, capture_output=True)
print("wrote", pdf_path)
