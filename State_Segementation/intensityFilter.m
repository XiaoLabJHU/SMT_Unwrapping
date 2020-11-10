function [NewTrace] = intensityFilter(OldTrace,Thresh_I)
%intensityFilter remove high intensity points over Thresh_I
% input: OldTrace: first column: time
%                  second: Coords: x-y positions, 
%                  third: Intensity
% output: a cell of all new traces after filtering
Intensity = OldTrace(:,end);
indexI = find(Intensity < Thresh_I);
NewTrace = OldTrace(indexI,:);

end

