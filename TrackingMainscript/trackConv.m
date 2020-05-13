function [ tracksFinal ] = trackConv( TrajList )
%Convert the format of TrajList into trackFinal for further refine
%Input: TrajList is from function closeLink
%Output: trackFinal is for TraceRefine.m
%        each Coord is for one traj
%        column 1 is the frame
%        column 2-4 is the xyz-coordinates
%        column 5 is the intensity

TrajNode = TrajList(:,1);

for ii = 1 : max(TrajNode)
    TraceTemp = TrajList(find(TrajNode == ii),:);
    Traceframe = TraceTemp(:,2);
    TraceCoord = TraceTemp(:,4:7);
    tracksFinal(ii).Coord = [Traceframe,TraceCoord];
end

