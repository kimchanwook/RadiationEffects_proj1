function annRate = annealing_rate_vs_temperature(T, R0, Eann_eV)
% ANNEALING_RATE_VS_TEMPERATURE
% First-order Arrhenius model for annealing or recovery rate.

kB_eV = 8.617333262145e-5; % eV/K
annRate = R0 .* exp(-Eann_eV ./ (kB_eV .* T));
end
