function tau_eff = lifetime_from_defects(N_D, tau_0, K_tau)
% lifetime_from_defects
% Computes effective carrier lifetime from defect concentration.
%
% Model:
%   1/tau_eff = 1/tau_0 + K_tau * N_D
%
% Inputs:
%   N_D   - defect concentration [cm^-3]
%   tau_0 - pre-radiation lifetime [s]
%   K_tau - recombination sensitivity coefficient [cm^3/s]
%
% Output:
%   tau_eff - effective lifetime [s]

validateattributes(N_D,   {'numeric'}, {'real', 'nonnegative', 'nonempty'});
validateattributes(tau_0, {'numeric'}, {'real', 'positive', 'scalar'});
validateattributes(K_tau, {'numeric'}, {'real', 'positive', 'scalar'});

inv_tau = (1 ./ tau_0) + K_tau .* N_D;
tau_eff = 1 ./ inv_tau;
end
