% ============================================================
% Module 07: Control Systems & Simulink Concepts
% demo_control.m
% ============================================================
% Simulink is MATLAB-only. This module implements equivalent
% block diagram systems using Octave's control package and
% ODE solvers — no license needed.
%
% Covers: transfer functions, step response, Bode plot,
%         closed-loop systems, PID controller.
% ============================================================

clear; clc; close all;
pkg load control;   % Octave: sudo octave --eval "pkg install -forge control"

%% ============================================================
%  BLOCK 1: Transfer Function & Step Response
%  Equivalent to: Simulink > Continuous > Transfer Fcn block
% ============================================================

fprintf('=== Block 1: Transfer Function ===\n');

% Second-order system: G(s) = wn^2 / (s^2 + 2*zeta*wn*s + wn^2)
wn   = 10;      % natural frequency [rad/s]
zeta = 0.3;     % damping ratio (underdamped)

num = [wn^2];
den = [1, 2*zeta*wn, wn^2];

G = tf(num, den);
fprintf('Transfer function G(s):\n'); disp(G);

% Step response
figure('Position', [100 100 1100 800]);

subplot(2,3,1);
step(G);
title(sprintf('Step Response (\\zeta=%.1f, \\omega_n=%d rad/s)', zeta, wn));
grid on;

% Compare different damping ratios
subplot(2,3,2);
hold on;
zeta_vals = [0.1 0.3 0.5 0.7 1.0 1.5];
colors = lines(length(zeta_vals));
for i = 1:length(zeta_vals)
  z = zeta_vals(i);
  G_i = tf(wn^2, [1, 2*z*wn, wn^2]);
  [y, t] = step(G_i);
  plot(t, y, 'Color', colors(i,:), 'DisplayName', sprintf('\\zeta=%.1f', z));
end
legend('Location', 'best'); grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('Step Response vs Damping Ratio');

%% ============================================================
%  BLOCK 2: Bode Plot
%  Equivalent to: Simulink > Analysis > Bode Plot
% ============================================================

subplot(2,3,3);
bode(G);
title('Bode Plot of G(s)');
grid on;

%% ============================================================
%  BLOCK 3: Closed-Loop with PID Controller
%  Equivalent to: Simulink feedback loop with PID block
%
%    r(t) --> [PID] --> [Plant G(s)] --> y(t)
%                ^                         |
%                |_________________________|
% ============================================================

fprintf('\n=== Block 3: PID Closed-Loop System ===\n');

% Plant: simple first-order system
K_plant = 1;
tau     = 0.5;
Plant   = tf(K_plant, [tau, 1]);

% PID gains
Kp = 10;
Ki = 5;
Kd = 1;

% PID transfer function: C(s) = Kp + Ki/s + Kd*s
%                              = (Kd*s^2 + Kp*s + Ki) / s
C_pid = tf([Kd Kp Ki], [1 0]);

% Open-loop and closed-loop
L         = series(C_pid, Plant);       % open-loop
G_cl      = feedback(L, 1);             % closed-loop (unity feedback)
G_ol_only = feedback(Plant, 1);         % plant alone (no controller)

subplot(2,3,4);
[y_cl, t_cl]     = step(G_cl);
[y_ol, t_ol]     = step(G_ol_only);
plot(t_ol, y_ol, 'r--', 'DisplayName', 'No Controller');
hold on;
plot(t_cl, y_cl, 'b', 'DisplayName', 'PID Controlled', 'LineWidth', 1.5);
yline(1, 'k:', 'Setpoint');
xlabel('Time (s)'); ylabel('Amplitude');
title(sprintf('PID Control (Kp=%d, Ki=%d, Kd=%d)', Kp, Ki, Kd));
legend; grid on;

%% ============================================================
%  BLOCK 4: ODE Solver (equivalent to Simulink Solver)
%  Manual simulation of: m*x'' + b*x' + k*x = F(t)
%  (mass-spring-damper, same as second-order LTI above)
% ============================================================

fprintf('\n=== Block 4: ODE Solver (mass-spring-damper) ===\n');

m = 1;      % mass [kg]
b = 2;      % damping [N*s/m]
k = 100;    % spring constant [N/m]
F = 1;      % step force [N]

% State space: [x; x'] -> A*[x;x'] + B*u
% x'' = (F - b*x' - k*x) / m
ode_func = @(t, y) [y(2); (F - b*y(2) - k*y(1)) / m];

t_span = [0 3];
y0     = [0; 0];    % initial conditions: x=0, x'=0

[t_ode, Y] = ode45(ode_func, t_span, y0);

subplot(2,3,5);
plot(t_ode, Y(:,1), 'b', 'LineWidth', 1.5, 'DisplayName', 'Position x(t)');
hold on;
plot(t_ode, Y(:,2), 'r--', 'DisplayName', 'Velocity x''(t)');
xlabel('Time (s)'); ylabel('State');
title('ODE45: Mass-Spring-Damper Step Response');
legend; grid on;

%% ============================================================
%  BLOCK 5: Root Locus
% ============================================================

subplot(2,3,6);
rlocus(Plant);
title('Root Locus of Plant');
grid on;

sgtitle('Module 07 — Control Systems & Simulink Concepts (Octave)');

%% Summary
fprintf('\n--- Simulink Block Equivalents Used ---\n');
fprintf('Transfer Fcn block   ->  tf(), step(), bode()\n');
fprintf('PID Controller block ->  tf([Kd Kp Ki],[1 0])\n');
fprintf('Feedback block       ->  feedback(L, 1)\n');
fprintf('Simulink ODE Solver  ->  ode45()\n');
fprintf('Root Locus block     ->  rlocus()\n');
