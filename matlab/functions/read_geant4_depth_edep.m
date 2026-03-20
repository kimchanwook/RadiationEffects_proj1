function T = read_geant4_depth_edep(filepath)
%READ_GEANT4_DEPTH_EDEP Read Geant4 depth-binned energy deposition CSV.
%
% Expected columns:
%   z_center_um, edep_eV

arguments
    filepath (1,:) char
end

if ~isfile(filepath)
    error('File not found: %s', filepath);
end

opts = detectImportOptions(filepath);
opts = setvartype(opts, {'z_center_um','edep_eV'}, {'double','double'});
T = readtable(filepath, opts);

required = {'z_center_um','edep_eV'};
assert(all(ismember(required, T.Properties.VariableNames)), ...
    'Depth deposition file must contain columns: %s', strjoin(required, ', '));
end
