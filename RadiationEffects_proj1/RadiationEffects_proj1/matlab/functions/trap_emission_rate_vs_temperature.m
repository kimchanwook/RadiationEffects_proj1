function emitRate = trap_emission_rate_vs_temperature(T, e0, Ea_eV)
% TRAP_EMISSION_RATE_VS_TEMPERATURE
% Thermally activated trap emission rate.

kB_eV = 8.617333262145e-5; % eV/K
emitRate = e0 .* exp(-Ea_eV ./ (kB_eV .* T));
end
