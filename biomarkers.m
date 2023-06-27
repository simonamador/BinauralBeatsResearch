function [biomrkrs] = biomarkers(idata, biomrkrs)
% BIOMARKERS
%   INPUT - Power spectrum data structure, biomarkers data structure
%   OUTPUT - Biomarkers data structure, containing appended new subject info
%   This function receives a powerspectrum from a specific register and
%   extracts the relative power bands, from which it calculates the
%   required biomarkers, and appends them to a given data structure fields.

%       Written by Simon Amador (samador0208@gmail.com)

% TBR = theta-beta ratio, used to aproximate grit
% C = concentration indicator
% f1-f4 = fatigue indicators

PSD         = idata.powspctrm';         % Extract PSD from data structure

alpha_abs   = sum(PSD(9:13,:));         % Obtain alpha absolute power band
beta_abs    = sum(PSD(13:31,:));        % Obtain beta absolute power band
delta_abs   = sum(PSD(2:5,:));          % Obtain delta absolute power band
theta_abs   = sum(PSD(5:9,:));          % Obtain theta absolute power band

alpha_rel   = alpha_abs./sum(PSD);      % Obtain alpha relative power band
beta_rel    = beta_abs./sum(PSD);       % Obtain beta relative power band
delta_rel   = delta_abs./sum(PSD);      % Obtain delta relative power band
theta_rel   = theta_abs./sum(PSD);      % Obtain theta relative power band

tbr     = theta_rel./beta_rel;          % Obtain the TBR in all channels
C       = beta_rel./theta_rel;          % Obtain C in all channels

% Obtain f4 in all channels
f4      = (theta_rel + alpha_rel)./(alpha_rel + beta_rel);

% Conditionals in case there are channels missing, to append TBR (tbr for
% frontal channels, where it is supposed to be obtained from), f1 as 
% fatigue from occipital alpha, and f3 as frontal theta to the data 
% structure.
if strcmp(idata.label{2},'Fz')
    biomrkrs.TBR    = [biomrkrs.TBR mean(tbr(1:3))];
    biomrkrs.F1     = [biomrkrs.F1 mean(alpha_rel(6:end))];
    biomrkrs.F3     = [biomrkrs.F3 mean(theta_rel(1:3))];
    if strcmp(idata.label{end},'Oz')
        if strcmp(idata.label{5},'T8')
            biomrkrs.alpha  = [biomrkrs.alpha; alpha_rel];
            biomrkrs.beta   = [biomrkrs.beta; beta_rel];
            biomrkrs.theta  = [biomrkrs.theta; theta_rel];
            biomrkrs.delta  = [biomrkrs.delta; delta_rel];
        else
            biomrkrs.alpha  = [biomrkrs.alpha; ...
                [alpha_rel(1:4) 0 alpha_rel(5:end)]];
            biomrkrs.beta   = [biomrkrs.beta; ...
                [beta_rel(1:4) 0 beta_rel(5:end)]];
            biomrkrs.theta  = [biomrkrs.theta; ...
                [theta_rel(1:4) 0 theta_rel(5:end)]];
            biomrkrs.delta  = [biomrkrs.delta; ...
                [delta_rel(1:4) 0 delta_rel(5:end)]];
        end
    else
        biomrkrs.alpha  = [biomrkrs.alpha; [alpha_rel 0]];
        biomrkrs.beta   = [biomrkrs.beta; [beta_rel 0]];
        biomrkrs.theta  = [biomrkrs.theta; [theta_rel 0]];
        biomrkrs.delta  = [biomrkrs.delta; [delta_rel 0]];
    end
else
    biomrkrs.TBR    = [biomrkrs.TBR mean(tbr(1:2))];
    biomrkrs.F1     = [biomrkrs.F1 mean(alpha_rel(5:end))];
    biomrkrs.F3     = [biomrkrs.F3 mean(theta_rel(1:2))];
    if strcmp(idata.label{end},'Oz')
        biomrkrs.alpha  = [biomrkrs.alpha; ...
            [alpha_rel(1) 0 alpha_rel(2:end)]];
        biomrkrs.beta   = [biomrkrs.beta; ...
            [beta_rel(1) 0 beta_rel(2:end)]];
        biomrkrs.theta  = [biomrkrs.theta; ...
            [theta_rel(1) 0 theta_rel(2:end)]];
        biomrkrs.delta  = [biomrkrs.delta; ...
            [delta_rel(1) 0 delta_rel(2:end)]];
    else
        biomrkrs.alpha  = [biomrkrs.alpha; ...
            [alpha_rel(1) 0 alpha_rel(2:end) 0]];
        biomrkrs.beta   = [biomrkrs.beta; ...
            [beta_rel(1) 0 beta_rel(2:end) 0]];
        biomrkrs.theta  = [biomrkrs.theta; ...
            [theta_rel(1) 0 theta_rel(2:end) 0]];
        biomrkrs.delta  = [biomrkrs.delta; ...
            [delta_rel(1) 0 delta_rel(2:end) 0]];
    end
end

% Append remaining biomarkers to biomarker structure
biomrkrs.tbr    = [biomrkrs.tbr mean(tbr)];
biomrkrs.F2     = [biomrkrs.F2 mean(beta_rel)];
biomrkrs.F4     = [biomrkrs.F4 mean(f4)];
biomrkrs.C      = [biomrkrs.C mean(C)];
end