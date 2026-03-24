%% main_import_geant4_pipeline.m
% Import Geant4 CSV outputs and connect them to the updated Module 2
% recoil-threshold-survival defect model, then propagate into the existing
% simplified lifetime / diffusion / leakage / CCE chain.

clear; clc; close all;
addpath('functions');

%% ------------------------ File locations ------------------------------
geant4OutDir = fullfile('..', 'geant4', 'output');
outdir = fullfile('output');
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

fileEvent  = fullfile(geant4OutDir, 'event_summary.csv');
fileDepth  = fullfile(geant4OutDir, 'depth_edep.csv');
fileRecoil = fullfile(geant4OutDir, 'recoil_candidates.csv');

assert(isfile(fileEvent),  'Missing file: %s', fileEvent);
assert(isfile(fileDepth),  'Missing file: %s', fileDepth);
assert(isfile(fileRecoil), 'Missing file: %s', fileRecoil);

%% ------------------------ Read Geant4 outputs -------------------------
Tevent  = read_geant4_event_summary(fileEvent);
Tdepth  = read_geant4_depth_edep(fileDepth);
Trecoil = read_geant4_recoil_candidates(fileRecoil);

nEvents = height(Tevent);

%% ------------------------ User parameters -----------------------------
beamArea_cm2 = 1.0;   % legacy diagnostic only
thickness_um = 300;   % assumed silicon thickness for depth profiles
thickness_cm = thickness_um * 1e-4;
detector_volume_cm3 = beamArea_cm2 * thickness_cm;

% Updated Module 2 parameters
p = module2_default_params('Si');
p.normalize_by_volume_cm3 = detector_volume_cm3;
p.depth_edges_um = linspace(0, thickness_um, 51);

% Downstream simplified device parameters (unchanged)
tau_0 = 1e-6;   % [s]
K_tau = 1e-10;  % [cm^3/s]
D     = 25;     % [cm^2/s]
alpha = 4e-17;  % [A/cm]
V     = 0.03;   % [cm^3]
I0    = 1e-9;   % [A]
W     = 300e-4; % [cm]

%% ------------------------ Geant4-derived diagnostics ------------------
Phi_eff = estimate_fluence_from_events(nEvents, beamArea_cm2); % diagnostic only
meanEdep_eV = mean(Tevent.total_edep_eV);
medianEdep_eV = median(Tevent.total_edep_eV);
recoilCount = height(Trecoil);
recoilPerEvent = recoilCount / max(nEvents, 1);

%% ------------------------ Updated Module 2 bridge ---------------------
defectOut = defect_sources_from_recoil_list(Trecoil, ...
    'Material', 'Si', ...
    'Temperature_K', p.Temperature_K, ...
    'UseDepth', true, ...
    'ReturnProfiles', true, ...
    'DepthBinning', p.depth_edges_um, ...
    'NormalizeByVolume_cm3', p.normalize_by_volume_cm3, ...
    'Params', p);

N_eff_bulk = effective_defect_density_from_sources( ...
    defectOut.NV_total_cm3, defectOut.NI_total_cm3, ...
    'Model', p.effective_model, ...
    'wV', p.wV, ...
    'wI', p.wI);

%% ------------------------ Downstream simplified chain -----------------
tau_eff = lifetime_from_defects(N_eff_bulk, tau_0, K_tau);
L = diffusion_length_from_lifetime(D, tau_eff);
DeltaI = leakage_current_from_fluence(Phi_eff, alpha, V); % legacy leakage path retained for now
I_total = I0 + DeltaI;
CCE = charge_collection_model(L, W);

%% ------------------------ Save summary tables -------------------------
summaryTable = table(Phi_eff, nEvents, meanEdep_eV, medianEdep_eV, ...
    recoilCount, recoilPerEvent, ...
    defectOut.NV_total_cm3, defectOut.NI_total_cm3, N_eff_bulk, ...
    defectOut.meanYieldPerRecoil, defectOut.meanDisplacementProbability, defectOut.meanSurvivalFraction, ...
    tau_eff, L, I_total, CCE, ...
    'VariableNames', {'EffectiveFluence_cm2', 'NumEvents', 'MeanEdep_eV', ...
    'MedianEdep_eV', 'RecoilCount', 'RecoilPerEvent', ...
    'VacancyDensity_cm3', 'InterstitialDensity_cm3', 'EffectiveDefectDensity_cm3', ...
    'MeanYieldPerRecoil', 'MeanDisplacementProbability', 'MeanSurvivalFraction', ...
    'TauEff_s', 'DiffusionLength_cm', 'LeakageCurrent_A', 'ChargeCollectionEff'});

writetable(summaryTable, fullfile(outdir, 'geant4_import_summary.csv'));

profileTable = table(Tdepth.z_center_um, Tdepth.edep_eV, ...
    'VariableNames', {'z_center_um', 'DepthEdep_eV'});

if isfield(defectOut, 'z_um')
    profileTable.Module2_z_um = defectOut.z_um(:);
    profileTable.NV_depth_cm3 = defectOut.NV_depth_cm3(:);
    profileTable.NI_depth_cm3 = defectOut.NI_depth_cm3(:);
    profileTable.Ndefect_depth_cm3 = defectOut.Ndefect_depth_cm3(:);
end

writetable(profileTable, fullfile(outdir, 'geant4_depth_defect_profile.csv'));

%% ------------------------ Figure 1: event edep histogram -------------
fig1 = figure('Name', 'Geant4 Event Energy Deposition', 'Color', 'w');
histogram(Tevent.total_edep_eV, 50);
grid on;
xlabel('Total deposited energy per event [eV]');
ylabel('Counts');
title('Geant4 Event-by-Event Deposited Energy');
saveas(fig1, fullfile(outdir, 'fig_geant4_event_edep_hist.png'));

%% ------------------------ Figure 2: depth edep profile ---------------
fig2 = figure('Name', 'Depth Energy Deposition', 'Color', 'w');
plot(Tdepth.z_center_um, Tdepth.edep_eV, 'LineWidth', 2);
grid on;
xlabel('Depth z [\mum]');
ylabel('Deposited energy [eV]');
title('Depth-Dependent Energy Deposition from Geant4');
saveas(fig2, fullfile(outdir, 'fig_geant4_depth_edep.png'));

%% ------------------------ Figure 3: recoil histogram -----------------
fig3 = figure('Name', 'Recoil Candidate Energies', 'Color', 'w');
if ~isempty(Trecoil)
    histogram(Trecoil.kinetic_energy_eV, 50);
else
    histogram(0);
end
grid on;
xlabel('Recoil candidate kinetic energy [eV]');
ylabel('Counts');
title('Geant4 Recoil-Candidate Energy Spectrum');
saveas(fig3, fullfile(outdir, 'fig_geant4_recoil_energy_hist.png'));

%% ------------------------ Figure 4: Module 2 depth profile -----------
fig4 = figure('Name', 'Module 2 Defect Profile', 'Color', 'w');
if isfield(defectOut, 'z_um')
    plot(defectOut.z_um, defectOut.Ndefect_depth_cm3, 'LineWidth', 2);
else
    plot(0, 0, 'LineWidth', 2);
end
grid on;
xlabel('Depth z [\mum]');
ylabel('Module 2 defect density [cm^{-3}]');
title('Depth-Dependent Primary Defect Density from Recoil Physics');
saveas(fig4, fullfile(outdir, 'fig_geant4_depth_module2_defect_profile.png'));

%% ------------------------ Figure 5: bulk device metrics --------------
fig5 = figure('Name', 'Bulk Device Metrics from Imported Geant4 Run', 'Color', 'w');
tiledlayout(2,2);
nexttile;
bar(N_eff_bulk); grid on; ylabel('N_{eff} [cm^{-3}]'); title('Effective Defect Density');
nexttile;
bar(tau_eff); grid on; ylabel('\tau_{eff} [s]'); title('Effective Lifetime');
nexttile;
bar(L); grid on; ylabel('L [cm]'); title('Diffusion Length');
nexttile;
bar(I_total); grid on; ylabel('I [A]'); title('Leakage Current');
saveas(fig5, fullfile(outdir, 'fig_geant4_imported_device_metrics.png'));

%% ------------------------ Console summary ----------------------------
fprintf('\nGeant4 import pipeline complete.\n');
fprintf('Read %d events from %s\n', nEvents, fileEvent);
fprintf('Effective nominal fluence (diagnostic): %.6e cm^-2\n', Phi_eff);
fprintf('Mean event deposited energy: %.6e eV\n', meanEdep_eV);
fprintf('Recoil candidates per event: %.6e\n', recoilPerEvent);
fprintf('Bulk effective defect density from Module 2: %.6e cm^-3\n', N_eff_bulk);
disp(summaryTable);
