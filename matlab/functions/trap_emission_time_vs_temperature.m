function emitTau = trap_emission_time_vs_temperature(T, e0, Ea_eV)
% TRAP_EMISSION_TIME_VS_TEMPERATURE
% Emission time constant defined as inverse of emission rate.

emitRate = trap_emission_rate_vs_temperature(T, e0, Ea_eV);
emitTau = 1 ./ emitRate;
end
