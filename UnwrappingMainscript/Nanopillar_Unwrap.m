function Nanopillar_Unwrap(CircleFits,Exposure_Time,Dark_Time,px_size,FileSaveName);
disp('Unwrapping trajectories...');
file_prev = '0';
path = pwd;
slashes = find(path == '\');
FileDate = path(slashes(end-1)+1:slashes(end-1)+8);
filesave = ['TraceInfo-' FileDate '-' FileSaveName '-'];
for idxa = 1:length(CircleFits);
    info = []; w = 0;
    track_curr = CircleFits(idxa).Source;
    tracks = load([track_curr '.mat']);
    TracksROI = tracks.tracksRefine.TracksROI;
    file_root = track_curr;
    file_num = track_curr(find(track_curr=='-')+1:find(track_curr=='-')+2);
    if strcmp(file_num,file_prev)
        cell = str2num(track_curr(end));
    else
        cell = 1;
    end
    CF(:,1) = CircleFits(idxa).CircleFitLine(1,1:end/2).';
    CF(:,2) = CircleFits(idxa).CircleFitLine(1,end/2+1:end).'; 
    for idx = 1:length(TracksROI);
        trace = [];
        coords = [];
        temp_coord = [];
        trace = TracksROI(idx).Coordinates;
        index = TracksROI(idx).Index;
        time = (trace(:,1)-min(trace(:,1)))*(Exposure_Time + Dark_Time);

        if length(trace) > 10;
            w = w + 1;
            info.FileDate = FileDate;
            info.Source = pwd;
            info.FileName = file_root; 
            info.TrackcOR_unwrap(w).RawTraj = trace;
            info.TrackcOR_unwrap(w).Intensity = trace(:,5);
            info.TrackcOR_unwrap(w).Time = trace(:,1);
            info.TrackcOR_unwrap(w).XYCoord = trace(:,2:3);
            info.CircleFit = [CF(:,1),CF(:,2)];
            info.Radius = CircleFits(idxa).Radius ;
            info.Center = CircleFits(idxa).CenterCoord;
            % see if ring was rotated left or right
            [xSorted,iSorted] = sort(trace(:,2)); 
            ySorted = trace(iSorted,3);
            yMid = round(length(ySorted)/2);
            rotClockwise = mean(ySorted(1:yMid)) < mean(ySorted(yMid:end));

            thetas_peeled = [];
            temp_coord = [];
            if rotClockwise;
                temp_coord = [trace(:,2)-CircleFits(idxa).CenterCoord(1), trace(:,3)-CircleFits(idxa).CenterCoord(2)];
            else
                temp_coord = [-(trace(:,2)-CircleFits(idxa).CenterCoord(1)), trace(:,3)-CircleFits(idxa).CenterCoord(2)];
            end

            %Unwrap the circle.
            [thetas, rhos_peeled] = cart2pol(temp_coord(:,1),temp_coord(:,2));
            for idxc = 2:length(thetas);
                previous_theta = thetas(idxc-1);
                if thetas(idxc)-previous_theta > pi;
                   thetas(idxc) = thetas(idxc) - 2*pi; 
                elseif thetas(idxc)-previous_theta < -pi;
                   thetas(idxc) = thetas(idxc) + 2*pi;
                end
            end
            rho_residuals = rhos_peeled - CircleFits(idxa).Radius;

            % convert angles from radians to nm along circumference and save.
            thetas_peeled = thetas .* CircleFits(idxa).Radius .* px_size;
            info.TrackcOR_unwrap(w).rawthetas = thetas;
            info.TrackcOR_unwrap(w).thetas_peeled = thetas_peeled;
            info.TrackcOR_unwrap(w).time = time;
            info.TrackcOR_unwrap(w).rhos_peeled = rhos_peeled;
            info.TrackcOR_unwrap(w).rho_residuals = rho_residuals;
            info.TrackcOR_unwrap(w).Diameter = CircleFits(idxa).Radius*2*px_size;
        end
    end
    
    if isempty(info);
        display(['Region ' track_curr(find(track_curr == '-')+1:end) ' has trajectories less than 10 steps. not Included!'])
    else
        if strcmp(file_num,file_prev);
            TraceInfo(length(TraceInfo)+1).TraceInfo = info;
        else
            clear TraceInfo
            TraceInfo.TraceInfo = info; 
        end
        clear info;
        save([filesave file_num '.mat'],'TraceInfo');
        file_prev = file_num;
    end
end
disp('Done!');
end