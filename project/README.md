# Project: Rotating Machine Vibration Analysis

## The Scenario
An electric motor rotating at 3000 RPM (50 Hz) develops a bearing fault.
The outer race defect introduces vibration at **87.3 Hz** (BPFO).
The fault is 7x weaker than the shaft — invisible in time domain, detectable via FFT.

## Signal Components

| Component | Frequency | Amplitude | Origin |
|-----------|-----------|-----------|--------|
| Shaft | 50 Hz | 1.00 g | Fundamental rotation |
| 2nd harmonic | 100 Hz | 0.40 g | Imbalance |
| 3rd harmonic | 150 Hz | 0.20 g | Misalignment |
| Bearing fault | 87.3 Hz | 0.15 g | Outer race defect (BPFO) |
| White noise | Broadband | σ=0.05 g | Sensor noise |

## How to Run
```octave
cd project
octave generate_signal.m   % creates machine_vibration.mat
octave full_analysis.m     % full diagnostic pipeline
```

## Module Connection

| Module | Usage |
|--------|-------|
| 02 | generate_signal.m — building the multi-tone signal |
| 03 | FFT reveals fault at 87.3 Hz |
| 04 | Band-pass filter isolates fault |
| 05 | Verify fs satisfies Nyquist |
| 07 | Transfer function model of drive system |
