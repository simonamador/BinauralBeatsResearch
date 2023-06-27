function [fdata, fs] = preprocessing(fname)
% PRE-PROCESSING

%   INPUT - File name
%   OUTPUT - Offset-removed, frequency-filtered EEG data register

%   This function extracts eeg data from a file, removes offset
%   through removing the mean of each channel, and applies a low-pass
%   filter of 30 Hz

%       Written by Simon Amador (samador0208@gmail.com)


raw           = readBinaryEbrFile(fname);     % Data extraction

channels      = {'F1'; 'Fz'; 'F2'; 'T7'; 'T8'; 'P3'; 'P4'; 'Oz'};
fs            = raw.sampRate;

raw           = raw.data;
raw           = squeeze(raw(:,1,1:8));
raw           = raw-mean(raw,1);                  % Offset removal
t             = (0:1:size(raw,1)-1)/fs;           % Time vector

data          = [];                 % Creating data object
data.label    = channels;           % Channel labels
data.fsample  = fs;                 % Sample rate
data.time     = t;                  % eeg data
data.trial    = raw';

cfg           = [];                 % Creating cfg object
cfg.lpfilter  = 'yes';              % Call low-pass filter 
                                    % Default: Butteworth
cfg.lpfiltord = 6;                  % Order: 6
cfg.lpfreq    = 30;                 % Cuttoff freq: 30 Hz
 
fdata = ft_preprocessing(cfg,data);  %Apply pre-processing
end

