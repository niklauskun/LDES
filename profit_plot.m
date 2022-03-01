ISOlist = ["NYISO","NYISO","CAISO","ERCOT","ERCOT"];
Llist = ["LONGIL","NORTH","WALNUT","HOUSTON","WEST"];
durlist = [1 3 7 30];
v = zeros(5,4);
for ind = 1:5
    ISO = ISOlist(ind);
    Location = Llist(ind);
    for i  = 1:length(durlist)
        Dur = durlist(i);
        for j = 2017:2019
            load(sprintf('%s_%s_Dur%d_%d_%d_DS.mat', ISO, Location, Dur, j, j),'ProfitOut')
            v(ind,i) = v(ind,i) + ProfitOut*Dur;
        end
    end
end

X = categorical({'NYISO\_LONGIL','NYISO\_NORTH','CAISO\_WALNUT','ERCOT\_HOUSTON','ERCOT\_WEST'});
X = reordercats(X,{'NYISO\_LONGIL','NYISO\_NORTH','CAISO\_WALNUT','ERCOT\_HOUSTON','ERCOT\_WEST'});
bar(X,v);
ylim([5000 16000])
legend('1d','3d','7d','30d','Orientation','horizontal')
ylabel('Abitrage Profit($)')