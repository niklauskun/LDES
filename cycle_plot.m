ISOlist = ["NYISO","NYISO","CAISO","ERCOT","ERCOT"];
Llist = ["LONGIL","NORTH","WALNUT","HOUSTON","WEST"];
t = tiledlayout(5,1);
t.Padding = 'compact';
t.TileSpacing = 'compact';
% vals = [2.69 2.84 2.85 2.84; 2.41 1.85 1.40 0.64; 1.50 1.05 0.79 0; 1.55 1.00 0.40 0;
%     2.64 2.71 2.74 2.77; 1.98 1.90 1.81 1.58; 1.91 1.91 1.70 0.79; 2.14 1.56 1.19 0.30;
%     2.63 2.72 2.77 2.82; 2.06 2.01 1.93 1.55; 1.87 2.02 1.83 0.52; 2.18 1.54 0.88 0.12;
%     2.24 2.35 2.41 2.53; 1.83 1.79 1.78 1.89; 1.56 2.00 2.02 1.09; 2.23 1.70 1.03 0;
%     2.30 2.40 2.47 2.54; 1.79 1.76 1.71 1.72; 1.64 1.91 1.84 0.90; 2.18 1.70 1.15 0.12];
vals = [2.69 2.84 2.85 2.84; 2.41 1.85 1.40 0.64; 1.50 1.05 0.79 0; 1.55 1.00 0.40 0;
        2.63	2.80	2.81	2.80; 2.42	1.83	1.44	0.48; 1.42	1.07	0.54	0.12; 1.58	0.94	0.48	0.00;
        2.61	2.83	2.87	2.85; 2.49	1.95	1.18	0.22; 1.56	0.90	0.52	0.00; 1.28	0.60	0.30	0.12;
        2.22	2.47	2.61	2.63; 2.34	2.14	1.34	0.26; 1.69	0.73	0.37	0.00; 1.26	0.56	0.00	0.00;
        2.25	2.48	2.60	2.61; 2.30	2.08	1.44	0.26; 1.72	1.02	0.52	0.00; 1.45	0.67	0.00	0.00;];
    
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

