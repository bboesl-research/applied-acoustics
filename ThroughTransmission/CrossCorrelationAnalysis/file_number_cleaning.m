function file_number_cleaning(myFolder,cleanFolder,fileType,sampleNumber)
    %% FILE_NUMBER_CLEANING
    %% What is the purpose of this code:
    %  Sometimes the number of tests in each channel are not the same due to
    % lagging saves, etc. and when that happens, the crosscorr_parse program
    % throws and error because it needs the number of tests to be the same as
    % the tests were actually run alongside eachother, so this code aligns the
    % number of test
    % data cleaning code to read the files in the folder, compare the number of
    % tests in that folder, and list the tests that each sample does not have, 
    % aka if 1 2 3 6 7 8 9 then the program will say test 4 and 5 are missing.
    % This is used to remove those files from each of the respective channels
    % to align the number of tests
    
    sampleNumberMatrix =[];
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
    
    testNumber = {};
    for j = 1 : sampleNumber
        % Explination:
        % going through the files in the folder and pulling out the pattern to
        % creat a structure array with all the attributes of the file name,
        % then it moves it into a table to sort the files by the date, and then
        % converts it back to the structure array to have all the files
        filePattern = fullfile(myFolder,['*_ch' int2str(j) '_*' fileType]); 
        s = dir(filePattern); % structure array containing attributes of files
        T        = struct2table(s); % convert the struct array to a table
        sortedT  = sortrows(T,'datenum'); % sort the table by 'datenum'
        theFiles = table2struct(sortedT); % change it back to struct array
        % Explination:
        % pulling each of the files with base file name and the full file name,
        % and it is also pulling the test number for all the files and
        % organizing them into a cell array for each of the channels
        lengthFiles=length(theFiles);
        
        for k = length(theFiles):-1:1
            
            % accesssing the name of the sample file in the structure
            baseFileName = theFiles(k).name;
            fullFileName = fullfile(theFiles(k).folder, baseFileName);
            fprintf(1, 'Pulling file %s\n', fullFileName);
    
            tokens = regexp(baseFileName, ['_(\d+)' regexptranslate('escape', fileType) '$'], 'tokens');
            if isempty(tokens)
                fprintf('Pattern not matching: %s\n', baseFileName);
            else
                Number = str2double(tokens{1}{1});
                testNumber (k,j) = {Number};
            end
    
        end
    end
    
    %% Explination:
    %find the maximum test number seen in all the files in the folder and
    %comparing it to the maxamium number of rows in each individual channel, if
    %the max number of tests is bigger than the max number of rows, itll make
    %the max number of rows equal to the max number of tests, anything else max
    %number of rows stays the same. Then when it has that final max number of
    %rows, itll look to see when the max number of rows for all channels is
    %different from the max number of rows in an indivdual channel, it knows
    %that there are missing files and it starts to create a matrix that will
    %leave as 0 the missing files in each channel and move the test number to
    %the equivalent row number for that channel. This is all needed to
    %eventually pull out what a matrix that is of equal dimensions and can be
    %used to access the test number and delete the files that do not match
    %across all channels
    maxLoc = 0;
    maxTest = 0;
    perChannelMatrix = [];
    fullMatrix = [];
    for j = 1 : sampleNumber
        perChannelMatrix = cell2mat(testNumber(:,j));
        maxTestNumber = max(perChannelMatrix);
        [maxLocInLoop,columnN] = size(perChannelMatrix);
    
        if maxTestNumber>maxLoc
            maxLoc=maxTestNumber;
        else
            maxLoc=maxLoc;
        end
    
        if maxLocInLoop ~= maxLoc
            for k = 1 : maxLocInLoop
                if perChannelMatrix(k,1) == k
                    fullMatrix(k,j)=k;
                else 
                    perChannelMatrix(k,1);
                    fullMatrix(perChannelMatrix(k,1),j) = perChannelMatrix(k,1);
                end
            end
        else
            fullMatrix(:,j)=perChannelMatrix;
        end
    
        perChannelMatrix = [];
    
    end
    
    %% Explination:
    % starts by copying the initial raw data file to another clean data folder 
    % to preserve the raw data. Then it uses the matrix that we created before
    % to find where the test numbers equal zero, make a list of unique file
    % numbers associated with the test number equal to zero and uses that to
    % build a structure like the one from above with all the attributes for the
    % file and goes through all the channels and all the test numbers that are
    % equal to zero. from here it deletes the files from the structure it just
    % built, so you are left with the clean folder, at the end it lists the
    % tests that were kept along with their file name and where you can access
    % the clean folder
    copyfile(myFolder,cleanFolder)
    fprintf('\n<strong>Folder %s copied to Folder %s</strong>\n\n',myFolder,cleanFolder)
    fprintf('<strong>Now working only on Folder %s</strong>\n\n',cleanFolder)
    fprintf('<strong>Missing files from folder across all channels:</strong>\n')
    [fileNum, channel] = find(fullMatrix == 0);
    fileNumUni = unique(fileNum);
    missingFiles = [];
    missingFiles(1:length(fileNum), 1:2) = [channel, fileNum];
    missingFilesTable = array2table(missingFiles, 'VariableNames', {'Channel', 'File Number'});
    disp(missingFilesTable)
    fprintf('<strong>Cleaning folder for analysis... deleting missing file numbers from all channels...</strong>\n\n')
    for j = 1 : sampleNumber
        for k = 1:length(fileNumUni)
    
                filePattern = fullfile(cleanFolder,sprintf('*_ch%d_%d%s', j, fileNumUni(k,1), fileType)); 
                s = dir(filePattern); % structure array containing attributes of files
                T        = struct2table(s); % convert the struct array to a table
                sortedT  = sortrows(T,'datenum'); % sort the table by 'datenum'
                theFiles = table2struct(sortedT); % change it back to struct array
       
                for m = length(theFiles):-1:1
                    % accesssing the name of the sample file in the structure
                    baseFileName = theFiles(m).name;
                    fullFileName = fullfile(theFiles(m).folder, baseFileName);
                    fprintf(1, 'Deleting file %s\n', fullFileName);
                    delete(fullFileName);
                end
        end
    end
    
    testNumberClean = {};
    for j = 1 : sampleNumber
    
        filePattern = fullfile(cleanFolder,['*_ch' int2str(j) '_*' fileType]); 
        s = dir(filePattern); % structure array containing attributes of files
        T        = struct2table(s); % convert the struct array to a table
        sortedT  = sortrows(T,'datenum'); % sort the table by 'datenum'
        theFiles = table2struct(sortedT); % change it back to struct array
    
        lengthFiles=length(theFiles);
        
        fprintf('\n\n<strong>Number of test for Channel %d: %d</strong>', j,lengthFiles)
        for k = length(theFiles):-1:1
            
            % accesssing the name of the sample file in the structure
            baseFileName = theFiles(k).name;
            fullFileName = fullfile(theFiles(k).folder, baseFileName);
            tokens = regexp(baseFileName, ['_(\d+)' regexptranslate('escape', fileType) '$'], 'tokens');
            if isempty(tokens)
                fprintf('Pattern not matching: %s\n', baseFileName);
            else
                Number = str2double(tokens{1}{1});
                testNumberClean (k,j) = {Number};
            end
            fprintf(1, '\n<strong>Test %d</strong>, File: %s', Number, fullFileName);
             
        end
    
    end
        
    fprintf('\n\n<strong>DATA FOR ANALYSIS FOUND IN: %s</strong>\n', cleanFolder)

end      