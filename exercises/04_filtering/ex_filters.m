% Module 04 — Exercises: Digital Filtering
pkg load signal;

%% Exercise 1 — FIR Design
% fc=200Hz, fs=2000Hz, Hamming window, order=64
% a) Design with fir1()
% b) Plot impulse response (stem)
% c) Plot magnitude in dB with freqz()
% d) What is the -3dB frequency?
% e) Order 128: how does transition band change?
% YOUR CODE HERE:

%% Exercise 2 — Filter the Project Signal
% load('../../project/machine_vibration.mat');
% Filter A: band-pass 75-100Hz (isolate bearing fault)
% Filter B: band-stop 45-55Hz (suppress shaft)
% Use butter(6, ...) + filtfilt()
% Did you isolate the 87.3Hz component? What amplitude?
% YOUR CODE HERE:

%% Exercise 3 (Challenge) — Stability
% Butterworth LP at fc=100Hz, fs=1000Hz, orders: 2,4,8,12,16
% a) Check stability: all(abs(roots(a)) < 1)
% b) Plot pole-zero diagrams with zplane()
% c) At what order do poles leave the unit circle?
% YOUR CODE HERE:
