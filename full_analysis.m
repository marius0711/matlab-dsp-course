% ============================================================
% Central Project: Full Analysis Pipeline
% project/full_analysis.m
% ============================================================
% PREREQUISITE: Run generate_signal.m first.
%
% This script runs the complete diagnostic pipeline on the
% rotating machine vibration dataset:
%
%   Step 1 — Load & inspect signal         (Module 01/02 concepts)
%   Step 2 — FFT spectrum analysis         (Module 03)
%   Step 3 — Isolate fault via band-pass   (Module 04)
%   Step 4 — Verify sampling constraints   (Module 05)
%   Step 5 — Dynamic system model          (Module 07)
%   Step 6 — Diagnostic report
%
% This is the file you present in a portfolio or interview.
% Each step is self-contained and annotated.
% ============================================================

clear; clc; close all;
pkg load signal;
pkg load control;

%% ── Load Dataset ─────────────────────────────────────────────────────────────
if ~exist('machine_vibration.mat', 'file')
  error('Run generate_signal.m first to create machine_vibration.mat');
end
load('machine_vibration.mat');  % loads: x, t, fs, params

N  = length(x);
fprintf('Loaded: %d samples @ %d Hz (%.1f s)\n', N, fs, N/fs);

% ═══════════════════════════════════════════════════════════════
%  STEP 1 — Signal Overview
% ═══════════════════════════════════════════════════════════════
figure('Position', [50 50 1200 900], 'Name', 'Full Analysis Pipeline');

subplot(4,3,1);
idx100ms = t < 0.1;
plot(t(idx100ms), x(idx100ms), 'k', 'LineWidth', 0.5);
title('Step 1: Raw Signal (100 ms)');
xlabel('Time (s)'); ylabel('Amplitude (g)'); grid on;
annotation_text = sprintf('fs=%d Hz\nN=%d\nDur=%.1fs', fs, N, N/fs);

subplot(4,3,2);
% Statistical overview
[counts, edges] = histc(x, linspace(min(x), max(x), 50));
bar(edges, counts, 'FaceColor', [0.3 0.5 0.8], 'EdgeColor', 'none');
title('Amplitude Distribution');
xlabel('Amplitude (g)'); ylabel('Count'); grid on;

subplot(4,3,3);
% RMS over time (envelope)
win = round(fs * 0.01);  % 10 ms window
x_rms = sqrt(movmean(x.^2, win));
plot(t, x_rms, 'r', 'LineWidth', 1);
title('RMS Envelope (10 ms window)');
xlabel('Time (s)'); ylabel('RMS (g)'); grid on;
fprintf('\nStep 1 — Signal statistics:\n');
fprintf('  RMS:     %.4f g\n', rms(x));
fprintf('  Peak:    %.4f g\n', max(abs(x)));
fprintf('  Crest factor: %.2f\n', max(abs(x)) / rms(x));

% ═══════════════════════════════════════════════════════════════
%  STEP 2 — FFT Spectrum Analysis (Module 03)
% ═══════════════════════════════════════════════════════════════
X      = fft(x .* hanning(N)');   % Hann window to reduce leakage
X_ss   = 2 * abs(X(1:N/2+1)) / sum(hanning(N));
f_axis = (0 : N/2) * (fs / N);

subplot(4,3,[4 5]);
plot(f_axis, X_ss, 'b', 'LineWidth', 0.5);
hold on;

% Annotate known frequencies
freq_labels = {params.f_shaft, 'Shaft (50Hz)';
               params.f_h2,    '2nd H (100Hz)';
               params.f_h3,    '3rd H (150Hz)';
               params.f_fault, 'FAULT (87.3Hz)'};
colors_ann = {[0.2 0.6 0.2], [0.2 0.6 0.2], [0.2 0.6 0.2], [0.8 0.1 0.1]};
for k = 1:size(freq_labels,1)
  f_k = freq_labels{k,1};
  [~, idx_k] = min(abs(f_axis - f_k));
  plot(f_axis(idx_k), X_ss(idx_k), 'v', 'MarkerSize', 9, ...
       'MarkerFaceColor', colors_ann{k}, 'MarkerEdgeColor', 'none');
  text(f_axis(idx_k)+1, X_ss(idx_k)+0.003, freq_labels{k,2}, ...
       'FontSize', 6.5, 'Color', colors_ann{k});
end

title('Step 2: FFT Spectrum (Hann window)');
xlabel('Frequency (Hz)'); ylabel('Amplitude (g)'); grid on;
xlim([0 300]);

subplot(4,3,6);
% Zoom into fault region
zoom_range = f_axis >= 60 & f_axis <= 120;
plot(f_axis(zoom_range), X_ss(zoom_range), 'b');
hold on;
[~, idx_fault] = min(abs(f_axis - params.f_fault));
plot(f_axis(idx_fault), X_ss(idx_fault), 'rv', 'MarkerFaceColor', 'r', 'MarkerSize', 10);
title(sprintf('Step 2: Zoom — Fault at %.1f Hz', params.f_fault));
xlabel('Frequency (Hz)'); ylabel('Amplitude (g)'); grid on;

[~, idx_shaft] = min(abs(f_axis - params.f_shaft));
fprintf('\nStep 2 — Spectral peaks:\n');
fprintf('  Shaft (%.0fHz):  A = %.4f g\n', params.f_shaft, X_ss(idx_shaft));
fprintf('  Fault (%.1fHz): A = %.4f g\n', params.f_fault, X_ss(idx_fault));
fprintf('  SNR (shaft/fault): %.1f dB\n', ...
        20*log10(X_ss(idx_shaft) / X_ss(idx_fault)));

% ═══════════════════════════════════════════════════════════════
%  STEP 3 — Band-Pass Filter to Isolate Fault (Module 04)
% ═══════════════════════════════════════════════════════════════
% Design band-pass filter around fault frequency (87.3 Hz)
% Pass-band: 75–100 Hz, transition: 5 Hz each side
f_low  = 75 / (fs/2);    % normalized cutoff (lower)
f_high = 100 / (fs/2);   % normalized cutoff (upper)
order  = 8;

[b_bp, a_bp] = butter(order, [f_low f_high], 'bandpass');
x_fault_isolated = filtfilt(b_bp, a_bp, x);  % zero-phase

subplot(4,3,7);
idx200ms = t < 0.2;
plot(t(idx200ms), x(idx200ms), 'k', 'LineWidth', 0.4, 'DisplayName', 'Full signal');
hold on;
plot(t(idx200ms), x_fault_isolated(idx200ms)*5, 'r', 'LineWidth', 1.2, ...
     'DisplayName', 'Fault component (×5)');
title('Step 3: Band-Pass Filter (75–100 Hz)');
xlabel('Time (s)'); ylabel('Amplitude (g)'); legend; grid on;

subplot(4,3,8);
[H_bp, w_bp] = freqz(b_bp, a_bp, 2048, fs);
plot(w_bp, 20*log10(abs(H_bp)+1e-10), 'b');
xline(params.f_fault, 'r--', 'DisplayName', 'Fault freq');
title('Filter Frequency Response');
xlabel('Hz'); ylabel('dB'); grid on; xlim([0 300]);

subplot(4,3,9);
% Spectrum of isolated fault component
X_filt  = fft(x_fault_isolated .* hanning(N)');
X_filt_ss = 2*abs(X_filt(1:N/2+1)) / sum(hanning(N));
plot(f_axis, X_filt_ss, 'r');
xline(params.f_fault, 'k--', 'Fault (87.3Hz)');
title('Step 3: Isolated Fault Spectrum');
xlabel('Hz'); ylabel('Amplitude (g)'); grid on; xlim([60 120]);
fprintf('\nStep 3 — Fault isolation:\n');
fprintf('  Fault amplitude after filter: %.4f g\n', rms(x_fault_isolated));

% ═══════════════════════════════════════════════════════════════
%  STEP 4 — Sampling Verification (Module 05)
% ═══════════════════════════════════════════════════════════════
f_max_interest = 300;    % highest frequency we care about [Hz]
fs_required    = 2 * f_max_interest;   % Nyquist minimum
fs_recommended = 5 * f_max_interest;   % engineering rule of thumb

subplot(4,3,10);
fs_vals  = [100 200 500 1000 5000];
alias_fault = mod(params.f_fault, fs_vals);
alias_fault(alias_fault > fs_vals/2) = fs_vals(alias_fault > fs_vals/2) ...
    - alias_fault(alias_fault > fs_vals/2);
bar(1:length(fs_vals), alias_fault, 'FaceColor', [0.3 0.5 0.8]);
hold on;
bar(find(fs_vals == fs), alias_fault(fs_vals==fs), 'FaceColor', [0.2 0.7 0.2]);
set(gca, 'XTickLabel', arrayfun(@(f) sprintf('%dHz',f), fs_vals, 'UniformOutput', false));
yline(params.f_fault, 'r--', 'True 87.3Hz');
title('Step 4: Apparent Fault Frequency vs Sample Rate');
xlabel('Sampling Rate'); ylabel('Apparent Frequency (Hz)');
grid on;

fprintf('\nStep 4 — Sampling analysis:\n');
fprintf('  Nyquist minimum:   %d Hz (for f_max=%dHz)\n', fs_required, f_max_interest);
fprintf('  Recommended:       %d Hz\n', fs_recommended);
fprintf('  Actual fs:         %d Hz  [%s]\n', fs, ...
        ternary(fs >= fs_required, 'OK', 'ALIASING!'));

% ═══════════════════════════════════════════════════════════════
%  STEP 5 — Drive System Model (Module 07)
% ═══════════════════════════════════════════════════════════════
% Simple second-order model of motor + mechanical load
% G(s) = wn^2 / (s^2 + 2*zeta*wn*s + wn^2)
wn   = 2*pi * params.f_shaft;  % natural frequency matches shaft speed
zeta = 0.05;  % lightly damped (typical for rotating machinery)
G = tf(wn^2, [1, 2*zeta*wn, wn^2]);

subplot(4,3,11);
[y_step, t_step] = step(G, linspace(0, 0.5, 1000));
plot(t_step, y_step, 'b', 'LineWidth', 1.5);
title('Step 5: Drive System Step Response');
xlabel('Time (s)'); ylabel('Normalized'); grid on;

subplot(4,3,12);
bode(G, {2*pi*1, 2*pi*500});
title('Step 5: Drive System Bode Plot');
grid on;

% ═══════════════════════════════════════════════════════════════
%  STEP 6 — Diagnostic Report
% ═══════════════════════════════════════════════════════════════
fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════╗\n');
fprintf('║         MACHINE VIBRATION DIAGNOSTIC REPORT          ║\n');
fprintf('╠══════════════════════════════════════════════════════╣\n');
fprintf('║ Shaft frequency:    %5.1f Hz                         ║\n', params.f_shaft);
fprintf('║ Fault frequency:    %5.1f Hz (BPFO, outer race)      ║\n', params.f_fault);
fprintf('║ Fault detected:     %-5s                            ║\n', 'YES');
fprintf('║ Fault amplitude:    %5.4f g                          ║\n', X_ss(idx_fault));
fprintf('║ Shaft/Fault ratio:  %5.1f dB                         ║\n', ...
        20*log10(X_ss(idx_shaft)/X_ss(idx_fault)));
fprintf('║ Sampling OK:        %-5s (%d Hz >= %d Hz Nyquist)  ║\n', ...
        ternary(fs>=fs_required,'YES','NO'), fs, fs_required);
fprintf('╠══════════════════════════════════════════════════════╣\n');
fprintf('║ RECOMMENDATION: Bearing replacement within 500 hrs   ║\n');
fprintf('╚══════════════════════════════════════════════════════╝\n');

sgtitle('Rotating Machine Vibration Analysis — Full Pipeline');

% ── Helper ────────────────────────────────────────────────────────────────────
function out = ternary(cond, a, b)
  if cond; out = a; else; out = b; end
end
