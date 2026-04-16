% ============================================================
% Module 06: Audio Processing
% demo_audio.m
% ============================================================
% Demonstrates the SAME four-step DSP pipeline from the
% rotating machine project, applied to audio signals.
%
% Goal: prove that the pipeline (generate → analyze → filter
% → reconstruct) is domain-agnostic.
%
% Covers: WAV I/O, audio spectrum analysis, noise reduction,
%         equalization (EQ), and audio export.
%
% NOTE: Octave requires the 'audio' package.
%   pkg install -forge audio   (run once)
% ============================================================

clear; clc; close all;
pkg load signal;
pkg load audio;   % for audioread/audiowrite

%% ── Step 1: Generate a Synthetic Audio Signal ───────────────────────────────
% We build a clean signal, add realistic noise, then clean it.
% If you have a real WAV file, replace this section with:
%   [x, fs] = audioread('yourfile.wav');
%   x = x(:,1)';  % use first channel if stereo

fs = 44100;      % standard audio sample rate [Hz]
T  = 2.0;        % duration [s]
t  = (0 : 1/fs : T - 1/fs);
N  = length(t);

% Musical note A4 (440 Hz) with harmonics — simulates a single guitar string
f0  = 440;
x_clean = 1.0 * sin(2*pi*f0*t) ...
        + 0.5 * sin(2*pi*2*f0*t) ...   % 2nd harmonic (880 Hz)
        + 0.25* sin(2*pi*3*f0*t) ...   % 3rd harmonic (1320 Hz)
        + 0.12* sin(2*pi*4*f0*t);      % 4th harmonic (1760 Hz)

% Add high-frequency noise (simulates microphone hiss / electromagnetic interference)
rng(7);
noise_hf = 0.3 * randn(1, N);
noise_lf = 0.1 * sin(2*pi*60*t);   % 60 Hz mains hum (common in recordings)

x_noisy = x_clean + noise_hf + noise_lf;
x_noisy = x_noisy / max(abs(x_noisy));   % normalize to [-1, 1]

fprintf('Audio signal: %.0f Hz fundamental, %d harmonics\n', f0, 4);
fprintf('Noise added: broadband hiss + 60Hz mains hum\n');

%% ── Step 2: Spectral Analysis ────────────────────────────────────────────────
NFFT    = 2^nextpow2(N);
X_noisy = fft(x_noisy .* hanning(N)', NFFT);
X_ss    = 2 * abs(X_noisy(1:NFFT/2+1)) / N;
f_axis  = (0:NFFT/2) * (fs/NFFT);

fprintf('\nDominant frequencies detected:\n');
% Find peaks above threshold
threshold = 0.003;
[peaks, locs] = findpeaks(X_ss(f_axis<5000), 'MinPeakHeight', threshold, ...
                          'MinPeakDistance', round(200/(fs/NFFT)));
f_peaks = f_axis(locs);
for k = 1:min(length(f_peaks), 8)
  fprintf('  %.0f Hz (A=%.4f)\n', f_peaks(k), peaks(k));
end

%% ── Step 3: Audio Filtering ──────────────────────────────────────────────────

% 3a) Low-pass filter — remove high-frequency hiss (cutoff: 4 kHz)
fc_lp = 4000 / (fs/2);
[b_lp, a_lp] = butter(6, fc_lp, 'low');
x_lp = filtfilt(b_lp, a_lp, x_noisy);

% 3b) Notch filter — remove 60 Hz mains hum
% Octave: iirnotch(w0, bw) where w0 and bw are normalized
w0_notch = 60 / (fs/2);
bw_notch = w0_notch / 10;     % narrow notch
[b_notch, a_notch] = iirnotch(w0_notch, bw_notch);
x_clean_filtered = filtfilt(b_notch, a_notch, x_lp);
x_clean_filtered = x_clean_filtered / max(abs(x_clean_filtered));

% 3c) Equalizer: boost mid frequencies (presence boost at 2kHz)
% Approximate with a peaking EQ filter
w0_eq = 2000 / (fs/2);
bw_eq = w0_eq / 2;
gain_dB = 4;    % +4 dB boost
[b_eq, a_eq] = iirpeak(w0_eq, bw_eq);
% Manual gain: scale the numerator
boost = 10^(gain_dB/20);
b_eq_boosted = b_eq * boost;
x_eq = filtfilt(b_eq_boosted, a_eq, x_clean_filtered);
x_eq = x_eq / max(abs(x_eq));

%% ── Step 4: Export ───────────────────────────────────────────────────────────
audiowrite('noisy_audio.wav',   x_noisy(:)',  fs);
audiowrite('cleaned_audio.wav', x_clean_filtered(:)', fs);
audiowrite('eq_audio.wav',      x_eq(:)',     fs);
fprintf('\nExported: noisy_audio.wav, cleaned_audio.wav, eq_audio.wav\n');
fprintf('Listen to all three to hear the difference.\n');

%% ── Plots ────────────────────────────────────────────────────────────────────
figure('Position', [100 100 1100 750]);

% Time domain comparison
subplot(3,2,1);
t_ms = t * 1000;
plot(t_ms(1:1000), x_noisy(1:1000), 'r', 'LineWidth', 0.5);
title('Input: Noisy Signal (first 23ms)');
xlabel('Time (ms)'); ylabel('Amplitude'); grid on;

subplot(3,2,2);
plot(t_ms(1:1000), x_clean_filtered(1:1000), 'b', 'LineWidth', 1);
title('Output: After Low-Pass + Notch Filter');
xlabel('Time (ms)'); ylabel('Amplitude'); grid on;

% Spectrum before/after
subplot(3,2,[3 4]);
NFFT2 = 2^nextpow2(N);
X_cf = 2*abs(fft(x_clean_filtered.*hanning(N)', NFFT2)) / N;
f2   = (0:NFFT2/2) * (fs/NFFT2);

semilogy(f_axis, X_ss(1:length(f_axis)), 'r', 'DisplayName', 'Noisy input');
hold on;
semilogy(f2, X_cf(1:length(f2)), 'b', 'LineWidth', 1.5, 'DisplayName', 'Filtered output');
xline(60, 'k--', '60Hz notch');
xline(4000, 'm--', '4kHz LP cutoff');
xlabel('Frequency (Hz)'); ylabel('Amplitude (log)');
title('Spectrum Before/After Filtering');
legend; grid on; xlim([0 5000]);

% Frequency response: Low-pass filter
subplot(3,2,5);
[H_lp, w] = freqz(b_lp, a_lp, 2048, fs);
plot(w, 20*log10(abs(H_lp)+1e-10), 'b');
title('Low-Pass Filter Response (cutoff 4kHz)');
xlabel('Hz'); ylabel('dB'); grid on; xlim([0 fs/2]);

% Spectrogram — shows time+frequency together
subplot(3,2,6);
segment = round(fs * 0.025);    % 25 ms window
overlap = round(segment * 0.75);
[S, F, T_s] = spectrogram(x_noisy, hanning(segment), overlap, NFFT2, fs);
imagesc(T_s, F, 20*log10(abs(S)+1e-10));
axis xy; colorbar;
ylabel('Frequency (Hz)'); xlabel('Time (s)');
title('Spectrogram of Noisy Signal');
ylim([0 5000]);
colormap('jet');

sgtitle('Module 06 — Audio DSP Pipeline');

fprintf('\nModule 06 complete.\n');
fprintf('Key insight: the pipeline is identical to the machine vibration project.\n');
fprintf('Domain changes; math does not.\n');
