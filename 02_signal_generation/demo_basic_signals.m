% ============================================================
% Module 02: Signal Generation
% demo_basic_signals.m
% ============================================================
clear; clc; close all;

fs = 1000; T = 1; f0 = 5;
t = 0 : 1/fs : T - 1/fs;

sine_wave   = sin(2*pi*f0*t);
cosine_wave = cos(2*pi*f0*t);
square_wave = sign(sin(2*pi*f0*t));
sawtooth_wave = 2 * (t*f0 - floor(t*f0 + 0.5));
white_noise = randn(1, length(t));
noisy_signal = sine_wave + 0.3 * white_noise;

% Fourier series approximation of square wave
square_approx = zeros(1, length(t));
for n = 1:2:19
  square_approx = square_approx + (1/n) * sin(2*pi*n*f0*t);
end
square_approx = (4/pi) * square_approx;

figure('Position', [100 100 900 700]);
subplot(3,2,1); plot(t, sine_wave, 'b');
title('Sine Wave'); ylabel('Amplitude'); xlabel('Time (s)'); grid on; xlim([0 0.5]);

subplot(3,2,2); plot(t, cosine_wave, 'r');
title('Cosine Wave'); ylabel('Amplitude'); xlabel('Time (s)'); grid on; xlim([0 0.5]);

subplot(3,2,3); plot(t, square_wave, 'm');
title('Square Wave'); ylabel('Amplitude'); xlabel('Time (s)'); grid on; xlim([0 0.5]);

subplot(3,2,4); plot(t, sawtooth_wave, 'g');
title('Sawtooth Wave'); ylabel('Amplitude'); xlabel('Time (s)'); grid on; xlim([0 0.5]);

subplot(3,2,5); plot(t, noisy_signal, 'k', 'LineWidth', 0.5);
title('Sine + White Noise'); ylabel('Amplitude'); xlabel('Time (s)'); grid on; xlim([0 0.5]);

subplot(3,2,6);
plot(t, square_approx, 'b', 'LineWidth', 1.5); hold on;
plot(t, square_wave, 'r--', 'LineWidth', 0.8);
title('Fourier Series Approx (19 harmonics)');
ylabel('Amplitude'); xlabel('Time (s)'); legend('Approx.','Ideal'); grid on; xlim([0 0.5]);

sgtitle('Module 02 — Signal Generation');
fprintf('Key takeaway: any periodic signal = sum of sinusoids (Fourier series)\n');
