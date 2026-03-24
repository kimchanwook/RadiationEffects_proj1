Geant4 Silicon Damage Starter
=============================

This Geant4 folder writes three CSV outputs into geant4/output/:

1. event_summary.csv
   - event_id
   - total_edep_eV

   Total energy deposited in the silicon slab for each event.

2. depth_edep.csv
   - z_center_um
   - edep_eV

   Depth-binned energy deposition through the 300 um silicon slab.

3. recoil_candidates.csv
   - event_id
   - track_id
   - parent_id
   - particle_name
   - kinetic_energy_eV
   - edep_eV
   - x_um
   - y_um
   - z_um
   - dir_x
   - dir_y
   - dir_z
   - volume_name
   - material_name
   - creator_process
   - global_time_ns

   These rows are recoil-like ion secondaries recorded once per qualifying
   track at the first relevant step inside SiliconSlab.

Selection rule for recoil_candidates.csv
----------------------------------------
A recoil row is written only if all of the following are true:
- the step is inside the SiliconSlab volume
- the candidate is a secondary track
- the candidate is an ion-like track (G4Ions)
- the track kinetic energy exceeds a small reporting threshold
- the track has not already been recorded earlier in the same event

This makes recoil_candidates.csv a cleaner handoff file for the MATLAB
Module 2 primary-defect model.

Interpretation notes
--------------------
- kinetic_energy_eV is the recoil-track kinetic energy at the first recorded step
- edep_eV is the parent-step local deposited energy at the recoil birth step;
  it is included as a diagnostic and is not a recoil-specific displacement metric
- x_um, y_um, z_um and dir_x, dir_y, dir_z support later spatial and directional
  defect modeling on the MATLAB side
- creator_process is useful for debugging and filtering recoil mechanisms

Current geometry assumptions
----------------------------
- the silicon slab spans z = -150 um to +150 um
- the target volume name is SiliconSlab
- the current implementation is intended for single-thread use

If you later enable multi-threading, migrate CSV writing to a thread-safe
analysis workflow.

Recommended use with MATLAB
---------------------------
The updated recoil_candidates.csv format is designed for the recoil-based
Module 2 MATLAB path:

recoil events -> threshold displacement screening -> primary defect yield
-> surviving vacancy/interstitial source terms

Suggested next upgrades
-----------------------
- record explicit target-lattice species or nuclear recoil metadata if practical
- add optional filtering by creator process class
- add crystal-orientation metadata if directional threshold physics is desired
- later consider a thread-safe Geant4 analysis manager workflow for MT mode
