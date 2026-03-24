function Neff_cm3 = effective_defect_density_from_sources(NV_cm3, NI_cm3, varargin)
%EFFECTIVE_DEFECT_DENSITY_FROM_SOURCES Map vacancy/interstitial densities to Neff.
%
%   Neff_cm3 = effective_defect_density_from_sources(NV_cm3, NI_cm3, ...)
%
%   Name-value pairs:
%       'Model' : 'sum' or 'weighted_sum'
%       'wV'    : vacancy weight
%       'wI'    : interstitial weight

    ip = inputParser;
    ip.addRequired('NV_cm3', @isnumeric);
    ip.addRequired('NI_cm3', @isnumeric);
    ip.addParameter('Model', 'weighted_sum', @(x) ischar(x) || isstring(x));
    ip.addParameter('wV', 1.0, @(x) isnumeric(x) && isscalar(x));
    ip.addParameter('wI', 1.0, @(x) isnumeric(x) && isscalar(x));
    ip.parse(NV_cm3, NI_cm3, varargin{:});

    model = lower(char(ip.Results.Model));
    wV = ip.Results.wV;
    wI = ip.Results.wI;

    switch model
        case 'sum'
            Neff_cm3 = NV_cm3 + NI_cm3;
        case 'weighted_sum'
            Neff_cm3 = wV .* NV_cm3 + wI .* NI_cm3;
        otherwise
            error('Unknown effective defect model: %s', model);
    end
end
