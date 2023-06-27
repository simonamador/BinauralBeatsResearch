function [fdata] = ica(idata,fs)
%ICA 

%   INPUT - EEG data structure, sampling rate.
%   OUTPUT - Ica filtered EEG data structure.

%   This function allows for the filtering of artifacts of an EEG signal
%   through the use of ICA. It inputs the data structure and the sampling
%   rate and returns the filtered data structure. In 20 s windows, it 
%   applies an ICA decomposition so user can identify and select artifact-
%   containing components for removal. Returns filtered signal.

%       Written by Simon Amador (samador0208@gmail.com)

long        = idata.avg;                % Takes the channel data
time        = idata.time;               % Takes the time vector

% Takes the total time length
ft          = size(time);               
ft          = ft(2);  

% Takes the number of channels
n = size(long);
n = n(1);

wndw        = 20*fs;                    % Set window to 20 s

fdata            = [];                  % Create data object
fdata.label      = idata.label;         % Channel labels
fdata.fsample    = fs;                  % Sample rate

cfg_comp             = [];              % Create ica conf object
cfg_comp.method      = 'runica';        % Define ica method

cfg_view             = [];              % Create view conf object
cfg_view.viewmode    = 'vertical';      % Define vertical view
cfg_view.blocksize   = 20;              % Define view size (s)
cfg_view.figure      = 'yes';           % Define new figure for object

n_data          = zeros(n,ft);         % Placeholder for fitlered data

for i = 1:wndw:ft-wndw                  % Loops for each window
    % Displays current window
    fprintf('Ventanta %1f de %1f',floor(i/wndw+1),floor(ft/wndw))
    
    fdata.trial  = long(:,i:i+wndw);    % Current window channel data
    fdata.time   = time(:,i:i+wndw);    % Current window time
    
    check = 'n';                        % Declare confirmation flag
    
    % While artifact removal not confirmed (so same window removal repeats
    % until used is satisfied with filtered signal, then moves on to next
    % window
    while check == 'n'
        % Plots window without artifact removal
        f1 = plot_eeg(fdata.trial,fdata.time,'No artifact removal','false');
        set(f1,'visible','on');
        
        % Decompose signal to components through ICA
        data_comp   = ft_componentanalysis(cfg_comp, fdata);

        % Plot components for artifact detection
        ft_databrowser(cfg_view, data_comp);
        f2 = gcf;

        comp        = '';               % Placeholder for comp name
        comp_list    = [];              % Placeholder for comp name list

        % Repeats until component name = end, indicating no more
        % components to remove
        while ~strcmp(comp,'end') 
            
            % Inputs component name
            comp        = input('Components to remove: ','s');
            
            % Adds component to list
            if ~strcmp(comp,'end')
                comp = str2double(comp);
                comp_list   = [comp_list; comp];
            end
        end

        set(f2,'visible','off');        % Sets off visibility of components

        cfg2                = [];       % Create artifact removal object
        
        % Adds component list for artifact removal
        cfg2.component      = comp_list';
        
        % Creates new data object for filtered window, adds it to
        % placeholder
        data_clean          = ft_rejectcomponent(cfg2, data_comp);
        n_data(:,i:i+wndw)  = data_clean.avg;

        % Plots window with chosen artifact removal
        f3 = plot_eeg(data_clean.avg,data_clean.time,... 
            'After artifact removal','false');
        set(f3,'visible','on');
        
        % Checks if user is satisfied with artifact removal
        check = input('Satisfied with artifact removal? (y/n): ','s');
        set(f1,'visible','off');        % Sets off visibility of plot
        set(f3,'visible','off');        % Sets off visibility of plot
    end
end

fdata.trial     = n_data;               % Adds filtered signal to object
fdata.time      = time;                 % Adds time to object
end

