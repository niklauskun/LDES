addpath(genpath('C:\Users\wenmi\Desktop\LDES'))
ISOlist = ["NYISO","NYISO","CAISO","ERCOT","ERCOT"];
Llist = ["LONGIL","NORTH","WALNUT","HOUSTON","WEST"];
durlist = [1 3 7 30];
figure(1)

a(1) = subplot(1,6,1);
hold on
load('NYISO_LONGIL_2010_2019.mat')
lambda1 = reshape(RTP(:,(end-1094):end),numel(RTP(:,(end-1094):end)),1); 
lambdaH1 = zeros(numel(lambda1)/12,1);
for i = 1:numel(lambdaH1)
   lambdaH1(i) = mean(lambda1((i-1)*12 + (1:12),:)); 
end
cdfplot(lambdaH1);
load('NYISO_NORTH_2010_2019.mat')
lambda2 = reshape(RTP(:,(end-1094):end),numel(RTP(:,(end-1094):end)),1); 
lambdaH2 = zeros(numel(lambda2)/12,1);
for i = 1:numel(lambdaH2)
   lambdaH2(i) = mean(lambda2((i-1)*12 + (1:12),:)); 
end
cdfplot(lambdaH2);
load('CAISO_WALNUT_2016_2021.mat')
lambda3 = reshape(Q(:,367:1461),numel(Q(:,367:1461)),1); 
lambdaH3 = zeros(numel(lambda3)/12,1);
for i = 1:numel(lambdaH3)
   lambdaH3(i) = mean(lambda3((i-1)*12 + (1:12),:)); 
end
cdfplot(lambdaH3);
load('ercot2017.mat')
load('ercot2018.mat')
load('ercot2019.mat')
l1 = reshape(N5,numel(N5),1);
l2 = reshape(N6,numel(N5),1);
l3 = reshape(N7,numel(N5),1);
lambda4 = cat(1,l1,l2,l3);
lambdaH4 = zeros(numel(lambda4)/4,1);
for i = 1:numel(lambdaH4)
   lambdaH4(i) = mean(lambda4((i-1)*4 + (1:4),:)); 
end
cdfplot(lambdaH4);
load('ercot2017west.mat')
load('ercot2018west.mat')
load('ercot2019west.mat')
l4 = reshape(N5,numel(N5),1);
l5 = reshape(N6,numel(N5),1);
l6 = reshape(N7,numel(N5),1);
lambda5 = cat(1,l4,l5,l6);
lambdaH5 = zeros(numel(lambda5)/4,1);
for i = 1:numel(lambdaH5)
   lambdaH5(i) = mean(lambda5((i-1)*4 + (1:4),:)); 
end
set(gca,'FontSize',12)
cdfplot(lambdaH5);
legend('NYISO\_LONGIL','NYISO\_NORTH','CAISO\_WALNUT','ERCOT\_HOUSTON','ERCOT\_WEST','FontSize',10)
title('Hourly price curve in nodes')
hold off
drawnow;
pause(1);
cutout(a(1),0.01,0.99,0.004)

for ind = 1:5
    a(ind+1) = subplot(1,6,ind+1);
    hold on
    ISO = ISOlist(ind);
    Location = Llist(ind);
    for i  = 1:length(durlist)
        v = zeros(101,8760*3);
        Dur = durlist(i);
        for j = 2017:2019
            load(sprintf('%s_%s_Dur%d_%d_%d_DS.mat', ISO, Location, Dur, j, j),'vAvg')
            v(:,(j-2017)*8760+1:(j-2016)*8760) = vAvg(:,1:end-1);
        end
        cdfplot(v(51,:));
    end
    legend('1d','3d','7d','30d','FontSize',10)
    title(sprintf('%s %s', ISO, Location))
    ylim([-20 250])
    set(gca,'FontSize',12)
    hold off
    drawnow;
    pause(1);
    cutout(a(ind+1),0.2,0.8,0.1);
end

% set(a(1),'position',[.15 .7 .35 .25])
% set(a(2),'position',[.55 .7 .35 .25])
% set(a(3),'position',[.15 .4 .35 .25])
% set(a(4),'position',[.55 .4 .35 .25])
% set(a(5),'position',[.15 .1 .35 .25])
% set(a(6),'position',[.55 .1 .35 .25])

