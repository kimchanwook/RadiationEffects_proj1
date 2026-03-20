clear; clc; close all;

addpath('functions');
outdir = 'output';
if ~exist(outdir,'dir')
    mkdir(outdir);
end

T = linspace(4, 400, 800); % K

params.D0 = 1e-3;          % cm^2/s, illustrative prefactor
params.Em_eV = 0.18;       % eV, illustrative migration barrier
params.e0 = 1e8;           % 1/s, illustrative emission prefactor
params.Ea_eV = 0.12;       % eV, illustrative trap activation energy
params.R0 = 1e5;           % 1/s, illustrative annealing prefactor
params.Eann_eV = 0.25;     % eV, illustrative annealing barrier

Ddef = defect_diffusivity_vs_temperature(T, params.D0, params.Em_eV);
emitRate = trap_emission_rate_vs_temperature(T, params.e0, params.Ea_eV);
emitTau = trap_emission_time_vs_temperature(T, params.e0, params.Ea_eV);
annRate = annealing_rate_vs_temperature(T, params.R0, params.Eann_eV);

summaryTable = table(T(:), Ddef(:), emitRate(:), emitTau(:), annRate(:), ...
    'VariableNames', {'Temperature_K','DefectDiffusivity_cm2_per_s', ...
    'TrapEmissionRate_per_s','TrapEmissionTime_s','AnnealingRate_per_s'});
writetable(summaryTable, fullfile(outdir,'cryogenic_kinetics_summary.csv'));

fig1 = figure('Color','w');
semilogy(T, Ddef, 'LineWidth', 2);
xlabel('Temperature (K)'); ylabel('Defect diffusivity (cm^2/s)');
title('Defect Diffusivity vs Temperature'); grid on;
saveas(fig1, fullfile(outdir,'defect_diffusivity_vs_temperature.png'));

fig2 = figure('Color','w');
semilogy(T, emitRate, 'LineWidth', 2);
xlabel('Temperature (K)'); ylabel('Trap emission rate (1/s)');
title('Trap Emission Rate vs Temperature'); grid on;
saveas(fig2, fullfile(outdir,'trap_emission_rate_vs_temperature.png'));

fig3 = figure('Color','w');
semilogy(T, emitTau, 'LineWidth', 2);
xlabel('Temperature (K)'); ylabel('Trap emission time (s)');
title('Trap Emission Time vs Temperature'); grid on;
saveas(fig3, fullfile(outdir,'trap_emission_time_vs_temperature.png'));

fig4 = figure('Color','w');
semilogy(T, annRate, 'LineWidth', 2);
xlabel('Temperature (K)'); ylabel('Annealing rate (1/s)');
title('Annealing Rate vs Temperature'); grid on;
saveas(fig4, fullfile(outdir,'annealing_rate_vs_temperature.png'));

fig5 = figure('Color','w');
plot(T, Ddef/max(Ddef), 'LineWidth', 2); hold on;
plot(T, emitRate/max(emitRate), 'LineWidth', 2);
plot(T, annRate/max(annRate), 'LineWidth', 2);
xlabel('Temperature (K)'); ylabel('Normalized value');
title('Normalized Cryogenic Kinetics Regime Map');
legend('Defect diffusivity','Trap emission rate','Annealing rate','Location','northwest');
grid on;
saveas(fig5, fullfile(outdir,'normalized_cryogenic_regime_map.png'));

disp('Cryogenic extension complete. Results written to matlab/output/.');
