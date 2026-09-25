# Automated Bode 100 Sweep Acquisition in LabVIEW

## Project Purpose

This LabVIEW program was developed to automate repeated measurements with a **Bode 100** analyzer.

The main purpose of the program is to remove the need for a user to remain at the instrument and manually:

- start each sweep;
- wait for the measurement to finish;
- save each result; and
- repeat the same process over and over.

Instead, the VI configures the instrument once, repeatedly triggers measurements, retrieves the data, displays the current sweep, and saves the results automatically.

This makes the program especially useful for **long-duration testing**, where repeated measurements need to be collected over an extended period of time without continuous user interaction.

The program is intended to support automated collection of repeated frequency sweeps so that changes in the measured response can later be examined as a function of time.

---

## Main Program

The main VI is:

`BODE_AUTO_v9.vi`

The program handles:

- communication with the Bode 100 over TCP/IP;
- instrument identification;
- configuration of sweep parameters;
- repeated triggering of Bode measurements;
- collection of S21 transmission data;
- plotting of the current sweep;
- tracking of completed iterations;
- estimating sweep duration;
- queueing completed sweeps for saving;
- timestamping collected data; and
- writing the repeated measurements to a file.

---

## Software and Instrument

### Software

This program was developed in:

- **LabVIEW 2015**

Keep an untouched copy of the original VI before allowing a newer version of LabVIEW to permanently convert the file.

### Instrument

This program is intended for use with a:

- **Bode 100**

Communication is performed over a TCP/IP socket connection.

---

# General Program Workflow

At a high level, the program follows this sequence:

```text
Open TCP/IP Connection
        |
        v
Query Instrument Identification
        |
        v
Send Sweep Configuration
        |
        v
Set Triggering Behavior
        |
        v
Trigger Sweep
        |
        v
Wait for Sweep Completion
        |
        v
Request S21 Data
        |
        v
Display Current Sweep
        |
        v
Queue Sweep for Saving
        |
        v
Write Sweep + Time Information to File
        |
        v
Repeat Until Stop Is Requested
```

The goal is continuous automated acquisition rather than one manually initiated measurement at a time.

---

# Front-Panel Controls and Indicators

## `Stop Testing`

Requests that automated testing stop.

The front panel specifically warns:

> **CLICK ONLY ONCE**

Stopping is not instantaneous because the program allows the active loops to complete and the remaining collected data to be saved before execution finishes.

Do not repeatedly click the stop control.

Allow the program time to finish the current operations and save the outstanding data.

---

## `File Name for Collected Sound Data`

Provides the base name used for the saved test data.

Although the label refers to "Sound Data," this VI is collecting **Bode 100 S21 sweep data**.

Use a descriptive test name so that the output file can easily be associated with the experiment.

---

## `Path to Folder (create new folder for test)`

Specifies the folder where the test data will be saved.

The front panel indicates that a **new folder should be created for the test**.

Before beginning a long-duration measurement:

1. Create the desired test folder.
2. Select that folder in the VI.
3. Confirm that the computer has write access.
4. Confirm that sufficient storage space is available.

---

## `Start Time and Date`

Displays the time and date associated with the beginning of the automated test.

This allows the saved repeated sweeps to be related to the actual experimental timeline.

---

## TCP/IP Device Address

The communication field follows the format:

```text
TCPIP0::<IP_AD>::<PORT>:SOCKET
```

This value identifies the Bode 100 TCP/IP socket connection used by LabVIEW.

The correct IP address and port must correspond to the instrument/network configuration.

If communication cannot be established, verify the network connection and this device address before modifying the rest of the program.

---

## `Device Identification`

Displays the identification returned by the instrument after the program sends:

```text
*IDN?
```

This provides confirmation that the VI is communicating with the expected device.

---

# Sweep Configuration

## `Start Frequency (Hz)`

Sets the beginning of the frequency sweep.

The front panel notes a lower reference of:

```text
100 Hz
```

The current default shown in the VI is:

```text
1,000,000 Hz
```

---

## `End Frequency (Hz)`

Sets the end of the frequency sweep.

The front panel indicates a maximum of:

```text
40 MHz
```

The current default shown in the VI is:

```text
6,000,000 Hz
```

---

## `Number of Points`

Sets the number of frequency points included in each sweep.

The current default shown in the VI is:

```text
50
```

Increasing the number of points provides more frequency samples across the sweep, but also increases the time required for each sweep and the amount of data collected.

---

## `Receiver Bandwidth (Hz)`

Sets the receiver bandwidth used by the Bode measurement.

The current default shown in the VI is:

```text
300 Hz
```

Receiver bandwidth affects measurement behavior and sweep duration.

When comparing measurements over time, keep this setting consistent unless changing bandwidth is part of the experiment.

---

## `Source Power`

Sets the Bode 100 source power.

The front panel indicates a maximum of:

```text
13 dBm
```

The current default shown in the VI is:

```text
0 dBm
```

Use a source level appropriate for the device or sample being tested.

---

## `Measurement Type`

Defines the measurement being requested from the Bode 100.

The current program uses:

```text
S21
```

The program is therefore configured to collect **S21 transmission measurements**.

---

# Parameter Configuration

Before repeated acquisition begins, the program sends commands to configure the Bode 100.

The block diagram includes commands corresponding to:

- defining the measurement parameter;
- setting the start frequency;
- setting the stop frequency;
- setting the number of sweep points;
- selecting a linear frequency sweep;
- setting receiver bandwidth;
- setting source power; and
- setting the returned calculation format.

The program configures the sweep as a **linear sweep**.

The returned S21 data are requested in a linear format using:

```text
:CALC:FORM SLIN
```

---

## `Testing Parameters Set`

This indicator confirms that the requested test configuration has been sent to the instrument.

Verify that the desired settings are entered before starting a long-duration test.

---

# Automated Sweep Acquisition

After configuration, the program repeatedly triggers measurements.

The block diagram uses instrument commands associated with:

```text
:TRIG:SOUR BUS
:INIT:CONT ON
:TRIG:SING
*WAI
*OPC?
```

The general purpose of this sequence is to:

1. configure instrument triggering;
2. initiate a sweep;
3. wait for the operation to complete; and
4. confirm completion before retrieving the measurement data.

This prevents the program from requesting data before the sweep has finished.

---

## `Collecting Data`

Indicates that the automated acquisition process is active.

During a long-duration test, this should remain active while measurements are being repeatedly acquired.

---

## `Iterations`

Displays the number of repeated sweep iterations collected by the program.

This is useful for confirming that acquisition continues to progress during unattended testing.

---

# S21 Data Collection

After each measurement is completed, the program requests the calculated data using:

```text
:CALC:DATA:SDAT?
```

The returned values are parsed and used as the current:

**S21 Transmission Sweep**

The data represent the S21 response across the configured set of frequencies.

---

## `S21 Transmission Sweep`

The front-panel graph displays the current S21 transmission result as a function of frequency.

The horizontal axis is:

```text
Frequency (Hz)
```

The plotted sweep provides a live visual check that:

- the instrument is returning data;
- the frequency range appears correct; and
- the measured response is changing or remaining stable as expected.

For long-term automated testing, the saved dataset is the primary record, while the live graph is mainly useful for monitoring the currently acquired sweep.

---

# Approximate Sweep Time

The program calculates an approximate duration for each sweep.

The block diagram contains the relationship:

```text
T = M(1.6 + 2.84(P / RBW))
```

where the variables are associated with the sweep configuration used by the program.

The resulting value is displayed as:

`Approximate Sweep Time (s)`

This estimate is useful when planning long-duration tests because the total number of measurements that can be collected over a given period depends on how long each sweep requires.

Changing:

- number of points;
- receiver bandwidth; or
- other sweep settings

may therefore change the effective measurement rate.

---

# Saving Architecture

Acquisition and saving are handled so that completed sweeps can wait to be written without requiring the user to manually save each measurement.

The front panel includes:

`Sweeps Waiting To Be Saved`

This indicates the number of completed measurements waiting in the saving process.

For normal operation, the saving system should generally keep up with acquisition.

If this value continuously increases during a long test, data are being generated faster than they are being written.

---

# Saved Data Format

The VI contains a specific note describing the structure of the saved data file.

The first row contains the frequencies used during the Bode sweep.

The rows below it correspond to individual measurements collected over time.

Conceptually, the file is arranged as:

```text
Frequency_Hz   f1      f2      f3      ...      fN
time_1         S21     S21     S21     ...      S21
time_2         S21     S21     S21     ...      S21
time_3         S21     S21     S21     ...      S21
...            ...     ...     ...     ...      ...
```

where:

- the first row identifies the frequency associated with each column;
- the first value in each later row corresponds to the time associated with that sweep;
- each remaining value is the S21 transmission result at the corresponding frequency;
- each data row represents one complete sweep.

The block diagram includes a placeholder value:

```text
102030405
```

This is **not experimental data**.

The program note explicitly indicates that this placeholder is intended to be replaced with:

```text
Frequency_Hz
```

as the name of the first row.

---

## Time Values

The rows underneath the frequency row use time in seconds corresponding to each individual sweep.

This structure allows the dataset to be interpreted in two dimensions:

- **frequency**, across columns; and
- **measurement time**, across rows.

This is useful for long-duration testing because changes in S21 can later be examined both as a function of frequency and as a function of time.

---

# File Naming

The VI includes a timestamp format:

```text
_D%m_%d_%y_T%H_%M_%S
```

This allows saved files to contain date and time information.

Using timestamped output helps distinguish repeated tests and makes it easier to relate saved data to an experimental log.

---

# Running an Automated Test

A recommended operating sequence is:

1. Connect the Bode 100 to the computer/network.
2. Verify that the instrument is reachable.
3. Open `BODE_AUTO_v9.vi`.
4. Enter the correct TCP/IP socket address.
5. Enter the desired test name.
6. Create and select a new folder for the test.
7. Set the start frequency.
8. Set the end frequency.
9. Set the number of sweep points.
10. Set the receiver bandwidth.
11. Set the source power.
12. Verify that the measurement type is `S21`.
13. Run the VI.
14. Confirm that the instrument identification appears.
15. Confirm that `Testing Parameters Set` indicates successful configuration.
16. Confirm that `Collecting Data` becomes active.
17. Verify that the S21 graph begins updating.
18. Verify that the iteration count increases.
19. Monitor `Sweeps Waiting To Be Saved` during the beginning of the test.
20. Allow the program to continue for the desired test duration.
21. When testing is complete, click `Stop Testing` **once**.
22. Wait for the program to finish active operations and save all remaining data before closing LabVIEW.

---

# Stopping a Long-Duration Test

Stopping this VI is intentionally not immediate.

When `Stop Testing` is selected, the program still needs to allow its loops and saving operations to finish.

For this reason:

- click `Stop Testing` only once;
- do not repeatedly press the button;
- do not immediately abort the VI;
- wait for outstanding sweeps to finish saving.

Aborting the program instead of allowing it to stop normally may result in unsaved measurements.

---

# Important Considerations for Long-Duration Testing

## Confirm the Save Location Before Starting

A long-duration test can generate many sweeps.

Before beginning unattended acquisition, confirm that:

- the save path is correct;
- the folder is writable;
- sufficient disk space is available; and
- the desired test name has been entered.

---

## Verify Communication Before Leaving the Test Unattended

Do not assume that the test is running simply because the VI started.

Confirm that:

- the Bode 100 identification is returned;
- test parameters are set;
- the collecting indicator is active;
- the iteration count is increasing; and
- the S21 graph is updating.

---

## Watch the Saving Queue Initially

At the start of a long test, monitor:

`Sweeps Waiting To Be Saved`

If this value continually increases, the file-saving portion of the program may not be keeping up with measurement acquisition.

A small temporary backlog may not necessarily indicate a problem, but a continuously growing backlog should be investigated before leaving the test unattended.

---

## Do Not Change Sweep Parameters During a Dataset Unless Intended

The saved data structure assumes that all rows correspond to the frequency array stored at the top of the file.

Changing the frequency range or number of points partway through a test can make the resulting dataset difficult or invalid to interpret using that structure.

If different sweep settings are required, stop the current test and begin a new dataset.

---

## Keep Experimental Settings Documented

For each long-duration test, record the settings used, including:

- start frequency;
- end frequency;
- number of points;
- receiver bandwidth;
- source power;
- measurement type; and
- any relevant physical experimental conditions.

The saved frequency array preserves the frequency coordinates, but complete experimental documentation is still important.

---

# Troubleshooting

## No Device Identification Appears

Check:

- the Bode 100 is powered on;
- the computer and instrument are connected to the network;
- the IP address is correct;
- the port is correct;
- the TCP/IP socket string is correctly formatted; and
- no network/firewall configuration is blocking communication.

---

## Testing Parameters Are Not Set

Check the instrument connection first.

Then verify that the requested:

- start frequency;
- stop frequency;
- number of points;
- receiver bandwidth; and
- source power

are valid for the instrument and current measurement configuration.

---

## No S21 Data Are Displayed

Confirm that:

- communication with the instrument is established;
- the measurement type is `S21`;
- the instrument completes the triggered sweep;
- the collection loop is active; and
- the requested frequency range and other parameters are valid.

---

## Iteration Count Does Not Increase

If the iteration count remains fixed, the program may be waiting for:

- instrument communication;
- sweep completion;
- a trigger response; or
- an error condition.

Check the Bode 100 and communication path before changing the acquisition logic.

---

## `Sweeps Waiting To Be Saved` Continually Increases

This indicates that completed measurements are entering the saving path faster than they are being written.

Check:

- disk performance;
- available storage;
- save-folder accessibility;
- whether another process is heavily using the disk; and
- whether recent modifications added slow operations to the saving loop.

For long-duration testing, this should be resolved before leaving the test unattended.

---

## Program Takes Time to Stop

This is expected behavior.

The program is designed to allow loops to finish and outstanding data to be saved.

Click `Stop Testing` only once and allow the VI time to shut down normally.

---

# Modifying the Program

## Preserve the Automated Trigger Sequence

The purpose of this VI is repeated unattended measurement.

Changes to the trigger or waiting logic can cause:

- measurements to be requested before completion;
- incomplete data;
- repeated or missed sweeps; or
- synchronization problems.

Trace the full command sequence before changing instrument-trigger logic.

---

## Preserve Frequency/Data Alignment

The saved file assumes that each S21 value corresponds directly to one frequency stored in the first row.

If the number of points or returned data format is changed, verify that:

- the frequency array length;
- the returned S21 array length; and
- the saved row length

remain consistent.

---

## Preserve Normal Shutdown and Saving

One of the most important features of this program is that it saves outstanding measurements before finishing.

When modifying the stop logic, make sure that:

- acquisition can stop;
- queued data can still be processed;
- remaining sweeps can be saved; and
- program execution ends only after the necessary cleanup is complete.

---

# Suggested Use

This program is best suited for experiments where the same Bode measurement must be repeated many times under the same sweep configuration.

Examples include situations where the goal is to observe how a measured transmission response changes over:

- minutes;
- hours; or
- another extended experimental period.

The primary advantage of the VI is **automation**.

Instead of requiring a person to remain at the Bode 100 and repeatedly start and save measurements, the program performs the repeated measurement-and-save cycle automatically.

---

# File Summary

The current implementation consists primarily of:

```text
BODE_AUTO_v9.vi
```

The VI contains the complete:

- instrument communication;
- sweep configuration;
- repeated triggering;
- S21 acquisition;
- plotting;
- timing;
- queue monitoring; and
- file-saving workflow.

Students can inspect the block diagram directly in LabVIEW to follow the individual VISA/TCP-IP commands and dataflow.

---

# Final Notes for Students

The central purpose of this VI is straightforward:

**automate repeated Bode 100 measurements so that long-duration tests can run without requiring someone to manually start and save every sweep.**

When using or modifying the program:

- verify the Bode connection before starting;
- confirm all sweep parameters;
- use a dedicated folder for each test;
- verify that data are actively being collected;
- monitor the save queue when the test begins;
- avoid changing the sweep configuration partway through one dataset;
- stop the program using `Stop Testing`;
- click the stop control only once; and
- allow all outstanding data to save before closing the VI.

The resulting dataset is organized so that repeated S21 sweeps can later be examined as a function of both frequency and elapsed measurement time.
