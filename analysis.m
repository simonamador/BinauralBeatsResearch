%% Import data
channels    = ["F1", 'Fz', 'F2', 'T7', 'T8', 'P3', 'P4', 'Oz'];
cases       = ["alpha", "beta", 'theta', "c", "tbr", "wm", "f"];
comps       = {[1,3],[4,6],[1,4],[6,3],[2,5]};

keys        = cell(1,length(comps));
results     = zeros(length(channels),length(cases));
result      = zeros(1,length(cases));

for comparison = 1:length(comps)
    for channel = 1:length(channels)
        for class = cases
            [h,p,ci,stats] = insight_finder(channel,comparison,class);
            a = find(cases==class);
            result(a) = h;
        end
        results(channel,:) = result;
    end
    keys{comparison} = results;
end