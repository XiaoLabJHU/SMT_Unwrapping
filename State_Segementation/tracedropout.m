function [V, Displ, StD, Ratio, N] = tracedropout(Time,Trace,Nboot,pdrop)
%tracedropout funciton do Nboot times of the Trace by dropping out pdrop
%percentage of points, and fit the rest of data points to a linear function
%Output: similar to linfitR but with Nboot columns with Nboots
Time = reshape(Time,[length(Time),1]);
Trace = reshape(Trace,[length(Trace),1]);
%%
RandN = rand(length(Time),Nboot);
LeftN = RandN > pdrop;
for ii = 1: Nboot
    TimeTemp = Time(find(LeftN(:,ii)>0));
    TraceTemp = Trace(find(LeftN(:,ii)>0));
    N(ii,1) = length(TimeTemp);
    [FitTrace, pn, Displn, StDn, Ration] = linfitR(TimeTemp,TraceTemp);
    V(ii,1) = abs(pn(1));
    Displ(ii,1) = abs(Displn);
    StD(ii,1) = abs(StDn);
    Ratio(ii,1) = abs(Ration);
end
%%
end

