%% main_leakage_model.m
% From Radiation-Induced Defects to Device Degradation in Silicon
% Module: Leakage current increase in an irradiated silicon device
%
% Model:
%   Delta I = alpha * Phi * V
%
% where alpha is the current-related damage coefficient and V is the active
% or depleted volume.

clear; clc; close all;

addpath('functions');

%% Parameters
Phi   = logspace(8, 14, 300);  % [cm^-2]
alpha = 4e-17;                 % [A/cm]
V     = 0.03;                  % [cm^3], representative depleted volume
I0    = 1e-9;                  % [A], baseline pre-radiation leakage current

%% Compute leakage current
DeltaI = leakage_current_from_fluence(Phi, alpha, V);
Itotal = I0 + DeltaI;

%% Plot
fig = figure('Name', 'Leakage Current vs Fluence', 'Color', 'w');
loglog(Phi, Itotal, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Total leakage current, I [A]');
title('Leakage Current Increase with Radiation Fluence');

%% Save
outdir = fullfile('output');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end
saveas(fig, fullfile(outdir, 'leakage_current_vs_fluence.png'));

%% Report
sample_idx = round(linspace(1, numel(Phi), 5));
T = table(Phi(sample_idx).', Itotal(sample_idx).', ...
    'VariableNames', {'Fluence_cm2', 'LeakageCurrent_A'});
disp(T);
