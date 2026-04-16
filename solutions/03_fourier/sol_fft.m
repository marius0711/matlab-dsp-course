% Module 03 — Solutions
clear; clc; close all;

%% Ex 1
fs=500; T=2; t=0:1/fs:T-1/fs; N=length(t);
x=2.0*sin(2*pi*30*t)+1.0*sin(2*pi*80*t)+0.5*sin(2*pi*150*t);
figure;
subplot(2,1,1); plot(t(t<0.1), x(t<0.1),'b');
title('Ex1 — Time domain (100ms)'); xlabel('Time (s)'); grid on;
X=fft(x); half=1:N/2+1;
X_ss=2*abs(X(half))/N; X_ss(1)=X_ss(1)/2;
f_ss=(0:N/2)*(fs/N);
subplot(2,1,2); plot(f_ss, X_ss,'b');
title('Ex1 — Spectrum'); xlabel('Hz'); ylabel('Amplitude'); grid on;

%% Ex 3
fprintf('Frequency resolution analysis:\n');
fs3=1000;
for N3=[256 2048]
  df=fs3/N3;
  fprintf('  N=%4d: df=%.3f Hz -> %s resolve 100 and 102Hz\n', ...
    N3, df, ternary(df<2,'CAN','CANNOT'));
end
fprintf('  Min N: %d (df=%.2fHz)\n', ceil(fs3/2), fs3/ceil(fs3/2));

function out=ternary(c,a,b); if c; out=a; else; out=b; end; end
