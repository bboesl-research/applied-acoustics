al clear;
close all;
close all force hidden;
clc;
sampleNumber = 4; % number of samples or channel count!!!!!!!!!!!!!!!!!
sampleThickness = [6.05 5.2 5.19 5.25]; % sample thicknessess, ordered by increasing channel number (in millimeters) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
delTime = 3-0.03; % time delay to compensate for the oscilloscope clock (in hours)
perThresh = 0.1; % percentage threshold multiplier (in this code
% used to get the percentage of the maximum peak, and usually takes on values in the range 0.05-0.2)
                 % the higher this number, the less inclusive the threshold
cycleOffset = 0; % integer number of cycles to offset from the central maximum peak !!!!!!!!!!!!!!!!!!!!!!!!
samplingRate = 6.25e9; % sampling rate (in samples per second)
frequency=1.5e6; %Hz
startTime = datenum(2026,05,14,15,04,58); % start time serial date number (in days) 24hour time!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
dt = 1.0/samplingRate; % time step (in seconds)
fileType = '.wfm';
fileType_ex = '.isf';
elementNum = cycleOffset*2 + 1; % total number of elements given by the desired number of cycle offsets (twice the number of
                                % cycle offsets to account for the number of offset to the left and right of central peak, 
                                % plus the one element at the central peak)
curveNames = {'CH1','CH2','CH3','CH4'}; % container for names to dynamically assign to legend
offset = 0.05; % how much away from the marker the text should be for the coordinates

% Specify the folder where the files are located !!!!!!!!!!!!!!!!!!!!!!!!!!
myFolder = "H:\FIU_MATLAB\MAY14TEST_D05_14_26_T15_04_58_CLEAN";
% Check to make sure that folder actually exists.  Warn user if it doesn't
if ~isfolder(myFolder)
    errorMessage = sprintf(['Error: The following folder does not ' ...
        'exist:\n%s\nPlease specify a new folder.'], myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% vector of amplitudes gathered from acquired samples
baselineFile = "H:\FIU_MATLAB\1.5MHz.isf";
switch fileType_ex
case '.wfm'
    [baselineArray] = wfm3read(baselineFile);
case '.isf'
    [baselineArray] = isfread(baselineFile);
case '.csv'
    [baselineArray] = readmatrix(baselineFile);
otherwise
    [baselineArray] = wfm3read(baselineFile);
end

for j = 1 : sampleNumber

    [leftBoundary, rightBoundary] = isf_analysis_region_selection_V2 (samplingRate, frequency, sampleThickness(1,j), fileType, j, myFolder, baselineArray);

    % get a list of all files in the folder with the desired file name pattern
    filePattern = fullfile(myFolder,['*_ch' int2str(j) '_*' fileType]); 
    s = dir(filePattern); % structure array containing attributes of files

    % 's' is the struct array. 'datenum' is the field that contains the
    % serial date time1
 
    T        = struct2table(s); % convert the struct array to a table
    sortedT  = sortrows(T,'datenum'); % sort the table by 'datenum'
    theFiles = table2struct(sortedT); % change it back to struct array
    
    n = 1; % initializing indexing varibale to keep track of the peak being followed (i.e. 1st, 2nd, 3rd, etc.)
    refPeaksIndexes = zeros(elementNum); % initializing vector to store the peak index locations
    bool = 0;
    
    while n <= length(refPeaksIndexes)
        for k = length(theFiles):-1:1
            leftCycleOffset = cycleOffset; % intializing variable with the number of cycles to offset to the left...
                                           % sometimes the number of cycles to offset to the left are less than the amount that
                                           % can be offset to the right (or even non-existent), but offsets to the right, along
                                           % with the central maximum peak always exist
        
            % accesssing the name of the sample file in the structure
            baseFileName = theFiles(k).name;
            fullFileName = fullfile(theFiles(k).folder, baseFileName);
            fprintf(1, 'Now reading %s\n', fullFileName);
        
            % vector of amplitudes gathered from acquired samples
            switch fileType
            case '.wfm'
                [sampleArray] = wfm3read(fullFileName);
            case '.isf'
                [sampleArray] = isfread(fullFileName);
            case '.csv'
                [sampleArray] = readmatrix(fullFileName);
            otherwise
                [sampleArray] = wfm3read(fullFileName);
            end
            
            if (k==length(theFiles)&n==1)
                length(theFiles);
            end
            
            sampleArray(1:round(leftBoundary(1))) = 0;
            sampleArray(round(rightBoundary(1)):end) = 0;
            
       
            % cross-corraltion vector of the input and output waveforms
            crossCorr = cross_correlation(sampleArray,baselineArray);
        
            % maximum value in 'crossCorr' 
            maximum = max(crossCorr);
        
            % find the peaks above a percent threshold of the maximum peak value
            [pks,loc] = findpeaks(crossCorr,'MinPeakHeight',maximum*perThresh);

            if n == 1
                % vector containing the curing times (in days) converted to hours
                cureTime(k) = (theFiles(k).datenum - startTime)*24 - delTime;
                % optional feature: collect the amplitudes of the samples
                amplitude(k,j) = max(sampleArray);
            end

            % initializing prevIndex variable to be used in the relative
            % error calculation (relError)
            if k == length(theFiles)
                prevIndex = refPeaksIndexes(n);
                prevError = 0; % initializing previous relative error variable to 
                               % compare to the current relative error
            end
        
            if bool == 0
                % index where the maximum value of obtained peaks subset occurs
                maxSubsetIndex = find(pks==maximum);
        
                % counting the number of 'NaN' values to append to the left side of the final 'time of flight' vector
                while((maxSubsetIndex - leftCycleOffset) < 1)
                    leftCycleOffset = leftCycleOffset - 1;
                end
        
                % establish the first set of reference peak indexes to use as benchmark to
                % make up to <elementNum> running plots of the same sample (offset at each peak)
                refPeaksIndexes = loc(maxSubsetIndex-leftCycleOffset:maxSubsetIndex+cycleOffset);

                bool = 1;

                break
            end
        
            % take the relative error between previous time indexes and current ones
            for i = 1:length(loc)
                % relative percent error between the previous index position for the time of flight associated with the old highest peak, and the new one 
                relError = abs((loc(i)-prevIndex)/prevIndex)*100;
                
                if relError <= prevError
                    selectedIndex = loc(i);
                end

                prevError = relError;
            end
        
            flightTime = selectedIndex*dt;
            flightTime2 (k,j,n) = flightTime*1e6; 
            prevIndex = selectedIndex;
        
            % vector containing the speeds of sound through the sample (mm/us)
            % sample thickness divided by the flight time converted to microseconds
            speed(k,j,n) = sampleThickness(j)/(flightTime*1e6); 
        end

        if k ~= length(theFiles)
            % plot the speed versus the curing time
            figure(j)
            plot(cureTime,speed(:,j,n));
            n = n + 1;
            hold on;
        end

    end
    
    figure(j)
    hold on;
    % label the plot
    legend;
    xlabel("Cure Time (hr)");
    ylabel("Speed (mm/us)");
end

figure(sampleNumber + 1)
hold on;

% table to store final results (cureTime, speeds, and amplitudes)
results = table(cureTime',zeros(length(theFiles),sampleNumber),amplitude);
results2 = table(cureTime', flightTime2);
temp1 = zeros(length(theFiles),sampleNumber); % initializing temporary array to store speeds

figure(1);
drawnow;
for a = 1 : sampleNumber
    promptText = sprintf(['Please indicate which curve you would like to use ' ...
        'from the figure(s) by typing the corresponding number (e.g., ' ...
        'if the 3rd curve (data3) is needed type in the number 3 and ' ...
        'press enter). Curve for sample %d, figure %d:'], a, a);
    
    prompt = {promptText};
    dlgtitle = sprintf('Select Curve for Sample %d', a);
    definput = {'1'};
    field_size = [1,100];
    figure(a);
    drawnow;
    answer = inputdlg(prompt,dlgtitle,field_size,definput);
    answer = str2double(answer{1});

    if isempty(answer)
        break; %stops loop if user hits cancel
    end

    figure(sampleNumber + 1)
    plot(cureTime,speed(:,a,answer));
    legend(curveNames(1:a));

    temp1(:,a) = speed(:,a,answer);
end

results{:,2} = temp1;
results = renamevars(results,["Var1","Var2","amplitude"],["Cure Time (hr)","Speed (mm/us)","Magnitude (V)"]);

hold off;
% label the plot
xlabel("Cure Time (hr)");
ylabel("Speed (mm/us)");

