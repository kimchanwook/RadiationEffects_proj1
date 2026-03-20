Geant4 Silicon Damage Starter
=============================

This Geant4 folder now writes three CSV outputs into geant4/output/:

1. event_summary.csv
   - event_id
   - total_edep_eV

2. depth_edep.csv
   - z_center_um
   - edep_eV
   Depth-binned energy deposition through the 300 um silicon slab.

3. recoil_candidates.csv
   - event_id
   - z_um
   - particle_name
   - kinetic_energy_eV
   These are ion secondaries created inside the silicon slab and are meant as
   recoil-like candidates, not a final displacement-damage metric.

Notes:
- The current implementation assumes the silicon slab spans z = -150 um to +150 um.
- The recoil CSV is a first-pass proxy for displacement-relevant events.
- This skeleton is intended for single-thread use. If you later enable MT mode,
  the CSV writing should be migrated to a thread-safe analysis workflow.

Suggested next upgrade:
- add explicit process-name tagging
- add NIEL-like damage-energy scoring
- write a MATLAB reader that imports the CSV files and overlays them with the
  defect/lifetime model
