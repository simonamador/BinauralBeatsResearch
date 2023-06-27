% The following code conducts the processing of registered data, saving 
% .mat files containing structures of two classes:
% * Power Spectrum Density (PSD)
% * Selected Biomarkers
% There are 6 structures of each class, as there are 6 registers per 
% subject. Each structure contains the biomarkers and PSD, respectively, 
% of each subject.

%       Written by Simon Amador (samador0208@gmail.com)

% Directory where all programs and register folder are
dir      = 'C:\Users\Simon\MATLAB\Projects\BinauralBeats\';

% Subject names
subjects = {'Valle', 'Iturbide', 'Uribe', 'Barragan', 'Sunden', ...
    'Aitziry', 'Sandoval', 'Yee', 'Metsamaki', 'Tenorio', 'Amador',...
    'Chagoya', 'Aguilar', 'Saldaña', 'Cardenas', 'Buganza', ... 
    'Gutierrez', 'Herrera', 'Leyva', 'Ureta', 'Sanchez', 'Domenzain',...
    'Panamito', 'Vazquez', 'Guevara'};

% Channel names and biomrkrs names (only 8 biomarkers in order to optimize
% the structure-generation loop)
channels = {'F1', 'Fz', 'F2', 'T7', 'T8', 'P3', 'P4', 'Oz'};
biomrkrs = {'alpha', 'beta', 'theta', 'delta', 'F1', 'F2', 'F3', 'F4'};

% Generate the to-be-saved structures and fields.
% PSD structure has a power spectrum, label, dimord, and channels fields.
% powspctrm holds the final channel spectrum after each channel field is
% averaged for all subjects.
for a = 1:6
    eval(['BIOMRKRS_' num2str(a) '= [];'])
    eval(['BIOMRKRS_' num2str(a) '.tbr' '= [];'])
    eval(['BIOMRKRS_' num2str(a) '.TBR' '= [];'])
    eval(['BIOMRKRS_' num2str(a) '.C' '= [];'])
    eval(['PSD_' num2str(a) '= [];'])
    eval(['PSD_' num2str(a) '.powspctrm = [];'])
    eval(['PSD_' num2str(a) '.label = channels;'])
    eval(['PSD_' num2str(a) '.dimord = "chan_freq";'])
    for b = 1:8
        eval(['PSD_' num2str(a) '.' channels{b} ' = [];'])
        eval(['BIOMRKRS_' num2str(a) '.' biomrkrs{b} '= [];']);
    end
end
%%
%   Loops for all subjects (25), for all registers (6)
for i = 1:25
    for n = 1:6
        % Subject with missing register
        if strcmp(subjects{i},'Iturbide') && (n == 3) 
            continue
        else
            % Define file name
            fname       = [dir 'Filtered\' subjects{i} '\' subjects{i} ...
                '_' int2str(n) '.mat'];
            data        = load(fname);          % Extract data
            PSD         = get_psd(data, 256);   % Extract PSD
            % Append biomarkers to corresponding structure
            eval(['BIOMRKRS_' num2str(n) '= biomarkers(PSD, ' ...
                'BIOMRKRS_' num2str(n) ');'])
            ch_labels    = PSD.label;           % Extract channel labels
            ch_psd      = PSD.powspctrm;        % Extract PSD
            % Append PSD to corresponding structure, maintaining each
            % channel as it's own field to mainting channel order as
            % some registers have different missing channels
            for c = 1:length(ch_labels)
                    eval(['PSD_' num2str(n) '.' ch_labels{c} ...
                        ' = [PSD_' num2str(n) '.' ch_labels{c} ...
                        '; ch_psd(' num2str(c) ',:)];']);
            end
        end
    end
end
%%
% Loop to save all Biomarkers structures as .mat files
for i = 1:6
    filename = ['Biomarkers\BIOMRKRS_' num2str(i) '.mat'];
    save([dir filename], '-struct', ['BIOMRKRS_' num2str(i)], 'tbr', ...
        'TBR', 'C', 'alpha', 'beta', 'theta', 'delta', 'F1', 'F2', ...
        'F3', 'F4');
end
%%
% Loop to average the subjects of all channels and combine them to generate
% the powspctrm field, and the removes channel fields.
for a = 1:6
    for b = 1:8
        eval(['PSD_' num2str(a) '.' channels{b} ' = mean(PSD_' ...
            num2str(a) '.' channels{b} ', 1);'])
        eval(['PSD_' num2str(a) '.powspctrm' ' = [ PSD_' num2str(a) ...
            '.powspctrm; PSD_' num2str(a) '.' channels{b} '];'])
        eval(['PSD_' num2str(a) '= rmfield(PSD_' num2str(a) ...
            ', ' '"' channels{b} '");'])
    end
end
%%
% Loop to save all PSD structures as .mat files
for i = 1:6
    filename = ['PSD\PSD_' num2str(i) '.mat'];
    save([dir filename], '-struct', ['PSD_' num2str(i)], ...
        'powspctrm', 'label', 'dimord');
end
%%
% (Optional) Plotting of PSD 

% Titles for the registers
titles = {'Initial Rest, No Stimuli', 'Game, No Stimuli', ... 
    'Final Rest, No Stimuli', 'Initial Rest, Stimuli', 'Game, Stimuli' ...
    'Final Rest, Stimuli'};

% Loop to plot PSD for each register
for i =1:6
    eval(['f = plot_eeg(PSD_' num2str(i) ... 
        '.powspctrm,1:41,titles{i},"true");']);
    set(f,'visible','on')
end
%%