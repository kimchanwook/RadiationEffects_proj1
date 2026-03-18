%% main_defect_model.m
% From Radiation-Induced Defects to Device Degradation in Silicon
% Module: Defect density build-up from radiation fluence
%
% This script computes a simple first-order defect density model:
%   N_D = k_D * Phi
% where N_D is defect concentration [cm^-3], k_D is an effective defect
% introduction coefficient [cm^-1], and Phi is particle fluence [cm^-2].
%
% The goal is not to claim a universally exact model, but to build a clean
% physics-based bridge from radiation exposure to semiconductor damage.

clear; clc; close all;

addpath('functions');

%% User-adjustable parameters
Phi = logspace(8, 14, 300);   % fluence [cm^-2]
k_D = 1e2;                    % effective defect introduction coefficient [cm^-1]

%% Compute defect density
N_D = defect_density_from_fluence(Phi, k_D);

%% Plot
fig = figure('Name', 'Defect Density vs Fluence', 'Color', 'w');
loglog(Phi, N_D, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Defect concentration, N_D [cm^{-3}]');
title('Defect Density Build-Up with Radiation Fluence');

%% Save figure
outdir = fullfile('output');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end
saveas(fig, fullfile(outdir, 'defect_density_vs_fluence.png'));

%% Display a few sample values
sample_idx = round(linspace(1, numel(Phi), 5));
T = table(Phi(sample_idx).', N_D(sample_idx).', ...
    'VariableNames', {'Fluence_cm2', 'DefectDensity_cm3'});
disp(T);
