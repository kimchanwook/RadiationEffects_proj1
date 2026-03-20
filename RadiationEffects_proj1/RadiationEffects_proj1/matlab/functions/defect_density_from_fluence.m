function N_D = defect_density_from_fluence(Phi, k_D)
% defect_density_from_fluence
% Computes an effective defect concentration from radiation fluence.
%
% Inputs:
%   Phi - particle fluence [cm^-2]
%   k_D - defect introduction coefficient [cm^-1]
%
% Output:
%   N_D - effective defect concentration [cm^-3]

validateattributes(Phi, {'numeric'}, {'real', 'positive', 'nonempty'});
validateattributes(k_D, {'numeric'}, {'real', 'positive', 'scalar'});

N_D = k_D .* Phi;
end
