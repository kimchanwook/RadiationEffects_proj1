function Pdisp = displacement_probability(Trecoil_eV, Ed_eV, varargin)
%DISPLACEMENT_PROBABILITY Probability that a recoil causes displacement.
%
%   Pdisp = displacement_probability(Trecoil_eV, Ed_eV)
%
%   Name-value pairs:
%       'Model'         : 'hard_threshold' or 'sigmoid'
%       'Broadening_eV' : width parameter for sigmoid
%       'Temperature_K' : reserved for future refinement
%       'Clamp'         : true/false
%
%   Supports scalar or vector inputs.

    ip = inputParser;
    ip.addRequired('Trecoil_eV', @isnumeric);
    ip.addRequired('Ed_eV', @isnumeric);
    ip.addParameter('Model', 'sigmoid', @(x) ischar(x) || isstring(x));
    ip.addParameter('Broadening_eV', 3.0, @(x) isnumeric(x) && isscalar(x) && x > 0);
    ip.addParameter('Temperature_K', [], @(x) isempty(x) || (isscalar(x) && x > 0));
    ip.addParameter('Clamp', true, @(x) islogical(x) && isscalar(x));
    ip.parse(Trecoil_eV, Ed_eV, varargin{:});

    model = lower(char(ip.Results.Model));
    delta = ip.Results.Broadening_eV;
    clampOut = ip.Results.Clamp;

    T = Trecoil_eV;
    Ed = Ed_eV;

    switch model
        case 'hard_threshold'
            Pdisp = double(T >= Ed);

        case 'sigmoid'
            Pdisp = 1 ./ (1 + exp(-(T - Ed) ./ delta));

        otherwise
            error('Unknown displacement probability model: %s', model);
    end

    if clampOut
        Pdisp = max(0, min(1, Pdisp));
    end
end
