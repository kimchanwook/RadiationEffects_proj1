function L = diffusion_length_from_lifetime(D, tau_eff)
% diffusion_length_from_lifetime
% Computes diffusion length from diffusivity and effective lifetime.
%
% Model:
%   L = sqrt(D * tau_eff)
%
% Inputs:
%   D       - diffusivity [cm^2/s]
%   tau_eff - effective lifetime [s]
%
% Output:
%   L - diffusion length [cm]

validateattributes(D, {'numeric'}, {'real', 'positive', 'scalar'});
validateattributes(tau_eff, {'numeric'}, {'real', 'positive', 'nonempty'});

L = sqrt(D .* tau_eff);
end
