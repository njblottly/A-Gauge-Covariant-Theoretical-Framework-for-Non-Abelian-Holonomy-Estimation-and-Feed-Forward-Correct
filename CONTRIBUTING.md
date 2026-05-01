# Contributing to timebin-berry-phase

Thanks for thinking about contributing! This repository contains Mathematica (Wolfram Language) notebooks and a headless exporter that produces the figures and tables used in our manuscript.

This guide covers how to set up, run, and contribute changes in a way that keeps the exported artifacts reproducible.

---

## Code of Conduct

Please read and follow our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). By participating, you agree to uphold it.

---

## Repository layout (what goes where)

- `src/` — runnable source
  - `run-all.wls` (headless exporter)
  - `notebooks_run-all WLS/` — notebooks executed by the exporter
  - optional: shared utilities as `*.wl`
- `notebooks/` — exploratory or illustrative notebooks **not** run in batch
- `results/` — curated outputs we keep in version control
  - `results/figs/` — final manuscript figures (PNG/PDF)
  - `results/tables/` — CSVs for the paper/SI
  - `results/logs/`, `results/css/` — ephemeral; ok to ignore in Git
- `data/` — small samples or pointers to large/raw data (see Data policy below)
- `docs/` — project documentation (usage notes, figure gallery)
- `scripts/` — helper shell scripts
- `environment/` — reproducibility notes (Mathematica version, OS, paclets, etc.)

---

## Quick start (local)

1. **Clone** and create a feature branch:
   ```bash
   git checkout -b feat/short-description
2. **Run the exporter** (macOS path shown; adjust if needed):
- /Applications/Mathematica.app/Contents/MacOS/WolframKernel -script src/run-all.wls
	- To run a specific notebook:
- /Applications/Mathematica.app/Contents/MacOS/WolframKernel -script src/run-all.wls wavefunctionplot.nb
	- Outputs appear under src/results/figs/, src/results/tables/, and logs in src/results/logs/.
3. Commit only curated outputs you intend to keep (see “What to commit” below), then open a Pull Request (PR).