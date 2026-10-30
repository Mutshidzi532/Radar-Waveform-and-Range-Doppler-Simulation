# Radar-Waveform-and-Range-Doppler-Simulation

<p align="center">
  <strong>MATLAB | Radar Signal Processing | Mathematical Modelling | Target Detection</strong>
</p>

1. Project Overview

This project explores radar waveform generation and signal processing using MATLAB. It demonstrates the generation of Linear Frequency Modulated (LFM) chirps, simulated target echoes, matched-filter pulse compression, range estimation, Doppler processing and range-Doppler visualisation.

The project also incorporates multiple-target simulation and a conceptual radar system architecture to illustrate the relationship between radar transmission, target interaction, signal reception and digital signal processing.

The objective is to apply mathematical modelling and computational techniques to simplified radar scenarios while developing an understanding of radar engineering principles.

2. Project Objectives

* Generate Linear Frequency Modulated radar waveforms.
* Examine waveform bandwidth and theoretical range resolution.
* Simulate delayed radar target echoes.
* Apply matched filtering and pulse compression.
* Explore target range estimation.
* Analyse Doppler frequency and radial velocity.
* Generate simplified range-Doppler visualisations.
* Simulate multiple targets with different ranges and velocities.
* Illustrate a conceptual radar system architecture.

3. Technologies and Tools

Technology	Application
MATLAB	Simulation and numerical computation
MATLAB FFT	Frequency and Doppler analysis
Complex-valued signals	Radar waveform representation
Mathematical modelling	Range and Doppler relationships
MATLAB plotting	Signal and performance visualisation
CSV	Simulation data and results export

4. Simulation Parameters

Parameter	Value
Signal bandwidth	20 MHz
Pulse duration	20 μs
Sampling frequency	100 MHz
Doppler carrier frequency	10 GHz
Single-target range	1,500 m
Multiple-target ranges	1,500 m and 2,400 m
Multiple-target velocities	+30 m/s and −20 m/s

These values are simulation inputs and not measurements from physical radar equipment.

5. Radar Waveform Generation

5.1 LFM Chirp Waveform

The first stage generates a Linear Frequency Modulated chirp. Its instantaneous frequency changes linearly throughout the pulse duration.

5.2 Instantaneous Frequency Sweep

The frequency sweep illustrates how the transmitted signal moves across its designated bandwidth during the pulse.

6. Target Echo Simulation and Pulse Compression

6.1 Simulated Target Echo

A delayed version of the transmitted waveform is used to represent a returning signal from a simulated target.

6.2 Matched Filter and Pulse Compression

Matched filtering is applied to the received signal to demonstrate pulse compression and the formation of a stronger response around the target delay.

The theoretical range resolution is related to signal bandwidth:

[
\Delta R = \frac{c}{2B}
]

For a bandwidth of 20 MHz, the theoretical range resolution is approximately 7.5 metres.

7. Target Range Estimation

The range profile illustrates the matched-filter response across different target distances.

The relationship between round-trip propagation delay and target range is:

[
R = \frac{c\tau}{2}
]

Where:

* (R) represents target range.
* (c) represents the speed of light.
* (\tau) represents round-trip propagation delay.

8. Doppler Processing

Doppler processing explores how a target’s radial movement produces a frequency shift in the received radar signal.

For a simplified monostatic radar:

[
f_d = \frac{2vf_c}{c}
]

Where:

* (f_d) is Doppler frequency.
* (v) is radial target velocity.
* (f_c) is carrier frequency.
* (c) is the speed of light.

The simulation uses a 10 GHz carrier frequency and a 30 m/s target velocity as an illustrative scenario.

9. Range-Doppler Processing

9.1 Range-Doppler Map

Range-Doppler processing combines range compression and Doppler analysis to produce a two-dimensional visualisation of radar signal responses.

The visualisation provides a conceptual representation of how radar processing can examine target responses across range and radial velocity.

9.2 Multiple-Target Simulation

The project extends the simulation to two targets with different distances and radial velocities.

Target	Simulated Range	Simulated Velocity
Target 1	1,500 m	+30 m/s
Target 2	2,400 m	−20 m/s

The marked positions represent the predefined simulation inputs. They are not independently verified detection results.

10. Conceptual Radar System Architecture

The following block diagram illustrates the conceptual signal-processing chain, from waveform generation and transmission to reception and target analysis.

This is a conceptual engineering illustration and does not represent a physically constructed or tested radar system.

11. Project Structure

Radar_Waveform_Range_Doppler/
│
├── figures/
│   ├── lfm_chirp_waveform.png
│   ├── lfm_frequency_sweep.png
│   ├── simulated_target_echo.png
│   ├── radar_pulse_compression.png
│   ├── radar_target_range_profile.png
│   ├── radar_doppler_spectrum.png
│   ├── radar_range_doppler_map.png
│   └── multiple_target_range_doppler_map.png
│
├── results/
│   ├── lfm_waveform_data.csv
│   ├── pulse_compression_results.csv
│   ├── doppler_results.csv
│   └── multiple_target_parameters.csv
│
├── documentation/
│   ├── radar_system_architecture.png
│   └── radar_waveform_range_doppler_report.txt
│
└── radar_waveform_range_doppler.m

12. How to Run the Simulation

1. Install MATLAB.
2. Clone or download the repository.
3. Open MATLAB and navigate to the project directory.
4. Ensure the figures, results and documentation folders exist.
5. Open radar_waveform_range_doppler.m.
6. Execute the script.
7. Examine the generated figures and CSV files.

13. Limitations

This project is an educational simulation and does not represent a complete operational radar system.

Current limitations include:

* Simplified target echo modelling.
* Limited propagation and environmental modelling.
* No comprehensive clutter or multipath simulation.
* No physical RF transmitter or receiver implementation.
* No physical antenna-array construction or testing.
* No FPGA or embedded hardware implementation.
* Range and Doppler estimates require further numerical validation.

The range-Doppler visualisations should be interpreted as simplified simulation outputs rather than verified radar detection or tracking performance.

14. Future Development

Potential improvements include:

* Refining delayed-echo generation and range-axis calibration.
* Validating range and velocity estimates against known target parameters.
* Introducing receiver noise and clutter.
* Investigating detection thresholds and probability of detection.
* Exploring different radar waveform parameters.
* Developing more realistic target and propagation models.
* Extending the simulation towards more advanced radar signal-processing techniques.

15. Engineering Skills Demonstrated

* MATLAB programming and simulation.
* Mathematical modelling.
* Complex-valued signal generation.
* Digital signal processing fundamentals.
* Fast Fourier Transform analysis.
* Matched filtering and pulse compression.
* Radar range and Doppler relationships.
* Multiple-target simulation.
* Numerical analysis and technical documentation.
* Engineering system visualisation.

16. Conclusion

This project demonstrates an initial exploration of radar waveform generation and signal processing through MATLAB-based mathematical modelling.

It combines waveform generation, simulated target responses, matched filtering, Doppler analysis and range-Doppler visualisation to explore fundamental radar engineering concepts.

The project reflects an interest in applying mathematics and computational techniques to engineering challenges, particularly in radar systems and signal processing.

⸻

Author: Mutshidzi Madavha
GitHub: Mutshidzi532
Project: Radar Waveform and Range-Doppler Simulation
