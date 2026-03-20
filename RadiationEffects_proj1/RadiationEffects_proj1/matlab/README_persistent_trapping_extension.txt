Persistent trapping extension

Purpose:
This extension connects the cryogenic defect-kinetics section to one concrete
and presentation-friendly device consequence: persistent trapped charge and
slower recovery at low temperature.

Main script:
- main_persistent_trapping_extension.m

Helper functions:
- recovery_time_constant_vs_temperature.m
- trapped_charge_recovery.m

Model summary:
A simple exponential recovery law is used,

    Q_trap(t,T) = Q0 * exp(-t / tau_rec(T))

where the recovery time constant follows an Arrhenius form,

    tau_rec(T) = tau0 * exp(Ea / (kB*T))

The script generates:
- persistent_trapping_recovery_emission.png
- persistent_trapping_recovery_annealing.png
- recovery_time_constant_vs_temperature.png
- time_to_50pct_recovery_vs_temperature.png
- persistent_trapping_summary.csv

Interpretation:
As temperature decreases, recovery time constants grow rapidly. This means that
trapped charge and radiation history can persist for much longer operational
times in the cryogenic regime.
