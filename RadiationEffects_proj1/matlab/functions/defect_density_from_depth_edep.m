function N_D_z = defect_density_from_depth_edep(edep_eV, k_depth)
%DEFECT_DENSITY_FROM_DEPTH_EDEP Convert depth-binned deposited energy into
% a simple defect-density proxy.
%
% This is intentionally phenomenological:
%   N_D(z) = k_depth * edep(z)
%
% where k_depth is a user-chosen scaling constant.

arguments
    edep_eV (:,1) double
    k_depth (1,1) double {mustBeNonnegative}
end

N_D_z = k_depth .* edep_eV;
end
