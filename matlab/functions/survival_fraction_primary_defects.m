function S = survival_fraction_primary_defects(Trecoil_eV, varargin)
%SURVIVAL_FRACTION_PRIMARY_DEFECTS Immediate survival fraction after creation.
%
%   S = survival_fraction_primary_defects(Trecoil_eV, ...)
%
%   Name-value pairs:
%       'Temperature_K' : lattice temperature
%       'Model'         : 'constant', 'energy_dependent', 'temp_dependent'
%       'BaseSurvival'  : baseline survival fraction
%       'Params'        : optional struct

    ip = inputParser;
    ip.addRequired('Trecoil_eV', @isnumeric);
    ip.addParameter('Temperature_K', 300, @(x) isnumeric(x) && isscalar(x) && x > 0);
    ip.addParameter('Model', 'constant', @(x) ischar(x) || isstring(x));
    ip.addParameter('BaseSurvival', 0.35, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
    ip.addParameter('Params', struct(), @isstruct);
    ip.parse(Trecoil_eV, varargin{:});

    T = Trecoil_eV;
    temperatureK = ip.Results.Temperature_K;
    model = lower(char(ip.Results.Model));
    S0 = ip.Results.BaseSurvival;

    switch model
        case 'constant'
            S = S0 .* ones(size(T));

        case 'energy_dependent'
            % Mild increase with recoil energy, saturating at 0.9.
            Tscale = 100;
            S = S0 + (0.9 - S0) .* (1 - exp(-T ./ Tscale));

        case 'temp_dependent'
            % Mild decrease with temperature as proxy for prompt recombination.
            beta = 5e-4;
            S = S0 .* exp(-beta .* (temperatureK - 300));
            S = S .* ones(size(T));

        otherwise
            error('Unknown survival model: %s', model);
    end

    S = max(0, min(1, S));
end
