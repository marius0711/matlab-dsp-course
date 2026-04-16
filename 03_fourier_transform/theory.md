# Module 03: The Fourier Transform

## Core Idea
Any periodic signal can be expressed as a sum of sinusoids.
The Fourier Transform finds the amplitudes and frequencies of those sinusoids.

## FFT
Always use `fft()` — it computes the DFT in O(N log N) instead of O(N²).

## Frequency Axis
The k-th output bin corresponds to: f_k = k * fs / N

**Frequency resolution:** df = fs / N

## Single-Sided Spectrum
```octave
half   = 1 : N/2 + 1;
X_ss   = 2 * abs(X(half)) / N;
X_ss(1) = X_ss(1) / 2;
f_ss   = (0 : N/2) * (fs / N);
```

## Windowing
Multiply by a window before FFT to reduce spectral leakage:
```octave
x_windowed = x .* hanning(N)';
```

## Common Mistakes
- Forgetting to divide by N after `abs(fft(x))`
- Using the full FFT output instead of the single-sided half
- Too few samples → poor frequency resolution
