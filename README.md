# Applied Acoustics Research Tools

## Repository Overview

This repository contains software developed for several applied-acoustics research and educational workflows. The projects are grouped by **measurement or analysis type** rather than by programming language.

The repository currently contains four main areas:

1. **SFAI** – automated swept-frequency measurements with the Bode 100 and subsequent resonance/peak analysis.
2. **SpectralAnalysis** – time-domain acoustic acquisition and time/frequency-domain analysis, originally developed for acoustic monitoring of the cold spray process.
3. **ThroughTransmission** – automated through-transmission ultrasonic waveform acquisition and cross-correlation analysis.
4. **WaveTutor** – an educational application for teaching wave-based nondestructive testing and ultrasonic concepts.

The folders are related in that several contain both an **acquisition stage** and a separate **analysis stage**. In general:

```text
Experimental Hardware
        |
        v
Automated Data Acquisition
        |
        v
Saved Experimental Data
        |
        v
MATLAB / Python Analysis
        |
        v
Processed Results and Interpretation
```

Not every folder is part of one single experimental pipeline. Each top-level project can be used independently.

---

# Repository Structure

```text
applied-acoustics/
│
├── SFAI/
│   ├── Bode_SFAI_Automation/
│   │   ├── BODE_AUTO_v9.vi
│   │   └── README.md
│   │
│   └── SFAI_Analysis/
│       ├── step1_column_seperator.ipynb
│       ├── step2_gaussian_convolution.ipynb
│       ├── step3_peaks_halfwidth.ipynb
│       └── README.md
│
├── SpectralAnalysis/
│   ├── LabVIEW_Audio_Projects/
│   │   ├── MicrophoneColdSpray_Complete_Descriptors_v10.vi
│   │   ├── FrequencyAtEachBin (SubVI).vi
│   │   ├── IfTruePassConcatenated (SubVI).vi
│   │   ├── MagnitudeFFT (SubVI).vi
│   │   ├── MeanOfArray (SubVI).vi
│   │   ├── Pa2dBSPL (SubVI).vi
│   │   ├── PositiveSpectralValues (SubVI).vi
│   │   ├── SpectralCentroid (SubVI).vi
│   │   ├── SpectralSpread (SubVI).vi
│   │   └── README.md
│   │
│   └── MATLAB_Analysis/
│       ├── Time2FreqDomainAnalysis.mlapp
│       └── README.md   
│
├── ThroughTransmission/
│   ├── LabVIEW_TT_Automation/
│   │   ├── MDO32_2-2-Channel_V2.vi
│   │   └── README.md
│   │
│   └── CrossCorrelationAnalysis/
│       ├── CrossCorrelationApp.mlapp
│       ├── cross_correlation.m
│       ├── crosscorr_parseV3.m
│       ├── file_number_cleaning.m
│       ├── isf_analysis_region_selection_V2.m
│       ├── isfread.m
│       ├── wfm3read.m
│       └── README.md  
│
└── WaveTutor/
    ├── app.py
    ├── app/
    ├── references/
    ├── outputs/
    ├── tests/
    ├── pyproject.toml
    ├── GEMINI.md
    └── README.md
```

Each project folder contains its own README with more detailed operating instructions, assumptions, and troubleshooting information.

---

# 1. SFAI

## Purpose

The `SFAI` folder contains tools for **Swept Frequency Acoustic Interferometry (SFAI)** measurements and analysis.

It is divided into:

```text
Bode_SFAI_Automation
        |
        v
Repeated Bode 100 measurements
        |
        v
Saved frequency / S21 data
        |
        v
SFAI_Analysis
        |
        v
Smoothing, interpolation, peak detection, and peak-width analysis
```

---

## `SFAI/Bode_SFAI_Automation`

### Main File

`BODE_AUTO_v9.vi`

### What It Does

This LabVIEW VI automates repeated measurements using a **Bode 100** analyzer.

Instead of requiring a user to manually start and save every sweep, the program:

- communicates with the Bode 100 over TCP/IP;
- configures the frequency sweep;
- repeatedly triggers S21 measurements;
- collects the returned sweep data;
- displays the current S21 response;
- tracks the number of completed measurements; and
- automatically saves the resulting data.

The program is particularly useful for **long-duration testing**.

### Output

The saved dataset contains:

- frequency values; and
- repeated S21 transmission sweeps collected over time.

The frequency values provide the common frequency axis for the repeated measurements.

See:

`SFAI/Bode_SFAI_Automation/README.md`

for detailed operating instructions.

---

## `SFAI/SFAI_Analysis`

This folder contains Jupyter notebooks for processing Bode/SFAI datasets.

The notebooks are intended to be run sequentially.

### Step 1

`step1_column_seperator.ipynb`

Separates a combined dataset containing one frequency axis and multiple magnitude measurements into individual frequency-magnitude files.

Conceptually:

```text
Frequency | Mag1 | Mag2 | Mag3 | ...
```

becomes:

```text
Frequency | Mag1
Frequency | Mag2
Frequency | Mag3
...
```

### Step 2

`step2_gaussian_convolution.ipynb`

Processes the individual frequency-magnitude files using:

- Gaussian smoothing;
- optional magnitude scaling;
- cubic-spline interpolation; and
- preliminary peak identification.

The interpolation creates a denser frequency grid for later peak analysis. It does **not** create additional experimental measurements.

### Step 3

`step3_peaks_halfwidth.ipynb`

Performs peak analysis within user-selected frequency regions.

The notebook identifies peaks and calculates peak widths using a half-height approach.

### Relationship to the Bode Automation

The automated Bode VI is the **data-acquisition tool**.

The SFAI notebooks are the **post-processing tools**.

However, the current notebook workflow was designed for a relatively small number of sweeps and can become slow when processing the large datasets generated by long-duration automated Bode testing.

Future development could integrate or automate the SFAI-processing workflow for larger datasets.

See:

`SFAI/SFAI_Analysis/README.md`

for the full processing procedure and data requirements.

---

# 2. Spectral Analysis

## Purpose

The `SpectralAnalysis` folder contains tools for examining the **frequency content of time-domain signals**.

The original research application was acoustic monitoring of the **cold spray manufacturing process**, where recorded microphone signals were being investigated to determine whether changes in their spectral content could potentially indicate process changes such as nozzle clogging.

These tools are not limited to cold spray. They can be used or adapted for other time-domain signals where frequency-domain or time-frequency analysis is useful.

The folder contains two complementary approaches:

```text
LabVIEW_Audio_Projects
        |
        |  Real-time / acquisition-side processing
        |
        +----------------------------+
                                     |
MATLAB_Analysis                      |
        |                            |
        |  Offline exploratory       |
        |  analysis of saved data    |
        +----------------------------+
```

They address similar signal-processing concepts but are not required to be used together.

---

## `SpectralAnalysis/LabVIEW_Audio_Projects`

### Main File

`MicrophoneColdSpray_Complete_Descriptors_v10.vi`

### What It Does

This LabVIEW program performs acoustic acquisition and live spectral processing.

It can use:

- real microphone data; or
- internally generated simulated signals.

The program includes:

- time-domain signal display;
- rolling signal buffering;
- FFT analysis;
- rolling Short-Time Fourier Transform (STFT);
- one-sided spectral processing;
- conversion to dB SPL;
- spectral centroid;
- spectral spread;
- baseline descriptor values; and
- data saving.

The current implementation includes only two spectral descriptors because the project is still exploratory. Additional work is needed to determine which descriptors are most useful for identifying meaningful changes in the cold spray process.

### Supporting SubVIs

The main VI uses several smaller LabVIEW SubVIs:

- `MagnitudeFFT (SubVI).vi` – calculates FFT magnitude.
- `PositiveSpectralValues (SubVI).vi` – extracts/scales the positive-frequency spectrum.
- `FrequencyAtEachBin (SubVI).vi` – generates the frequency value associated with each FFT bin.
- `Pa2dBSPL (SubVI).vi` – converts acoustic pressure values to dB SPL.
- `SpectralCentroid (SubVI).vi` – calculates spectral centroid.
- `SpectralSpread (SubVI).vi` – calculates spectral spread.
- `MeanOfArray (SubVI).vi` – calculates an array mean.
- `IfTruePassConcatenated (SubVI).vi` – conditionally accumulates array data.

See:

`SpectralAnalysis/LabVIEW_Audio_Projects/README.md`

for detailed operation and implementation notes.

---

## `SpectralAnalysis/MATLAB_Analysis`

### Main File

`Time2FreqDomainAnalysis.mlapp`

### What It Does

This MATLAB App Designer application provides a broader **offline spectral-analysis environment** for recorded time-domain signals.

It allows the user to investigate how analysis settings affect the resulting frequency-domain representation.

The application includes:

- time-domain visualization;
- STFT analysis;
- selectable window functions;
- configurable window length;
- configurable overlap;
- magnitude, power, and PSD representations;
- multiple frequency bands; and
- a larger collection of spectral descriptors.

The MATLAB application includes descriptors beyond those implemented in the LabVIEW version, including:

- spectral centroid;
- spectral spread;
- spectral skewness;
- spectral kurtosis;
- spectral entropy;
- spectral flatness;
- spectral crest;
- spectral flux;
- spectral slope;
- spectral decrease; and
- spectral rolloff.

### Relationship to the LabVIEW Spectral Program

The two programs share the same broader research goal but serve different purposes.

**LabVIEW program:**

- designed around live acquisition and live/rolling processing;
- includes a smaller set of implemented descriptors;
- useful for testing real-time monitoring concepts.

**MATLAB app:**

- designed for offline analysis of previously recorded data;
- allows more flexible exploration of framing and spectrum settings;
- contains a larger set of candidate spectral descriptors;
- useful for investigating which features may be worth implementing or studying further.

Neither program should currently be considered a validated nozzle-clogging detection system. They are research tools for investigating potential acoustic indicators.

See:

`SpectralAnalysis/MATLAB_Analysis/README.md`

for detailed use instructions.

---

# 3. Through Transmission

## Purpose

The `ThroughTransmission` folder contains the acquisition and analysis software used for **through-transmission ultrasonic measurements**.

The workflow is:

```text
Through-Transmission Experiment
        |
        v
MDO32_2-2-Channel_V2.vi
        |
        |  Repeated waveform acquisition
        |  + temperature measurement
        v
Tektronix .isf Waveform Files
        |
        v
CrossCorrelationApp.mlapp
        |
        |  Cross-correlation / time-of-flight analysis
        v
Ultrasonic Results
```

---

## `ThroughTransmission/LabVIEW_TT_Automation`

### Main File

`MDO32_2-2-Channel_V2.vi`

### What It Does

This LabVIEW VI automates repeated waveform acquisition from a through-transmission setup.

The current implementation uses:

- two MDO32 oscilloscopes;
- two channels from each oscilloscope;
- four total saved waveform channels; and
- cDAQ temperature acquisition.

The waveform mapping is:

```text
MDO32_1 CH1 -> waveform_ch1_<iteration>.isf
MDO32_1 CH2 -> waveform_ch2_<iteration>.isf
MDO32_2 CH1 -> waveform_ch3_<iteration>.isf
MDO32_2 CH2 -> waveform_ch4_<iteration>.isf
```

The program automatically repeats the acquisition at the selected interval and records temperature during the experiment.

This removes the need to manually save each oscilloscope waveform during long-duration testing.

### Important Hardware Requirement

Each oscilloscope requires its corresponding USB storage device:

```text
USB 1 -> Oscilloscope 1
USB 2 -> Oscilloscope 2
```

See:

`ThroughTransmission/LabVIEW_TT_Automation/README.md`

for complete setup and operating instructions.

---

## `ThroughTransmission/CrossCorrelationAnalysis`

### Main File

`CrossCorrelationApp.mlapp`

### Purpose

This MATLAB application processes through-transmission ultrasonic waveform data and uses **cross-correlation** to identify the relative timing of ultrasonic signals.

The workflow is based on comparing a sample waveform with an excitation or reference waveform.

The analysis can then be used to obtain quantities such as:

- correlation location;
- time of flight; and
- sound speed when the required sample information is provided.

### Supporting MATLAB Files

This folder also contains supporting scripts/functions for:

- cross-correlation;
- parsing repeated waveform datasets;
- cleaning waveform file numbers;
- selecting the waveform region used for analysis;
- reading Tektronix `.isf` files; and
- reading Tektronix waveform formats.

Files include:

```text
cross_correlation.m
crosscorr_parseV3.m
file_number_cleaning.m
isf_analysis_region_selection_V2.m
isfread.m
wfm3read.m
```

### Relationship to the LabVIEW Acquisition Program

The LabVIEW program produces the repeated `.isf` waveform files.

The Cross-Correlation App is then used to **analyze those recorded waveforms**.

The matching filename convention used by the acquisition program makes it possible to organize and process repeated measurements by channel and iteration.

See:

`ThroughTransmission/CrossCorrelationAnalysis/README.md`

for the complete analysis procedure, assumptions, file naming requirements, clock/time corrections, and troubleshooting information.

---

# 4. WaveTutor

## Purpose

`WaveTutor` is different from the experimental acquisition and analysis tools elsewhere in the repository.

It is an **educational application** designed to support students learning concepts related to:

- ultrasonic waves;
- nondestructive testing;
- material properties;
- longitudinal and shear waves;
- sound-speed measurement;
- cross-correlation; and
- related wave-analysis concepts.

The application provides guided instructional content and can also use Socratic AI tutoring agents.

---

## Main Components

### `app.py`

Main Streamlit application entry point.

### `app/`

Contains the core application and agent code.

This includes:

- agent behavior;
- FastAPI functionality;
- diagram generation;
- signal generation;
- signal-processing utilities; and
- supporting application utilities.

### `references/`

Contains locally stored instructional material used by the application.

These include resources related to:

- wave modes;
- sound-speed measurement;
- material properties;
- cross-correlation;
- density measurement;
- hints and feedback;
- tutorial content; and
- reference values.

### `outputs/`

Contains example/generated waveform-related output files for several materials.

### `tests/`

Contains unit, integration, and agent-evaluation tests.

### `GEMINI.md`

Contains project context used for AI-assisted development.

### `pyproject.toml`

Defines the Python project and dependencies.

---

## Relationship to the Research Tools

WaveTutor is **not part of the experimental data-acquisition pipeline**.

Instead, it serves as a learning resource for many of the concepts that appear elsewhere in the repository.

For example, students using the through-transmission analysis tools may also encounter concepts in WaveTutor related to:

- longitudinal and shear waves;
- sound speed;
- cross-correlation; and
- ultrasonic material characterization.

WaveTutor therefore complements the research software educationally, but it does not need to be run in order to use the LabVIEW or MATLAB research programs.

See:

`WaveTutor/README.md`

for installation, deployment, API-key information, and development instructions.

---

# How the Major Projects Relate

## SFAI Workflow

```text
Bode 100
   |
   v
BODE_AUTO_v9.vi
   |
   v
Repeated S21 frequency sweeps
   |
   v
SFAI Jupyter notebooks
   |
   v
Smoothed/interpolated responses
   |
   v
Peak frequency + peak width results
```

---

## Spectral-Analysis Workflow

```text
Microphone / Time-Domain Signal
            |
            +------------------------------+
            |                              |
            v                              v
LabVIEW Live Processing            Saved Time-Domain Data
            |                              |
            v                              v
FFT / STFT /                     MATLAB Spectral App
Centroid / Spread                         |
                                           v
                                  FFT / STFT / Multiple
                                  Candidate Descriptors
```

The LabVIEW and MATLAB tools overlap conceptually but support different stages of exploration.

---

## Through-Transmission Workflow

```text
Ultrasonic Through-Transmission Setup
            |
            v
Two MDO32 Oscilloscopes + Temperature DAQ
            |
            v
MDO32_2-2-Channel_V2.vi
            |
            v
Repeated .isf waveform files
            |
            v
CrossCorrelationApp.mlapp
            |
            v
Cross-correlation / Time of Flight / Sound Speed
```

---

## Educational Connection

```text
Research Workflows
      |
      | concepts such as waves,
      | sound speed, cross-correlation,
      | ultrasonic measurement
      v
WaveTutor
```

WaveTutor can help students build conceptual understanding of methods used in the experimental projects, but it remains a separate educational tool.

---

# Which Folder Should I Use?

| Goal | Folder |
|---|---|
| Automatically collect repeated Bode 100 S21 sweeps | `SFAI/Bode_SFAI_Automation` |
| Smooth SFAI responses and calculate peak locations/widths | `SFAI/SFAI_Analysis` |
| Acquire microphone data and perform live FFT/STFT analysis | `SpectralAnalysis/LabVIEW_Audio_Projects` |
| Explore saved time-domain signals and many spectral descriptors | `SpectralAnalysis/MATLAB_Analysis` |
| Automatically collect repeated through-transmission waveforms and temperature | `ThroughTransmission/LabVIEW_TT_Automation` |
| Analyze through-transmission waveforms using cross-correlation | `ThroughTransmission/CrossCorrelationAnalysis` |
| Learn or review ultrasonic/NDT concepts | `WaveTutor` |

---

# Software Used Across the Repository

Different sections of the repository require different software.

## LabVIEW

The LabVIEW projects were developed in:

**LabVIEW 2015**

This applies to the current:

- Bode automation;
- cold spray/audio spectral acquisition; and
- through-transmission acquisition tools.

Keep backup copies before opening the VIs in newer LabVIEW versions that may convert them.

## MATLAB

MATLAB is used for:

- the offline spectral-analysis app;
- the through-transmission cross-correlation app; and
- supporting analysis scripts.

Refer to the README inside each MATLAB project for project-specific requirements.

## Python / Jupyter

Python/Jupyter is used for:

- SFAI processing notebooks; and
- WaveTutor.

WaveTutor has its own Python environment and dependency configuration in `pyproject.toml`.

---

# General Guidance for New Students

If you are new to this repository, start with the README in the folder corresponding to the experiment or analysis you are working on.

A useful rule is:

> **Acquisition programs create the data. Analysis programs interpret the data.**

Before modifying an acquisition program, make sure you understand the format expected by the corresponding analysis tools.

Likewise, before modifying an analysis program, confirm how the acquisition software created and organized the original data.

For long-duration automated experiments:

- verify hardware connections before leaving the system unattended;
- confirm that files are actually being saved;
- preserve consistent experimental settings within a dataset;
- keep an untouched copy of working software before making major changes; and
- document any changes to file formats or naming conventions because downstream analysis may depend on them.

---


# Current Project Status and Development Notes

At the time this repository was prepared, the programs and workflows described here were **generally functioning as expected** for their intended research use.

However, these tools should still be treated as **research software under active development** rather than finalized production software.

This means:

- bugs may still exist;
- edge cases may not yet be handled;
- some workflows may be inefficient for larger datasets;
- hardware or software changes may require updates;
- assumptions built into one experiment may not apply to another; and
- future students may identify better ways to organize, process, or automate the same work.

When unexpected behavior occurs, do not assume that the experimental data are necessarily wrong. First verify the hardware, acquisition settings, file structure, and program logic, then correct the software as needed.

A good example is the current SFAI analysis workflow. The existing notebook sequence works well for relatively small numbers of measurements, but it is not optimized for processing large numbers of repeated sweeps generated during long-duration automated testing. A future version could combine steps, reduce repeated file operations, automate batch processing, or otherwise improve efficiency.

Similar opportunities for improvement may exist throughout the repository.

## Development Practices

When continuing development, use good version-control and software-development habits.

In particular:

- keep the current working versions intact;
- avoid overwriting a known-good version while testing major changes;
- make changes in a new branch or clearly identified development copy;
- use meaningful commit messages;
- document important changes to program behavior, file formats, or experimental assumptions;
- increment or otherwise track versions when major changes are made;
- test changes on small or simulated datasets before using them in long experiments;
- verify saved output before leaving automated tests unattended; and
- preserve compatibility with downstream analysis tools whenever possible.

The existing programs should provide a **known working baseline**.

If future development introduces a problem, there should always be a stable version available to return to while the issue is investigated.

For this reason, do not remove or replace a working program simply because a newer version is being developed. Keep the stable version available until the replacement has been thoroughly tested and verified.

## Room for Improvement

Students are encouraged to improve these tools when appropriate.

Possible improvements may include:

- making processing more efficient;
- reducing repetitive manual steps;
- improving error handling;
- making hardware configuration more flexible;
- improving file organization;
- automating larger analysis pipelines;
- adding validation checks;
- improving documentation;
- adding additional spectral or ultrasonic analysis methods; and
- making the programs easier to maintain or reuse.

Improvements should be made carefully and incrementally so that working functionality is not lost.

The goal is not to treat the current repository as untouchable. The goal is to use it as a reliable starting point, understand how the existing workflows operate, and improve them while preserving a stable fallback.


# Summary

This repository brings together several related applied-acoustics workflows:

- **SFAI** combines automated Bode 100 acquisition with resonance-peak analysis.
- **SpectralAnalysis** provides both real-time LabVIEW processing and flexible offline MATLAB analysis of time-domain signals.
- **ThroughTransmission** combines automated waveform/temperature acquisition with cross-correlation-based ultrasonic analysis.
- **WaveTutor** provides an educational environment covering concepts relevant to ultrasonic and wave-based measurements.

The individual projects are intentionally modular. They can be used independently, but the acquisition and analysis folders within each experimental area are designed to complement one another.
