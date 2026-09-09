function y = isfread (fullFileName)
%ISFREAD  Read a Tektronix ISF file.
%   DATA = ISFREAD(FILENAME) reads the Tektronix ISF file given by FILENAME
%   and returns a structure containg the data and the header.
%
% ISF is the name of an internal data format used by Tektronix
% oscilloscopes. The files consist of a short text header followed by
% binary data.
%
% This function was written to read data saved by a model TDS 360
% oscilloscope, but is likely to work with other models that use the ISF
% format. It was tested by saving the same waveform on the oscilloscope
% in both comma-separated values (CSV) format and ISF, then comparing CSV
% data to that returned by ISFREAD.
%
% This function is based on <a
% href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/6247')">isfread</a> by John Lipp.
%
% See also
%   Programmer Manual for Tektronix TDS 340A, TDS 360 and TDS 380 Digital
%   Real-Time Oscilloscopes (070-9442-02).
%
% Iain Robinson, School of Geosciences, University of Edinburgh.
% Last updated: 2012-09-11

    % Open the file.
    fileID = fopen(fullFileName);
    if (fileID == -1)
        error('The file exists, but could not be opened: %s', fullFileName);
    end
    
    % Read the text header into a variable called 'h'. The loop reads the
    % file character-by-character into h until h finishes with the
    % characters ":CURVE #" or ":CURV #".
    h = '';
    while( isempty( regexp(h, ':CURVE? #', 'once') ) )
        % If the end of the file has been reached something is wrong.
        if( feof(fileID) )
            error('The end of the file %s was reached whilst still reading the header. This suggests that it is not a Tektronix ISF file.', fileName);
        end
        c = char( fread(fileID, 1, 'char') );
        h = [h, c];
    end
    
    % Parse the header
%     header.BYT_NR = str2double( regexp(h, 'BYT_NR?\s+(\d+)', 'once', 'tokens') ); % Binary field data width
%     header.BIT_NR = str2double( regexp(h, 'BIT_NR?\s+(\d+)', 'once', 'tokens') ); % Number of bits per binary waveform point
%     header.ENCDG = char( regexp(h, 'ENCD?G?\s+(.*?)\s*[;:]', 'once', 'tokens') ); % Type of encoding for the waveform data
%     header.BN_FMT = char( regexp(h, 'BN_FM?T?\s+(.*?)\s*[;:]', 'once', 'tokens') ); % Format of the binary data
%     header.BYT_OR = char( regexp(h, 'BYT_OR?\s+(.*?)\s*[;:]', 'once', 'tokens') );  % Byte order of the binary data
%     header.WFID = char(regexp(h, 'WFID?\s+"*\s*(.*?)\s*"*[;:]', 'once', 'tokens') ); % Waveform identifier
%     header.NR_PT = str2double( regexp(h, 'NR_PT?\s+(\d+)', 'once', 'tokens') ); % Number of waveform points
%     header.PT_FMT = char( regexp(h, 'PT_FM?T?\s+(.*?)\s*[;:]', 'once', 'tokens') ); % Point format: 'ENV' for envelope pairs or 'Y' 
%     header.XUNIT = char( regexp(h, 'XUNI?T?\s+"*(.*?)"*[;:]', 'once', 'tokens')); % Horizontal units
%     header.XINCR = str2double( regexp(h, 'XINC?R?\s+([-\+\d\.eE]+)', 'once', 'tokens') ); % Horizontal sampling interval
%     header.PT_OFF = str2double( regexp(h, 'PT_OF?F?\s+([-\+\d\.eE]+)', 'once', 'tokens') ); % Trigger point within the waveform record
%     header.YUNIT = char( regexp(h, 'YUNI?T?\s+"*(.*?)"*[;:]', 'once', 'tokens') ); % Vertical units of waveform data
    header.YMULT = str2double( regexp(h, 'YMUL?T?\s+([-\+\d\.eE]+)', 'once', 'tokens') ); % Vertical scale factor
    header.YOFF = str2double( regexp(h, 'YOFF?\s+([-\+\d\.eE]+)', 'once', 'tokens') ); % Offset of the vertical component
    header.YZERO = str2double( regexp(h, 'YZER?O?\s+([-\+\d\.eE]+)', 'once', 'tokens') ); % Offset
    
    % In addition, some header fields are described in the Programmer
    % Manual, but do not seem to appear in any of my files: XMULT, XOFF,
    % XZERO, ZMULT, ZOFF, ZUNIT and ZZERO.
    
    % Check that at least some part of the header was parsed.
%     if isempty(header.BYT_NR)
%         warning('Failed to read some part of, or possibly all of, the header in the file %s.', fileName);
%     end
    
    % The next few characters in the file give the number of bytes in the
    % waveform data. The first digit, referred to as 'x' on page 2-60 of
    % the Programmer Manual, gives the number of bytes that immediately
    % follow giving the value 'y', where 'y' is the number of bytes in the
    % waveform. The manual explains it better than I can.
    xBytes = str2double( char( fread(fileID, 1, 'char') ) );
    yBytes = str2double( char( fread(fileID, xBytes, 'char') ) );
    
    % For some reason there is an offset of 1 byte in reading the data
    % files. I don't know why, but I found I could fix it by moving the
    % file position back by one byte.
    fseek(fileID, -1, 'cof');
    
    % Read the waveform.
    % For some oscilloscopes it may be necessary to add 'ieee-be' to the
    % fread statement below. See the comments here:
    % http://www.mathworks.co.uk/matlabcentral/fileexchange/6247-isfread
    [binaryData, ~] = fread(fileID, yBytes/2, 'int16');

    % Check that the expected number of points have been read.
%     if(count ~= header.NR_PT)
%         error('According to the header, the file %s contains %d points, but only %d were read.', fileName, header.NR_PT, count);
%     end
    
    % Calculate the vertical (y) values. This equation
    % is given on page 2-171 of the Programmer Manual.
    y = header.YZERO + header.YMULT * (binaryData - header.YOFF);

    % Close the file.
    fclose(fileID);
end