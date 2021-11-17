addpath(genpath('/Users/ningkunzheng/Documents/GitHub/LDES/'))
ISOlist = ["NYISO","NYISO","CAISO","ERCOT","ERCOT"];
Llist = ["LONGIL","NORTH","WALNUT","HOUSTON","WEST"];
durlist = [1 3 7 30];
% t = tiledlayout(5,1);
% t.Padding = 'compact';
% t.TileSpacing = 'compact';
figure(1)

for ind = 1:5
    a(ind) = subplot(3,2,ind)
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
        cdfplot2(v(51,:));
    end
    legend('1d','3d','1w','1m')
    title(sprintf('%s %s', ISO, Location))
    hold off
    drawnow;
    pause(1);
    cutout(a(1),0.2,0.8,0.1);
end


% saveas(gcf,sprintf('%s %s price duration.png', ISO, Location))
