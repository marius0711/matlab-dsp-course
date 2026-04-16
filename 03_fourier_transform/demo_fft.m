% ============================================================
% Module 03: Fourier Transform
% demo_fft.m
% ============================================================
% Covers: DFT intuition, FFT computation, single-sided
%         spectrum, frequency resolution, windowing.
% ============================================================

clear; clc; close all;

%% Parameters
fs = 1000;          % [Hz]
N  = 1024;          % number of samples (power of 2 for FFT efficiency)
t  = (0:N-1) / fs;  % time vector

%% 1. Compose a multi-tone signal
f1 = 50;   A1 = 1.0;
f2 = 120;  A2 = 0.5;
f3 = 200;  A3 = 0.3;

x = A1*sin(2*pi*f1*t) + A2*sin(2*pi*f2*t) + A3*sin(2*pi*f3*t);

fprintf('Signal: %.1f Hz (A=%.1f) + %.1f Hz (A=%.1f) + %.1f Hz (A=%.1f)\n', ...
        f1, A1, f2, A2, f3, A3);

%% 2. Compute FFT
X     = fft(x);                     % complex FFT output
X_mag = abs(X) / N;                 % normalize by N
f_axis = (0:N-1) * (fs/N);         % full frequency axis

% Single-sided spectrum (0 to fs/2)
half   = 1 : N/2 + 1;
X_ss   = X_mag(half);
X_ss(2:end-1) = 2 * X_ss(2:end-1); % double to conserve energy
f_ss   = f_axis(half);

%% 3. Effect of Windowing
% Without window: spectral leakage when signal doesn't fit exactly
% Hann window: reduces leakage at cost of frequency resolution

x_hann  = x .* hanning(N)';
X_hann  = fft(x_hann);
X_hann_mag = 2 * abs(X_hann(half)) / sum(hanning(N));

%% 4. Plots
figure('Position', [100 100 1000 700]);

% Time domain
subplot(3,1,1);
plot(t(1:300), x(1:300), 'b');
xlabel('Time (s)'); ylabel('Amplitude');
title('Multi-tone Signal (first 300 samples)');
grid on;

% Single-sided spectrum (rectangular window)
subplot(3,1,2);
stem(f_ss, X_ss, 'b', 'Marker', 'none', 'LineWidth', 1);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title('Single-Sided Spectrum — Rectangular Window');
xlim([0 fs/2]); grid on;
% Mark the peaks
hold on;
[~, i1] = min(abs(f_ss - f1));
[~, i2] = min(abs(f_ss - f2));
[~, i3] = min(abs(f_ss - f3));
plot(f_ss([i1 i2 i3]), X_ss([i1 i2 i3]), 'rv', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
legend('Spectrum', 'Detected peaks');

% Comparison: rectangular vs Hann window
subplot(3,1,3);
plot(f_ss, 20*log10(X_ss + 1e-10), 'b', 'DisplayName', 'Rectangular');
hold on;
plot(f_ss, 20*log10(X_hann_mag + 1e-10), 'r', 'DisplayName', 'Hann');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Windowing Effect on Spectral Leakage');
legend; grid on; xlim([0 fs/2]); ylim([-80 10]);

sgtitle('Module 03 — FFT & Spectral Analysis');

%% 5. Frequency resolution
df = fs / N;
fprintf('\nFrequency resolution: %.2f Hz per bin\n', df);
fprintf('To resolve 1 Hz: need at least %d samples at fs=%d Hz\n', fs, fs);
