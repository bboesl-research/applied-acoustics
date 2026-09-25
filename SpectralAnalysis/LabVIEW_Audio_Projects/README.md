# Acoustic Monitoring and Spectral Analysis in LabVIEW

## Project Purpose

This LabVIEW project was developed as a preliminary acoustic-monitoring tool for the **cold spray manufacturing process**. The broader research goal is to investigate whether changes in the acoustic signal produced during cold spray can be used to identify changes in the process, particularly the development of **nozzle clogging**.

The program acquires a time-domain acoustic signal and analyzes its frequency content while the process is running. In addition to displaying the original time-domain signal, the program performs frequency-domain analysis and a rolling Short-Time Fourier Transform (STFT) so that changes in the spectral content of the signal can be observed over time.

Spectral descriptors are calculated from the frequency-domain data to provide quantitative values that can be tracked throughout the process. The current implementation includes two descriptors:

- **Spectral centroid**
- **Spectral spread**

These descriptors provide simplified measures of how the frequency content of the signal is distributed. This implementation is preliminary. Many other spectral descriptors could potentially be useful, and additional investigation is still required to determine which descriptors, combinations of descriptors, or other signal-processing approaches are most useful for identifying nozzle clogging or other changes in the cold spray process.

This software is **not inherently limited to cold spray**. The signal-processing framework can be used with other time-domain signals when the objective is to examine frequency content, track changes in the spectrum over time, or calculate spectral descriptors.

> **Important:** This program is an exploratory research tool. A change in spectral centroid or spectral spread should not, by itself, be interpreted as confirmation of nozzle clogging. The relationship between acoustic features and process conditions still requires experimental investigation and validation.

---

## Main Program

The main VI is:

`MicrophoneColdSpray_Complete_Descriptors_v10.vi`

The main program handles:

- real or simulated signal input;
- time-domain signal display;
- acoustic data acquisition;
- rolling signal buffering;
- FFT-based frequency-domain analysis;
- rolling STFT generation;
- conversion of acoustic pressure spectra to dB SPL;
- spectral centroid calculation;
- spectral spread calculation;
- baseline descriptor calculations;
- live descriptor visualization;
- queue-based transfer of acquired data for processing; and
- saving collected sound data.

The supporting SubVIs are described later in this document.

---

## Software and Hardware

### Software

This project was developed in:

- **LabVIEW 2015**

Opening the VIs in a significantly newer LabVIEW version may cause LabVIEW to convert the files. Keep an untouched copy of the original project before allowing any permanent version conversion.

### Data Acquisition Hardware

The real-data acquisition portion of the program was configured for:

- **NI cDAQ-9174**
- **NI 9232**
- **PCB Piezotronics 378A04 microphone**

The DAQ configuration and microphone setup are already incorporated into the acquisition portion of the program. If different hardware is used, the DAQ configuration will need to be reviewed and modified.

---

## General Program Workflow

At a high level, the program follows this processing sequence:

```text
Time-Domain Signal
        |
        v
Real DAQ Input or Simulated Signal
        |
        v
Rolling Signal Buffer
        |
        v
Windowed Signal Segments
        |
        v
FFT
        |
        v
Magnitude Spectrum
        |
        v
Positive-Frequency Spectrum
        |
        +----------------------+
        |                      |
        v                      v
Frequency Array            dB SPL
        |
        v
Spectral Centroid
        |
        v
Spectral Spread
        |
        v
Baseline / Rolling Descriptor Tracking
```

The same general frequency-domain processing can be applied to signals other than cold spray microphone recordings.

---

## Main Front-Panel Controls

### `Stop`

Stops execution of the program.

Use the program's normal stop control rather than aborting execution whenever possible so that loops, queues, and acquisition processes can terminate normally.

---

### `Real Data?`

Selects whether the program operates using:

- **real microphone data**, or
- **internally generated simulated signals**.

Use simulated mode when testing changes to the signal-processing portion of the program without connecting the DAQ hardware.

---

### `TestName`

Provides the test identifier used when collected sound data are saved.

Choose a descriptive name that allows the dataset to be associated with the corresponding experiment.

---

### `Path to Save Folder for Collected Sound Data`

Specifies the directory where recorded sound data are saved.

Before starting a real experiment, verify that:

- the path exists;
- the computer has write access to the folder; and
- sufficient storage space is available.

---

### `Device Name`

Specifies the NI-DAQ device/channel configuration used by the acquisition portion of the program.

The correct name depends on the device configuration in NI Measurement & Automation Explorer (NI MAX). If the program reports an acquisition error, confirm that the device name matches the hardware configuration on the computer.

---

### `Rate (Hz)`

Controls the acquisition sampling rate.

The displayed default configuration uses:

`51200 Hz`

The sampling rate affects:

- the highest resolvable frequency;
- FFT frequency-bin spacing;
- time resolution;
- the amount of data processed;
- STFT behavior; and
- computational load.

Do not change the sampling rate without considering the effect on the entire spectral-analysis pipeline.

---

### `Number of Samples per Read`

Controls the number of samples returned during each acquisition/read operation.

This value affects:

- the duration of each acquired block;
- FFT length;
- frequency resolution;
- STFT window duration;
- update rate; and
- processing load.

The simulated-signal section of the program specifically notes using:

`4096 samples per read`

when testing with the built-in simulated signals.

---

### `Rolling Buffer (s) MAX 20s`

Controls the amount of recent signal history retained for rolling processing and display.

The front panel limits this value to a maximum of approximately 20 seconds.

Larger buffers provide a longer visible history but require additional memory and processing.

---

### `Microphone Sensitivity`

Stores the microphone sensitivity used by the real-data acquisition path.

The current front-panel value is:

`450`

Verify the units and correct sensitivity for the microphone being used before collecting quantitative acoustic measurements.

---

### `Window Type`

Selects the window applied to each signal segment before calculating the FFT.

The program includes the following window options:

| Value | Window |
|---:|---|
| 0 | Rectangle / Rectangular |
| 1 | Hanning |
| 2 | Hamming |
| 3 | Blackman-Harris |
| 4 | Exact Blackman |
| 5 | Blackman |
| 6 | Flat Top |
| 11 | Blackman-Nuttall |
| 30 | Triangle |
| 31 | Bartlett-Hanning |
| 32 | Bohman |
| 33 | Parzen |
| 34 | Welch |

The selected window affects spectral leakage, amplitude behavior, equivalent noise bandwidth, and frequency-domain interpretation.

If students are comparing results between experiments, the same window type should generally be used unless the effect of changing the window is intentionally being investigated.

---

## Live Displays

### Live Audio Sound Pressure

Displays the acquired or simulated time-domain signal.

This is useful for:

- confirming that a signal is being received;
- identifying large transient events;
- observing clipping or abnormal amplitudes; and
- comparing time-domain behavior with changes seen in the spectral displays.

---

### Rolling STFT

Displays the frequency content of the signal as it changes over time.

The STFT is intended to show how the acoustic spectrum evolves during the process rather than only providing a single FFT from one instant.

This is particularly important for the cold spray application because potential clogging behavior may develop progressively rather than appearing as a single isolated spectral event.

---

### Spectral Descriptors

The program tracks the currently implemented spectral descriptors over time:

- spectral centroid;
- spectral spread.

Baseline values are also calculated and displayed.

These descriptors are intended to reduce the frequency spectrum to quantitative features that can be compared across time or process conditions.

---

## Rolling STFT

The program performs frequency analysis on overlapping portions of the signal.

The block diagram indicates that each processing window has a length corresponding to the configured number of samples per read, while the starting location advances by approximately half that amount between windows.

This corresponds to approximately:

**50% overlap**

between consecutive analysis windows.

In general, the STFT process can be thought of as:

1. Select a segment of the recent time-domain signal.
2. Apply the selected window function.
3. Calculate the FFT.
4. Convert the FFT to a magnitude spectrum.
5. Retain the positive-frequency portion of the spectrum.
6. Associate each FFT bin with its corresponding frequency.
7. Display the result as part of the rolling STFT.
8. Calculate spectral descriptors from the same spectral information.

Because the STFT is calculated continuously, changes in the spectral structure of the process can be observed as a function of time.

---

## Frequency-Domain Processing

### 1. Windowing

Before the FFT is calculated, the selected window function is applied to the time-domain segment.

Windowing reduces discontinuities at the edges of each finite signal segment and therefore helps control spectral leakage.

Different window functions produce different tradeoffs between:

- frequency resolution;
- spectral leakage;
- amplitude accuracy; and
- equivalent noise bandwidth.

The program includes correction-related values such as coherent gain and equivalent noise bandwidth in the processing section.

---

### 2. FFT Magnitude

The FFT converts the windowed time-domain signal into its frequency-domain representation.

Because the FFT output is complex, its magnitude is calculated before subsequent spectral processing.

The supporting SubVI responsible for this operation is:

`MagnitudeFFT (SubVI).vi`

---

### 3. Positive-Frequency Spectrum

For a real-valued time-domain signal, the FFT contains mirrored positive- and negative-frequency components.

The program extracts the positive-frequency portion of the spectrum and accounts for the negative-frequency contribution where appropriate.

The retained spectrum includes:

- the **0 Hz (DC) bin**; and
- the **Nyquist bin**.

The supporting SubVI is:

`PositiveSpectralValues (SubVI).vi`

---

### 4. Frequency Array

Each element of the FFT spectrum corresponds to a frequency bin.

The program generates a frequency array using:

- acquisition sampling rate;
- full FFT length; and
- positive-spectrum length.

The supporting SubVI is:

`FrequencyAtEachBin (SubVI).vi`

For a standard FFT, the frequency spacing is conceptually:

```text
Δf = Fs / N
```

where:

- `Fs` = sampling rate;
- `N` = FFT length;
- `Δf` = spacing between adjacent FFT bins.

The generated frequency array is used for plotting and for calculation of the spectral descriptors.

---

## dB SPL Conversion

For the acoustic-processing path, the positive-frequency pressure spectrum is converted to sound pressure level.

The supporting SubVI is:

`Pa2dBSPL (SubVI).vi`

The VI uses the standard acoustic reference pressure:

```text
p_ref = 20 µPa = 2 × 10^-5 Pa
```

The calculation follows the general form:

```text
SPL = 20 log10(p / p_ref)
```

A very small value is included in the implementation to avoid invalid logarithmic behavior when the input contains zero-valued elements.

The dB SPL representation is useful for viewing acoustic spectral levels, while the descriptor calculations should be interpreted according to the exact signal representation wired into those SubVIs.

---

# Spectral Descriptors

## Spectral Centroid

The spectral centroid represents the weighted center of the spectrum.

Conceptually:

```text
                 Σ f[k] M[k]
Centroid = -------------------------
                   Σ M[k]
```

where:

- `f[k]` is the frequency associated with FFT bin `k`;
- `M[k]` is the spectral magnitude at that bin.

A higher spectral centroid generally indicates that a larger proportion of the spectrum is concentrated at higher frequencies. A lower centroid indicates a shift toward lower-frequency content.

The program calculates the centroid using:

`SpectralCentroid (SubVI).vi`

The SubVI also outputs the sum of the FFT magnitudes, which is used by later calculations.

### Interpretation in This Project

The centroid is being investigated as one possible feature for tracking changes in the acoustic signature of the cold spray process.

At this stage, a change in centroid should be treated as an observed change in spectral distribution, not as direct evidence of nozzle clogging.

---

## Spectral Spread

Spectral spread describes how widely the spectral content is distributed around the spectral centroid.

Conceptually, it behaves similarly to a weighted standard deviation of frequency:

```text
Spread = sqrt(
    Σ [(f[k] - Centroid)^2 M[k]]
    --------------------------------
              Σ M[k]
)
```

The program calculates spectral spread using:

`SpectralSpread (SubVI).vi`

Inputs include:

- the positive-frequency spectral values;
- frequency array;
- spectral centroid; and
- sum of FFT magnitudes.

### Interpretation in This Project

Spectral spread is being investigated as another possible indicator of changes in the cold spray acoustic signature.

A change in spread indicates that the distribution of frequency content has become broader or narrower around the centroid.

As with centroid, this should not currently be interpreted as a standalone clogging detector.

---

## Baseline Spectral Descriptors

The main VI calculates baseline values for:

- spectral centroid;
- spectral spread.

These baseline values provide a reference against which later descriptor values can be compared.

The interface also displays upper and lower spread-related levels around the centroid.

The purpose of the baseline section is to make changes in the spectral descriptors easier to observe as the signal evolves.

The exact relationship between these changes and physical cold spray conditions still requires experimental validation.

---

# Simulated Signal Mode

The program contains a built-in simulation mode so that signal-processing behavior can be tested without the microphone and DAQ hardware.

Three configurable simulated signals are provided.

The front panel includes controls for each signal's:

- frequency;
- amplitude; and
- noise amplitude.

The signals are described in the VI as sine waves with inverse-frequency noise.

The current default settings shown on the front panel are approximately:

| Signal | Frequency | Amplitude | Noise Amplitude |
|---|---:|---:|---:|
| Signal 1 | 500 Hz | 1 V | 0.3 V |
| Signal 2 | 2000 Hz | 0.5 V | 0.02 V |
| Signal 3 | 5000 Hz | 0.3 V | 0.01 V |

These values can be changed for testing.

---

## Simulated Signal Sequence

The program notes the following repeating sequence:

```text
10 s: Signal 1

10 s: Signal 1 + Signal 2

10 s: Signal 1 + Signal 2 + Signal 3

10 s: Signal 1 + Signal 2

Repeat
```

This sequence intentionally changes the frequency content over time so that students can observe how the:

- STFT;
- spectral centroid; and
- spectral spread

respond to known changes in the input signal.

For simulation testing, the VI notes that `Number of Samples per Read` should be set to:

`4096`

---

# Data Acquisition and Processing Architecture

The program separates data acquisition and data processing so that signal collection can continue while calculations are being performed.

The block diagram includes status monitoring for:

- data acquisition;
- data processing; and
- the queue used to transfer data.

Front-panel/status indicators include messages corresponding to:

- **Data Acquisition Running Successfully**
- **Error in Data Acquisition**
- **Data Processing Running Successfully**
- **Error in Data Processing**
- queue status / number of elements in the queue

This structure is important because real-time acquisition should not be unnecessarily blocked by downstream spectral calculations.

When modifying the program, avoid introducing slow operations directly into the acquisition path unless their effect on acquisition timing has been evaluated.

---

# Saving Data

The main VI allows collected sound data to be saved to a user-selected folder.

The saved filename uses the supplied test name together with a timestamp.

The block diagram contains a date/time formatting string in the form:

```text
_D%m_%d_%y_T%H_%M_%S
```

This produces filenames containing the date and time so that repeated tests can be distinguished.

Before running an experiment:

1. Enter a meaningful `TestName`.
2. Confirm the save folder.
3. Confirm that the folder exists.
4. Confirm that the computer can write to that location.
5. Verify that enough storage space is available.

---

# Supporting SubVIs

## `MagnitudeFFT (SubVI).vi`

### Purpose

Calculates the magnitude of the FFT for a windowed time-domain signal.

### Input

- `Windowed Signal Array`

### Output

- `Magnitude FFT`

### General Operation

The FFT produces complex values containing real and imaginary components. The SubVI combines those components to calculate the magnitude of each FFT bin.

This magnitude spectrum is passed to the later frequency-domain processing steps.

---

## `PositiveSpectralValues (SubVI).vi`

### Purpose

Extracts the positive-frequency portion of the scaled FFT while retaining the DC and Nyquist bins.

### Inputs

- `Scaled Full Length FFT`
- `Size of Positive Half of FFT`

### Output

- `Positive Half of FFT with 0Hz and Nyquist`

### General Operation

For real-valued signals, the negative-frequency side of the FFT mirrors the positive-frequency side.

The SubVI constructs the one-sided spectrum and accounts for the negative-frequency contribution for bins that have mirrored counterparts.

The DC and Nyquist bins are handled separately because they should not be doubled in the same way as the interior positive-frequency bins.

---

## `FrequencyAtEachBin (SubVI).vi`

### Purpose

Generates the frequency corresponding to each bin in the positive-frequency FFT.

### Inputs

- `Length of Positive Half of FFT`
- `Length of Full FFT`
- `Rate of Measurement (Hz)`

### Output

- `Frequency Array`

### General Operation

The frequency-bin spacing is determined from the measurement rate and full FFT length.

The SubVI creates a regularly spaced frequency array corresponding to the length of the positive-frequency spectrum.

This frequency array is required for:

- plotting the spectrum;
- calculating spectral centroid; and
- calculating spectral spread.

---

## `Pa2dBSPL (SubVI).vi`

### Purpose

Converts the positive-frequency acoustic pressure spectrum to sound pressure level in dB SPL.

### Input

- `Positive Half of FFT with 0Hz and Nyquist`

### Output

- `dB SPL`

### General Operation

The conversion uses the acoustic reference pressure:

```text
20 µPa
```

and applies a logarithmic conversion based on:

```text
20 log10(p / p_ref)
```

The implementation also includes protection against taking the logarithm of zero.

---

## `SpectralCentroid (SubVI).vi`

### Purpose

Calculates the spectral centroid.

### Inputs

- `Positive Half of FFT with 0Hz and Nyquist`
- `Frequency Array`

### Outputs

- `Spectral Centroid`
- `Sum of FFT Mags`

### General Operation

Each frequency is weighted by its associated spectral magnitude. The weighted frequencies are summed and divided by the total spectral magnitude.

The total magnitude is also returned because it is used in the spectral-spread calculation.

---

## `SpectralSpread (SubVI).vi`

### Purpose

Calculates the spread of spectral content around the spectral centroid.

### Inputs

- `Spectral Centroid`
- `Sum of FFT Mags`
- `Positive Half of FFT with 0Hz and Nyquist`
- `Frequency Array`

### Output

- `Spectral Spread`

### General Operation

The SubVI calculates a magnitude-weighted measure of the distance between each frequency bin and the spectral centroid.

This provides a measure of whether the spectrum is concentrated tightly around the centroid or distributed more broadly.

---

## `MeanOfArray (SubVI).vi`

### Purpose

Calculates the arithmetic mean of an input array.

### Input

- `Array`

### Output

- `Mean`

This SubVI is used by the main program when averaging descriptor values, including baseline-related calculations.

---

## `IfTruePassConcatenated (SubVI).vi`

### Purpose

Conditionally builds or passes an accumulated array during loop execution.

### Inputs

- `New Array`
- `Condition`
- `Loop Number`
- `Old Array`

### Output

- `If True, Concatenated`

This SubVI is used where the program needs to preserve and concatenate selected values across iterations.

Students modifying this SubVI should first trace where its condition input is generated in the main VI, because changes to its behavior can alter the descriptor history accumulated by the program.

---

# Running the Program with Real Data

Before beginning a real cold spray acquisition:

1. Connect the required NI cDAQ hardware and microphone.
2. Confirm that the DAQ hardware is visible in NI MAX.
3. Open `MicrophoneColdSpray_Complete_Descriptors_v10.vi`.
4. Set `Real Data?` to real-data mode.
5. Verify the `Device Name`.
6. Verify the sampling `Rate (Hz)`.
7. Verify `Number of Samples per Read`.
8. Verify the microphone sensitivity.
9. Select the desired FFT window.
10. Enter a `TestName`.
11. Select the folder where collected sound data should be saved.
12. Run the VI.
13. Confirm that the live time-domain signal appears reasonable.
14. Confirm that the acquisition status indicates successful operation.
15. Observe the rolling STFT and spectral-descriptor displays.
16. Stop the VI using the front-panel `Stop` control.

If an acquisition error occurs, check the hardware connection and DAQ configuration before modifying the signal-processing code.

---

# Running the Program with Simulated Data

Simulation mode is the preferred way to test signal-processing changes when the DAQ hardware is not required.

1. Open `MicrophoneColdSpray_Complete_Descriptors_v10.vi`.
2. Set `Real Data?` to simulated-data mode.
3. Set `Number of Samples per Read` to `4096`.
4. Review the frequency, amplitude, and noise settings for Signals 1–3.
5. Run the VI.
6. Observe the transitions between the known simulated-signal combinations.
7. Confirm that the rolling STFT changes as expected.
8. Observe how spectral centroid and spectral spread respond.
9. Use this behavior to validate code changes before testing with experimental data.

Because the simulated frequencies are known, simulation mode is useful for checking whether frequency bins, FFT scaling, descriptor calculations, and plots behave as expected.

---

# Important Considerations When Modifying the Program

## Sampling Rate and FFT Length Are Connected

Changing the sampling rate or number of samples changes the frequency resolution.

Before changing either value, consider its effect on:

- FFT bin spacing;
- Nyquist frequency;
- STFT timing;
- descriptor calculations;
- array lengths; and
- computational load.

---

## Keep Spectral Arrays the Same Length

The following arrays must correspond correctly to one another:

- positive-frequency magnitude spectrum;
- dB SPL spectrum when plotted against frequency;
- frequency array.

The descriptor calculations assume that spectral values and frequency values correspond element-by-element.

---

## Preserve DC and Nyquist Handling

The one-sided FFT logic treats the:

- DC bin; and
- Nyquist bin

differently from the mirrored interior frequency bins.

Do not simply multiply the entire positive spectrum by two.

---

## Be Careful When Changing the Window

Changing the window changes the spectral representation.

If comparing experiments quantitatively, document the window used and avoid changing it between datasets unless the change is intentional.

---

## Check Scaling Before Interpreting Absolute Levels

If the purpose of an analysis is to compare absolute acoustic levels rather than relative changes, verify:

- microphone sensitivity;
- DAQ scaling;
- FFT amplitude scaling;
- window coherent-gain correction;
- one-sided-spectrum scaling; and
- dB SPL conversion.

The current project was primarily developed as an exploratory framework for monitoring spectral changes.

---

## Test Changes Using Simulated Signals First

The built-in simulated signals provide a controlled input with known frequencies.

Whenever possible:

1. modify the processing code;
2. test using simulated mode;
3. confirm expected FFT/STFT behavior;
4. confirm descriptor behavior; and
5. only then test using real acquisition hardware.

---

## Do Not Assume the Existing Descriptors Are Optimal

Spectral centroid and spectral spread were implemented as an initial exploration.

Future work may investigate additional descriptors such as:

- spectral bandwidth;
- spectral rolloff;
- spectral flatness;
- spectral entropy;
- spectral flux;
- band-specific energy;
- peak-frequency behavior;
- harmonic features; or
- other time-frequency features.

These are examples of possible directions, not requirements of the current implementation.

Descriptor selection should ultimately be driven by experimental evidence showing which features are useful for distinguishing process conditions.

---

# Troubleshooting

## No Real Signal Appears

Check:

- whether `Real Data?` is set correctly;
- DAQ hardware power and USB connection;
- NI MAX device recognition;
- the `Device Name`;
- microphone connection;
- channel configuration; and
- whether another program is currently using the DAQ device.

---

## Data Acquisition Error

First check the DAQ hardware and configuration.

Potential causes include:

- incorrect device name;
- disconnected cDAQ chassis;
- unavailable channel;
- incompatible DAQ configuration;
- hardware already reserved by another program; or
- acquisition settings unsupported by the configured hardware.

---

## Data Processing Error

Inspect the processing path for:

- unexpected array sizes;
- invalid or empty data;
- modifications to FFT or buffer lengths;
- descriptor inputs that no longer have matching dimensions; or
- errors propagated from earlier portions of the program.

---

## Queue Continues to Grow

If the number of elements in the queue continually increases, the processing loop may not be keeping up with acquisition.

Possible causes include:

- computationally expensive additions to the processing loop;
- plotting too much data;
- very large buffers;
- high acquisition rates;
- excessively frequent file operations; or
- debugging probes/highlighting slowing execution.

A growing queue indicates that acquisition is generating data faster than the downstream processing section is consuming it.

---

## Spectrum Looks Incorrect

Check:

- sampling rate;
- number of samples;
- window selection;
- FFT scaling;
- positive-spectrum extraction;
- frequency-array calculation; and
- simulated-signal settings if using simulation mode.

Using the built-in simulated signals is a good way to verify whether known peaks appear at the expected frequencies.

---

# Suggested Workflow for Future Development

This project should be treated as a starting point for continued investigation rather than a completed clogging-detection system.

A reasonable future workflow is:

1. Collect acoustic data under known cold spray conditions.
2. Record the corresponding physical/process condition of each dataset.
3. Examine time-domain and STFT behavior.
4. Calculate candidate spectral features.
5. Determine which features change consistently with nozzle condition.
6. Evaluate whether changes are distinguishable from normal process variability.
7. Add promising descriptors to the LabVIEW pipeline.
8. Validate them using additional experiments.
9. Only after validation, consider using the descriptors for automated detection or classification.

---

# File Summary

The core files associated with the current implementation are:

```text
MicrophoneColdSpray_Complete_Descriptors_v10.vi
FrequencyAtEachBin (SubVI).vi
IfTruePassConcatenated (SubVI).vi
MagnitudeFFT (SubVI).vi
MeanOfArray (SubVI).vi
Pa2dBSPL (SubVI).vi
PositiveSpectralValues (SubVI).vi
SpectralCentroid (SubVI).vi
SpectralSpread (SubVI).vi
```

The main VI contains the overall acquisition and processing architecture. The SubVIs separate individual calculations into smaller components that can be opened independently to inspect their block diagrams.

---

# Final Notes for Students

The purpose of this program is not simply to produce an FFT. It provides a framework for observing how the frequency content of a time-domain signal changes over time and for reducing that behavior to quantitative spectral features.

For the cold spray project, the scientific question is whether those acoustic changes contain useful information about the state of the manufacturing process, including possible nozzle clogging.

The current spectral centroid and spectral spread calculations are the beginning of that investigation, not the final answer.

When continuing this project:

- preserve copies of working versions;
- document any changes to acquisition or spectral-processing settings;
- validate code changes with simulated signals;
- do not interpret descriptor changes without comparing them to known experimental conditions; and
- keep the signal-processing framework general enough that additional descriptors or other time-domain signals can be incorporated later.
