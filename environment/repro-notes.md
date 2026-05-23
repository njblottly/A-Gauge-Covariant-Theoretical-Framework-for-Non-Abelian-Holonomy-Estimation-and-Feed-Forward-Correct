# Reproducibility Notes — A-Gauge-Covariant-Theoretical-Framework-for-Non-Abelian-Holonomy-Estimation-and-Feed-Forward-Correct

This repository accompanies the manuscript **“A-Gauge-Covariant-Theoretical-Framework-for-Non-Abelian-Holonomy-Estimation-and-Feed-Forward-Correct.”**

It contains Wolfram Mathematica / Wolfram Language scripts and notebooks that reproduce the paper’s synthetic theoretical validation checks, including gauge covariance, non-Abelian path ordering, mesh-refinement convergence, conditioning diagnostics, and feed-forward correction fidelity.

This repository supports a theoretical manuscript. The generated data are synthetic validation outputs, not experimental measurements.

---

## System used for the main runs

- **Wolfram Mathematica:** 13.3
- **Kernel:** Wolfram Language 13.3.0.0
- **Platform:** macOS, Apple Silicon / ARM, 64-bit
- See the exact environment snapshot in `wolfram-version.txt`.

---

## Repository layout

```text
src/
  run-all.wls                         # Headless driver; kernel only, no front end required

results/
  figs/                               # Auto-generated figures, if enabled
  tables/                             # Auto-generated CSV validation tables
  logs/                               # Run logs

notebooks_run-all WLS/                # Batch-friendly notebook/script copies used by run-all.wls
notebooks/                            # Original interactive Mathematica notebooks
```

---

## Reproducibility subset

The reproducibility subset is designed to regenerate the main algorithmic validation artifacts.

### 1. Gauge covariance residuals

These checks verify that the reconstructed holonomy transforms by conjugation under discrete frame changes. For a closed loop and a gauge sequence satisfying \(G_N=G_0\), the expected transformation is

\[
\widehat U_\gamma \mapsto G_0^\dagger \widehat U_\gamma G_0.
\]

The reported gauge residual is

\[
\epsilon_{\mathrm{gauge}}
=
\left\|
\widehat U_\gamma'
-
G_0^\dagger \widehat U_\gamma G_0
\right\|_F.
\]

For exact arithmetic this residual is zero. In floating-point arithmetic it should be near machine precision.

### 2. Non-Abelian synthetic connection benchmark

These checks compare the discrete ordered product against a continuum solution of

\[
\dot U(t)=-A(t)U(t),
\qquad
U(0)=I.
\]

The benchmark uses a synthetic noncommuting anti-Hermitian connection, so path ordering is essential.

### 3. Mesh-refinement convergence tables

These checks report the refinement error

\[
\epsilon_N
=
\left\|
\widehat U_N-U_{\mathrm{ref}}
\right\|_F
\]

as the number of time steps \(N\) is increased.

The expected behavior is that \(\epsilon_N\) decreases under partition refinement.

### 4. Conditioning diagnostics

These checks report the minimum singular value of the adjacent-frame overlap matrices,

\[
\mu_{\min}
=
\min_k \sigma_{\min}(M_k).
\]

This quantity diagnoses whether the local subspace-comparison problem is well conditioned. Small values of \(\mu_{\min}\) indicate that the holonomy estimate may be sensitive to perturbations in the overlap data.

### 5. Feed-forward correction checks

These checks evaluate correction error and unitary fidelity for synthetic effective logical gates of the form

\[
V_{\mathrm{eff}}=U_\gamma V
\]

and, where included, the right-acting convention

\[
V_{\mathrm{eff}}=VU_\gamma.
\]

For the left-acting convention, the correction is

\[
V_{\mathrm{corr}}
=
\widehat U_\gamma^\dagger V_{\mathrm{eff}}.
\]

For the right-acting convention, the correction is

\[
V_{\mathrm{corr}}
=
V_{\mathrm{eff}}\widehat U_\gamma^\dagger.
\]

---

## Running the validation scripts

From the repository root, run:

```bash
wolframscript -file src/run-all.wls
```

The run will populate or update:

```text
results/tables/
results/figs/
results/logs/
```

The headless driver is intended to run without the Mathematica front end.

---

## Expected outputs

A successful run should produce validation tables containing some or all of the following diagnostics:

```text
N
connection_convergence_error
gauge_covariance_error
unitarity_error
min_singular_value
correction_error
correction_fidelity
eigenphases
wilson_traces
```

Typical numerical expectations:

- Gauge covariance residuals should be near machine precision.
- Unitarity errors should be near machine precision because each polar step is unitary.
- Convergence errors should decrease under mesh refinement.
- Correction fidelity should approach 1 as the holonomy estimate improves.
- Runs with small `min_singular_value` should be interpreted as poorly conditioned.

---

## Gauge-invariant reporting

The matrix entries of \(\widehat U_\gamma\) depend on the chosen frame inside the logical subspace. For a closed loop, the reconstructed holonomy transforms by conjugation, not by equality. Therefore the preferred gauge-invariant diagnostics are:

\[
\operatorname{spec}(\widehat U_\gamma),
\]

the eigenphases

\[
\Theta
=
\{\arg z: z\in\operatorname{spec}(\widehat U_\gamma)\},
\]

and Wilson-loop-type traces

\[
W_r
=
\operatorname{Tr}(\widehat U_\gamma^r),
\qquad
r=1,2,\ldots,r_{\max}.
\]

These quantities are invariant under closed-loop gauge transformations.

---

## Notes on interpretation

The scripts validate the mathematical structure of the algorithm rather than a specific photonic device.

In particular:

- The overlap matrices are generated from analytic or synthetic frame/connection data.
- The holonomies are non-Abelian when the connection values fail to commute at different parameter values.
- The eigenphases and traces of powers of the reconstructed holonomy are the preferred gauge-invariant diagnostics.
- The matrix entries of the holonomy itself are gauge-dependent and should not be interpreted as directly physical without fixing a frame.
- The generated validation outputs are synthetic and are not experimental data.

---

## Relation to prior work

This repository supports the non-Abelian extension of the earlier Abelian time-bin geometric-phase calibration framework. In the prior setting, geometric distortion was represented by bin-resolved scalar Pancharatnam--Berry phases. In the present work, the transported object is an encoded logical subspace, so the geometric contribution becomes a matrix-valued Wilczek--Zee holonomy. The scripts in this repository validate the corresponding holonomy-estimation and feed-forward correction algorithms.

---

## Reproducibility status

The headless validation pipeline is intended to reproduce the algorithmic checks used in the manuscript. Exact numerical values may vary slightly across Wolfram Language versions, operating systems, BLAS/LAPACK backends, and hardware, but the qualitative checks should remain stable:

- gauge covariance residuals near machine precision;
- unitarity errors near machine precision;
- decreasing convergence error under refinement;
- improved feed-forward correction as the holonomy estimate converges;
- increased sensitivity when overlap matrices are poorly conditioned.

---

## Citation

When using this repository, please cite the accompanying manuscript:

**“A-Gauge-Covariant-Theoretical-Framework-for-Non-Abelian-Holonomy-Estimation-and-Feed-Forward-Correct.”**