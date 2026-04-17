% save_plots.m — Regenerate and save all Phase 1 plots as PNG
% Run from repo root: octave save_plots.m

pkg load signal;

output_dir = 'plots';
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

%% --- Plot 1: Composite signal (Exercise 1, first 200ms) ---
fs = 500;
T = 1;
t = 0:1/fs:T-1/fs;
x = 2*sin(2*pi*10*t) + 0.8*cos(2*pi*25*t);
idx = t <= 0.2;

fig1 = figure('visible', 'off');
plot(t(idx), x(idx), 'b', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Amplitude');
title('Exercise 1: Composite Signal — first 200ms');
grid on;
print(fig1, fullfile(output_dir, '01_composite_signal.png'), '-dpng', '-r150');
fprintf('Saved: 01_composite_signal.png\n');

%% --- Plot 2: Fourier series square wave (Exercise 2) ---
f0 = 8;
t2 = 0:1/500:1-1/500;
harmonics = [1, 3, 5, 15];
ideal = sign(sin(2*pi*f0*t2));

fig2 = figure('visible', 'off');
for i = 1:4
  x_sq = zeros(size(t2));
  for k = 1:2:harmonics(i)
    x_sq = x_sq + (1/k)*sin(2*pi*k*f0*t2);
  end
  x_sq = (4/pi) * x_sq;

  subplot(2, 2, i);
  plot(t2, x_sq, 'b', 'LineWidth', 1.2); hold on;
  plot(t2, ideal, 'r--', 'LineWidth', 0.8);
  title(sprintf('%d harmonic(s)', harmonics(i)));
  xlabel('Time (s)');
  xlim([0 0.5]);
  ylim([-1.5 1.5]);
  grid on;
end
print(fig2, fullfile(output_dir, '02_fourier_square_wave.png'), '-dpng', '-r150');
fprintf('Saved: 02_fourier_square_wave.png\n');

%% --- Plot 3: Machine vibration signal (Exercise 3, first 50ms) ---
load('project/machine_vibration.mat');
idx3 = t <= 0.05;

fig3 = figure('visible', 'off');
plot(t(idx3), x(idx3), 'b', 'LineWidth', 1.2);
xlabel('Time (s)');
ylabel('Amplitude');
title('Exercise 3: Machine Vibration Signal — first 50ms');
grid on;
print(fig3, fullfile(output_dir, '03_machine_vibration.png'), '-dpng', '-r150');
fprintf('Saved: 03_machine_vibration.png\n');

fprintf('\nAll plots saved to ./%s/\n', output_dir);
