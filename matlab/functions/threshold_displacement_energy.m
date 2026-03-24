function Ed_eV = threshold_displacement_energy(material, varargin)
%THRESHOLD_DISPLACEMENT_ENERGY Return threshold displacement energy Ed.
%
%   Ed_eV = threshold_displacement_energy(material)
%   Ed_eV = threshold_displacement_energy(material, 'Direction', [1 0 0], ...)
%
%   Name-value pairs:
%       'Direction'     : [nx ny nz] recoil direction
%       'Temperature_K' : lattice temperature
%       'Model'         : 'constant', 'directional', 'effective_temp'
%       'Params'        : parameter struct from module2_default_params
%
%   Notes:
%   - This is a first-pass parameter model, not an atomistic calculation.
%   - Directional mapping is simplified to common cubic directions.

    ip = inputParser;
    ip.addRequired('material', @(x) ischar(x) || isstring(x));
    ip.addParameter('Direction', [], @(x) isnumeric(x) && numel(x) == 3);
    ip.addParameter('Temperature_K', [], @(x) isempty(x) || (isscalar(x) && x > 0));
    ip.addParameter('Model', '', @(x) ischar(x) || isstring(x));
    ip.addParameter('Params', struct(), @isstruct);
    ip.parse(material, varargin{:});

    direction = ip.Results.Direction;
    temperatureK = ip.Results.Temperature_K;
    pIn = ip.Results.Params;
    model = char(ip.Results.Model);

    p = module2_default_params(material);
    p = merge_structs_local(p, pIn);

    if isempty(model)
        model = p.Ed_model;
    end
    if isempty(temperatureK)
        temperatureK = p.Temperature_K;
    end

    switch lower(model)
        case 'constant'
            Ed_eV = p.Ed_const_eV;

        case 'directional'
            if isempty(direction)
                Ed_eV = p.Ed_const_eV;
                return;
            end
            Ed_eV = directional_ed_local(direction, p);

        case 'effective_temp'
            % Very simple first-pass temperature adjustment.
            Ed0 = p.Ed_const_eV;
            alpha = 1.0e-3; % fractional change per K around 300 K
            Ed_eV = Ed0 * (1 - alpha * (temperatureK - 300));
            Ed_eV = max(0.5 * Ed0, Ed_eV);

        otherwise
            error('Unknown Ed model: %s', model);
    end
end

function Ed = directional_ed_local(direction, p)
    d = direction(:) / norm(direction);
    refs = [1 0 0; 1 1 0; 1 1 1];
    refs = refs ./ vecnorm(refs, 2, 2);

    dots = abs(refs * d);
    [~, idx] = max(dots);

    switch idx
        case 1
            Ed = p.Ed_directional_map.d100;
        case 2
            Ed = p.Ed_directional_map.d110;
        case 3
            Ed = p.Ed_directional_map.d111;
        otherwise
            Ed = p.Ed_const_eV;
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
