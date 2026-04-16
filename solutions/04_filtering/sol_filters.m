% Module 04 — Solutions
clear; clc; close all;
pkg load signal;

%% Ex 1
fs=2000; fc=200; fc_norm=fc/(fs/2);
b64=fir1(64, fc_norm,'low',hamming(65));
b128=fir1(128,fc_norm,'low',hamming(129));
figure;
subplot(2,2,1); stem(b64,'b','Marker','.','MarkerSize',3);
title('FIR IR (order=64)'); grid on;
subplot(2,2,2);
[H64,w]=freqz(b64,1,2048,fs); [H128,~]=freqz(b128,1,2048,fs);
plot(w,20*log10(abs(H64)+1e-10),'b','DisplayName','Order 64'); hold on;
plot(w,20*log10(abs(H128)+1e-10),'r','DisplayName','Order 128');
xline(fc,'k--'); yline(-3,'m:','-3dB');
title('Magnitude Response'); xlabel('Hz'); ylabel('dB'); legend; grid on;

%% Ex 3
fprintf('Butterworth stability:\n');
fs3=1000; fc3=100/(fs3/2);
for ord=[2 4 8 12 16]
  [~,a]=butter(ord,fc3,'low');
  stable=all(abs(roots(a))<1);
  fprintf('  Order %2d: max pole=%.4f -> %s\n', ord, max(abs(roots(a))), ...
    ternary(stable,'STABLE','UNSTABLE'));
end

function out=ternary(c,a,b); if c; out=a; else; out=b; end; end
