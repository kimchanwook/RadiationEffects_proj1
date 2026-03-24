function nu = defect_multiplicity_from_recoil(Trecoil_eV, Ed_eV, varargin)
%DEFECT_MULTIPLICITY_FROM_RECOIL Number of defect units produced per recoil.
%
%   nu = defect_multiplicity_from_recoil(Trecoil_eV, Ed_eV, ...)
%
%   Name-value pairs:
%       'Model'              : 'single_pair', 'piecewise', 'powerlaw'
%       'CascadeThreshold_eV': onset of multi-defect production
%       'MultiplicityScale'  : scale factor
%       'MaxMultiplicity'    : upper cap

    ip = inputParser;
    ip.addRequired('Trecoil_eV', @isnumeric);
    ip.addRequired('Ed_eV', @isnumeric);
    ip.addParameter('Model', 'single_pair', @(x) ischar(x) || isstring(x));
    ip.addParameter('CascadeThreshold_eV', 200, @(x) isnumeric(x) && isscalar(x) && x > 0);
    ip.addParameter('MultiplicityScale', 1.0, @(x) isnumeric(x) && isscalar(x) && x > 0);
    ip.addParameter('MaxMultiplicity', 50, @(x) isnumeric(x) && isscalar(x) && x >= 1);
    ip.parse(Trecoil_eV, Ed_eV, varargin{:});

    model = lower(char(ip.Results.Model));
    T = Trecoil_eV;
    Ed = Ed_eV;
    Tc = ip.Results.CascadeThreshold_eV;
    scale = ip.Results.MultiplicityScale;
    nuMax = ip.Results.MaxMultiplicity;

    nu = zeros(size(T));

    switch model
        case 'single_pair'
            nu(T >= Ed) = 1;

        case 'piecewise'
            mask1 = (T >= Ed) & (T < Tc);
            nu(mask1) = 1;

            mask2 = T >= Tc;
            nu(mask2) = 1 + scale .* floor((T(mask2) - Tc) ./ max(Ed, 1));
            nu = min(nu, nuMax);

        case 'powerlaw'
            mask = T >= Ed;
            nu(mask) = scale .* (T(mask) ./ max(Ed, 1)).^0.5;
            nu(mask) = max(1, nu(mask));
            nu = min(nu, nuMax);

        otherwise
            error('Unknown multiplicity model: %s', model);
    end
end
