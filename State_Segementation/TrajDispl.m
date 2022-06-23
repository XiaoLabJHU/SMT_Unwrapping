% given a trajectory (traj), t, the time interval (in s) between subsequent frames, and the corresponding frame index of each coordinate pair in traj, 
% calculate the displacements at all possible time lags.
% the output is a list with first column being the time lags, 2nd column mean squared displacement of all pairs with the same time lag, 3rd column the calculated diffusion coefficient
% 
function d=TrajDispl(traj, t, frame)

if nargin==2   % if there is no frame information, it is assumed that all the coordiantes are in consequetive frames
    n=size(traj,1);
    for i = 1:n-1 % i is the time lag
        r=[];
        for j = 1: n-i % n-i is the total number of lags one can calculate for time lag t
            dif = 0.160 * (traj(j+i, :)-traj(j, :));% each pixel is 0.160 um
            r(j, 1)=sum(dif.^2); % sqaure displacement
            %r(j,1)=dif^2;
        end
        d(i, 1)=i;
        d(i, 2)=mean(r); 
    end
    
else
    n=length(traj);
    r_all=[];
    for i = 1:n-1 % i is the frame lag
        r=[];
        for j = 1: n-i % n-i is the total number of lags one can calculate for frame lag t
            r(j, 1)=frame(i+1)-frame(i); % convert frame lag to time lag
            dif=(traj(j+i, :)-traj(j, :));% each pixel is 0.160 um
            r(j, 2)=sum(dif.^2); % sqaure displacement
        end
        r_all(end+1:end+size(r, 1), :)=r;
    end
    
    time_lags=unique(r_all(:, 1)); % find all unique time lags
    
    for i=1:size(time_lags, 1)
        ind=find(r_all(:, 1)==time_lags(i));
        d(i, 1)=time_lags(i);
        d(i, 2)=mean(r_all(ind, 2));
    end
    
    
end
