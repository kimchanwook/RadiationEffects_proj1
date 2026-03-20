clear; clc; close all;

addpath('functions');
outdir = 'output';
if ~exist(outdir,'dir')
    mkdir(outdir);
end

% Illustrative cryogenic recovery model parameters
Q0 = 1.0;                  % normalized initial trapped charge
Ea_rec_eV = 0.10;          % eV, illustrative recovery activation energy
emit_tau0 = 1e-9;          % s, emission-based attempt timescale
ann_tau0 = 1e-6;           % s, annealing-based attempt timescale
T_list = [300, 77, 20, 4]; % K

t = logspace(-9, 8, 1200); % s

emitTau_T = recovery_time_constant_vs_temperature(T_list, emit_tau0, Ea_rec_eV);
annTau_T  = recovery_time_constant_vs_temperature(T_list, ann_tau0, Ea_rec_eV);

timeTo50_emit = emitTau_T .* log(2);
timeTo50_ann  = annTau_T .* log(2);

Q_emit = zeros(numel(T_list), numel(t));
Q_ann  = zeros(numel(T_list), numel(t));
for i = 1:numel(T_list)
    Q_emit(i,:) = trapped_charge_recovery(t, Q0, emitTau_T(i));
    Q_ann(i,:)  = trapped_charge_recovery(t, Q0, annTau_T(i));
end

summaryTable = table(T_list(:), emitTau_T(:), annTau_T(:), timeTo50_emit(:), timeTo50_ann(:), ...
    'VariableNames', {'Temperature_K','EmissionRecoveryTau_s','AnnealingRecoveryTau_s', ...
    'EmissionTimeTo50pct_s','AnnealingTimeTo50pct_s'});
writetable(summaryTable, fullfile(outdir,'persistent_trapping_summary.csv'));

fig1 = figure('Color','w');
for i = 1:numel(T_list)
    semilogx(t, Q_emit(i,:), 'LineWidth', 2); hold on;
end
xlabel('Time (s)'); ylabel('Normalized trapped charge');
title('Persistent Trapping Recovery via Trap Emission');
legend('300 K','77 K','20 K','4 K','Location','best');
grid on;
saveas(fig1, fullfile(outdir,'persistent_trapping_recovery_emission.png'));

fig2 = figure('Color','w');
for i = 1:numel(T_list)
    semilogx(t, Q_ann(i,:), 'LineWidth', 2); hold on;
end
xlabel('Time (s)'); ylabel('Normalized trapped charge');
title('Persistent Trapping Recovery via Annealing');
legend('300 K','77 K','20 K','4 K','Location','best');
grid on;
saveas(fig2, fullfile(outdir,'persistent_trapping_recovery_annealing.png'));

Tscan = linspace(4, 400, 800);
tau_emit_scan = recovery_time_constant_vs_temperature(Tscan, emit_tau0, Ea_rec_eV);
tau_ann_scan  = recovery_time_constant_vs_temperature(Tscan, ann_tau0, Ea_rec_eV);

fig3 = figure('Color','w');
semilogy(Tscan, tau_emit_scan, 'LineWidth', 2); hold on;
semilogy(Tscan, tau_ann_scan, 'LineWidth', 2);
xlabel('Temperature (K)'); ylabel('Recovery time constant (s)');
title('Recovery Time Constant vs Temperature');
legend('Emission-limited recovery','Annealing-limited recovery','Location','best');
grid on;
saveas(fig3, fullfile(outdir,'recovery_time_constant_vs_temperature.png'));

fig4 = figure('Color','w');
loglog(T_list, timeTo50_emit, 'o-', 'LineWidth', 2, 'MarkerSize', 8); hold on;
loglog(T_list, timeTo50_ann, 's-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Temperature (K)'); ylabel('Time to 50% recovery (s)');
title('Time to 50% Recovery vs Temperature');
legend('Emission-limited','Annealing-limited','Location','best');
grid on;
saveas(fig4, fullfile(outdir,'time_to_50pct_recovery_vs_temperature.png'));

disp('Persistent trapping extension complete. Results written to matlab/output/.');
