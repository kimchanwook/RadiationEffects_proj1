function [Y, details] = frenkel_pair_yield(Trecoil_eV, material, varargin)
%FRENKEL_PAIR_YIELD Surviving defect yield per recoil.
%
%   [Y, details] = frenkel_pair_yield(Trecoil_eV, material, ...)
%
%   Governing form:
%       Y = nu(T) .* Pdisp(T) .* S(T)
%
%   details contains:
%       Ed_eV, Pdisp, nu, S

    ip = inputParser;
    ip.addRequired('Trecoil_eV', @isnumeric);
    ip.addRequired('material', @(x) ischar(x) || isstring(x));
    ip.addParameter('Direction', [], @(x) isempty(x) || (isnumeric(x) && numel(x) == 3));
    ip.addParameter('Temperature_K', [], @(x) isempty(x) || (isscalar(x) && x > 0));
    ip.addParameter('ThresholdModel', '', @(x) ischar(x) || isstring(x));
    ip.addParameter('DispModel', '', @(x) ischar(x) || isstring(x));
    ip.addParameter('MultiplicityModel', '', @(x) ischar(x) || isstring(x));
    ip.addParameter('SurvivalModel', '', @(x) ischar(x) || isstring(x));
    ip.addParameter('Params', struct(), @isstruct);
    ip.parse(Trecoil_eV, material, varargin{:});

    direction = ip.Results.Direction;
    temperatureK = ip.Results.Temperature_K;
    pIn = ip.Results.Params;

    p = module2_default_params(material);
    p = merge_structs_local(p, pIn);

    if isempty(temperatureK)
        temperatureK = p.Temperature_K;
    end

    thresholdModel = char_or_default(ip.Results.ThresholdModel, p.Ed_model);
    dispModel = char_or_default(ip.Results.DispModel, p.disp_model);
    multModel = char_or_default(ip.Results.MultiplicityModel, p.multiplicity_model);
    survivalModel = char_or_default(ip.Results.SurvivalModel, p.survival_model);

    Ed_eV = threshold_displacement_energy(material, ...
        'Direction', direction, ...
        'Temperature_K', temperatureK, ...
        'Model', thresholdModel, ...
        'Params', p);

    Pdisp = displacement_probability(Trecoil_eV, Ed_eV, ...
        'Model', dispModel, ...
        'Broadening_eV', p.broadening_eV, ...
        'Temperature_K', temperatureK);

    nu = defect_multiplicity_from_recoil(Trecoil_eV, Ed_eV, ...
        'Model', multModel, ...
        'CascadeThreshold_eV', p.cascade_threshold_eV, ...
        'MultiplicityScale', p.multiplicity_scale, ...
        'MaxMultiplicity', p.max_multiplicity);

    S = survival_fraction_primary_defects(Trecoil_eV, ...
        'Temperature_K', temperatureK, ...
        'Model', survivalModel, ...
        'BaseSurvival', p.base_survival, ...
        'Params', p);

    Y = nu .* Pdisp .* S;

    if nargout > 1
        details = struct();
        details.Ed_eV = Ed_eV;
        details.Pdisp = Pdisp;
        details.nu = nu;
        details.S = S;
    end
end

function out = char_or_default(val, defaultVal)
    if isempty(val)
        out = defaultVal;
    else
        out = char(val);
    end
end

function s = merge_structs_local(a, b)
    s = a;
    if isempty(b)
        return;
    end
    fn = fieldnames(b);
    for k = 1:numel(fn)
        s.(fn{k}) = b.(fn{k});
    end
end
