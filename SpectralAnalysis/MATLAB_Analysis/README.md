# Time-to-Frequency Domain Spectral Analysis App

## Overview

This MATLAB App Designer program was originally developed as part of the **Cold Spray Project** to analyze acoustic recordings collected during cold spray operation.

The motivation for the application was to investigate whether changes in the sound produced during spraying could be used to identify changes in system behavior, particularly the onset or development of **nozzle clogging**. The general idea is that changes in the spray process may produce measurable changes in the frequency content of the recorded acoustic signal. By tracking these changes over time using spectral analysis and spectral descriptors, it may be possible to identify acoustic features associated with nozzle clogging or other changes in process condition.

The app converts recordings collected in the **time domain** into frequency-domain and time-frequency representations. It allows the user to investigate how the spectral content of a signal changes over time while varying analysis parameters such as:

* Window function
* Window length
* Window overlap
* Spectrum type
* Spectral descriptor

The application displays the original time-domain signal, a Short-Time Fourier Transform (STFT), and spectral descriptor values calculated across multiple frequency ranges.

Although the app was developed for the Cold Spray Project, **it is not specific to cold spray data**. It can be used or adapted for other applications in which a signal is recorded in the time domain and needs to be investigated in the frequency domain.

Potential applications include acoustic monitoring, vibration analysis, machinery monitoring, process monitoring, transient-event analysis, and other sensor-based time-series measurements.

A key consideration when comparing spectral descriptors is that the framing settings should remain constant. Changes in window type, window length, or overlap affect the calculated spectrum and can therefore affect the resulting spectral descriptors.

At the time of handoff, this application should be considered an **exploratory research tool rather than a validated nozzle-clogging detection system**. It provides a framework for investigating potential acoustic indicators of nozzle condition, but additional experimental work is required to determine which spectral features and analysis settings are reliable indicators of clogging.

---

## Original Research Application: Cold Spray Nozzle Monitoring

The original purpose of this application was to support development of an acoustic-monitoring approach for the cold spray system.

During operation, the cold spray nozzle may begin to clog. The goal of the acoustic analysis is to investigate whether this change in nozzle condition produces a detectable change in the sound recorded during spraying.

The general research workflow is:

Cold Spray Operation
→ Record Acoustic Signal in the Time Domain
→ Convert Signal to Time-Frequency/Frequency-Domain Representation
→ Evaluate Changes in Spectral Content
→ Calculate Spectral Descriptors
→ Compare Spectral Behavior Over Time
→ Investigate Features Potentially Associated with Nozzle Clogging

The application provides the analysis framework needed to explore these relationships.

---

## File Included

**Time2FreqDomainAnalysis.mlapp**

Main MATLAB App Designer application containing the user interface, TDMS reading, STFT calculations, spectral descriptor calculations, plotting, and output-saving routines.

---

## MATLAB Requirements

The app was last saved using:

**MATLAB R2026a Update 4**

The `.mlapp` metadata indicates a minimum supported MATLAB version of R2018a, although the program was developed and tested using a much newer MATLAB release.

The app uses MATLAB functions including:

* `tdmsinfo`
* `tdmsread`
* `stft`
* `spectralCentroid`
* `spectralSpread`
* `spectralSkewness`
* `spectralKurtosis`
* `spectralEntropy`
* `spectralFlatness`
* `spectralCrest`
* `spectralFlux`
* `spectralSlope`
* `spectralDecrease`
* `spectralRolloffPoint`

The appropriate MATLAB toolboxes containing these functions must therefore be installed.

---

## Input Data

The app is designed to read:

**TDMS (`.tdms`) files**

The user provides the path to the TDMS file directly in the app.

The sampling rate must also be entered manually in Hertz.

### Important TDMS Behavior

The current version of the app reads the:

**first channel from the first channel group listed in the TDMS file.**

The code obtains:

`ChannelGroupName_tdms = info.ChannelList.ChannelGroupName(1)`

and

`ChannelName_tdms = info.ChannelList.ChannelName(1)`

Therefore, if a TDMS file contains multiple channels, the current program does not provide a graphical option for selecting which channel should be analyzed.

Future users working with multi-channel TDMS files should verify that the desired signal is stored as the first listed channel or modify the application to allow channel selection.

---

## General Workflow

1. Open `Time2FreqDomainAnalysis.mlapp` in MATLAB.
2. Enter the path to the TDMS data file.
3. Enter the sampling rate in Hz.
4. Select the desired spectrum type:

   * Magnitude
   * Power
   * PSD
5. Select the desired spectral descriptor.
6. Select the window function:

   * Rectangular
   * Hann
   * Hamming
   * Blackman
7. Enter the desired window length in milliseconds.
8. Enter the desired window overlap in milliseconds.
9. Enter the folder where analysis results should be saved.
10. Select **Run Analysis** to view the selected analysis in the application.
11. Use **Show Descriptor Information** for a description of the selected spectral descriptor and guidance on interpreting it.
12. Once suitable framing parameters have been selected, use:

* **Save Analysis Setting Only**, or
* **Save Full Analysis**

---

## Signal Preprocessing

After the TDMS signal is loaded, the app removes its DC offset.

This is performed using:

`data = data - mean(data)`

Removing the mean centers the acoustic waveform around zero and prevents a constant DC component from dominating the zero-frequency portion of the spectrum.

The app treats the imported signal as sound pressure data, with the time-domain plot labeled in:

**Sound Pressure (Pa)**

Users should therefore verify that the TDMS channel being analyzed actually contains data calibrated in Pascals if physically meaningful sound-pressure values are required.

---

## Time-Domain Analysis

The app displays the complete imported signal as:

**Sound Pressure (Pa) vs. Time (s)**

This plot can be used to inspect the raw recording before interpreting the frequency-domain results.

The full duration of the imported signal is displayed.

---

## Framing Controls

Spectral analysis is performed on short sections, or frames, of the time-domain signal.

The app allows the user to control the framing process using:

* Window function
* Window length
* Window overlap

These parameters directly affect both the STFT and the spectral descriptor calculations.

---

## Window Functions

The available window functions are:

### Rectangular

A rectangular window applies essentially no tapering to the frame.

It preserves the original signal amplitude within the frame but generally produces more spectral leakage when the signal does not contain an integer number of cycles within the window.

### Hann

A Hann window gradually reduces the signal toward zero at both ends of each frame.

It is commonly used for general spectral analysis because it provides a good compromise between spectral leakage and frequency resolution.

### Hamming

The Hamming window is similar to the Hann window but does not reach exactly zero at its endpoints.

It provides different sidelobe behavior and may be useful when spectral leakage is important.

### Blackman

The Blackman window provides stronger suppression of spectral leakage than Hann or Hamming windows but generally results in a wider main spectral lobe.

This can improve suppression of leakage while reducing the ability to distinguish very closely spaced frequencies.

---

## Window Length

Window length is entered in:

**milliseconds**

The program converts this value to a number of samples using:

`Window Samples = Sampling Rate × Window Length / 1000`

The result is rounded to the nearest whole sample.

The FFT length is then set equal to the number of samples in the window.

Therefore:

**FFT Length = Window Length in Samples**

### Effect of Window Length

Shorter windows provide better time resolution.

They are better for identifying rapid changes or transient events but provide poorer frequency resolution.

Longer windows provide better frequency resolution.

They produce smoother frequency-domain results but may hide short-duration spectral changes.

The appropriate window length depends on the physical phenomenon being studied.

---

## Window Overlap

Window overlap is also entered in:

**milliseconds**

The overlap is converted to samples using:

`Overlap Samples = Sampling Rate × Overlap / 1000`

Increasing overlap produces more closely spaced spectral estimates in time.

A large overlap can make time-varying descriptor curves appear smoother but also increases computational load.

### Important Requirement

The window length must be greater than the window overlap.

For example:

Window Length = 30 ms
Window Overlap = 20 ms

is acceptable.

Window Length = 20 ms
Window Overlap = 30 ms

is not valid.

---

## Default Framing Settings

The current GUI opens with:

* Window Function: Rectangular
* Window Length: 30 ms
* Window Overlap: 20 ms

These are only default values and should not automatically be assumed to be appropriate for every signal.

---

## Short-Time Fourier Transform

The app computes a one-sided Short-Time Fourier Transform using MATLAB's `stft` function.

The STFT uses the currently selected:

* Sampling rate
* Window function
* Window length
* Window overlap
* FFT length

The frequency range extends from:

**0 Hz to the Nyquist frequency**

where:

`Nyquist Frequency = Sampling Rate / 2`

The resulting STFT is displayed as a time-frequency heat map.

---

## Spectrum Types

The app allows three different spectral representations.

### Magnitude

Magnitude mode displays the amplitude spectrum.

The STFT magnitude is corrected for the removal of the negative-frequency half of the spectrum.

The app also applies a correction based on the coherent gain of the selected window.

The peak amplitude is converted to RMS and then referenced to:

`20 µPa`

using:

`p_ref = 20e-6 Pa`

The result is displayed in:

**dB**

This is consistent with an acoustic sound-pressure-level reference.

---

### Power

Power mode calculates the squared magnitude of the STFT.

The one-sided spectrum is corrected to account for removal of the negative-frequency portion of the signal.

The result is normalized using the energy of the selected window.

Power is referenced to:

`(20 µPa)^2`

and displayed in:

**dB**

---

### PSD

PSD mode calculates a power spectral density.

The squared STFT magnitude is normalized by both:

* sampling frequency
* window energy

The result is referenced to:

`(20 µPa)^2`

and displayed in:

**dB/Hz**

PSD is particularly useful when comparing spectral energy across signals or analysis settings where frequency-bin width may differ.

---

## Frequency Bands

Spectral descriptors are calculated over four frequency ranges:

* Full frequency band
* Low frequency band
* Mid frequency band
* High frequency band

The upper limit is automatically determined from the sampling rate:

`Maximum Frequency = Sampling Rate / 2`

The app then divides this frequency range into three equal sections.

For a Nyquist frequency of `Fmax`:

**Full Band**

`0 to Fmax`

**Low Band**

`0 to Fmax/3`

**Mid Band**

`Fmax/3 to 2Fmax/3`

**High Band**

`2Fmax/3 to Fmax`

For example, if:

Sampling Rate = 30,000 Hz

then:

Nyquist Frequency = 15,000 Hz

and the bands would be approximately:

* Low: 0–5,000 Hz
* Mid: 5,000–10,000 Hz
* High: 10,000–15,000 Hz

These frequency bands are determined automatically and are not manually entered in the current version of the app.

---

## Spectral Descriptors

The app calculates eleven different spectral descriptors.

Each descriptor is calculated independently for:

* Full frequency band
* Low frequency band
* Mid frequency band
* High frequency band

The descriptor values are plotted as a function of time.

The available descriptors are:

1. Centroid
2. Spread
3. Skewness
4. Kurtosis
5. Entropy
6. Flatness
7. Crest
8. Flux
9. Slope
10. Decrease
11. Rolloff Point

---

## Spectral Centroid

Spectral centroid represents the weighted average frequency of the spectrum.

It is often described as the spectral "center of mass."

Higher centroid values generally indicate that more spectral content is concentrated at higher frequencies.

Lower values indicate a spectrum weighted more strongly toward lower frequencies.

Units:

**Hz**

Shorter framing windows allow the centroid to react more rapidly to short-duration spectral changes.

Longer windows generally produce smoother centroid curves.

---

## Spectral Spread

Spectral spread describes how broadly the spectral energy is distributed around the centroid.

Low values indicate that spectral energy is concentrated relatively close to the centroid.

High values indicate a broader spectral distribution.

Units:

**Hz**

Short windows may cause greater frame-to-frame variation.

Longer windows generally stabilize the measurement but can smooth over brief spectral changes.

---

## Spectral Skewness

Spectral skewness describes the asymmetry of the spectral distribution around the centroid.

It indicates whether the spectral distribution contains a longer or stronger tail toward lower or higher frequencies.

Units:

**Unitless**

---

## Spectral Kurtosis

Spectral kurtosis describes the shape or peakedness of the spectral energy distribution.

Higher values are generally associated with spectra containing strong narrow peaks or unusual spectral concentration.

Units:

**Unitless**

---

## Spectral Entropy

Spectral entropy describes how evenly spectral energy is distributed across the frequency range.

A more ordered or concentrated spectrum generally produces lower entropy.

A more broadly distributed or noise-like spectrum generally produces higher entropy.

Units:

**Unitless**

---

## Spectral Flatness

Spectral flatness compares the geometric mean of the spectrum with its arithmetic mean.

It can be used as an indication of whether a spectrum is more:

* tonal
* noise-like

Low flatness generally indicates strong spectral peaks or tonal behavior.

High flatness indicates a flatter and more noise-like spectrum.

Units:

**Unitless**

---

## Spectral Crest

Spectral crest describes how dominant the strongest spectral component is relative to the rest of the spectrum.

A large spectral crest value generally indicates a spectrum containing a strong dominant peak.

Units:

**Unitless**

---

## Spectral Flux

Spectral flux measures how much the spectrum changes between successive frames.

Large values indicate rapid changes in spectral content.

Small values indicate relatively stable spectral behavior.

Spectral flux is therefore particularly sensitive to window length and overlap.

Units depend on the MATLAB implementation and selected spectrum type.

---

## Spectral Slope

Spectral slope describes the overall trend of spectral magnitude or power with increasing frequency.

It can indicate whether the spectrum generally increases or decreases as frequency increases.

---

## Spectral Decrease

Spectral decrease characterizes how rapidly the spectral content decreases relative to the lower-frequency region of the spectrum.

It can be useful for characterizing spectra dominated by low-frequency components with progressively weaker high-frequency content.

Units:

**Unitless**

---

## Spectral Rolloff Point

Spectral rolloff represents the frequency below which a specified proportion of spectral energy is contained.

It provides another way of describing how far the significant spectral content extends toward higher frequencies.

Units:

**Hz**

---

## Descriptor Information Button

The app includes a:

**Show Descriptor Information**

button.

Selecting this button displays a description of the currently selected spectral descriptor, including:

* what the descriptor measures
* how to interpret high and low values
* how framing parameters may affect the result

This information is intended as a quick reference and should not replace understanding of the underlying mathematical definition when the descriptor is being used for quantitative research.

---

## Comparing Spectral Descriptors

When comparing multiple descriptors from the same dataset:

**Keep the framing controls constant.**

This includes:

* Window function
* Window length
* Window overlap

Changing these values between descriptors changes the underlying spectral framing and can make direct descriptor-to-descriptor comparison misleading.

A recommended workflow is:

1. Test several framing settings.
2. Determine which settings provide a physically meaningful and interpretable representation of the signal.
3. Select those framing settings.
4. Keep them fixed.
5. Run and save all desired descriptors using the same framing parameters.

---

## Save Analysis Setting Only

The **Save Analysis Setting Only** button saves the current analysis configuration without performing and exporting the complete set of descriptor calculations.

It creates:

`analysis_settings.txt`

which contains:

* Data path
* Sampling rate
* Window function
* Window length
* Window overlap

It also creates:

`freq_band_ranges.txt`

which records the calculated:

* Full frequency range
* Low frequency range
* Mid frequency range
* High frequency range

These files are tab-delimited text files.

This option is useful for documenting the exact processing conditions used for an analysis.

---

## Save Full Analysis

The **Save Full Analysis** option performs the analysis and exports a much larger set of results.

The full-save routine generates results for both:

* Magnitude-spectrum descriptors
* Power-spectrum descriptors

for all eleven spectral descriptors.

It also saves the time-domain signal and STFT figures.

The exported analysis includes descriptors such as:

* centroid
* spread
* skewness
* kurtosis
* entropy
* flatness
* crest
* flux
* slope
* decrease
* rolloff point

for:

* Full frequency band
* Low frequency band
* Mid frequency band
* High frequency band

The app generates a collection of figures and saves them as:

`.png`

files.

Descriptor values are also written to tab-delimited:

`.txt`

files.

---

## Important: STFT Numerical Data

In the current full-analysis code, the STFT magnitude, power, and PSD matrices are plotted, but the sections intended to write the complete STFT matrix to text files are commented out.

Therefore, the full analysis saves the STFT figure as an image, but the complete numerical time-frequency STFT matrix may not currently be exported as a text file.

Future users who need numerical STFT data should review the commented `writetable` sections in the full-analysis routine.

---

## Sound Pressure Reference

The app uses:

`p_ref = 20e-6`

which corresponds to:

**20 µPa**

This is the conventional reference sound pressure used for airborne acoustics.

Magnitude, power, and PSD calculations expressed in decibels are therefore referenced to this value.

If this application is adapted for another type of pressure measurement or another reference convention, the reference value may need to be changed.

---

## General Use Beyond Cold Spray

The underlying analysis is general and can be applied to other time-series data.

In its current form, the application reads TDMS recordings and performs spectral analysis on the recorded signal. However, the same analysis approach can be used for essentially any application where:

1. A physical signal is recorded as a function of time.
2. Information may be contained in the frequency content of that signal.
3. The frequency content may change over the duration of the recording.

Examples include:

* Acoustic monitoring
* Machinery or equipment monitoring
* Vibration analysis
* Process monitoring
* Transient-event detection
* Experimental acoustics
* Condition monitoring
* Other sensor signals recorded in the time domain

The input routines may need to be modified if data are stored in a format other than TDMS, but the STFT, framing, frequency-band, and spectral-descriptor portions of the program can be reused.

---

## Development Status

**This application is still under development.**

It was created as a research and exploratory analysis tool rather than as finalized production software.

Future students should expect that portions of the application may need to be modified as the Cold Spray Project progresses or as it is adapted to other datasets.

Areas that may benefit from future development include:

* Determining which spectral descriptors are most sensitive to nozzle clogging
* Determining which frequency ranges contain the most useful information
* Optimizing window type, window length, and overlap
* Relating acoustic features to independently verified nozzle conditions
* Developing quantitative criteria for identifying the onset of clogging
* Adding automated detection or classification methods if reliable acoustic indicators are identified
* Allowing manual selection of frequency-band boundaries
* Allowing selection between multiple TDMS channels
* Improving organization and export of STFT numerical data
* Adding support for additional input file formats
* Further validating normalization and processing choices for different experimental configurations

For the Cold Spray Project specifically, the current app should be viewed as a framework for **exploring potential acoustic indicators of nozzle clogging**, not as proof that a particular descriptor or frequency-domain feature reliably predicts clogging.

---

## Important Assumptions and Limitations

* Input data are expected to be stored in a TDMS file.
* The current program analyzes only the first channel listed in the TDMS file.
* Sampling rate must be entered manually.
* The program assumes the imported signal represents sound pressure in Pascals.
* The signal mean is automatically removed before spectral analysis.
* The FFT length is automatically set equal to the selected window length in samples.
* Frequency bands are automatically divided into equal low, middle, and high thirds of the Nyquist range.
* Frequency-band boundaries cannot currently be manually adjusted through the GUI.
* The maximum analyzed frequency is the Nyquist frequency.
* Window length and overlap are entered in milliseconds and converted to samples internally.
* Window length must be greater than overlap.
* Magnitude results are referenced to 20 µPa.
* Power and PSD results are referenced to `(20 µPa)^2`.
* Changing framing settings changes the descriptor results.
* Descriptor results should not be compared directly if they were produced with different framing settings.
* Full analysis can generate many output files.
* Numerical STFT matrices are not currently exported even though the plotting calculations are performed.

---

## Troubleshooting

### TDMS File Does Not Load

Check that:

* the file path is correct
* the file is a valid TDMS file
* MATLAB can successfully read it using `tdmsinfo`
* the desired channel exists in the first listed channel position

If the desired signal is stored in another channel, the app code will need to be modified or the TDMS organization changed.

---

### Time Axis Appears Incorrect

Verify that the sampling rate entered in the app matches the sampling rate used during data acquisition.

The app explicitly provides the entered sampling rate to `tdmsread`.

An incorrect value will affect:

* time
* window size
* overlap
* FFT frequency bins
* spectral descriptor calculations

---

### Frequency Axis Appears Incorrect

Check the sampling rate.

The maximum plotted frequency is:

`Sampling Rate / 2`

Therefore, an incorrect sampling rate directly produces an incorrect frequency axis.

---

### Analysis Fails After Changing Window Settings

Verify that:

**Window Length > Window Overlap**

Also verify that the selected window length produces a reasonable number of samples for the chosen sampling frequency.

---

### Spectral Curves Are Too Noisy

Consider:

* increasing window length
* increasing overlap
* changing the window function

Be aware that increasing window length improves frequency resolution while reducing time resolution.

---

### Brief Events Are Being Smoothed Out

Consider decreasing the window length.

Shorter windows provide improved time localization, although frequency resolution will decrease.

---

### Excessive Spectral Leakage

Consider replacing the Rectangular window with:

* Hann
* Hamming
* Blackman

The appropriate choice depends on the desired balance between spectral leakage and frequency resolution.

---

### Descriptor Results Change Significantly When Window Settings Change

This is expected.

Spectral descriptors are calculated from the framed spectrum, so changes to window type, length, and overlap can significantly affect the results.

Select a physically meaningful framing configuration before making quantitative comparisons.

---

## Recommended Workflow for New Datasets

For a new experimental dataset:

1. Verify the TDMS file and sampling rate.
2. Inspect the raw time-domain signal.
3. Begin with a reasonable window length.
4. Evaluate the STFT.
5. Compare several window functions.
6. Adjust the window length to balance time and frequency resolution.
7. Adjust overlap to provide sufficient time resolution.
8. Examine several spectral descriptors.
9. Select the framing configuration that best captures the physical behavior of interest.
10. Keep those framing settings fixed.
11. Run all descriptors needed for comparison.
12. Save the settings and complete analysis.

---

## Recommended Practice for Future Modifications

Before modifying the application:

1. Preserve a known TDMS dataset.
2. Record the original analysis settings.
3. Run the original application and save its output.
4. Make one code change at a time.
5. Re-run the same dataset.
6. Compare the new output against the original results.

Particular care should be taken when modifying:

* TDMS channel selection
* sampling-rate handling
* FFT length
* window normalization
* one-sided spectrum correction
* dB reference pressure
* frequency-band boundaries
* spectral descriptor settings
* output file structure

---

## Summary

The Time-to-Frequency Domain Spectral Analysis App was developed for the Cold Spray Project as a way to investigate whether the sound generated during cold spray operation contains frequency-domain features that can be associated with changes in nozzle condition, particularly nozzle clogging.

The main processing workflow is:

Time-Domain Recording
→ Read TDMS Signal
→ Remove DC Offset
→ Select Window Function
→ Define Window Length and Overlap
→ Compute STFT
→ Examine Frequency Content Over Time
→ Divide Spectrum into Full/Low/Mid/High Frequency Bands
→ Calculate Spectral Descriptors
→ Compare Spectral Behavior
→ Investigate Features Associated with Process Changes

Although cold spray motivated its development, the application is a **general time-to-frequency-domain analysis tool** and can be adapted for other recorded time-series signals.

The application is still a work in progress. Future users are encouraged to continue developing and validating the analysis rather than treating the existing parameters or spectral descriptors as finalized.

