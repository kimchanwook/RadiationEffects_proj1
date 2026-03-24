MATLAB module overview
======================

This folder contains the MATLAB side of the project:
From Radiation-Induced Defects to Device Degradation in Silicon.

The MATLAB implementation now has two front-end modeling paths:

1. Legacy simplified path
   fluence -> defect density -> lifetime degradation -> diffusion length loss
   -> leakage current increase -> charge collection degradation

2. Updated Module 2 path
   recoil events -> threshold displacement screening -> primary defect yield
   -> surviving vacancy/interstitial source terms -> effective defect density
   -> lifetime degradation -> diffusion length loss -> charge collection degradation

The new default scientific direction is the recoil-based Module 2 path.
The older fluence/proxy functions are retained as simplified baseline models
for comparison, debugging, and continuity.

--------------------------------------------------
Main scripts
--------------------------------------------------

- main_defect_model.m
  Stand-alone Module 2 physics demonstration.
  Intended to study recoil-threshold-survival behavior and visualize:
  - displacement probability
  - defect multiplicity
  - survival fraction
  - Frenkel-pair yield

- main_lifetime_model.m
  Downstream lifetime degradation model.

- main_diffusion_length_model.m
  Diffusion-length model driven by effective lifetime.

- main_leakage_model.m
  Simplified leakage-current model.
  Currently retained as a compact engineering model.

- main_full_pipeline.m
  End-to-end MATLAB demonstration.
  At present, this should be viewed as a transitional full-chain script while
  the newer recoil-based Module 2 is being integrated more deeply into all
  downstream observables.

- main_import_geant4_pipeline.m
  Geant4-to-MATLAB import workflow.
  This is the main entry point for using Geant4 recoil outputs inside the
  recoil-based Module 2 physics chain.

--------------------------------------------------
Core helper functions for the updated Module 2 path
--------------------------------------------------

Primary-defect formation / recoil-physics helpers:

- functions/module2_default_params.m
- functions/threshold_displacement_energy.m
- functions/displacement_probability.m
- functions/defect_multiplicity_from_recoil.m
- functions/survival_fraction_primary_defects.m
- functions/frenkel_pair_yield.m
- functions/defect_sources_from_recoil_list.m
- functions/effective_defect_density_from_sources.m

These functions implement a first-pass physically improved Module 2 based on:

- recoil energy
- threshold displacement energy
- displacement probability
- defect multiplicity
- immediate defect survival
- surviving vacancy/interstitial source estimation

This path is intended to replace the old purely phenomenological
N_D = k * Phi style front-end as the main Module 2 model.

--------------------------------------------------
Downstream degradation helpers
--------------------------------------------------

- functions/lifetime_from_defects.m
- functions/diffusion_length_from_lifetime.m
- functions/charge_collection_model.m

These remain the main downstream bridge from effective defect density to
device-level degradation observables.

--------------------------------------------------
Geant4 import helpers
--------------------------------------------------

- functions/read_geant4_event_summary.m
- functions/read_geant4_depth_edep.m
- functions/read_geant4_recoil_candidates.m

Among these, recoil_candidates is the most important input for the updated
Module 2 path.

The depth-dependent deposited-energy import can still be useful as a
diagnostic quantity, but it is no longer the preferred primary bridge from
Geant4 output to defect creation physics.

--------------------------------------------------
Legacy / simplified helper functions
--------------------------------------------------

The following functions are retained as simplified baseline models:

- functions/legacy/defect_density_from_fluence.m
- functions/legacy/defect_density_from_depth_edep.m
- functions/legacy/estimate_fluence_from_events.m
- functions/legacy/leakage_current_from_fluence.m

These should be interpreted as legacy or compact engineering approximations,
not as the main physically preferred Module 2 path.

They are still useful for:
- sanity checks
- quick comparisons
- debugging
- reproducing earlier simplified results

--------------------------------------------------
Recommended starting points
--------------------------------------------------

If you want to study the new Module 2 physics directly:
- run main_defect_model.m

If you want to use Geant4-generated recoil outputs:
- run main_import_geant4_pipeline.m

If you want a compact end-to-end MATLAB demonstration:
- run main_full_pipeline.m

All scripts should be run from inside the matlab/ folder unless adjusted.

--------------------------------------------------
How to use the Geant4 import pipeline
--------------------------------------------------

1. Build and run the Geant4 case so that these files exist in ../geant4/output/:
   - event_summary.csv
   - depth_edep.csv
   - recoil_candidates.csv

2. From inside matlab/, run:
   main_import_geant4_pipeline

3. MATLAB will generate summary CSV files and figures inside matlab/output/

--------------------------------------------------
Important modeling note
--------------------------------------------------

The current recoil-based Module 2 is a first-pass physics upgrade.
It is more physically grounded than the older fluence-only or deposited-energy
proxy model, but it is still not a full atomistic cascade or defect-chemistry solver.

What it includes:
- recoil-based screening
- threshold displacement physics
- simple defect multiplicity
- immediate survival correction
- vacancy/interstitial source estimation

What it does not yet include in full detail:
- fully resolved cascade transport
- full defect-species chemistry
- time-dependent vacancy/interstitial reaction kinetics
- MD/DFT-calibrated material-specific defect libraries
- complete leakage-current reformulation from defect populations

So this MATLAB framework should currently be viewed as:
a compact multistage bridge from recoil information to simplified
device-degradation observables, with the newer Module 2 now centered on
primary defect formation physics rather than a purely phenomenological
defect-density law.

--------------------------------------------------
Extension modules
--------------------------------------------------

Separate extension files are also included for additional temperature/trapping
studies:

- README_cryogenic_extension.txt
- README_persistent_trapping_extension.txt
- main_cryogenic_extension.m
- main_persistent_trapping_extension.m

Related helper functions for those extensions remain in functions/.