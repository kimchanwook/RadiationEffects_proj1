%% main_defect_model.m
% Module 2 stand-alone study:
% recoil energy -> displacement probability -> multiplicity -> survival -> yield

clear; clc; close all;
addpath('functions');

outdir = fullfile('output');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

%% ------------------------ Parameters -----------------------------------
p = module2_default_params('Si');
Trecoil_eV = linspace(0, 500, 1000);

%% ------------------------ Module 2 physics -----------------------------
[Y, details] = frenkel_pair_yield(Trecoil_eV, 'Si', 'Params', p);

%% ------------------------ Save sample table ----------------------------
sample_idx = round(linspace(1, numel(Trecoil_eV), 8));
Tsample = table(Trecoil_eV(sample_idx).', ...
                repmat(details.Ed_eV(1), numel(sample_idx), 1), ...
                details.Pdisp(sample_idx).', ...
                details.nu(sample_idx).', ...
                details.S(sample_idx).', ...
                Y(sample_idx).', ...
    'VariableNames', {'Trecoil_eV', 'Ed_eV', 'Pdisp', 'Multiplicity', 'Survival', 'Yield'});
writetable(Tsample, fullfile(outdir, 'module2_recoil_yield_samples.csv'));

%% ------------------------ Figure 1: Pdisp -----------------------------
fig1 = figure('Name', 'Module 2 Displacement Probability', 'Color', 'w');
plot(Trecoil_eV, details.Pdisp, 'LineWidth', 2);
grid on;
xlabel('Recoil energy [eV]');
ylabel('Displacement probability');
title('Module 2: Displacement Probability vs Recoil Energy');
saveas(fig1, fullfile(outdir, 'fig_module2_displacement_probability.png'));

%% ------------------------ Figure 2: multiplicity ----------------------
fig2 = figure('Name', 'Module 2 Multiplicity', 'Color', 'w');
plot(Trecoil_eV, details.nu, 'LineWidth', 2);
grid on;
xlabel('Recoil energy [eV]');
ylabel('Defect multiplicity');
title('Module 2: Defect Multiplicity vs Recoil Energy');
saveas(fig2, fullfile(outdir, 'fig_module2_multiplicity.png'));

%% ------------------------ Figure 3: survival --------------------------
fig3 = figure('Name', 'Module 2 Survival', 'Color', 'w');
plot(Trecoil_eV, details.S, 'LineWidth', 2);
grid on;
xlabel('Recoil energy [eV]');
ylabel('Survival fraction');
title('Module 2: Survival Fraction vs Recoil Energy');
saveas(fig3, fullfile(outdir, 'fig_module2_survival_fraction.png'));

%% ------------------------ Figure 4: total yield -----------------------
fig4 = figure('Name', 'Module 2 Yield', 'Color', 'w');
plot(Trecoil_eV, Y, 'LineWidth', 2);
grid on;
xlabel('Recoil energy [eV]');
ylabel('Surviving defect yield per recoil');
title('Module 2: Frenkel-Pair Yield vs Recoil Energy');
saveas(fig4, fullfile(outdir, 'fig_module2_frenkel_pair_yield.png'));

fprintf('\nModule 2 stand-alone study complete.\n');
fprintf('Results saved to: %s\n', outdir);
disp(Tsample);
