function [eegData] = readBinaryEbrFile(fileName)
% [eegData] = readBinaryEbrFile(fileName): Read binary EBR file.
%
% Input:
%       - fileName: The name of the file to be loaded.
% Output:
%       - eegData: The structure with the loaded EEG data and the 
%                  metadata. The data is stored in a 4-dimensional array
%                  indexed by 4 variables: sample, band, channel and 
%                  trial. For RAW data, only one band and one trial
%                  are used.
% Usage:
%      eegData = readBinaryEbrFile('file.ebr')
%
%   Written by Omar Mendoza Montoya (omendoz@live.com.mx)
%
%   Copyright (c) 2019 Omar Mendoza Montoya. All rights reserved. 
%   Permission is hereby granted, free of charge, to any person obtaining 
%   a copy of this software and associated documentation files (the 
%   "Software"), to deal in the Software without restriction, including 
%   without limitation the rights to use, copy, modify, merge, publish, 
%   distribute, sublicense,  and/or sell copies of the Software, and to 
%   permit persons to whom the Software is furnished to do so, 
%   subject to the following conditions: 
%   The above copyright notice and this permission notice shall be 
%   included in all copies or substantial  portions of the Software. 
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
%   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
%   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
%   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
%   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
%   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
%   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% Check input arguments.
if (nargin ~= 1)
    error('Bad input arguments.'); 
end

if (~ischar(fileName))
    error('Bad file name.'); 
end

% Open file.
fid = fopen(fileName);

% Read magic key.
magic = fgetl(fid);
if (~strcmp(magic, 'ebr binary 1.0'))
    error('File type not supporded by this function.'); 
end

% Read header.
headerEnd = 0;
eegData.dataType = 0;
eegData.sampRate = 0;
eegData.numberOfSamples = 0;
eegData.numberOfBands = 0;
eegData.bands = 0;
eegData.numberOfChannels = 0;
eegData.channels = 0;
eegData.numberOfTrials = 0;
eegData.trials = 0;
eegData.numberOfComments = 0;
eegData.comments = 0;
eegData.numberOfMarks = 0;
eegData.marks = 0;
eegData.data = 0;

while (~headerEnd)
    line = strtrim(fgetl(fid));
    
    if (startsWith(line, 'data_type'))
        val = extractAfter(line,'data_type');
        eegData.dataType = strtrim(val);
        
    elseif (startsWith(line, 'sampling_rate'))
        val = extractAfter(line,'sampling_rate');
        eegData.sampRate = str2num(val); %#ok<*ST2NM>
        
    elseif (startsWith(line, 'samples'))
        val = extractAfter(line,'samples');
        eegData.numberOfSamples = str2num(val); %#ok<*ST2NM>
        
    elseif (startsWith(line, 'bands'))
        val = extractAfter(line,'bands');
        eegData.numberOfBands = str2num(val); %#ok<*ST2NM>
        eegData.bands = cell(eegData.numberOfBands, 1);
        
    elseif (startsWith(line, 'band_'))
        val = extractAfter(line,'band_');
        sval = strsplit(val);
        index = str2num(sval{1});
        eegData.bands{index} = extractAfter(val,' ');
        
    elseif (startsWith(line, 'channels'))
        val = extractAfter(line,'channels');
        eegData.numberOfChannels = str2num(val); %#ok<*ST2NM>
        eegData.channels = cell(eegData.numberOfChannels, 1);
        
    elseif (startsWith(line, 'channel_'))
        val = extractAfter(line,'channel_');
        sval = strsplit(val);
        index = str2num(sval{1});
        eegData.channels{index} = extractAfter(val,' ');
        
    elseif (startsWith(line, 'trials'))
        val = extractAfter(line,'trials');
        eegData.numberOfTrials = str2num(val); %#ok<*ST2NM>
        eegData.trials = cell(eegData.numberOfTrials, 1);
        
    elseif (startsWith(line, 'trial_'))
        val = extractAfter(line,'trial_');
        sval = strsplit(val);
        index = str2num(sval{1});
        eegData.trials{index} = extractAfter(val,' ');
        
    elseif (startsWith(line, 'comments'))
        val = extractAfter(line,'comments');
        eegData.numberOfComments = str2num(val); %#ok<*ST2NM>
        eegData.comments = cell(eegData.numberOfComments, 1);
        
    elseif (startsWith(line, 'comment_'))
        val = extractAfter(line,'comment_');
        sval = strsplit(val);
        index = str2num(sval{1});
        eegData.comments{index} = extractAfter(val,' ');
        
    elseif (startsWith(line, 'marks'))
        val = extractAfter(line,'marks');
        eegData.numberOfMarks = str2num(val); %#ok<*ST2NM>
        eegData.marks = cell(eegData.numberOfMarks, 2);
        
    elseif (startsWith(line, 'mark_'))
        val = extractAfter(line,'mark_');
        sval = strsplit(val);
        index = str2num(sval{1});        
        val = extractAfter(val,' ');
        sval = strsplit(val);        
        eegData.marks{index, 1} = str2num(sval{1});
        eegData.marks{index, 2} = extractAfter(val,' ');
        
    elseif (strcmp(line, 'end_header'))
        headerEnd = 1;
    end    
end

% Read data.
size = eegData.numberOfSamples * eegData.numberOfBands * ...
    eegData.numberOfChannels * eegData.numberOfTrials;

if (strcmp(eegData.dataType, 'int8') ||...
        strcmp(eegData.dataType, 'char'))
    eegData.data = fread(fid, size, 'int8');
    
elseif (strcmp(eegData.dataType, 'uint8') || ...
        strcmp(eegData.dataType, 'unsigned char'))
    eegData.data = fread(fid, size, 'uint8');
    
elseif (strcmp(eegData.dataType, 'int16') ||...
        strcmp(eegData.dataType, 'short'))
    eegData.data = fread(fid, size, 'int16');
    
elseif (strcmp(eegData.dataType, 'uint16') ||...
        strcmp(eegData.dataType, 'unsigned short'))
    eegData.data = fread(fid, size, 'uint16');
   
elseif (strcmp(eegData.dataType, 'int32') ||...
        strcmp(eegData.dataType, 'int'))
    eegData.data = fread(fid, size, 'int32');
 
elseif (strcmp(eegData.dataType, 'uint32') ||...
        strcmp(eegData.dataType, 'unsigned int'))
    eegData.data = fread(fid, size, 'uint32');
    
elseif (strcmp(eegData.dataType, 'int64') ||...
        strcmp(eegData.dataType, '__int64'))
    eegData.data = fread(fid, size, 'int64');
 
elseif (strcmp(eegData.dataType, 'uint64') ||...
        strcmp(eegData.dataType, 'unsigned __int64'))
    eegData.data = fread(fid, size, 'uint64');
   
elseif (strcmp(eegData.dataType, 'float'))
    eegData.data = fread(fid, size, 'float32');
    
elseif (strcmp(eegData.dataType, 'double'))
    eegData.data = fread(fid, size, 'float64');
    
elseif (strcmp(eegData.dataType, 'complex') ||...
        strcmp(eegData.dataType, 'class std::complex<double>'))
    allData = fread(fid, 2*size, 'float64');
    eegData.data = allData(1:2:end) + 1i*allData(2:2:end);
end

eegData.data = reshape(eegData.data, eegData.numberOfSamples, ...
    eegData.numberOfBands, eegData.numberOfChannels, ...
    eegData.numberOfTrials);

% Close file.
fclose(fid);