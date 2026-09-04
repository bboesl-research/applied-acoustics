# Cross-Correlation App for Through-Transmission Ultrasonic Data

## Overview

This MATLAB App Designer program processes ultrasonic through-transmission data collected using a function generator and oscilloscope setup. The main goal of the app is to estimate ultrasonic time of flight and speed of sound through one or more samples by cross-correlating the measured transmitted waveform with a reference excitation waveform.

The app was developed for laboratory datasets in which multiple oscilloscope waveform files are collected over time for up to four channels/samples.

A major part of the workflow is the removal of front-end noise and restriction of the waveform to the region containing the transmitted ultrasonic signal before cross-correlation is performed. This prevents large noise or electrical artifacts at the beginning of the waveform from dominating the correlation result.

The app also contains a data-cleaning step that ensures all channels contain matching test numbers before analysis.

## Files Included

**CrossCorrelationApp.mlapp**
Main MATLAB App Designer application.

**cross_correlation.m**
Computes the cross-correlation between a sample waveform and the baseline/excitation waveform. The full `xcorr` result is truncated so the returned vector has the same length as the input waveform.

**file_number_cleaning.m**
Compares the test numbers available in each channel. If a test number is missing from any channel, that test is removed from all channels in a copied clean dataset so that the channels remain aligned.

**isf_analysis_region_selection_V2.m**
Interactive routine used to determine the waveform region that should be analyzed. It allows the user to identify the end of the front-end noise, applies peak detection, estimates a usable signal window, and displays preliminary sound-speed values for verification.

**isfread.m**
Reads Tektronix `.isf` waveform files.

**wfm3read.m**
Reads Tektronix `.wfm` waveform files. This is a modified version of `wfm2read` with more robust handling of NULL-terminated metadata fields.

**crosscorr_parseV3.m**
Script/development version of the cross-correlation analysis workflow. The App Designer program contains the primary user interface.

## MATLAB Requirements

The app was last saved using MATLAB R2026a Update 4.

The `.mlapp` metadata indicates a minimum supported MATLAB release of R2018a, although the app has primarily been used and tested in newer MATLAB releases.

The Signal Processing Toolbox is required because the analysis uses functions including:

* `xcorr`
* `findpeaks`

## Supported Data

The app interface currently supports Tektronix:

* `.isf`
* `.wfm`

The underlying analysis code also contains support for `.csv` files through `readmatrix`, although `.csv` is not currently offered in the App Designer file-type dropdown menus.

## Expected File Organization and Naming

Collected waveform files are expected to contain the channel number and test number in the filename.

The analysis searches for files using patterns similar to:

`*_ch1_*.isf`
`*_ch2_*.isf`
`*_ch3_*.isf`
`*_ch4_*.isf`

or the equivalent `.wfm` pattern.

The file-cleaning routine expects the test number to appear at the end of the filename immediately before the extension.

For example:

`waveform_ch1_1.isf`
`waveform_ch2_1.isf`
`waveform_ch1_2.isf`
`waveform_ch2_2.isf`

In this example, `1` and `2` are the test numbers.

Files are also sorted by their filesystem date/time during processing.

## General Workflow

1. Collect through-transmission ultrasonic data using the function generator and oscilloscope.
2. Save the excitation/reference waveform.
3. Save the measured transmitted waveforms for each sample/channel.
4. Create an empty folder that will store the cleaned copy of the raw data.
5. Create a folder that will store the final results.
6. Open `CrossCorrelationApp.mlapp` in MATLAB.
7. Enter the raw-data folder, clean-data folder, excitation file, and results folder.
8. Enter the experiment/sample information:

   * Number of samples/channels, maximum 4
   * Thickness of each sample in millimeters
   * Test start date and time
   * Excitation frequency in Hz
   * Oscilloscope sampling rate in samples/second
   * Cycle offset
9. Verify all entries before selecting **Start Data Processing**.
10. The app first cleans the dataset so every analyzed channel contains matching test numbers.
11. For each channel, the app opens an interactive analysis-region-selection procedure.
12. Follow the prompts to identify the usable portion of the waveform and verify the preliminary sound-speed results.
13. The app performs cross-correlation, follows the selected correlation peak through the dataset, calculates time of flight and sound speed, and plots sound speed versus cure/test time.
14. If multiple candidate correlation peaks are being tracked, select the curve that represents the physically correct result when prompted.
15. Final data are written to `Results.csv` in the Results Folder specified in the app.

## Front-End Noise Removal and Analysis Window

This is an important part of the program.

Oscilloscope through-transmission recordings can contain a large electrical artifact or other front-end noise near the beginning of the acquisition. If this region is included without restriction, the noise may produce a stronger correlation response than the actual transmitted ultrasonic signal.

The analysis-region routine therefore asks the user to identify the index corresponding to the end of the front-end noise.

The program then:

1. Sets the waveform values from the beginning of the record through the selected front-end-noise index to zero.
2. Uses peak detection on the remaining waveform.
3. Uses the excitation frequency, sample thickness, sampling rate, and expected propagation behavior to estimate the region containing the transmitted signal.
4. Defines a left and right analysis boundary around the selected signal region.
5. Sets all waveform values outside those boundaries to zero.
6. Displays the resulting waveform and preliminary sound-speed values.
7. Asks the user to verify the region. If rejected, the region-selection procedure restarts.

This step is intended to isolate the physically meaningful transmitted ultrasonic signal before cross-correlation.

## Cross-Correlation Method

For each cleaned sample waveform, the app calculates:

`xcorr(sample waveform, excitation/reference waveform)`

The correlation vector is then truncated to retain the non-negative-lag portion with the same number of points as the original waveform.

Peaks in the cross-correlation are identified using a threshold equal to a percentage of the maximum correlation peak.

The current threshold in the app code is:

`perThresh = 0.1`

Therefore, correlation peaks must be at least 10% of the maximum correlation value to be considered.

The app tracks the selected peak between successive measurements rather than independently selecting an unrelated peak in every waveform. This is useful when several correlation peaks occur because of the periodic nature of an ultrasonic waveform.

## Cycle Offset

The Cycle Offset setting allows nearby correlation peaks to be evaluated in addition to the central maximum peak.

Available app settings are:

* 0
* 1
* 2

**Cycle Offset = 0**
Tracks only the central correlation peak.

**Cycle Offset = 1**
Allows analysis of the central peak and neighboring cycle peaks.

**Cycle Offset = 2**
Allows a wider set of neighboring correlation peaks.

When multiple candidate curves are generated, the app plots them and asks the user which curve should be retained for each sample.

The correct curve should be selected based on physical reasonableness, continuity, and knowledge of the experimental setup.

## Time of Flight and Sound Speed

Once a correlation-peak index is selected:

`time of flight = selected correlation index / sampling rate`

The program reports time of flight internally in microseconds.

Sound speed is calculated from:

`sound speed = sample thickness / time of flight`

where:

* sample thickness is entered in millimeters
* time of flight is converted to microseconds

The resulting speed is therefore reported in:

`mm/us`

Numerically, `mm/us` is equivalent to `km/s`.

## Output

The app generates plots of:

**Sound Speed (mm/us) vs. Cure Time (hr)**

for each sample/channel, as well as a final combined figure using the user-selected correlation curve.

The final CSV file is saved as:

`Results.csv`

The output includes:

* Cure Time (hr)
* Speed (mm/us)
* Magnitude (V)

for the analyzed channels/samples.

## Data-Cleaning Behavior

The analysis assumes measurements from different channels were acquired together and should therefore have matching test numbers.

Occasionally, an oscilloscope save may lag or fail, resulting in a missing waveform for one channel.

For example:

Channel 1: tests 1, 2, 3, 4, 5
Channel 2: tests 1, 2, 4, 5

Test 3 cannot be compared consistently across all channels.

`file_number_cleaning.m` therefore:

1. Reads the test numbers for every channel.
2. Identifies test numbers missing from one or more channels.
3. Copies the raw data folder to the specified clean-data folder.
4. Deletes the mismatched test numbers from all channels in the copied folder.
5. Performs the analysis only on the aligned clean dataset.

The original raw-data folder is not intentionally modified by this routine. Always retain the raw experimental data separately.

## Important: Oscilloscope Clock/Time Correction

The current app contains the following hard-coded time correction:

`delTime = 3 - 0.03`

which corresponds to:

`2.97 hours`

Cure time is calculated using the file timestamp and experiment start time, followed by subtraction of this 2.97-hour correction.

This correction was included to compensate for the oscilloscope clock used during development/testing.

Future users should verify whether this correction is still appropriate for their oscilloscope and computer setup.

If the oscilloscope clock is synchronized correctly, or if a different time offset exists, this value should be changed in the app code before relying on the calculated cure times.

Search for:

`delTime`

inside `CrossCorrelationApp.mlapp`.

## Important Assumptions and Limitations

* Maximum number of samples/channels in the current GUI is 4.

* Sample thickness must be entered in millimeters.

* Sampling rate must be entered in samples/second.

* Frequency must be entered in Hz.

* Test start time uses a 24-hour clock.

* The start time can often be obtained from the experimental folder name.

* The analysis assumes that the transmitted signal appears after the initial front-end noise and within a physically reasonable delay based on the sample thickness.

* The region-selection function currently assumes five excitation cycles when estimating excitation duration:

  `numberofCycles = 5`

* If a substantially different excitation waveform is used, this assumption should be reviewed.

* The region-selection routine currently uses:

  `minSSaccepted = 1`

  corresponding to a minimum expected sound speed of approximately 1 mm/us when estimating the maximum acceptable delay.

* The analysis window currently uses fixed time tolerances around the detected signal region:

  * approximately 1 us before the selected point
  * approximately 1.75 us after the selected point

  These values may need adjustment for substantially different frequencies, pulse lengths, materials, or acquisition settings.

* The preliminary sound-speed display inside `isf_analysis_region_selection_V2.m` contains a hard-coded distance value of:

  `distance = 6`

  This is used only for the preliminary verification table. Future users should verify this value if sample thickness differs significantly from 6 mm. The main final sound-speed calculation uses the sample thickness entered in the app.

* The program depends strongly on consistent file naming.

* Do not overwrite or work directly from the only copy of raw experimental data.

## Troubleshooting

**No files found for a channel**
Check that the selected file type matches the files and that filenames contain `_chN_`, where `N` is the channel number.

**File-number-cleaning errors**
Verify that filenames end in an underscore followed by the numeric test number before the extension.

Example:

`waveform_ch1_15.isf`

**Incorrect cure times**
Verify the entered test start date/time and check the hard-coded `delTime = 2.97` hour correction.

**Unreasonable sound speed**
Check:

* sample thickness
* sampling rate
* excitation frequency
* selected analysis region
* selected correlation curve/cycle
* whether the front-end noise was correctly excluded

**Correlation follows the wrong cycle**
Try a different Cycle Offset and select the physically reasonable continuous curve when prompted.

**Early noise dominates the result**
Repeat the analysis-region selection and make sure the selected end-of-front-end-noise index is after the initial electrical/noise artifact but before the transmitted ultrasonic signal.

**.wfm file does not read correctly**
`wfm3read.m` was developed for Tektronix waveform formats. Compatibility may vary between oscilloscope families or firmware/file-format versions.

## Recommended Practice for Future Modifications

Before modifying the analysis:

1. Preserve a known dataset with a known-good result.
2. Run the original version and save the output.
3. Make one change at a time.
4. Re-run the known dataset.
5. Compare sound speed, time of flight, selected peaks, and analysis windows against the original result.

This is especially important when modifying:

* front-end-noise handling
* peak thresholds
* analysis-window limits
* cycle-offset logic
* sampling-rate assumptions
* clock/time corrections

## Summary

The Cross-Correlation App is intended to convert repeated through-transmission oscilloscope measurements into time-of-flight and sound-speed data.

The main processing sequence is:

Raw waveform files
→ Align test numbers across channels
→ Remove/zero front-end noise
→ Select transmitted-signal analysis region
→ Cross-correlate sample waveform with excitation waveform
→ Track correlation peak through successive measurements
→ Calculate time of flight
→ Calculate sound speed
→ Plot results and save `Results.csv`

When using this program with a new experimental configuration, do not assume that the hard-coded timing correction, signal-window tolerances, five-cycle excitation assumption, or preliminary 6-mm distance are appropriate without verification.

