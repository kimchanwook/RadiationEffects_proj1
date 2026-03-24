%% main_full_pipeline.m
% Full simplified chain with two modes:
%   1) legacy_fluence          : original phenomenological defect model
%   2) module2_synthetic_recoil: updated Module 2 front end using synthetic recoil spectrum

clear; clc; close all;
addpath('functions');

%% ------------------------ User parameters -----------------------------
mode = 'module2_synthetic_recoil';

Phi   = logspace(8, 14, 400); % [cm^-2]
k_D   = 1e2;                  % [cm^-1] legacy defect-introduction coefficient

% Downstream simplified device parameters
tau_0 = 1e-6;   % [s]
K_tau = 1e-10;  % [cm^3/s]
D     = 25;     % [cm^2/s]
alpha = 4e-17;  % [A/cm]
V     = 0.03;   % [cm^3]
I0    = 1e-9;   % [A]
W     = 300e-4; % [cm]

outdir = fullfile('output');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

%% ------------------------ Front-end defect model ----------------------
switch lower(mode)
    case 'legacy_fluence'
        N_eff = defect_density_from_fluence(Phi, k_D);
        modeLabel = repmat("legacy_fluence", numel(Phi), 1);

    case 'module2_synthetic_recoil'
        p = module2_default_params('Si');
        detector_volume_cm3 = 0.03;
        p.normalize_by_volume_cm3 = detector_volume_cm3;

        N_eff = zeros(size(Phi));
        for i = 1:numel(Phi)
            nRecoils = max(10, round(2e-12 * Phi(i))); % purely synthetic scaling for demo use
            Tsynthetic = 10 + exprnd(60, [nRecoils, 1]);
            Trecoil = table(Tsynthetic, 'VariableNames', {'kinetic_energy_eV'});

            defectOut = defect_sources_from_recoil_list(Trecoil, ...
                'Material', 'Si', ...
                'NormalizeByVolume_cm3', p.normalize_by_volume_cm3, ...
                'Params', p);

            N_eff(i) = effective_defect_density_from_sources( ...
                defectOut.NV_total_cm3, defectOut.NI_total_cm3, ...
                'Model', p.effective_model, ...
                'wV', p.wV, ...
                'wI', p.wI);
        end
        modeLabel = repmat("module2_synthetic_recoil", numel(Phi), 1);

    otherwise
        error('Unknown mode: %s', mode);
end

%% ------------------------ Downstream chain ----------------------------
tau_eff = lifetime_from_defects(N_eff, tau_0, K_tau);
L = diffusion_length_from_lifetime(D, tau_eff);
DeltaI = leakage_current_from_fluence(Phi, alpha, V); % legacy leakage retained
I_total = I0 + DeltaI;
CCE = charge_collection_model(L, W);

%% ------------------------ Save data table -----------------------------
results_table = table(modeLabel(:), Phi(:), N_eff(:), tau_eff(:), L(:), I_total(:), CCE(:), ...
    'VariableNames', {'Mode', 'Fluence_cm2', 'EffectiveDefectDensity_cm3', 'TauEff_s', ...
    'DiffusionLength_cm', 'LeakageCurrent_A', 'ChargeCollectionEff'});

writetable(results_table, fullfile(outdir, 'full_pipeline_results.csv'));

%% ------------------------ Figure 1: defects --------------------------
fig1 = figure('Name', 'Effective Defect Density', 'Color', 'w');
loglog(Phi, N_eff, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Effective defect concentration [cm^{-3}]');
title(sprintf('Effective Defect Density vs Fluence (%s)', mode));
saveas(fig1, fullfile(outdir, 'fig1_effective_defect_density.png'));

%% ------------------------ Figure 2: lifetime -------------------------
fig2 = figure('Name', 'Lifetime', 'Color', 'w');
loglog(Phi, tau_eff, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Effective lifetime, \tau_{eff} [s]');
title(sprintf('Carrier Lifetime vs Fluence (%s)', mode));
saveas(fig2, fullfile(outdir, 'fig2_lifetime.png'));

%% ------------------------ Figure 3: diffusion length -----------------
fig3 = figure('Name', 'Diffusion Length', 'Color', 'w');
loglog(Phi, L, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Diffusion length, L [cm]');
title(sprintf('Diffusion Length vs Fluence (%s)', mode));
saveas(fig3, fullfile(outdir, 'fig3_diffusion_length.png'));

%% ------------------------ Figure 4: leakage current ------------------
fig4 = figure('Name', 'Leakage Current', 'Color', 'w');
loglog(Phi, I_total, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Leakage current, I [A]');
title('Leakage Current vs Fluence (legacy leakage path)');
saveas(fig4, fullfile(outdir, 'fig4_leakage_current.png'));

%% ------------------------ Figure 5: charge collection ----------------
fig5 = figure('Name', 'Charge Collection Efficiency', 'Color', 'w');
semilogx(Phi, CCE, 'LineWidth', 2);
grid on;
xlabel('Fluence, \Phi [cm^{-2}]');
ylabel('Normalized charge collection efficiency');
title(sprintf('Charge Collection Efficiency vs Fluence (%s)', mode));
saveas(fig5, fullfile(outdir, 'fig5_charge_collection_efficiency.png'));

%% ------------------------ Console summary ----------------------------
fprintf('\nFull pipeline complete.\n');
fprintf('Mode: %s\n', mode);
fprintf('Results saved to: %s\n', outdir);
disp(results_table(1:50:end, :));
