function tau_rec = recovery_time_constant_vs_temperature(T, tau0, Ea_eV)
% recovery_time_constant_vs_temperature
% Simple Arrhenius recovery time constant model.
% T      : temperature in K
% tau0   : prefactor in s
% Ea_eV  : activation energy in eV

kB_eV = 8.617333262145e-5; % eV/K
T = max(T, 1e-12);
tau_rec = tau0 .* exp(Ea_eV ./ (kB_eV .* T));
end
