function defectOut = defect_sources_from_recoil_list(Trecoil, varargin)
%DEFECT_SOURCES_FROM_RECOIL_LIST Convert recoil table into defect source terms.
%
%   defectOut = defect_sources_from_recoil_list(Trecoil, ...)
%
%   Required input:
%       Trecoil : MATLAB table containing at least a recoil-energy column
%
%   Name-value pairs:
%       'Material'               : material string, default 'Si'
%       'Temperature_K'          : lattice temperature
%       'DepthBinning'           : vector of z-bin edges in um
%       'UseDepth'               : true/false
%       'NormalizeByVolume_cm3'  : scalar volume for bulk concentration
%       'ReturnProfiles'         : true/false
%       'Params'                 : module parameter struct
%
%   Expected default energy column:
%       kinetic_energy_eV

    ip = inputParser;
    ip.addRequired('Trecoil', @istable);
    ip.addParameter('Material', 'Si', @(x) ischar(x) || isstring(x));
    ip.addParameter('Temperature_K', [], @(x) isempty(x) || (isscalar(x) && x > 0));
    ip.addParameter('DepthBinning', [], @isnumeric);
    ip.addParameter('UseDepth', false, @(x) islogical(x) && isscalar(x));
    ip.addParameter('NormalizeByVolume_cm3', [], @(x) isempty(x) || (isscalar(x) && x > 0));
    ip.addParameter('ReturnProfiles', false, @(x) islogical(x) && isscalar(x));
    ip.addParameter('Params', struct(), @isstruct);
    ip.parse(Trecoil, varargin{:});

    material = char(ip.Results.Material);
    pIn = ip.Results.Params;

    p = module2_default_params(material);
    p = merge_structs_local(p, pIn);

    if ~isempty(ip.Results.Temperature_K)
        p.Temperature_K = ip.Results.Temperature_K;
    end
    if ~isempty(ip.Results.NormalizeByVolume_cm3)
        p.normalize_by_volume_cm3 = ip.Results.NormalizeByVolume_cm3;
    end
    if ~isempty(ip.Results.DepthBinning)
        p.depth_edges_um = ip.Results.DepthBinning;
    end
    p.return_profiles = ip.Results.ReturnProfiles;

    if ~ismember(p.col_energy_eV, Trecoil.Properties.VariableNames)
        error('Trecoil must contain column "%s".', p.col_energy_eV);
    end

    T = double(Trecoil.(p.col_energy_eV)(:));
    [Y, details] = frenkel_pair_yield(T, material, ...
        'Temperature_K', p.Temperature_K, ...
        'ThresholdModel', p.Ed_model, ...
        'DispModel', p.disp_model, ...
        'MultiplicityModel', p.multiplicity_model, ...
        'SurvivalModel', p.survival_model, ...
        'Params', p);

    % Each surviving Frenkel-pair unit contributes one vacancy and one interstitial.
    NV_count = sum(Y);
    NI_count = sum(Y);

    if isempty(p.normalize_by_volume_cm3)
        NV_total_cm3 = NV_count;
        NI_total_cm3 = NI_count;
    else
        NV_total_cm3 = NV_count ./ p.normalize_by_volume_cm3;
        NI_total_cm3 = NI_count ./ p.normalize_by_volume_cm3;
    end

    defectOut = struct();
    defectOut.recoilCount = numel(T);
    defectOut.Y_per_recoil = Y;
    defectOut.Ed_eV = details.Ed_eV;
    defectOut.Pdisp = details.Pdisp;
    defectOut.nu = details.nu;
    defectOut.S = details.S;
    defectOut.NV_total_cm3 = NV_total_cm3;
    defectOut.NI_total_cm3 = NI_total_cm3;
    defectOut.Ndefect_total_cm3 = NV_total_cm3 + NI_total_cm3;
    defectOut.meanYieldPerRecoil = mean(Y);
    defectOut.meanDisplacementProbability = mean(details.Pdisp);
    defectOut.meanSurvivalFraction = mean(details.S);

    useDepth = ip.Results.UseDepth || ip.Results.ReturnProfiles;
    if useDepth && ismember(p.col_z_um, Trecoil.Properties.VariableNames) && ~isempty(p.depth_edges_um)
        z_um = double(Trecoil.(p.col_z_um)(:));
        zEdges = p.depth_edges_um(:);
        nb = numel(zEdges) - 1;

        NV_depth = zeros(nb, 1);
        NI_depth = zeros(nb, 1);
        z_center = 0.5 * (zEdges(1:end-1) + zEdges(2:end));

        binIdx = discretize(z_um, zEdges);
        for k = 1:nb
            mask = (binIdx == k);
            NV_depth(k) = sum(Y(mask));
            NI_depth(k) = sum(Y(mask));
        end

        if ~isempty(p.normalize_by_volume_cm3)
            % Placeholder normalization. Replace with per-bin volume if known.
            NV_depth = NV_depth ./ p.normalize_by_volume_cm3;
            NI_depth = NI_depth ./ p.normalize_by_volume_cm3;
        end

        defectOut.z_um = z_center;
        defectOut.NV_depth_cm3 = NV_depth;
        defectOut.NI_depth_cm3 = NI_depth;
        defectOut.Ndefect_depth_cm3 = NV_depth + NI_depth;
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
