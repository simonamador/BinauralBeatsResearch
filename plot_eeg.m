function [f] = plot_eeg(y,t,title_name, psd)
%PLOT

%   INPUT - y vector (eeg signal / PSD), time vector, title name, psd flag
%   ('true'/'false')
%   OUTPUT - figure containing either time or PSD plot.

%   This function inputs the channel data matrix, time vector, and title
%   name, and returns a plot of the EEG signal.

%       Written by Simon Amador (samador0208@gmail.com)

% Check flag to see if an eeg plot or PSD plot should be made.
if strcmp(psd,'false')
    offset = 150;               % Each channel has offset in order to see 
                                % them separately
    labelx = 'Time (s)';
    labely = 'Voltage (\muV)';
elseif strcmp(psd,'true')
    offset = 0;                 % No offset required for PSD, as all 
                                % channels should be at the same level
    labelx = 'Frequency (Hz)';
    labely = 'Power (\muV^2/Hz)';
end

sz = size(y);                       % Number of channels
f = figure('visible','off');        % Creates figure object
for i =1:sz(1)                      % Loops for every channel
    plot(t,y(i,:)+offset*(i-1));    % Plots individual channel, adding
                                    % offset to distinguish channels
    hold on
end
title(title_name);                  % Adds channel to plot
xlabel(labelx);
ylabel(labely);

if strcmp(psd,'true')
    legend('F1', 'Fz', 'F2', 'T7', 'T8', 'P3', 'P4', 'Oz')
end
end

