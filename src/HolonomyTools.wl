(* ::Package:: *)

(* ::Package:: *)

(* HolonomyTools.wl
   Shared utilities for:
   Gauge-Covariant Holonomy Estimation and Feed-Forward Correction
   for Time-Bin Photonic Qudits
*)

ClearAll["Global`*"];

(* ========================================================= *)
(* Paths *)
(* ========================================================= *)

ClearAll[projectRoot, resultsDir, tablesDir, figsDir, logsDir];

projectRoot[] := DirectoryName[DirectoryName[$InputFileName]] /; StringQ[$InputFileName];

projectRoot[] := NotebookDirectory[] /; $InputFileName === "" && Head[NotebookDirectory[]] === String;

resultsDir[] := FileNameJoin[{projectRoot[], "results"}];
tablesDir[] := FileNameJoin[{resultsDir[], "tables"}];
figsDir[] := FileNameJoin[{resultsDir[], "figs"}];
logsDir[] := FileNameJoin[{resultsDir[], "logs"}];

Scan[
  If[! DirectoryQ[#], CreateDirectory[#, CreateIntermediateDirectories -> True]] &,
  {resultsDir[], tablesDir[], figsDir[], logsDir[]}
];

(* ========================================================= *)
(* Core polar and holonomy routines *)
(* ========================================================= *)

ClearAll[
  polarUnitary,
  overlapMatrices,
  backwardStepsFromOverlaps,
  forwardStepsFromOverlaps,
  discreteHolonomyFromOverlaps,
  discreteHolonomyFromFrames
];

polarUnitary[M_?MatrixQ] := Module[{u, s, v},
  {u, s, v} = SingularValueDecomposition[N[M]];
  u . ConjugateTranspose[v]
];

overlapMatrices[frames_List] :=
  Table[
    ConjugateTranspose[frames[[k]]] . frames[[k + 1]],
    {k, 1, Length[frames] - 1}
  ];

backwardStepsFromOverlaps[overlaps_List] :=
  polarUnitary /@ overlaps;

forwardStepsFromOverlaps[overlaps_List] :=
  ConjugateTranspose /@ backwardStepsFromOverlaps[overlaps];

(* Column-vector convention:
   c_{k+1} = T_k c_k.
   Therefore total holonomy is T_{N-1} ... T_0.
*)
discreteHolonomyFromOverlaps[overlaps_List] :=
  Dot @@ Reverse[forwardStepsFromOverlaps[overlaps]];

discreteHolonomyFromFrames[frames_List] :=
  discreteHolonomyFromOverlaps[overlapMatrices[frames]];

(* ========================================================= *)
(* Diagnostics *)
(* ========================================================= *)

ClearAll[
  unitaryError,
  eigenphases,
  wilsonTraces,
  minOverlapSingularValue,
  frobeniusError
];

unitaryError[U_?MatrixQ] :=
  Norm[
    ConjugateTranspose[U] . U - IdentityMatrix[Length[U]],
    "Frobenius"
  ];

eigenphases[U_?MatrixQ] :=
  Sort[Arg[Eigenvalues[N[U]]]];

wilsonTraces[U_?MatrixQ, rmax_Integer : 3] :=
  Table[Tr[MatrixPower[U, r]], {r, 1, rmax}];

minOverlapSingularValue[overlaps_List] :=
  Min[Flatten[SingularValueList /@ overlaps]];

frobeniusError[A_?MatrixQ, B_?MatrixQ] :=
  Norm[A - B, "Frobenius"];

(* ========================================================= *)
(* Random unitaries and gauge transforms *)
(* ========================================================= *)

ClearAll[
  randomHermitian,
  randomUnitary,
  gaugeTransformFrames,
  gaugeCovarianceError
];

randomHermitian[m_Integer] := Module[{x},
  x = RandomComplex[NormalDistribution[0, 1], {m, m}];
  (x + ConjugateTranspose[x])/2
];

randomUnitary[m_Integer] :=
  MatrixExp[I randomHermitian[m]];

gaugeTransformFrames[frames_List, gauges_List] :=
  MapThread[#1 . #2 &, {frames, gauges}];

gaugeCovarianceError[frames_List] := Module[
  {m, gauges, framesG, H, HG, G0},

  m = Dimensions[frames[[1]]][[2]];

  gauges = Table[randomUnitary[m], {Length[frames]}];

  (* Closed-loop gauge condition. *)
  gauges[[-1]] = gauges[[1]];

  framesG = gaugeTransformFrames[frames, gauges];

  H = discreteHolonomyFromFrames[frames];
  HG = discreteHolonomyFromFrames[framesG];
  G0 = gauges[[1]];

  Norm[
    HG - ConjugateTranspose[G0] . H . G0,
    "Frobenius"
  ]
];

(* ========================================================= *)
(* Synthetic non-Abelian connection benchmark *)
(* ========================================================= *)

ClearAll[
  sigmaX,
  sigmaY,
  sigmaZ,
  syntheticConnection,
  continuumHolonomy,
  discreteFromConnection
];

sigmaX = {{0, 1}, {1, 0}};
sigmaY = {{0, -I}, {I, 0}};
sigmaZ = {{1, 0}, {0, -1}};

syntheticConnection[t_] :=
  I (
    0.7 Cos[t] sigmaX
    + 0.4 Sin[2 t] sigmaY
    + 0.2 sigmaZ
  );

continuumHolonomy[Tmax_ : 2 Pi] :=
  NDSolveValue[
    {
      U'[t] == -syntheticConnection[t] . U[t],
      U[0] == IdentityMatrix[2]
    },
    U[Tmax],
    {t, 0, Tmax}
  ];

discreteFromConnection[N_Integer] := Module[
  {Tmax, dt, mids, Wsteps, Tsteps},

  Tmax = 2 Pi;
  dt = Tmax/N;
  mids = Table[(k + 1/2) dt, {k, 0, N - 1}];

  (* Backward comparators W_k approximate Exp[A dt]. *)
  Wsteps = MatrixExp[syntheticConnection[#] dt] & /@ mids;

  (* Forward transports T_k = W_k^\dagger approximate Exp[-A dt]. *)
  Tsteps = ConjugateTranspose /@ Wsteps;

  Dot @@ Reverse[Tsteps]
];

(* ========================================================= *)
(* Frame-based synthetic benchmark *)
(* ========================================================= *)

ClearAll[
  ambientUnitary,
  framePath,
  sampledFrames
];

ambientUnitary[t_] := Module[
  {L1, L2, L3},

  L1 = {
    {0, 1, 0},
    {-1, 0, 0},
    {0, 0, 0}
  };

  L2 = {
    {0, 0, 1},
    {0, 0, 0},
    {-1, 0, 0}
  };

  L3 = {
    {0, 0, 0},
    {0, 0, 1},
    {0, -1, 0}
  };

  MatrixExp[
    0.6 Sin[t] L1 + 0.4 Cos[2 t] L2 + 0.3 Sin[3 t] L3
  ]
];

framePath[t_] :=
  ambientUnitary[t][[All, {1, 2}]];

sampledFrames[N_Integer] := Module[{dt},
  dt = 2 Pi/N;
  Table[framePath[k dt], {k, 0, N}]
];

(* ========================================================= *)
(* Feed-forward correction *)
(* ========================================================= *)

ClearAll[
  gateFidelity,
  leftCorrection,
  rightCorrection
];

gateFidelity[U_?MatrixQ, V_?MatrixQ] :=
  Abs[Tr[ConjugateTranspose[U] . V]]^2/Length[U]^2;

leftCorrection[Hhat_?MatrixQ, Veff_?MatrixQ] :=
  ConjugateTranspose[Hhat] . Veff;

rightCorrection[Hhat_?MatrixQ, Veff_?MatrixQ] :=
  Veff . ConjugateTranspose[Hhat];

(* ========================================================= *)
(* Noise and conditioning tests *)
(* ========================================================= *)

ClearAll[
  randomComplexMatrix,
  normalizedNoiseMatrix,
  noisyOverlaps,
  noiseSensitivityRows
];

randomComplexMatrix[m_Integer] :=
  RandomComplex[NormalDistribution[0, 1], {m, m}];

normalizedNoiseMatrix[m_Integer] := Module[{X},
  X = randomComplexMatrix[m];
  X/Norm[X, 2]
];

noisyOverlaps[overlaps_List, eta_?NumericQ] := Module[{m},
  m = Length[overlaps[[1]]];
  overlaps + eta Table[
    normalizedNoiseMatrix[m],
    {Length[overlaps]}
  ]
];

noiseSensitivityRows[frames_List, etas_List] := Module[
  {overlaps, H0, mu},

  overlaps = overlapMatrices[frames];
  H0 = discreteHolonomyFromOverlaps[overlaps];
  mu = minOverlapSingularValue[overlaps];

  Table[
    With[
      {
        noisy = noisyOverlaps[overlaps, eta]
      },
      {
        eta,
        mu,
        eta/mu,
        frobeniusError[discreteHolonomyFromOverlaps[noisy], H0],
        unitaryError[discreteHolonomyFromOverlaps[noisy]]
      }
    ],
    {eta, etas}
  ]
];

(* ========================================================= *)
(* Export helpers *)
(* ========================================================= *)

ClearAll[
  exportCSV,
  exportTXT
];

exportCSV[name_String, data_] := Module[{path},
  path = FileNameJoin[{tablesDir[], name}];
  Export[path, data, "CSV"];
  path
];

exportTXT[name_String, text_String] := Module[{path},
  path = FileNameJoin[{logsDir[], name}];
  Export[path, text, "Text"];
  path
];
