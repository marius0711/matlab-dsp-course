# Module 04: Digital Filtering

## FIR vs IIR

| Property | FIR | IIR |
|----------|-----|-----|
| Phase | Linear | Non-linear |
| Stability | Always stable | Can be unstable |
| Efficiency | Lower | Higher |

## FIR Design
```octave
fc_norm = fc / (fs/2);
b = fir1(order, fc_norm, 'low', hamming(order+1));
y = filtfilt(b, 1, x);
```

## IIR Butterworth
```octave
[b, a] = butter(order, fc_norm, 'low');
y = filtfilt(b, a, x);
```

## Stability Check
```octave
all(abs(roots(a)) < 1)
```

## Band-Pass for the Project
```octave
f_low  = 75  / (fs/2);
f_high = 100 / (fs/2);
[b, a] = butter(6, [f_low f_high], 'bandpass');
x_fault = filtfilt(b, a, x);
```
