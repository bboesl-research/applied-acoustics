function crossCorr = cross_correlation(sampleArray,baselineArray)
%This function takes the cross-correlation of two vectors passed into it
%   It takes the cross-correlation of the inputs and then truncates it to a
%   vector of equal length as the inputs (inputs must be equal in length) 
   
% dummy variable to store the full cross-correlation vector
temp = xcorr(sampleArray,baselineArray); 

% array with half of the size of the cross-correlation vector 
tempSize = (length(temp)+1)/2; 

% truncated cross-correlation vector (half-size)
crossCorr = temp(tempSize:end,1); 
end