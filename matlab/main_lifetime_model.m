%% main_lifetime_model.m
% From Radiation-Induced Defects to Device Degradation in Silicon
% Module: Carrier lifetime degradation due to defect build-up
%
% Model:
%   1/tau_eff = 1/tau_0 + K_tau * N_D
%
% where tau_0 is the pre-radiation carrier lifetime and K_tau is an
% effective recombination sensitivity coefficient.

clear; clc; close all;

addpath('functions');

%% Parameters
Phi   = logspace(8, 14, 300);  % [cm^-2]
k_D   = 1e2;                   % [cm^-1]
tau_0 = 1e-6;                  % [s]
K_tau = 1e-10;                 % [cm^3/s]

%% Build defect density and lifetime
N_D     = defect_density_from_fluence(Phi, k_D);
tau_eff = lifetime_from_defects(N_D, tau_0, K_tau);

%% Plot
fig = figure('Name', 'Lifetime vs Fluence', 'Color', 'w');
loglog(Phi, tau_eff, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Effective lifetime, \tau_{eff} [s]');
title('Carrier Lifetime Degradation with Radiation Fluence');

%% Save
outdir = fullfile('output');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end
saveas(fig, fullfile(outdir, 'lifetime_vs_fluence.png'));

%% Report
sample_idx = round(linspace(1, numel(Phi), 5));
T = table(Phi(sample_idx).', tau_eff(sample_idx).', ...
    'VariableNames', {'Fluence_cm2', 'TauEff_s'});
disp(T);
