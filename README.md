# Project: Rotating Machine Vibration Analysis

This folder contains the central example project that ties all course modules together.

## The Scenario

An electric motor rotating at 3000 RPM (50 Hz) develops a bearing fault. The outer race defect introduces a characteristic vibration at **87.3 Hz** (BPFO — Ball Pass Frequency, Outer race).

The challenge: the fault signal is ~7x weaker than the shaft vibration. It is invisible in the time domain, but detectable via spectral analysis — if you know what to look for.

## Signal Composition

| Component | Frequency | Amplitude | Physical Origin |
|-----------|-----------|-----------|-----------------|
| Shaft rotation | 50 Hz | 1.00 g | Fundamental rotation |
| 2nd harmonic | 100 Hz | 0.40 g | Mechanical imbalance |
| 3rd harmonic | 150 Hz | 0.20 g | Misalignment artifact |
| Bearing fault | 87.3 Hz | 0.15 g | Outer race defect (BPFO) |
| White noise | Broadband | σ=0.05 g | Sensor noise |

## Files

| File | Description | Runs after |
|------|-------------|------------|
| `generate_signal.m` | Creates and saves `machine_vibration.mat` | Nothing (run first) |
| `full_analysis.m` | Complete 5-step diagnostic pipeline | `generate_signal.m` |

## How to Run

```octave
% Step 1: generate the dataset
cd project
octave generate_signal.m

% Step 2: run the full pipeline
octave full_analysis.m
```

## Pipeline Steps

```
Raw Signal
    │
    ▼
Step 1: Signal statistics (RMS, crest factor, envelope)
    │
    ▼
Step 2: FFT spectrum analysis — detect shaft + fault peaks
    │
    ▼
Step 3: Band-pass filter (75-100 Hz) — isolate fault component
    │
    ▼
Step 4: Sampling verification — confirm fs satisfies Nyquist
    │
    ▼
Step 5: Drive system transfer function model
    │
    ▼
Diagnostic Report: fault confirmed, amplitude quantified
```

## Connection to Each Module

| Module | Project Usage |
|--------|---------------|
| 02 — Signals | `generate_signal.m` — composing the multi-tone signal |
| 03 — FFT | Spectrum analysis reveals fault at 87.3 Hz |
| 04 — Filtering | Band-pass filter isolates fault from shaft noise |
| 05 — Sampling | Verify fs=5000 Hz satisfies Nyquist for all components |
| 07 — Control | Transfer function model of the motor drive system |

## Expected Output (full_analysis.m)

```
╔══════════════════════════════════════════════════════╗
║         MACHINE VIBRATION DIAGNOSTIC REPORT          ║
╠══════════════════════════════════════════════════════╣
║ Shaft frequency:     50.0 Hz                         ║
║ Fault frequency:     87.3 Hz (BPFO, outer race)      ║
║ Fault detected:      YES                             ║
║ Fault amplitude:     0.0xxx g                        ║
║ Shaft/Fault ratio:  ~17 dB                           ║
║ Sampling OK:         YES (5000 Hz >= 600 Hz Nyquist) ║
╠══════════════════════════════════════════════════════╣
║ RECOMMENDATION: Bearing replacement within 500 hrs   ║
╚══════════════════════════════════════════════════════╝
```

## Why This Example?

Vibration-based predictive maintenance is used across:
- Industrial motors and pumps
- Wind turbines
- CNC machines
- Surgical robot actuators (MedTech)
- EV drivetrains

The same FFT + filter pipeline appears in every one of these domains. Mastering it here transfers directly.
