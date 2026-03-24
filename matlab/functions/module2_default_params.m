function p = module2_default_params(material)
%MODULE2_DEFAULT_PARAMS Default parameter set for Module 2 primary defect physics.
%
%   p = module2_default_params(material)
%
%   Returns a struct of default parameters for recoil-threshold-survival
%   based primary defect formation.
%
%   Example:
%       p = module2_default_params('Si');

    if nargin < 1 || isempty(material)
        material = 'Si';
    end

    p = struct();
    p.material = char(material);

    % Environmental / lattice settings
    p.Temperature_K = 300;

    % Threshold displacement model
    p.Ed_model = 'constant';          % 'constant', 'directional', 'effective_temp'
    p.Ed_const_eV = 25;               % first-pass placeholder for Si
    p.Ed_directional_map = struct( ...
        'd100', 21, ...
        'd110', 25, ...
        'd111', 35);

    % Displacement probability model
    p.disp_model = 'sigmoid';         % 'hard_threshold' or 'sigmoid'
    p.broadening_eV = 3.0;            % threshold broadening

    % Multiplicity model
    p.multiplicity_model = 'single_pair'; % 'single_pair', 'piecewise', 'powerlaw'
    p.cascade_threshold_eV = 200;     % start allowing multiplicity > 1
    p.multiplicity_scale = 1.0;
    p.max_multiplicity = 50;

    % Survival model
    p.survival_model = 'constant';    % 'constant', 'energy_dependent', 'temp_dependent'
    p.base_survival = 0.35;

    % Effective defect mapping for downstream simplified models
    p.effective_model = 'weighted_sum';
    p.wV = 1.0;
    p.wI = 1.0;

    % Geometry / normalization defaults
    p.return_profiles = false;
    p.depth_edges_um = [];
    p.normalize_by_volume_cm3 = [];

    % Column name assumptions for recoil tables
    p.col_energy_eV = 'kinetic_energy_eV';
    p.col_z_um = 'z_um';
    p.col_x_um = 'x_um';
    p.col_y_um = 'y_um';
end
