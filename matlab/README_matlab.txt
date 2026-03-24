MATLAB module overview
======================

This folder contains an updated MATLAB-side implementation for the project:

    From Radiation-Induced Defects to Device Degradation in Silicon

The main change is that Module 2 has been upgraded from a simple phenomenological
fluence-to-defect law,

    N_D = k_D * Phi,

into a recoil-based primary defect model with these physics ingredients:

    recoil energy -> threshold displacement screening -> displacement probability
    -> defect multiplicity -> immediate survival -> vacancy/interstitial sources

The goal is still to keep the project compact and interview-friendly, but the
front-end defect model is now much more physically grounded.


Main scripts
------------

- main_defect_model.m
  Stand-alone Module 2 study.
  Generates plots of:
    * displacement probability vs recoil energy
    * defect multiplicity vs recoil energy
    * survival fraction vs recoil energy
    * Frenkel-pair yield vs recoil energy

- main_import_geant4_pipeline.m
  Imports Geant4 CSV outputs and uses the new recoil-based Module 2 model to
  build effective defect densities before propagating into the existing
  simplified lifetime / diffusion length / leakage / CCE chain.

- main_full_pipeline.m
  Full simplified pipeline with two modes:
    * legacy_fluence
    * module2_synthetic_recoil

  The default mode is the updated synthetic-recoil demonstration mode.


New Module 2 helper functions
-----------------------------

All new Module 2 functions live inside functions/:

- module2_default_params.m
  Central parameter struct for Module 2.

- threshold_displacement_energy.m
  Returns threshold displacement energy Ed for the chosen material and model.

- displacement_probability.m
  Computes probability that a recoil produces a displacement.

- defect_multiplicity_from_recoil.m
  Maps recoil energy into number of defect units created.

- survival_fraction_primary_defects.m
  Applies prompt survival / recombination correction.

- frenkel_pair_yield.m
  Combines threshold, probability, multiplicity, and survival into a total
  surviving defect yield per recoil.

- defect_sources_from_recoil_list.m
  Main Module 2 engine for converting a recoil-event table into total and
  optional depth-dependent vacancy/interstitial source terms.

- effective_defect_density_from_sources.m
  Maps vacancy/interstitial densities into one effective defect density that
  can be consumed by the existing downstream simplified models.


Existing downstream helper functions retained
---------------------------------------------

These functions are assumed to remain in your original repo and are not
rewritten here:

- functions/defect_density_from_fluence.m
  Legacy baseline model.

- functions/lifetime_from_defects.m
- functions/diffusion_length_from_lifetime.m
- functions/leakage_current_from_fluence.m
- functions/charge_collection_model.m

- functions/read_geant4_event_summary.m
- functions/read_geant4_depth_edep.m
- functions/read_geant4_recoil_candidates.m
- functions/estimate_fluence_from_events.m
- functions/defect_density_from_depth_edep.m
  Legacy depth proxy model.


Recommended starting points
---------------------------

1) Stand-alone Module 2 physics check
   Run from inside matlab/:

       main_defect_model

   This is the best first check that the new recoil-threshold-survival physics
   is behaving as expected.

2) Geant4 import workflow
   Make sure these files exist in ../geant4/output/:

       event_summary.csv
       depth_edep.csv
       recoil_candidates.csv

   Then run:

       main_import_geant4_pipeline

   Output CSV files and figures will be written into matlab/output/.

3) Full simplified pipeline demonstration
   Run:

       main_full_pipeline

   and choose the desired mode at the top of the script.


Expected recoil table columns
-----------------------------

The new Module 2 bridge expects recoil_candidates.csv to provide at least:

- kinetic_energy_eV

Optional columns for depth profiles:

- z_um

If your Geant4 recoil table uses a different column name, update the column-name
fields in module2_default_params.m.


Current modeling status
-----------------------

This updated Module 2 includes:

- threshold displacement physics
- recoil-energy dependence
- simple multiplicity laws
- immediate survival correction
- vacancy/interstitial accounting
- effective defect mapping for downstream models

This updated Module 2 does NOT yet include:

- full atomistic cascade simulation
- explicit defect-species chemistry
- time-dependent vacancy/interstitial recombination kinetics
- fully calibrated material-specific parameters from MD or DFT
- leakage-current model tied directly to vacancy/interstitial populations

So this remains a compact multistage physics model, not a replacement for MD,
TCAD, or a validated displacement-damage chemistry code.


Recommended integration order into the repo
-------------------------------------------

1) Add the new functions into matlab/functions/
2) Replace main_defect_model.m with the stand-alone Module 2 version
3) Replace main_import_geant4_pipeline.m with the new recoil-based version
4) Update main_full_pipeline.m
5) Keep the old fluence-only and deposited-energy-only functions as baseline
   comparison models, not as the main Module 2 path

