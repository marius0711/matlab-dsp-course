% ============================================================
% Module 05: Sampling & Aliasing
% demo_sampling.m
% ============================================================
clear; clc; close all;

f_cont = 1000;
t_cont = 0 : 1/f_cont : 1;
f_sig  = 50;
x_cont = sin(2*pi*f_sig*t_cont);

fs_ok    = 200;
fs_alias = 70;

t_ok    = 0 : 1/fs_ok    : 1;
t_alias = 0 : 1/fs_alias : 1;

x_ok    = sin(2*pi*f_sig*t_ok);
x_alias = sin(2*pi*f_sig*t_alias);

f_alias_apparent = abs(f_sig - fs_alias);
fprintf('Signal:         %d Hz\n', f_sig);
fprintf('Sampling rate:  %d Hz (below Nyquist!)\n', fs_alias);
fprintf('Apparent alias: %d Hz\n', f_alias_apparent);

figure('Position', [100 100 1000 600]);

subplot(2,2,1);
plot(t_cont, x_cont, 'k'); hold on;
stem(t_ok, x_ok, 'b', 'Marker', 'o', 'MarkerFaceColor', 'b');
title(sprintf('Above Nyquist: fs=%d Hz', fs_ok));
xlabel('Time (s)'); grid on; xlim([0 0.2]);
legend('Continuous', 'Samples');

subplot(2,2,2);
plot(t_cont, x_cont, 'k'); hold on;
stem(t_alias, x_alias, 'r', 'Marker', 'o', 'MarkerFaceColor', 'r');
title(sprintf('BELOW Nyquist: fs=%d Hz — ALIASING!', fs_alias));
xlabel('Time (s)'); grid on; xlim([0 0.2]);
legend('Continuous', 'Samples');

subplot(2,2,[3 4]);
f_range = 0:1:200;
f_apparent = mod(f_range, fs_alias);
f_apparent(f_apparent > fs_alias/2) = fs_alias - f_apparent(f_apparent > fs_alias/2);
plot(f_range, f_apparent, 'r');
hold on;
xline(fs_alias/2, 'b--', sprintf('Nyquist = %d Hz', fs_alias/2));
xline(f_sig, 'k--', sprintf('Signal = %d Hz', f_sig));
plot(f_sig, f_alias_apparent, 'rv', 'MarkerSize', 10, 'MarkerFaceColor', 'r', ...
     'DisplayName', sprintf('Alias = %d Hz', f_alias_apparent));
xlabel('True Frequency (Hz)'); ylabel('Apparent Frequency (Hz)');
title(sprintf('Aliasing Map for fs=%d Hz', fs_alias));
legend; grid on;

sgtitle('Module 05 — Sampling & the Nyquist Theorem');
