function Ddef = defect_diffusivity_vs_temperature(T, D0, Em_eV)
% DEFECT_DIFFUSIVITY_VS_TEMPERATURE
% First-order Arrhenius model for defect diffusivity.

kB_eV = 8.617333262145e-5; % eV/K
Ddef = D0 .* exp(-Em_eV ./ (kB_eV .* T));
end
