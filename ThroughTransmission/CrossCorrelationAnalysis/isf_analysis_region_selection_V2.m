function [leftBoundary, rightBoundary] = isf_analysis_region_selection_V2 (samplingRate, frequency, sampleThickness, fileType, sampleNumber, myFolder, baselineArray)

go = 0;
while go == 0

    % samplingRate = 2.50e9; % sampling rate (in samples per second) %from main code
    dt = 1.0/samplingRate; % time step (in seconds)
    %frequency = 1.5e6;%Hz %from main code
    numberofCycles=5; %from main code
    %sampleThickness = 6; %from main code
    excitationTime = (numberofCycles/frequency)*1e6;
    minSSaccepted = 1;
    maxDelayAccepted = sampleThickness/minSSaccepted;
    
    %fileType = '.isf';
    %sampleNumber = 1;
    
    promptText = sprintf(['To create analysis region, input the number ' ...
        '(positve whole even number) of evenly time spaced divisions you would ' ...
        'like to display for analysis window selection']); 
    prompt = {promptText};
    dlgtitle = sprintf('Select Number of Divisions');
    definput = {'2'};
    field_size = [1, 100];
    answer = inputdlg(prompt,dlgtitle,field_size,definput);
    divNum = str2double(answer{1});
    while ~(divNum>0 && mod(divNum,1)==0 && mod(divNum,2)==0)
        promptText = sprintf('Selection invalid, try again. Enter a positive whole even number.'); 
        prompt = {promptText};
        dlgtitle = sprintf('Select Number of Divisions');
        definput = {'2'};
        field_size = [1, 100];
        answer = inputdlg(prompt,dlgtitle,field_size,definput);
        divNum =str2double(answer{1});
    end
   
    j = sampleNumber;
    % get a list of all files in the folder with the desired file name pattern
    filePattern = fullfile(myFolder,['*_ch' int2str(j) '_*' fileType]);
    s = dir(filePattern); % structure array containing attributes of files
    
    % 's' is the struct array. 'datenum' is the field that contains the
    % serial date time1
    
    T        = struct2table(s); % convert the struct array to a table
    sortedT  = sortrows(T,'datenum'); % sort the table by 'datenum'
    theFiles = table2struct(sortedT); % change it back to struct array
    
    testNumDiv = round(linspace(1,length(theFiles),divNum));
    
    figNum = 10+j;
    figure(figNum);
    hold on
    tiledlayout(length(testNumDiv)/2,2);
    
    
    for i = length(testNumDiv):-1:1
    
        for k = testNumDiv(1,i)
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
                [sampleArray] = wfm2read(fullFileName);
            end
            
            nexttile(i)
            plot(sampleArray)
            hold on;
            grid on
            grid minor
            title("Channel " + j + ". File " + k)
            
        end
            
    end
    
    promptText = sprintf(['Please indicate index of the end of the front-end' ...
        ' noise Figure %d. Enter a positive whole number.'], figNum);
    prompt = {promptText};
    dlgtitle = sprintf('Index for End of Front-End Noise');
    definput = {'1'};
    file_size = [1,100];

    answer = inputdlg(prompt,dlgtitle,file_size,definput);
    front_end_noise = str2double(answer{1});

    while ~(front_end_noise>0 && mod(front_end_noise,1)==0)
        
        promptText = sprintf('Selection invalid, try again. Enter a positive whole number');
        prompt = {promptText};
        dlgtitle = sprintf('Index for End of Front-End Noise');
        definput = {'1'};
        file_size = [1,100];
    
        answer = inputdlg(prompt,dlgtitle,file_size,definput);
        front_end_noise = str2double(answer{1});
        
    end
    
    for i = length(testNumDiv):-1:1
    
        for k = testNumDiv(1,i)
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
                [sampleArray] = wfm2read(fullFileName);
            end
            
            sampleArray(1:front_end_noise) = 0;
            nexttile(i)
            plot(sampleArray)
            hold on;
            title("Channel " + j + ". File " + k)
    
        end
    
    end   
    
    promptText = sprintf(['Select treshold of peak finder (0.0 < threshold < 1.0). ' ...
        'Example: 0.7 includes peaks that are 70 percent of the max peak.']);
    prompt = {promptText};
    dlgtitle = sprintf("Threshold");
    definput = {'0.7'};
    field_size = [1,100];
    answer = inputdlg(prompt,dlgtitle,field_size,definput);
    thresholdSample = str2double(answer{1});

    while ~(thresholdSample>0 && thresholdSample<1)
        promptText = sprintf('Selection invalid, try again. 0.0 < threshold < 1.0.');
        prompt{promptText};
        dlgtitle = sprintf("Threshold");
        definput = '{0.7}';
        field_size = [1,100];
        answer = inputdlg(prompt,dlgtitle,field_size,definput);
        thresholdSample = str2double(answer{1});
    end
    
    for i = length(testNumDiv):-1:1
    
        for k = testNumDiv(1,i)
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
                [sampleArray] = wfm2read(fullFileName);
            end
    
            sampleArray(1:front_end_noise) = 0;
            maximumS=max(sampleArray);
            [pksS, locS] = findpeaks(sampleArray, 'MinPeakHeight', maximumS*thresholdSample);
            nexttile(i)
            plot(locS,pksS,'or');
            hold on;
            title("Channel " + j + ". File " + k)
    
        end
    
    end
    
    for i = length(testNumDiv):-1:1
    
        for k = testNumDiv(1,i)
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
                [sampleArray] = wfm2read(fullFileName);
            end
    
            sampleArray(1:front_end_noise) = 0;
            maximumS=max(sampleArray);
            [pksS, locS] = findpeaks(sampleArray, 'MinPeakHeight', maximumS*thresholdSample);
    
            delayTimeS = (locS-1)*dt*1e6;
            delayTimeMatrixS = [delayTimeS, locS, locS-1];
            delayTimeMatrixScleaned = delayTimeMatrixS;
            delayTimeMatrixScleaned(1,1)=NaN;
            [jS,ignoreS] = size(delayTimeS);
            threshold=0.25;
            
            for f=2:1:jS
                percentDiff = (delayTimeMatrixS(f,2)-delayTimeMatrixS(f-1,2))/((delayTimeMatrixS(f,2)+delayTimeMatrixS(f-1,2))/2);
                if percentDiff>threshold
                    delayTimeMatrixScleaned(f,1)=NaN;
                end
            end
            
            [boundary, ignoreC] = find(isnan(delayTimeMatrixScleaned));
            [countR, ignoreC] = size(boundary);
            
            cutOffLeftInBoundary = [1];
            cutOffRightInBoundary = [];
            for g=2:1:countR
            
            
                timeD = delayTimeMatrixS(boundary(g-1,1),1);
                if timeD<excitationTime
                    cutOffLeftInBoundary(end+1,1) = g;
                elseif timeD>maxDelayAccepted
                    cutOffRightInBoundary(end+1,1) = g;
            
                end
            
            end
            
            cutOffLeftInBoundaryIndex = max(cutOffLeftInBoundary);
            mainPoint = delayTimeMatrixS(boundary(cutOffLeftInBoundaryIndex,1),2);
            
            leftToleranceDT = 1;
            leftToleranceDP = leftToleranceDT*samplingRate*1e-6;
            leftBoundary = round(mainPoint - leftToleranceDP);
            rightBoundaryDT = 1.75;
            rightBoundaryDP = rightBoundaryDT*samplingRate*1e-6;
            rightBoundary = round(mainPoint + rightBoundaryDP);
            
            sampleArray(1:leftBoundary) = 0;
            sampleArray(rightBoundary:end) = 0;
    
            nexttile(i)
            plot(sampleArray);
            title("Channel " + j + ". File " + k)
            % cross-corraltion vector of the input and output waveforms
            crossCorr = cross_correlation(sampleArray,baselineArray);
            
            % maximum value in 'crossCorr' 
            maximum = max(crossCorr); % comment this out in the case of shear data
            
            % time of flight (in microseconds)
            maxIDXval = find(crossCorr==maximum);
            maxIDX = max(maxIDXval);
            flightTime = maxIDX*dt*1e6;
            distance = 6;
            soundspeed(i,2) = distance/flightTime;
            soundspeed(i,1) = k;
            
            hold on
        end
    
    end
    myTable = array2table(soundspeed, 'VariableNames', {'File Number', 'Sound Speed (mm/us)'});
    fig = uifigure("Name","Preliminary Sound Speed Values");
    fig.Position(1:2) = [1500,500];
    fig.Position(3:4) = [350,300];
    uit = uitable(fig, 'Data', myTable);
    uit.Position = [1 1 350 300]; % Adjust size and location

    promptText = sprintf(['Verify analysis region selection and preliminary sound speed values. ' ...
        '1 for YES || 0 for NO (selection process will restart)']);
    prompt = {promptText};
    dlgtitle = sprintf('Verify Analysis Region');
    definput = {'1'};
    field_size = [1,100];
    answer = inputdlg(prompt,dlgtitle,field_size,definput);
    go=str2double(answer{1});

    while go~=1 && go~=0
        promptText = sprintf(['Selection invalid, try again. ' ...
        '1 for YES || 0 for NO (selection process will restart)']);
        prompt = {promptText};
        dlgtitle = sprintf('Verify Analysis Region');
        definput = {'1'};
        field_size = [1,100];
        answer = inputdlg(prompt,dlgtitle,field_size,definput);
        go=str2double(answer{1});
    end
    
end
