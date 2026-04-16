% Module 02 — Solutions
clear; clc; close all;

%% Ex 1
fs=500; T=1; t=0:1/fs:T-1/fs;
x = 2*sin(2*pi*10*t) + 0.8*cos(2*pi*25*t);
figure;
subplot(2,1,1);
plot(t(t<0.2)*1000, x(t<0.2), 'b', 'LineWidth', 1.2);
xlabel('Time (ms)'); ylabel('Amplitude');
title('Ex1 — Composite Signal (200ms)'); grid on;

rms_analytical = sqrt((2^2 + 0.8^2)/2);
fprintf('RMS analytical: %.4f\n', rms_analytical);
fprintf('RMS octave:     %.4f\n', rms(x));
fprintf('Composite period: 0.20 s (LCM of 0.1s and 0.04s)\n');

%% Ex 2
f0=8; fs2=2000; t2=0:1/fs2:1-1/fs2;
ideal_sq = sign(sin(2*pi*f0*t2));
subplot(2,1,2); hold on;
colors_line = {'r','g','m','b'};
for idx=1:4
  n_max=[1 3 5 15]; nmax=n_max(idx);
  xa=zeros(size(t2));
  for k=1:2:nmax; xa=xa+(1/k)*sin(2*pi*k*f0*t2); end
  xa=(4/pi)*xa;
  plot(t2,xa,colors_line{idx},'DisplayName',sprintf('%d harmonic(s)',nmax));
end
plot(t2,ideal_sq,'k--','LineWidth',0.5,'DisplayName','Ideal');
xlim([0 0.25]); legend; grid on;
xlabel('Time (s)'); title('Ex2 — Fourier Approx (Gibbs visible at n=15)');
