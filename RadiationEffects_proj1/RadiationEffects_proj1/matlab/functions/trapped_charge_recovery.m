function Qtrap = trapped_charge_recovery(t, Q0, tau_rec)
% trapped_charge_recovery
% Exponential recovery of trapped charge.
% t       : time array in s
% Q0      : initial trapped charge (arbitrary units)
% tau_rec : recovery time constant in s

Qtrap = Q0 .* exp(-t ./ tau_rec);
end
