%% main_diffusion_length_model.m
% From Radiation-Induced Defects to Device Degradation in Silicon
% Module: Diffusion length reduction due to lifetime degradation
%
% Model:
%   L = sqrt(D * tau_eff)
%
% where D is carrier diffusivity and tau_eff is the effective lifetime.

clear; clc; close all;

addpath('functions');

%% Parameters
Phi   = logspace(8, 14, 300);  % [cm^-2]
k_D   = 1e2;                   % [cm^-1]
tau_0 = 1e-6;                  % [s]
K_tau = 1e-10;                 % [cm^3/s]
D     = 25;                    % [cm^2/s], representative diffusivity

%% Compute chain
N_D     = defect_density_from_fluence(Phi, k_D);
tau_eff = lifetime_from_defects(N_D, tau_0, K_tau);
L       = diffusion_length_from_lifetime(D, tau_eff);

%% Plot
fig = figure('Name', 'Diffusion Length vs Fluence', 'Color', 'w');
loglog(Phi, L, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Diffusion length, L [cm]');
title('Diffusion Length Degradation with Radiation Fluence');

%% Save
outdir = fullfile('output');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end
saveas(fig, fullfile(outdir, 'diffusion_length_vs_fluence.png'));

%% Report
sample_idx = round(linspace(1, numel(Phi), 5));
T = table(Phi(sample_idx).', L(sample_idx).', ...
    'VariableNames', {'Fluence_cm2', 'DiffusionLength_cm'});
disp(T);
