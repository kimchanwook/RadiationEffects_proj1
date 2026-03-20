function CCE = charge_collection_model(L, W)
% charge_collection_model
% Returns a simple normalized charge collection efficiency curve based on
% diffusion length and a characteristic collection distance.
%
% Simple phenomenological model:
%   CCE = 1 - exp(-L / W)
%
% Inputs:
%   L - diffusion length [cm]
%   W - characteristic collection distance [cm]
%
% Output:
%   CCE - normalized charge collection efficiency [0, 1]

validateattributes(L, {'numeric'}, {'real', 'positive', 'nonempty'});
validateattributes(W, {'numeric'}, {'real', 'positive', 'scalar'});

CCE = 1 - exp(-L ./ W);
CCE = max(0, min(1, CCE));
end
