%% main_full_pipeline.m
% From Radiation-Induced Defects to Device Degradation in Silicon
%
% This script runs the full simplified physics chain:
%   radiation fluence -> defect density -> lifetime degradation
%   -> diffusion length degradation -> leakage current increase
%   -> simple charge collection degradation
%
% The models here are intentionally simple and interview-friendly. They are
% meant to demonstrate physical reasoning and code organization, not to
% replace full TCAD or experimentally calibrated device simulations.

clear; clc; close all;

addpath('functions');

%% ------------------------ User parameters ------------------------------
Phi   = logspace(8, 14, 400);  % particle fluence [cm^-2]
k_D   = 1e2;                   % defect introduction coefficient [cm^-1]
tau_0 = 1e-6;                  % pre-radiation lifetime [s]
K_tau = 1e-10;                 % lifetime sensitivity coefficient [cm^3/s]
D     = 25;                    % diffusivity [cm^2/s]
alpha = 4e-17;                 % current-related damage coefficient [A/cm]
V     = 0.03;                  % active/depleted volume [cm^3]
I0    = 1e-9;                  % baseline leakage current [A]
W     = 300e-4;                % characteristic collection distance [cm], 300 um

%% ------------------------ Full physics chain --------------------------
N_D     = defect_density_from_fluence(Phi, k_D);
tau_eff = lifetime_from_defects(N_D, tau_0, K_tau);
L       = diffusion_length_from_lifetime(D, tau_eff);
DeltaI  = leakage_current_from_fluence(Phi, alpha, V);
I_total = I0 + DeltaI;
CCE     = charge_collection_model(L, W);

%% ------------------------ Save data table -----------------------------
results_table = table(Phi(:), N_D(:), tau_eff(:), L(:), I_total(:), CCE(:), ...
    'VariableNames', {'Fluence_cm2', 'DefectDensity_cm3', 'TauEff_s', ...
    'DiffusionLength_cm', 'LeakageCurrent_A', 'ChargeCollectionEff'});

outdir = fullfile('output');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end
writetable(results_table, fullfile(outdir, 'full_pipeline_results.csv'));

%% ------------------------ Figure 1: Defects --------------------------
fig1 = figure('Name', 'Defect Density', 'Color', 'w');
loglog(Phi, N_D, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Defect concentration, N_D [cm^{-3}]');
title('Defect Density vs Fluence');
saveas(fig1, fullfile(outdir, 'fig1_defect_density.png'));

%% ------------------------ Figure 2: Lifetime -------------------------
fig2 = figure('Name', 'Lifetime', 'Color', 'w');
loglog(Phi, tau_eff, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Effective lifetime, \tau_{eff} [s]');
title('Carrier Lifetime vs Fluence');
saveas(fig2, fullfile(outdir, 'fig2_lifetime.png'));

%% ------------------------ Figure 3: Diffusion length -----------------
fig3 = figure('Name', 'Diffusion Length', 'Color', 'w');
loglog(Phi, L, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Diffusion length, L [cm]');
title('Diffusion Length vs Fluence');
saveas(fig3, fullfile(outdir, 'fig3_diffusion_length.png'));

%% ------------------------ Figure 4: Leakage current ------------------
fig4 = figure('Name', 'Leakage Current', 'Color', 'w');
loglog(Phi, I_total, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Leakage current, I [A]');
title('Leakage Current vs Fluence');
saveas(fig4, fullfile(outdir, 'fig4_leakage_current.png'));

%% ------------------------ Figure 5: Charge collection ----------------
fig5 = figure('Name', 'Charge Collection Efficiency', 'Color', 'w');
semilogx(Phi, CCE, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Normalized charge collection efficiency');
title('Charge Collection Efficiency vs Fluence');
saveas(fig5, fullfile(outdir, 'fig5_charge_collection_efficiency.png'));

%% ------------------------ Console summary ----------------------------
fprintf('\nFull pipeline complete.\n');
fprintf('Results saved to: %s\n', outdir);
disp(results_table(1:5:end, :));
