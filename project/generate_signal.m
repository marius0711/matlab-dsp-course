% ============================================================
% Central Project: Rotating Machine Vibration Analysis
% project/generate_signal.m
% ============================================================
% PURPOSE
%   Generates a synthetic vibration signal simulating an electric
%   motor / pump with a developing bearing fault. This is the
%   single dataset used across all course modules.
%
% PHYSICAL MODEL
%   The machine rotates at 50 Hz (3000 RPM). The vibration signal
%   contains:
%     - Shaft rotation and harmonics (imbalance, misalignment)
%     - A bearing outer race defect at 87.3 Hz (BPFO)
%     - Broadband sensor noise
%
% BEARING FAULT FREQUENCY (BPFO) — how to compute it:
%   BPFO = (Nb/2) * rpm/60 * (1 - Bd/Pd * cos(phi))
%   where Nb = number of rolling elements, Bd = ball diameter,
%   Pd = pitch diameter, phi = contact angle.
%   For a typical 6205 deep groove bearing: BPFO ≈ 87.3 Hz at 3000 RPM.
%
% OUTPUT
%   Saves 'machine_vibration.mat' in the project/ folder.
%   Variables: x (signal), t (time), fs (sample rate), params (struct)
%
% USAGE
%   Run this script once. All subsequent modules load the .mat file:
%     load('../project/machine_vibration.mat');
% ============================================================

clear; clc;

%% ── Configurable Parameters ─────────────────────────────────────────────────
params.fs          = 5000;     % sampling frequency [Hz]
params.duration    = 2.0;      % signal duration [s]

% Shaft
params.f_shaft     = 50;       % shaft rotation frequency [Hz] = 3000 RPM
params.A_shaft     = 1.00;     % shaft vibration amplitude

% Harmonics (imbalance artifacts)
params.f_h2        = 100;      % 2nd harmonic [Hz]
params.A_h2        = 0.40;
params.f_h3        = 150;      % 3rd harmonic [Hz]
params.A_h3        = 0.20;

% Bearing fault (outer race defect, BPFO)
params.f_fault     = 87.3;     % bearing fault frequency [Hz]
params.A_fault     = 0.15;     % small amplitude — hard to see in time domain

% Modulation: fault creates amplitude modulation at shaft frequency
% (characteristic of outer race defects in rotating machinery)
params.modulation  = true;

% Noise
params.noise_std   = 0.05;     % Gaussian white noise standard deviation

%% ── Signal Construction ──────────────────────────────────────────────────────
N  = params.fs * params.duration;
t  = (0 : N-1) / params.fs;

% Base shaft + harmonics
x_shaft = params.A_shaft * sin(2*pi * params.f_shaft * t) ...
        + params.A_h2    * sin(2*pi * params.f_h2    * t) ...
        + params.A_h3    * sin(2*pi * params.f_h3    * t);

% Bearing fault component
% With amplitude modulation by shaft frequency (physically realistic)
if params.modulation
  modulator = 1 + 0.4 * sin(2*pi * params.f_shaft * t);
  x_fault = params.A_fault * modulator .* sin(2*pi * params.f_fault * t);
else
  x_fault = params.A_fault * sin(2*pi * params.f_fault * t);
end

% Noise
rng(42);  % fixed seed for reproducibility
x_noise = params.noise_std * randn(1, N);

% Complete signal
x = x_shaft + x_fault + x_noise;
fs = params.fs;

%% ── Quick Sanity Plots ────────────────────────────────────────────────────────
figure('Position', [100 100 1000 500]);

subplot(2,1,1);
t_plot = t(t < 0.1);
plot(t_plot, x(1:length(t_plot)), 'k', 'LineWidth', 0.6);
xlabel('Time (s)'); ylabel('Acceleration (g)');
title('Machine Vibration Signal — First 100 ms');
grid on;

subplot(2,1,2);
X    = fft(x);
half = 1 : N/2+1;
X_ss = 2 * abs(X(half)) / N;
X_ss(1) = X_ss(1)/2;
f_ax = (0:N/2) * (fs/N);

plot(f_ax, X_ss, 'b', 'LineWidth', 0.5);
hold on;
% Mark key frequencies
for f_mark = [params.f_shaft, params.f_h2, params.f_h3, params.f_fault]
  [~, idx] = min(abs(f_ax - f_mark));
  plot(f_ax(idx), X_ss(idx), 'rv', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
end
xlabel('Frequency (Hz)'); ylabel('Amplitude (g)');
title('Frequency Spectrum — Can you spot the fault at 87.3 Hz?');
xlim([0 300]); grid on;
legend('Spectrum', 'Key frequencies', 'Location', 'northeast');

sgtitle('Project Signal: Motor Vibration with Bearing Fault');

%% ── Save ─────────────────────────────────────────────────────────────────────
save('machine_vibration.mat', 'x', 't', 'fs', 'params');
fprintf('\nSignal saved to machine_vibration.mat\n');
fprintf('  Duration:        %.1f s\n', params.duration);
fprintf('  Samples:         %d\n', N);
fprintf('  Sampling rate:   %d Hz\n', fs);
fprintf('  Freq resolution: %.3f Hz/bin\n', fs/N);
fprintf('\nSignal components:\n');
fprintf('  Shaft:       %.0f Hz, A=%.2f\n', params.f_shaft, params.A_shaft);
fprintf('  2nd harmonic:%.0f Hz, A=%.2f\n', params.f_h2, params.A_h2);
fprintf('  3rd harmonic:%.0f Hz, A=%.2f\n', params.f_h3, params.A_h3);
fprintf('  Fault (BPFO):%.1f Hz, A=%.2f  <-- diagnostic target\n', params.f_fault, params.A_fault);
fprintf('  Noise std:   %.3f\n', params.noise_std);
fprintf('\nFault-to-shaft amplitude ratio: %.1f:1 (shaft dominates by %.0fx)\n', ...
        params.A_fault/params.A_shaft, params.A_shaft/params.A_fault);
