% ============================================================
% Module 01: MATLAB/Octave Basics
% demo_basics.m
% ============================================================
clear; clc; close all;

%% 1. Vectors and Matrices
fprintf('--- Vectors & Matrices ---\n');
t = 0:0.1:1;
fprintf('Length of t: %d\n', length(t));

v = [1; 2; 3; 4; 5];
fprintf('Sum of v: %d\n', sum(v));

A = [1 2; 3 4];
B = [5 6; 7 8];
C = A * B;
fprintf('Trace of A*B: %d\n', trace(C));

%% 2. Element-wise vs Matrix Operations
fprintf('\n--- Element-wise Operations ---\n');
x = [1 2 3 4];
y = x .^ 2;
fprintf('x^2 = ');
disp(y);

%% 3. Control Flow
fprintf('--- Control Flow ---\n');
for k = 1:5
  if mod(k, 2) == 0
    fprintf('%d is even\n', k);
  else
    fprintf('%d is odd\n', k);
  end
end

%% 4. Functions
fprintf('\n--- Functions ---\n');
result = my_rms([1 2 3 4 5]);
fprintf('RMS of [1 2 3 4 5] = %.4f\n', result);

energy = my_energy([1 2 3 4 5]);
fprintf('Energy of [1 2 3 4 5] = %.4f\n', energy);

%% 5. Basic Plot
t = linspace(0, 2*pi, 1000);
y = sin(t);
figure;
plot(t, y, 'b-', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Amplitude');
title('Basic Sine Wave — Module 01');
grid on;
fprintf('\nModule 01 complete.\n');

%% Local Functions
function rms_val = my_rms(x)
  rms_val = sqrt(mean(x .^ 2));
end

function e = my_energy(x)
  % Sum of squared samples — a fundamental signal measure
  e = sum(x .^ 2);
end
