function [ SpotsLink ] = gmtOptimize( Spots, R, Dth, Zf, If )
%   Link the spots by greedy climb optimization similar to Sbalzarini,2005.
%   Method: Calculate the cost value(square of diaplacement) between all different frames(i,i+r), r =
%   1:R. optimize the Gmat based on Cmat. The threshold for excluding far
%   spots is sqrt(R)*Dth^2 depending on the gap, R. The algorithm links the spots
%   with smaller gaps first. 

% input:
%       Spots: the coordinates list of all spots 
%              each .Coord is the coordinates of all the spots in that
%              frame
%              column 1: spot id (unique for every spot in the frame)
%              column 2: x-coordinates
%              column 3: y-coordinates
%              column 4: z-coordinates
%              column 5: spots intensity or other aspect as use defined
%              column 6: the previous frame linked to this spot, 0 means no
%              linkage now.
%              column 7: the spot id in the previous frame linked to this spot, 0 means no
%              linkage now.
%              column 8: the next frame linked to this spot, 0 means no
%              linkage now.
%              column 9: the spot id in the previous frame linked to this spot, 0 means no
%              linkage now.          

%       R : the gap allowed for linakage. All spots in the threshold and in
%       R frames will be linked together.

%       Dth: the displacement threshold, unit nm(or pixel based on the
%       ccordinates)

%       If and Zf are the weight of intensity and z coordinate
% (the cost function here does not consider the Z weight and I weight(Zf and
% If in function costPairwise)


% Output:
%        SpotsLink: the Spots structure with the linkage info updated.

% By Xinxing Yang@Xiaolab 20160704

%% initial some parameters
% Zf = 1;
% If = 0;
% R = 5;
% Dthresh = 300;
%%
for ff = 1 : R
    for jj = 1:length(Spots)-ff
        frame1 = jj;
        frame2 = jj+ff;
        
        % load the original coordinates
        
        Coordtemp1 = Spots(jj).Coord;
        Coordtemp2 = Spots(jj+ff).Coord;
        
        if ~isempty(Coordtemp1) & ~isempty(Coordtemp2)
            
            % refine the spot in the first frame but not link to the second one
            index1 = find(Coordtemp1(:,8) == 0);
            CoordT1 = Coordtemp1(index1,:);
            
            % refine the spot in the second frame but not link to the first frame
            index2 = find(Coordtemp2(:,6) == 0);
            CoordT2 = Coordtemp2(index2,:);
            
            if ~isempty(CoordT1) & ~isempty(CoordT2)
                % initiate the Cmat and Gmat
                CmatTemp =  costMat( CoordT1(:,2:5), CoordT2(:,2:5), Zf, If );
                Cmat = costMatThresh(CmatTemp,sqrt(ff)*Dth^2);
                Gmat = initialGmat(CoordT1(:,2:5), CoordT2(:,2:5), sqrt(ff)*Dth^2);
                
                % optimize the linkage of Gmat
                [Grow Gcol] = size(Gmat);
                for Gr = 1:Grow
                    for Gc = 1:Gcol
%                         Gr
%                         Gc
                        [ Gmatnew, Zij, flag ] = redCost( Gmat, Cmat, Gr, Gc );
                        if flag == 1
                            Gmat = Gmatnew;
                        end
                    end
                end
                
                % update the original Spots structure
                for Gr = 2:Grow % every spot in the previous frame1
                    G1 = Gmat(Gr,:);
                    Index = find(G1 == 1);
                    if Index > 1
                        CoordT1(Gr-1,8) = frame2;
                        CoordT1(Gr-1,9) = CoordT2(Index-1,1);
                    end
                end
                
                for Gc = 2:Gcol % every spot in the previous frame1
                    G2 = Gmat(:,Gc);
                    Index = find(G2 == 1);
                    if Index > 1
                        CoordT2(Gc-1,6) = frame1;
                        CoordT2(Gc-1,7) = CoordT1(Index-1,1);
                    end
                end
                
                % assign the linkage info to the original Spots,frame1
                for LL1 =  1: size(CoordT1,1)
                    id1 = CoordT1(LL1,1);
                    Coordtemp1(find(Coordtemp1(:,1)==id1),:) = CoordT1(LL1,:);
                end
                % assign the linkage info to the original Spots,frame2
                for LL2 =  1: size(CoordT2,1)
                    id2 = CoordT2(LL2,1);
                    Coordtemp2(find(Coordtemp2(:,1)==id2),:) = CoordT2(LL2,:);
                end                
                
                Spots(frame1).Coord = Coordtemp1;
                Spots(frame2).Coord = Coordtemp2;
            end
        end
    end
end
SpotsLink = Spots;
end

