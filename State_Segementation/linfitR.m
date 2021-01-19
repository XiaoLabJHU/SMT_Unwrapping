function [FitTrace, p, Displ, StD, Ratio] = linfitR(Time,Trace)
% function linfitR fit a trace with linear function
% Input: Time and the corresponding position
% Output: FitTrace: fit line
%         p: fit parameter, p(1) is velocity
%         Displ: the total displacement
%         StD: the average standard deviation
%         Ratio: the ratio of StD to Displ
p = polyfit(Time,Trace,1); % linear fit
Displ = p(1) * (Time(end) - Time(1)); % the displacement of x from linear fit of this segment
FitTrace = p(1)*Time + p(2);
StD = std(Trace-FitTrace);
Ratio = StD/(Displ+0.00001);