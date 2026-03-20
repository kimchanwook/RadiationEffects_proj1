function DeltaI = leakage_current_from_fluence(Phi, alpha, V)
% leakage_current_from_fluence
% Computes radiation-induced leakage current increase.
%
% Model:
%   Delta I = alpha * Phi * V
%
% Inputs:
%   Phi   - particle fluence [cm^-2]
%   alpha - current-related damage coefficient [A/cm]
%   V     - active or depleted volume [cm^3]
%
% Output:
%   DeltaI - increase in leakage current [A]

validateattributes(Phi,   {'numeric'}, {'real', 'positive', 'nonempty'});
validateattributes(alpha, {'numeric'}, {'real', 'positive', 'scalar'});
validateattributes(V,     {'numeric'}, {'real', 'positive', 'scalar'});

DeltaI = alpha .* Phi .* V;
end
