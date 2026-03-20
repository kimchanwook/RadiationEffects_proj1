function T = read_geant4_event_summary(filepath)
%READ_GEANT4_EVENT_SUMMARY Read Geant4 event-level deposited energy CSV.
%
% Expected columns:
%   event_id, total_edep_eV

arguments
    filepath (1,:) char
end

if ~isfile(filepath)
    error('File not found: %s', filepath);
end

opts = detectImportOptions(filepath);
opts = setvartype(opts, {'event_id','total_edep_eV'}, {'double','double'});
T = readtable(filepath, opts);

required = {'event_id','total_edep_eV'};
assert(all(ismember(required, T.Properties.VariableNames)), ...
    'Event summary file must contain columns: %s', strjoin(required, ', '));
end
