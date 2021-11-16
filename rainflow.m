function varargout = rainflow(x,varargin)
%RAINFLOW Rainflow counts for fatigue analysis
%   C = RAINFLOW(X) computes cycle counts for fatigue analysis of the load
%   time history, X, according to the ASTM E 1049 standard. The matrix C
%   contains cycle information in its columns, in this order: counts, ranges,
%   mean values, initial cycle samples, and final cycle samples.
%
%   C = RAINFLOW(X,Fs) computes cycle counts for X sampled at Fs in hertz.
%
%   C = RAINFLOW(X,T) computes cycle counts for X with corresponding time
%   values in T. T can be a vector, a one-dimensional duration array, or a
%   scalar duration. If T is a vector or a duration array, it contains the
%   sample times for each corresponding element of X. If T is a scalar
%   duration, it contains the time interval between samples. The start and 
%   end times contained in C are in units of seconds. Time values must be 
%   strictly increasing.
%
%   C = RAINFLOW(XT) computes cycle counts for the time history stored in
%   the timetable XT. The start and end times contained in C are in units
%   of seconds. XT must contain a single numeric column variable. Time
%   values in XT must be strictly increasing.
%
%   C = RAINFLOW(...,'ext') specifies the time history vector, X, as
%   a vector of identified peaks and valleys.
%
%   [C,RM,RMR,RMM] = RAINFLOW(...) outputs a rainflow matrix, RM. The rows
%   of RM correspond to cycle range and the columns to cycle mean. The
%   vectors RMR and RMM contain bin edges for the rows and columns of RM,
%   respectively.
%
%   [C,RM,RMR,RMM,IDX] = RAINFLOW(...) returns the linear indices of the
%   identified extrema in X.
%
%   RAINFLOW(...) with no output arguments plots load reversals and a
%   rainflow matrix histogram for X in the current figure.
%
%   % Example 1 
%   %   Compute cycle counts for a set of extrema and display a
%   %   histogram.
%   X = [-2 1 -3 5 -1 3 -4 4 -2]';
%   [C,hist,edges] = rainflow(X,'ext');
%   subplot(2,1,1)
%   plot(X)
%   xlabel('Sample Index')  
%   ylabel('Stress')
%   subplot(2,1,2)
%   histogram('BinEdges',edges','BinCounts',sum(hist,2))
%   xlabel('Stress Range')  
%   ylabel('Cycle Counts')
%
%   % Example 2 
%   %   Display extrema and a rainflow matrix for a random noise signal.
%   fs = 100;
%   t = seconds((0:10^5-1)'/fs);
%   x = randn(size(t));
%   TT = timetable(t,x);
%   rainflow(TT)
%
%   See also FINDPEAKS, HISTCOUNTS, HISTCOUNTS2.

%   Copyright 2017-2018 MathWorks, Inc.

%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

narginchk(1,3);
nargoutchk(0,5);

isInMATLAB = coder.target('MATLAB');

if nargout == 0 && ~isInMATLAB
    % Plotting is not supported for code generation. If this is running in
    % MATLAB, just call MATLAB's RAINFLOW, else error.
    coder.internal.assert(coder.target('MEX') || coder.target('Sfun'), ...
        'signal:codegeneration:PlottingNotSupported');
    feval('rainflow',x,varargin{:});
    return
end

[x,t,ext,td] = parseInputs(x,varargin{:});

% Validate extrema, if provided.
if ext
  validateExt(x);
end

% Find extrema.
idx = signal.internal.rainflow.callFindExtrema(x,ext,isInMATLAB);

% Perform rainflow counting.
CM = signal.internal.rainflow.callCountCycles(x,idx,isInMATLAB);

% Create the output matrix.
C = [CM(:,1:3) t(idx(CM(:,4))) t(idx(CM(:,5)))];

if nargout == 0 || nargout > 1 
  % Compute the rainflow matrix. Add an extra set of counts for whole
  % cycles. To get the number of cycles, divide histogram values by 2.
  iWhole = find(CM(:,1) == 1);
  XC = [C(:,2); C(iWhole,2)];
  XM = [C(:,3); C(iWhole,3)];
  [RM1,xedges,yedges] = localhistcounts2(XC,XM(:));
  RM = RM1/2;
  RMR = xedges(:); 
  RMM = yedges(:); 
  
  % Plot rainflow matrix if no outputs are requested.
  if nargout == 0 && isInMATLAB
    if isempty(td)
      plotRainflow(t(idx),[],x(idx),RM,xedges,yedges)
    else
      plotRainflow(t(idx),td(idx),x(idx),RM,xedges,yedges)
    end
  end
end

if nargout > 0
  varargout{1} = C;
end

if nargout > 1 
  varargout{2} = RM;
end

if nargout > 2 
  varargout{3} = RMR;
end

if nargout > 3 
  varargout{4} = RMM;
end

if nargout > 4 
  varargout{5} = idx;
end

end
%--------------------------------------------------------------------------
function [x,t,ext,td] = parseInputs(x,varargin)

isInMATLAB = coder.target('MATLAB');

% Parse and remove the 'ext' flag
iChar = false(nargin - 1,1);
iExt = false(nargin - 1,1);
argsToParse = cell(1,0);
for i = 1:nargin - 1
    cond = isstring(varargin{i}) && ~isscalar(varargin{i});
    coder.internal.errorIf(cond,'signal:rainflow:InvalidOption');
    iChar(i) = ischar(varargin{i}) || isstring(varargin{i});
    iExt(i) = strncmpi('ext',varargin{i},2);
    if ~iExt(i)
        argsToParse{end+1} = varargin{i};
    end
end

% Error out if we have 3 input arguments and none of them is a string.
if nargin>2 && ~any(iChar)
  validateattributes(varargin{2},{'string','char'},{},'rainflow','');
end

% Error out if we have more than one string or any string is not 'ext'.
cond = sum(iChar) > 1 || any(iChar) && ~any(iExt);
if cond
    coder.internal.errorIf(cond,...
         'signal:rainflow:InvalidOption');
end

ext = false;
if any(iExt)
  ext = true;
end

% Parse signal and time information. Store duration, datetime, or sample
% information in td for plotting.
if isempty(argsToParse)
  [x,t,td] = signal.internal.nvh.parseTimeCodegen(x,'rainflow',[],false);
else
  [x,t,td] = signal.internal.nvh.parseTimeCodegen(x,'rainflow',argsToParse{1},false);
end

% Validate type and attributes.
validateattributes(x,{'single','double'},...
  {'real','finite','nonsparse','vector',},'rainflow','X');
validateattributes(t,{'single','double'},...
  {'real','finite','nonsparse','vector','increasing',...
  'numel',length(x)},'rainflow','T');

x = x(:);
t = t(:);

% Check that x and t have at least 3 samples
if isInMATLAB
  if numel(x) < 3 || numel(t) < 3
    error(message('signal:rainflow:ThreeSamples'))
  end
else
  coder.internal.assert(numel(x) >= 3 && numel(t) >= 3,'signal:rainflow:ThreeSamples');
end

if isInMATLAB
  % Cast to enforce precision rules
  if isa(x,'single')
    t = single(t);
  elseif isa(x,'double')
    t = double(t);
  end
end

end
%--------------------------------------------------------------------------
function plotRainflow(t,td,y,RM,xedges,yedges)
% Convenience plot for rainflow.
newplot;

p1 = subplot(2,1,1);
if isempty(td)
  [~,E,U]=engunits(t,'unicode','time');
  plot(t*E,y);
  xlab = [getString(message('signal:rainflow:Time')) ' (' U ')']; 
else
  plot(td,y);
  if isequal(t,td)
    % We are in samples.
    xlab = getString(message('signal:rainflow:Samples')); 
  else
    xlab = getString(message('signal:rainflow:Time'));
  end  
end
xlabel(xlab)
ylabel(getString(message('signal:rainflow:Amplitude')))
title(getString(message('signal:rainflow:LoadReversals')))
grid on
p2 = subplot(2,1,2);
histogram2('XBinEdges',xedges,'YBinEdges',yedges,'BinCounts',RM,'FaceColor','flat');
colorbar;
xlabel(getString(message('signal:rainflow:CycleRange')))
ylabel(getString(message('signal:rainflow:CycleAverage')))
zlabel(getString(message('signal:rainflow:NumberOfCycles')))
title(getString(message('signal:rainflow:RainflowMatrixHistogram')))

% Resize the plots, make the time series plot smaller.
p1p = get(p1,'position');
p1p(2) = p1p(2)+p1p(4)/2;
p1p(4) = p1p(4)/2;
set(p1,'position',p1p)
p1p = get(p1,'position');
p2p = get(p2,'position');
p2p(4) = 0.75*(p1p(2)-p2p(2));
set(p2,'position',p2p)

% Make the time series plot tight in x and give a margin in y
axis(p1,'tight');
yl = signal.internal.nvh.plotLimits(get(p1,'ylim'));
set(p1,'ylim',yl);

xl = signal.internal.nvh.plotLimits(get(p2,'xlim'));
set(p2,'xlim',xl);
yl = signal.internal.nvh.plotLimits(get(p2,'ylim'));
set(p2,'ylim',yl);

% Create tags
p1.Tag = 'Series';
p2.Tag = 'Matrix';

% Set NextPlot to replace to clobber next time a plot command is issued.
set(p2.Parent,'NextPlot','replace');

end
%--------------------------------------------------------------------------
function validateExt(ext)
% Warn if provided extrema don't have alternating positive and negative
% slope.
dext = diff(ext)>0;
if ~(all(dext(1:2:end) == dext(1)) && all(dext(2:2:end) == dext(2)))
  coder.internal.warning('signal:rainflow:InvalidExt');
end

end
%--------------------------------------------------------------------------
function [rm,xedges,yedges] = localhistcounts2(xc,xm)
% Compute two-dimensional histogram.
isSingle = isa(xc,'single');
n_edges=11;
binWidth=0.1;
edgesx = zeros(1,n_edges);
for i=1:n_edges
    edgesx(1,i)=(i-1)*binWidth;
end
[~,xedges,binx] = histcounts(xc,edgesx); % specific edges for range
[~,yedges,biny] = histcounts(xm,1); % only 1 bin for average

% [~,xedges,binx] = histcounts(xc,10);
% [~,yedges,biny] = histcounts(xm,10);
countslenx = length(xedges)-1;
countsleny = length(yedges)-1;
subs = [binx(:) biny(:)];
if coder.target('MATLAB')
  if isSingle
    val = ones(size(subs,1),1,'like',single(0));
  else
    val = ones(size(subs,1),1);
  end
  rm = accumarray(subs,val,[countslenx countsleny]);
else
  rm = signal.internal.rainflow.AccumHistArray(subs,[countslenx countsleny],isSingle);
end

end

