function [fdata] = get_psd(idata,fs)
%GET_PSD 

%   INPUT - EEG data structure, sampling rate
%   OUTPUT - PSD data structure

%   This function inputs pre-processed data and conducts a spectral
%   analysis to obtain the power spectral density (PSD) of the signal. The
%   analysis is conducted for windows of 1 second, with 50% overlap, which
%   are all averaged to obtain the final power spectrum. It returns said
%   power spectrum as a data strucutre where fdata.powspctrm returns the
%   power spectrum matrix.

%       Written by Simon Amador (samador0208@gmail.com)

long        = idata.trial;              % Extract data from channels
time        = idata.time;               % Extract time vector
ft          = size(time);               % Extract total time
ft          = ft(2);
sz          = size(long);               % Extract total channels
sz          = sz(1);
x           = floor(ft/(fs*.5));        % Obtain windows total, 50% overlap
wndw        = 1*fs;                     % Define a 1 second window
psd         = zeros(sz,41,x);           % Placeholder for PSD 

wndws           = [];                   % Create window structure
wndws.label     = idata.label;          % Define channel labels
wndws.fsample   = fs;                   % Define sampling rate

cfg2            = [];                   % Create conf structe for PSD
cfg2.output     = 'pow';                % Define output as PSD 
cfg2.channel    = 'all';                % Include all channels
cfg2.method     = 'mtmfft';             % Define a fft method
cfg2.taper      = 'hanning';            % Define a hanning window
cfg2.foi        = 0:1:40;               % Define frequency range

for i = 1:wndw/2:ft-wndw                % Loop for each window
    wndws.trial     = long(:,i:i+wndw); % Window channel data
    wndws.time      = time(:,i:i+wndw); % Window time vector
    
    % Obtain the PSD
    fdata           = ft_freqanalysis(cfg2, wndws);
    psd(:,:,i)      = fdata.powspctrm;  % Assign PSD to placeholder
end

psd             = mean(psd,3);          % Average all windows

% Generate a PSD structure from all data
fdata           = ft_freqanalysis(cfg2, idata);
fdata.powspctrm = psd;                  % Replace data with window data

% f1 = plot_eeg(fdata.trial,fdata.time,'PSD','true');
% set(f1,'visible','on')
end

