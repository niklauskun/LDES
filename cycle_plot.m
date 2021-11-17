ISOlist = ["NYISO","NYISO","CAISO","ERCOT","ERCOT"];
Llist = ["LONGIL","NORTH","WALNUT","HOUSTON","WEST"];
t = tiledlayout(5,1);
t.Padding = 'compact';
t.TileSpacing = 'compact';
vals = [2.69 2.84 2.85 2.84; 2.41 1.85 1.40 0.64; 1.50 1.05 0.79 0; 1.55 1.00 0.40 0;
    2.64 2.71 2.74 2.77; 1.98 1.90 1.81 1.58; 1.91 1.91 1.70 0.79; 2.14 1.56 1.19 0.30;
    2.63 2.72 2.77 2.82; 2.06 2.01 1.93 1.55; 1.87 2.02 1.83 0.52; 2.18 1.54 0.88 0.12;
    2.24 2.35 2.41 2.53; 1.83 1.79 1.78 1.89; 1.56 2.00 2.02 1.09; 2.23 1.70 1.03 0;
    2.30 2.40 2.47 2.54; 1.79 1.76 1.71 1.72; 1.64 1.91 1.84 0.90; 2.18 1.70 1.15 0.12];
for ind = 1:5
    nexttile
    ISO = ISOlist(ind);
    Location = Llist(ind);
    X = categorical({'shallow','light','moderate','deep'});
    X = reordercats(X,{'shallow','light','moderate','deep'});
    v = vals((ind-1)*4+1:ind*4,:);
    bar(X,v);
    title(sprintf('Log-scaled number of cycles in %s_%s',ISO,Location),'Interpreter','none')
    xlabel('cycle depth')
    ylabel('log(cycle numer)')
    ylim([0 3])
end
leg = legend('Dur=1d','Dur=3d','Dur=7d','Dur=30d','Orientation', 'Horizontal');
leg.Layout.Tile = 'south';

