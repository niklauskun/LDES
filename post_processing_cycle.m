addpath(genpath('C:\Users\wenmi\Desktop\LDES'))
ISO = 'NYISO';
Location = 'LONGIL';
durlist = [1 3 7 30];
binE = [0 0.1 0.4 0.7 1];
binC = zeros(12,4);
% figure()
% hold on
for i  = 1:3
    year = 2016 + i;
    for j = 1:4
        Dur = durlist(j);
        load(sprintf('%s_%s_Dur%d_%d_%d_DS.mat', ISO, Location, Dur, year, year),'eS')
        [c,hist,edges,rmm,idx] = rainflow(eS);
        binC((i-1)*4+j,:) = [hist(1) sum(hist(2:4)) sum(hist(5:7)) sum(hist(8:10))];
    end
end

% xlabel('Cycle Depth')
% ylabel('Cycle Counts')
