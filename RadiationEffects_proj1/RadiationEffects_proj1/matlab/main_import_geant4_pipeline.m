%% main_import_geant4_pipeline.m
% Import Geant4 CSV outputs and connect them to the simplified MATLAB
% defect/lifetime/device degradation model.
%
% Expected Geant4 files:
%   ../geant4/output/event_summary.csv
%   ../geant4/output/depth_edep.csv
%   ../geant4/output/recoil_candidates.csv
%
% Workflow:
%   1) Read Geant4 scoring outputs
%   2) Estimate an effective fluence from number of simulated primaries
%   3) Build a defect-density model from that fluence
%   4) Build a depth-dependent defect proxy from depth_edep.csv
%   5) Propagate into lifetime, diffusion length, leakage current, and CCE

clear; clc; close all;
addpath('functions');

%% ------------------------ File locations ------------------------------
geant4OutDir = fullfile('..', 'geant4', 'output');
outdir       = fullfile('output');

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
% Geometry assumption for converting # simulated primaries -> nominal fluence
beamArea_cm2 = 1.0;  % assumes 1 cm^2 illuminated slab area

% Defect / materials / device model coefficients
k_D      = 1e2;      % [cm^-1] defect introduction coefficient for fluence model
k_depth  = 5e7;      % [cm^-3 / eV] depth-damage scaling for qualitative proxy
au_0    = 1e-6;     % [s] pre-radiation minority-carrier lifetime
K_tau    = 1e-10;    % [cm^3/s] lifetime sensitivity coefficient
D        = 25;       % [cm^2/s] diffusivity
alpha    = 4e-17;    % [A/cm] current-related damage coefficient
V        = 0.03;     % [cm^3] active/depleted volume
I0       = 1e-9;     % [A] baseline leakage current
W        = 300e-4;   % [cm] characteristic collection distance (300 um)

%% ------------------------ Geant4-derived metrics ----------------------
Phi_eff = estimate_fluence_from_events(nEvents, beamArea_cm2);
meanEdep_eV = mean(Tevent.total_edep_eV);
medianEdep_eV = median(Tevent.total_edep_eV);
recoilCount = height(Trecoil);
recoilPerEvent = recoilCount / max(nEvents, 1);

% Depth-dependent damage proxy from deposited energy
N_D_depth = defect_density_from_depth_edep(Tdepth.edep_eV, k_depth);

% Bulk defect density from effective fluence
N_D_bulk = defect_density_from_fluence(Phi_eff, k_D);

% Continue through the simplified materials/device model
au_eff = lifetime_from_defects(N_D_bulk, au_0, K_tau);
L       = diffusion_length_from_lifetime(D, au_eff);
DeltaI  = leakage_current_from_fluence(Phi_eff, alpha, V);
I_total = I0 + DeltaI;
CCE     = charge_collection_model(L, W);

%% ------------------------ Save summary tables -------------------------
summaryTable = table(Phi_eff, nEvents, meanEdep_eV, medianEdep_eV, ...
    recoilCount, recoilPerEvent, N_D_bulk, au_eff, L, I_total, CCE, ...
    'VariableNames', {'EffectiveFluence_cm2', 'NumEvents', 'MeanEdep_eV', ...
    'MedianEdep_eV', 'RecoilCount', 'RecoilPerEvent', 'BulkDefectDensity_cm3', ...
    'TauEff_s', 'DiffusionLength_cm', 'LeakageCurrent_A', 'ChargeCollectionEff'});

writetable(summaryTable, fullfile(outdir, 'geant4_import_summary.csv'));

profileTable = table(Tdepth.z_center_um, Tdepth.edep_eV, N_D_depth, ...
    'VariableNames', {'z_center_um', 'DepthEdep_eV', 'DepthDefectProxy_cm3'});

writetable(profileTable, fullfile(outdir, 'geant4_depth_defect_profile.csv'));

%% ------------------------ Figure 1: Event edep histogram -------------
fig1 = figure('Name', 'Geant4 Event Energy Deposition', 'Color', 'w');
histogram(Tevent.total_edep_eV, 50);
grid on;
xlabel('Total deposited energy per event [eV]');
ylabel('Counts');
title('Geant4 Event-by-Event Deposited Energy');
saveas(fig1, fullfile(outdir, 'fig_geant4_event_edep_hist.png'));

%% ------------------------ Figure 2: Depth edep profile ---------------
fig2 = figure('Name', 'Depth Energy Deposition', 'Color', 'w');
plot(Tdepth.z_center_um, Tdepth.edep_eV, 'LineWidth', 2);
grid on;
xlabel('Depth z [\mum]');
ylabel('Deposited energy [eV]');
title('Depth-Dependent Energy Deposition from Geant4');
saveas(fig2, fullfile(outdir, 'fig_geant4_depth_edep.png'));

%% ------------------------ Figure 3: Recoil histogram -----------------
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

%% ------------------------ Figure 4: Depth defect proxy ---------------
fig4 = figure('Name', 'Depth Defect Proxy', 'Color', 'w');
plot(Tdepth.z_center_um, N_D_depth, 'LineWidth', 2);
grid on;
xlabel('Depth z [\mum]');
ylabel('Defect-density proxy [cm^{-3}]');
title('Depth-Dependent Defect Proxy Derived from Geant4');
saveas(fig4, fullfile(outdir, 'fig_geant4_depth_defect_proxy.png'));

%% ------------------------ Figure 5: Bulk device metrics --------------
fig5 = figure('Name', 'Bulk Device Metrics from Imported Geant4 Run', 'Color', 'w');
tiledlayout(2,2);

nexttile;
bar(N_D_bulk);
grid on;
ylabel('N_D [cm^{-3}]');
title('Bulk Defect Density');

nexttile;
bar(au_eff);
grid on;
ylabel('\tau_{eff} [s]');
title('Effective Lifetime');

nexttile;
bar(L);
grid on;
ylabel('L [cm]');
title('Diffusion Length');

nexttile;
bar(I_total);
grid on;
ylabel('I [A]');
title('Leakage Current');

saveas(fig5, fullfile(outdir, 'fig_geant4_imported_device_metrics.png'));

%% ------------------------ Console summary ----------------------------
fprintf('\nGeant4 import pipeline complete.\n');
fprintf('Read %d events from %s\n', nEvents, fileEvent);
fprintf('Effective nominal fluence: %.6e cm^-2\n', Phi_eff);
fprintf('Mean event deposited energy: %.6e eV\n', meanEdep_eV);
fprintf('Recoil candidates per event: %.6e\n', recoilPerEvent);

disp(summaryTable);
