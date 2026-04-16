% ============================================================
% Module 04: Digital Filtering
% demo_filters.m
% ============================================================
% Covers: FIR (windowed sinc), IIR (Butterworth),
%         frequency response, zero-phase filtering.
% ============================================================

clear; clc; close all;
pkg load signal;    % Octave: load signal processing package

%% Parameters
fs  = 1000;         % [Hz]
N   = 2048;
t   = (0:N-1) / fs;

%% 1. Create a test signal: low-freq signal + high-freq interference
f_signal = 10;      % desired signal [Hz]
f_noise  = 200;     % interference [Hz]
x = sin(2*pi*f_signal*t) + 0.8*sin(2*pi*f_noise*t) + 0.2*randn(1,N);

%% 2. FIR Low-Pass Filter (windowed sinc method)
fc_norm  = 30 / (fs/2);      % cutoff = 30 Hz, normalized to Nyquist
order_fir = 100;              % filter order (higher = sharper, more delay)
b_fir    = fir1(order_fir, fc_norm, 'low', hamming(order_fir+1));

y_fir    = filter(b_fir, 1, x);  % causal filter (introduces delay)

% Zero-phase version using filtfilt (no delay, requires signal package)
y_fir_zp = filtfilt(b_fir, 1, x);

%% 3. IIR Butterworth Low-Pass Filter
order_iir = 5;
[b_iir, a_iir] = butter(order_iir, fc_norm, 'low');
y_iir    = filtfilt(b_iir, a_iir, x);   % zero-phase

%% 4. Frequency Response
[H_fir, w] = freqz(b_fir, 1, 1024, fs);
[H_iir, ~] = freqz(b_iir, a_iir, 1024, fs);

%% 5. Plots
figure('Position', [100 100 1100 800]);

% Time domain comparison
subplot(3,2,[1 2]);
plot(t(1:500), x(1:500), 'k', 'LineWidth', 0.5, 'DisplayName', 'Input');
hold on;
plot(t(1:500), y_fir_zp(1:500), 'b', 'LineWidth', 1.5, 'DisplayName', 'FIR LP (zero-phase)');
plot(t(1:500), y_iir(1:500), 'r--', 'LineWidth', 1.5, 'DisplayName', 'IIR Butterworth (zero-phase)');
xlabel('Time (s)'); ylabel('Amplitude');
title('Low-Pass Filtering: Removing 200 Hz Interference');
legend; grid on;

% FIR impulse response
subplot(3,2,3);
stem(b_fir, 'b', 'Marker', '.', 'MarkerSize', 4);
title(sprintf('FIR Impulse Response (order=%d)', order_fir));
xlabel('Sample'); ylabel('Coefficient'); grid on;

% IIR pole-zero plot
subplot(3,2,4);
zplane(b_iir, a_iir);
title(sprintf('IIR Butterworth Pole-Zero Plot (order=%d)', order_iir));

% Magnitude response comparison
subplot(3,2,5);
plot(w, 20*log10(abs(H_fir)), 'b', 'DisplayName', 'FIR');
hold on;
plot(w, 20*log10(abs(H_iir)), 'r--', 'DisplayName', 'IIR Butterworth');
xline(30, 'k--', 'DisplayName', 'Cutoff (30 Hz)');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Frequency Response'); legend; grid on;
xlim([0 200]); ylim([-80 5]);

% Phase response
subplot(3,2,6);
plot(w, angle(H_fir)*180/pi, 'b', 'DisplayName', 'FIR');
hold on;
plot(w, angle(H_iir)*180/pi, 'r--', 'DisplayName', 'IIR Butterworth');
xlabel('Frequency (Hz)'); ylabel('Phase (degrees)');
title('Phase Response'); legend; grid on; xlim([0 200]);

sgtitle('Module 04 — FIR vs IIR Filtering');

%% Key Takeaways
fprintf('\n--- Key Takeaways ---\n');
fprintf('FIR: linear phase, always stable, higher order needed for sharp cutoff\n');
fprintf('IIR: more efficient (lower order), non-linear phase, can be unstable\n');
fprintf('filtfilt: zero-phase by filtering twice (forward + backward)\n');
