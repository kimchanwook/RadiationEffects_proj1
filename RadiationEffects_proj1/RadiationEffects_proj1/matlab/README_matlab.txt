MATLAB module overview
======================

This folder contains the MATLAB side of the project:
From Radiation-Induced Defects to Device Degradation in Silicon.

Main scripts:
- main_defect_model.m
- main_lifetime_model.m
- main_diffusion_length_model.m
- main_leakage_model.m
- main_full_pipeline.m

Helper functions:
- functions/defect_density_from_fluence.m
- functions/lifetime_from_defects.m
- functions/diffusion_length_from_lifetime.m
- functions/leakage_current_from_fluence.m
- functions/charge_collection_model.m

Recommended starting point:
Run main_full_pipeline.m from inside the matlab/ folder.
It will generate figures and a CSV file inside matlab/output/.

Physics chain implemented:
fluence -> defect density -> lifetime degradation -> diffusion length loss
-> leakage current increase -> charge collection degradation


Additional Geant4 import workflow:
- main_import_geant4_pipeline.m

Additional helper functions:
- functions/read_geant4_event_summary.m
- functions/read_geant4_depth_edep.m
- functions/read_geant4_recoil_candidates.m
- functions/estimate_fluence_from_events.m
- functions/defect_density_from_depth_edep.m

How to use the Geant4 import pipeline:
1. Build and run the Geant4 case so that these files exist in ../geant4/output/:
   - event_summary.csv
   - depth_edep.csv
   - recoil_candidates.csv
2. From inside matlab/, run:
   main_import_geant4_pipeline
3. MATLAB will generate imported-run summary CSV files and PNG figures inside matlab/output/.

Important note:
The Geant4-to-defect conversion is intentionally phenomenological.
The imported depth-dependent deposited energy is used as a qualitative damage proxy,
not as a rigorously calibrated displacement-damage or defect-chemistry model.
