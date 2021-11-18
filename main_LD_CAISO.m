addpath(genpath('C:\Users\wenmi\Desktop\LDES'))

ISO = 'CAISO';
Location = 'WALNUT';
load(sprintf('%s_%s_2016_2021.mat', ISO, Location))
Ts = 1; % time step
Ystart = 2019; % start year
Yend = 2019; % end year
lambda = reshape(Q(:,((Ystart-2016)*365+2):((Yend-2015)*365+1)),numel(Q(:,((Ystart-2016)*365+2):((Yend-2015)*365+1))),1); 

%% convert lambda to hourly resolution
lambdaH = zeros(numel(lambda)/12,1);

for i = 1:numel(lambdaH)
   lambdaH(i) = mean(lambda((i-1)*12 + (1:12),:)); 
end

T = numel(lambdaH); % number of time steps

%%
Dur = 30; 
Pr = 1/(Dur*24); % normalized power rating wrt energy rating
P = Pr*Ts; % actual power rating taking time step size into account
eta = .8; % efficiency
c = 0; % marginal discharge cost - degradation
ed = 1/(Dur*1500); % SoC sample granularity, 1500 segments/day
% ed = 1/20000; % SoC sample granularity for 1 month duration
ef = .5; % final SoC target level, use 0 if none
Ne = floor(1/ed)+1; % number of SOC samples
e0 = .5;

vEnd = zeros(Ne,1);  % generate value function samples

vEnd(1:floor(ef*Ne)) = 1e2; % use 100 as the penalty for final discharge level


%%
tic
v = zeros(Ne, T+1); % initialize the value function series
% v(1,1) is the marginal value of 0% SoC at the beginning of day 1
% V(Ne, T) is the maringal value of 100% SoC at the beginning of the last operating day
v(:,end) = vEnd; % update final value function

% process index
es = (0:ed:1)';
Ne = numel(es);
% calculate soc after charge vC = (v_t(e+P*eta))
eC = es + P*eta; 
% round to the nearest sample 
iC = ceil(eC/ed)+1;
iC(iC > (Ne+1)) = Ne + 2;
iC(iC < 2) = 1;
% calculate soc after discharge vC = (v_t(e-P/eta))
eD = es - P/eta; 
% round to the nearest sample 
iD = floor(eD/ed)+1;
iD(iD > (Ne+1)) = Ne + 2;
iD(iD < 2) = 1;

for t = T:-1:1 % start from the last day and move backwards
    vi = v(:,t+1); % input value function from tomorrow
    vo = CalcValueNoUnc(lambdaH(t), c, P, eta, vi, ed, iC, iD);
    v(:,t) = vo; % record the result 
end

tElasped = toc;

%% convert value function to 5 segments
vAvg = zeros(101,T+1);

NN = (Ne-1)/100;

vAvg(1,:) = v(1,:);

for i = 1:100
   vAvg(i+1,:) = mean(v((i-1)*NN + 1 + (1:NN),:)); 
end

%% perform the actual arbitrage
eS = zeros(T,1); % generate the SoC series
pS = eS; % generate the power series

e = e0; % initial SoC

for t = 1:T % start from the first day and move forwards
    vv = v(:,t+1); % read the SoC value for this day
   [e, p] =  Arb_Value(lambdaH(t), vv, e, P, 1, eta, c, size(v,1));
   eS(t) = e; % record SoC
   pS(t) = p; % record Power
end

ProfitOut = sum(pS.*lambdaH) - sum(c*pS(pS>0));
Revenue = sum(pS.*lambdaH);
fprintf('Profit=%e, revenue=%e',ProfitOut, Revenue)
solTimeOut = toc;

clear v

save(sprintf('%s_%s_Dur%d_%d_%d_DS.mat', ISO, Location, Dur, Ystart, Yend), '-v7.3')