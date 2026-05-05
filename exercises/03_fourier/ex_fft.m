% Module 03 — Exercises: Fourier Transform

%% Exercise 1
% Signal: 30Hz (A=2.0) + 80Hz (A=1.0) + 150Hz (A=0.5), fs=500Hz, T=2s

fs = 500;
T  = 2;
N  = fs * T;
t  = (0:N-1) / fs;

x = 2.0*sin(2*pi*30*t) + 1.0*sin(2*pi*80*t) + 0.5*sin(2*pi*150*t);

% FFT
X    = fft(x);
half = 1 : N/2 + 1;
X_ss = abs(X(half)) / N;
X_ss(2:end-1) = 2 * X_ss(2:end-1);
f_ss = (0:N/2) * (fs/N);

figure(1);

subplot(2,1,1);
plot(t(1:round(0.1*fs)), x(1:round(0.1*fs)), 'b');
xlabel('Time (s)'); ylabel('Amplitude');
title('Exercise 1 — Time Domain (first 100ms)');
grid on;

subplot(2,1,2);
stem(f_ss, X_ss, 'b', 'Marker', 'none', 'LineWidth', 1);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title('Exercise 1 — Single-Sided Spectrum');
xlim([0 fs/2]); grid on;

print -dpng plots/03_ex1_spectrum.png
fprintf('Ex1 — df = %.2f Hz/bin\n', fs/N);

%% Exercise 2
% Load machine_vibration.mat, FFT with Hann window

load('project/machine_vibration.mat');  % loads variable x

fs2 = 5000;
N2  = length(x);
t2  = (0:N2-1) / fs2;

% Rectangular window
X2    = fft(x);
half2 = 1 : N2/2 + 1;
X2_ss = abs(X2(half2)) / N2;
X2_ss(2:end-1) = 2 * X2_ss(2:end-1);
f2_ss = (0:N2/2) * (fs2/N2);

% Hann window
w        = hanning(N2)';
X2h      = fft(x .* w);
X2h_ss   = 2 * abs(X2h(half2)) / sum(w);
X2h_ss(1) = X2h_ss(1) / 2;

figure(2);

subplot(3,1,1);
plot(t2(1:500), x(1:500), 'b');
xlabel('Time (s)'); ylabel('Amplitude');
title('Exercise 2 — Machine Vibration (first 500 samples)');
grid on;

subplot(3,1,2);
plot(f2_ss, X2_ss, 'b');
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title('Exercise 2 — Spectrum (Rectangular)');
xlim([0 300]); grid on;

subplot(3,1,3);
plot(f2_ss, X2h_ss, 'r');
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title('Exercise 2 — Spectrum (Hann) — spot 87.3 Hz');
xlim([0 300]); grid on;
% Mark expected fault frequency
hold on;
xline(87.3, 'k--', '87.3 Hz', 'LabelVerticalAlignment', 'bottom');

print -dpng plots/03_ex2_machine_fft.png

fprintf('\nEx2 — df = %.2f Hz/bin, N = %d\n', fs2/N2, N2);

%% Exercise 3 — Frequency Resolution Challenge
% Two sinusoids: f1=100Hz, f2=102Hz, fs=1000Hz

fs3 = 1000;
f3a = 100; f3b = 102;

for N3 = [256, 2048]
    t3 = (0:N3-1) / fs3;
    x3 = sin(2*pi*f3a*t3) + sin(2*pi*f3b*t3);
    X3    = fft(x3);
    half3 = 1 : N3/2 + 1;
    X3_ss = 2 * abs(X3(half3)) / N3;
    f3_ss = (0:N3/2) * (fs3/N3);
    df3   = fs3 / N3;

    figure;
    plot(f3_ss, X3_ss, 'b');
    xlabel('Frequency (Hz)'); ylabel('Amplitude');
    title(sprintf('Exercise 3 — N=%d, df=%.2f Hz/bin', N3, df3));
    xlim([90 112]); grid on;
    if df3 < 2
        status = 'RESOLVED';
    else
        status = 'NOT RESOLVED';
    end
    fprintf('Ex3 N=%d: df=%.2f Hz — %s\n', N3, df3, status);
    print(sprintf('plots/03_ex3_N%d.png', N3), '-dpng');
end

% Minimum N: need df < (f2-f1) = 2 Hz
% df = fs/N < 2  =>  N > fs/2 = 500
fprintf('\nMinimum N to resolve 2 Hz gap: N > %d (here: %d)\n', fs3/2, fs3/2 + 1);
