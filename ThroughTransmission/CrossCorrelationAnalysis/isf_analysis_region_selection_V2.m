function [leftBoundary, rightBoundary] = isf_analysis_region_selection_V2 (samplingRate, frequency, sampleThickness, fileType, sampleNumber, myFolder, baselineArray)
%ISF_ANALYSIS_REGION_SELECTION_V2 Select the end of front-end noise only.
%
% This version preserves the useful diagnostic workflow from the original:
%   1) choose how many evenly spaced files to inspect,
%   2) inspect representative raw waveforms,
%   3) choose the end of the front-end noise,
%   4) preview representative waveforms with ONLY that front-end removed,
%   5) display preliminary sound-speed values using the established
%      cross-correlation convention,
%   6) accept the selection or repeat it.
%
% IMPORTANT: No automatic left boundary and no right boundary are calculated.
% The selected front-end-noise index is the only cutoff. Everything after it
% is preserved for the established cross-correlation analysis.
%
% The original function signature is preserved so the existing app can call
% this function without changing the established cross-correlation logic.

    %#ok<INUSD> % frequency retained for compatibility with the existing app

    j = sampleNumber;
    dt = 1.0 / samplingRate;

    % Find and sort files for this channel.
    filePattern = fullfile(myFolder, ['*_ch' int2str(j) '_*' fileType]);
    s = dir(filePattern);

    if isempty(s)
        error('No %s files were found for Channel %d in %s.', fileType, j, myFolder);
    end

    T = struct2table(s);
    sortedT = sortrows(T, 'datenum');
    theFiles = table2struct(sortedT);

    go = 0;

    while go == 0
        %% Choose how many evenly spaced files to inspect
        promptText = sprintf(['To inspect the data across the run, enter the number ' ...
            '(positive whole even number) of evenly spaced files you would like ' ...
            'to display for Channel %d.'], j);
        prompt = {promptText};
        dlgtitle = sprintf('Select Number of Divisions - Channel %d', j);
        definput = {'4'};
        field_size = [1, 100];

        answer = inputdlg(prompt, dlgtitle, field_size, definput);
        if isempty(answer)
            error('Analysis-region selection was cancelled by the user.');
        end
        divNum = str2double(answer{1});

        while ~(isfinite(divNum) && divNum > 0 && mod(divNum,1) == 0 && mod(divNum,2) == 0)
            answer = inputdlg({'Enter a positive whole even number.'}, ...
                dlgtitle, field_size, definput);
            if isempty(answer)
                error('Analysis-region selection was cancelled by the user.');
            end
            divNum = str2double(answer{1});
        end

        % Evenly spaced representative file indices. UNIQUE prevents duplicate
        % indices if the requested number exceeds the available distinct files.
        testNumDiv = unique(round(linspace(1, length(theFiles), divNum)), 'stable');

        %% Show representative raw waveforms
        figNum = 10 + j;
        figure(figNum);
        clf;
        tiledlayout(ceil(length(testNumDiv)/2), 2);

        for i = 1:length(testNumDiv)
            k = testNumDiv(i);
            fullFileName = fullfile(theFiles(k).folder, theFiles(k).name);
            fprintf(1, 'Now reading %s\n', fullFileName);

            sampleArray = readWaveform(fullFileName, fileType);

            nexttile;
            plot(sampleArray);
            grid on;
            grid minor;
            title("Channel " + j + ". File " + k + " - Raw");
            xlabel('Sample index');
            ylabel('Amplitude');
        end

        %% User selects the ONLY boundary: end of front-end noise
        promptText = sprintf(['Please indicate the index where the front-end noise ends ' ...
            'for Channel %d. Everything AFTER this index will be preserved.'], j);
        prompt = {promptText};
        dlgtitle = sprintf('End of Front-End Noise - Channel %d', j);
        definput = {'1'};
        field_size = [1, 100];

        answer = inputdlg(prompt, dlgtitle, field_size, definput);
        if isempty(answer)
            error('Analysis-region selection was cancelled by the user.');
        end
        leftBoundary = str2double(answer{1});

        while ~(isfinite(leftBoundary) && leftBoundary >= 0 && mod(leftBoundary,1) == 0)
            answer = inputdlg({'Enter a non-negative whole-number sample index.'}, ...
                dlgtitle, field_size, definput);
            if isempty(answer)
                error('Analysis-region selection was cancelled by the user.');
            end
            leftBoundary = str2double(answer{1});
        end

        % Clamp to the waveform length so an accidental oversized entry cannot
        % index beyond the data.
        firstFileName = fullfile(theFiles(1).folder, theFiles(1).name);
        firstArray = readWaveform(firstFileName, fileType);
        leftBoundary = min(round(leftBoundary), length(firstArray));

        %% Preview representative waveforms with ONLY front-end noise removed
        previewFigNum = 100 + figNum;
        figure(previewFigNum);
        clf;
        tiledlayout(ceil(length(testNumDiv)/2), 2);

        %% Preliminary sound speed values (diagnostic only)
        soundspeed = nan(length(testNumDiv), 2);

        for i = 1:length(testNumDiv)
            k = testNumDiv(i);
            fullFileName = fullfile(theFiles(k).folder, theFiles(k).name);
            sampleArray = readWaveform(fullFileName, fileType);

            % ONLY preprocessing operation: remove the selected front-end noise.
            if leftBoundary > 0
                sampleArray(1:leftBoundary) = 0;
            end

            nexttile;
            plot(sampleArray);
            grid on;
            grid minor;
            title("Channel " + j + ". File " + k + " - Front-End Removed");
            xlabel('Sample index');
            ylabel('Amplitude');

            % Use the established cross-correlation function and the same
            % positive-maximum/index convention used by the existing analysis.
            crossCorr = cross_correlation(sampleArray, baselineArray);
            maximum = max(crossCorr);
            maxIDXval = find(crossCorr == maximum);

            if isempty(maxIDXval)
                prelimSpeed = NaN;
            else
                maxIDX = max(maxIDXval);
                flightTime_us = maxIDX * dt * 1e6;

                if flightTime_us > 0
                    prelimSpeed = sampleThickness / flightTime_us;
                else
                    prelimSpeed = NaN;
                end
            end

            soundspeed(i,1) = k;
            soundspeed(i,2) = prelimSpeed;
        end

        %% Display preliminary sound-speed table
        myTable = array2table(soundspeed, ...
            'VariableNames', {'File Number', 'Sound Speed (mm/us)'});

        tableFig = uifigure('Name', sprintf('Preliminary Sound Speed Values - Channel %d', j));
        tableFig.Position(1:2) = [1200, 450];
        tableFig.Position(3:4) = [380, 320];
        uit = uitable(tableFig, 'Data', myTable);
        uit.Position = [1 1 380 320];

        %% Let user accept the front-end selection or repeat
        promptText = sprintf(['Verify the front-end-noise cutoff and preliminary sound-speed values for Channel %d. ' ...
            '1 for YES || 0 for NO (selection process will restart).'], j);
        prompt = {promptText};
        dlgtitle = sprintf('Verify Front-End Selection - Channel %d', j);
        definput = {'1'};
        field_size = [1, 100];

        answer = inputdlg(prompt, dlgtitle, field_size, definput);
        if isempty(answer)
            if isvalid(tableFig)
                close(tableFig);
            end
            error('Analysis-region selection was cancelled by the user.');
        end
        go = str2double(answer{1});

        while ~(go == 0 || go == 1)
            answer = inputdlg({'Enter 1 for YES or 0 for NO.'}, ...
                dlgtitle, field_size, definput);
            if isempty(answer)
                if isvalid(tableFig)
                    close(tableFig);
                end
                error('Analysis-region selection was cancelled by the user.');
            end
            go = str2double(answer{1});
        end

        if isvalid(tableFig)
            close(tableFig);
        end
    end

    % Preserve the old two-output interface. There is deliberately no right
    % cutoff. The app should preserve every sample after leftBoundary.
    rightBoundary = Inf;

end


function sampleArray = readWaveform(fullFileName, fileType)
%READWAVEFORM Local helper to keep the file-reading behavior consistent.

    switch fileType
        case '.wfm'
            sampleArray = wfm3read(fullFileName);
        case '.isf'
            sampleArray = isfread(fullFileName);
        case '.csv'
            sampleArray = readmatrix(fullFileName);
        otherwise
            sampleArray = wfm3read(fullFileName);
    end

end
