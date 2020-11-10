function s_MSD=MSDcalculate_2d(struc,pixelsize,frameT,darkT,CMode)
%% calculate MSD from a structure 
%   Modified from Jie's code MSD_all
% only calculate the dimension msd 
% input : struc : the data structure
%        pixelsize : the dimension of single pixel in nm
%        frameT : the exposure time in s
%        darkT : the dark time between two frames in s
%         dim   : the dimension for calculation (1:x,2:y)
%        CMode : calculation mode 
%                'all': use every interval time
%                'consec' : use consecutive traces
% output :   s_MSD: MSD data
%                   column 1: time index
%                   column 2: MSD
%                   column 3: std of MSD

if nargin<5
    CMode='all';
end
if nargin<4
    error('not enough input!');
    return;
end

% determine which mode should use
if strcmp(CMode,'consec')
    struc_r=TrajConsec(struc); % devide the discrete traj
else
    struc_r=struc;
end
S=struc_r.TracksROI;
%  determine the length of MSD
for idxN=1:length(S)
    Coordinates=S(idxN).Coordinates;
    N_msd(idxN)=Coordinates(end,1)-Coordinates(1,1);
end
N_msdmax=floor(max(N_msd)/2); %the length of MSD is about the half of the longest traj

% calculate MSD one by one

for idxM=1:N_msdmax
    MSD_temp=[]; % initial
    for idxN=1:length(S)
        Coordinates=S(idxN).Coordinates;
        frames=Coordinates(:,1)-Coordinates(1,1)+1;
        for idxQ=1:min((frames(end)-idxM),length(frames))
            Startf=frames(idxQ);
            Endf=find(frames==(Startf+idxM));   
            if Endf
                Startp=Coordinates(idxQ,2:3);
                Endp=Coordinates(Endf,2:3);
                SquareD=sum(((Startp-Endp)*(pixelsize)).^2); % square displacement in nm
                MSD_temp=[MSD_temp;SquareD];
            end
        end
    end
    if isempty(MSD_temp)
        MSD(idxM,2)=NaN;
    else
        MSD(idxM,2)=mean(MSD_temp);
        stats=bootstrp(1000, @mean, MSD_temp);
        MSD(idxM,3)=std(stats);
    end
end
Timebin=(1:N_msdmax)*(frameT+darkT);
MSD(:,1)=Timebin';
MSD(~any(isnan(MSD),2),:);
s_MSD=MSD;
