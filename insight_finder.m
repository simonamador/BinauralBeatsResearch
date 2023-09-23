function [h,p,ci,stats] = insight_finder(channel,comparison,class)
%INSIGHT_PARSER Summary of this function goes here
%   Detailed explanation goes here
comps       = {[1,3],[4,6],[1,4],[6,3],[2,5]};
cases       = ["alpha", "beta", 'theta', "c", "tbr", "wm", "f"];

for i=1:6
    eval(['b_' num2str(i) '=load("Biomarkers\BIOMRKRS_' num2str(i) '.mat");'])
end

p = inputParser;
validchannel = @(x) isnumeric(x) && (x>0) && (x<9);
validcomp = @(x) isnumeric(x) && (x>0) && (x<6);
validcase = @(x) isstring(x) && any(ismember(cases,x));
addRequired(p,'channel',validchannel);
addRequired(p,'comparison',validcomp);
addRequired(p,'class',validcase);

parse(p,channel,comparison,class);

ch          = p.Results.channel;
comp        = comps{p.Results.comparison};
class       = convertCharsToStrings(class);

a_1 = [];  a_2 = [];

keys = { {['a_1' ' = b_' num2str(comp(1)) '.' class ';'], ...
               ['a_2' ' = b_' num2str(comp(2)) '.' class ';']}, ...
    {['a_1' ' = b_' num2str(comp(1)) '.' class ';'], ...
               ['a_2' ' = b_' num2str(comp(2)) '.' class ';']}, ...
    {['a_1' ' = b_' num2str(comp(1)) '.' class ';'], ...
               ['a_2' ' = b_' num2str(comp(2)) '.' class ';']}, ...
    {['a_1 = b_' num2str(comp(1)) '.beta ./ ' ...
                'b_' num2str(comp(1)) '.theta;'], ...
                ['a_2 = b_' num2str(comp(2)) '.beta ./ ' ...
                'b_' num2str(comp(2)) '.theta;']}, ...
    {['a_1 = b_' num2str(comp(1)) '.theta ./ ' ...
                'b_' num2str(comp(1)) '.beta;'],...
                ['a_2 = b_' num2str(comp(2)) '.beta ./ ' ...
                'b_' num2str(comp(2)) '.theta;']}, ...
    {['a_1 = b_' num2str(comp(1)) '.alpha ./ ' ...
                'b_' num2str(comp(1)) '.beta;'], ...
                ['a_2 = b_' num2str(comp(2)) '.alpha ./ ' ...
                'b_' num2str(comp(2)) '.beta;']}, ...
    {['a_1 = (b_' num2str(comp(1)) '.alpha + b_' num2str(comp(1)) '.theta) ./ (b_' num2str(comp(1)) '.alpha + b_' num2str(comp(1)) '.beta);'], ...
                ['a_2 = (b_' num2str(comp(2)) '.alpha + b_' num2str(comp(2)) '.theta) ./ (b_' num2str(comp(2)) '.alpha + b_' num2str(comp(2)) '.beta);']}};

case_dict   = dictionary(cases,keys);


marker = case_dict(class); marker = marker{1};

if ~ischar(marker{1})
    marker{1} = strjoin(marker{1},'');
    marker{2} = strjoin(marker{2},'');
end

eval(marker{1})
eval(marker{2})

if (comparison == 1) || (comparison ==4)
    a_1(2,:) = [];
end

[h,p,ci,stats] = ttest(a_1(:,ch),a_2(:,ch));
end

