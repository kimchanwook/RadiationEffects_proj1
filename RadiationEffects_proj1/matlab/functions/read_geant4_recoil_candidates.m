function T = read_geant4_recoil_candidates(filepath)
%READ_GEANT4_RECOIL_CANDIDATES Read Geant4 recoil-candidate CSV.
%
% Expected columns:
%   event_id, z_um, particle_name, kinetic_energy_eV

arguments
    filepath (1,:) char
end

if ~isfile(filepath)
    error('File not found: %s', filepath);
end

opts = detectImportOptions(filepath, 'TextType', 'string');
opts = setvartype(opts, {'event_id','z_um','kinetic_energy_eV'}, {'double','double','double'});
opts = setvartype(opts, 'particle_name', 'string');
T = readtable(filepath, opts);

required = {'event_id','z_um','particle_name','kinetic_energy_eV'};
assert(all(ismember(required, T.Properties.VariableNames)), ...
    'Recoil candidate file must contain columns: %s', strjoin(required, ', '));
end
