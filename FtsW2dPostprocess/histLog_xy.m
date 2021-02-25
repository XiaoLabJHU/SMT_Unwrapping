function [HisRes,HisX,HisObj] = histLog_xy(x,LowLog,HighLog,Nbin)
%histLog_xy generate the histogram of x in a log space with
%   Nbins from 10^LowLog to 10^HighLog

if nargin < 5
    PlotMode = 0;
end
if nargin < 4
    error('Not enough inputs');
end

Xbin = logspace(LowLog, HighLog,Nbin);
[~,edges] = histcounts(x,Xbin);
HisObj = histogram(x,edges,'Normalization','probability');
HisX = HisObj.BinEdges;
HisRes = HisObj.Values;
HisObj.FaceColor = 'w';
set(gca,'Xscale','log')
end

