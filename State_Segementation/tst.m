[filenameIn pathname] = uigetfile('.mat','input the long coord','multiselect','on');

% convert single file selection
if ~iscell(filenameIn)
    filename{1} = filenameIn;
else
    filename = filenameIn;
end

CountIndex = 1;

for ii = 1 : length(filename)
    filenameX = filename{ii};
    load([pathname filenameX]);
    for jj = 1 : length(tracksFinal)
        CountIndex = CountIndex +1;
    end
end

disp(['Experiment: ' pathname]);
disp(['There are ' num2str(CountIndex) ' raw trajectories']);

%% 

Experiment = '2D_Tracking'; 
ExpT = 0.5; % timeinterval in second
PixelS = 100; % pixel size in nm
ThreshT = 10; % the threshold of trajectory length. Only select the trajectories longer than this
[filenameIn pathname] = uigetfile('.mat','input the unwrapped trajectory files','multiselect','on');

%%Refine_Trajectories(filenameIn,pathname,Experiment,ExpT,PixelS,ThreshT);

CountIndex = 1; % an index for later filter

% convert single file selection
if ~iscell(filenameIn)
    filename{1} = filenameIn;
else
    filename = filenameIn;
end

% import trajectroy data to get the statistic properties
I_all = []; % variable to save all the intensity values
time_all = []; % variable to save time boundary in nanopillar condition.
disp('Loading all files in one condition for intensity analysis...')
for ii = 1 : length(filename)
    filenameX = filename{ii};
    load([pathname filenameX]);
    for jj = 1 : length(TraceInfo)
        Track = TraceInfo(jj).TraceInfo.TrackcOR_unwrap;
        for kk = 1 : length(Track)
            CountIndex = CountIndex +1;
        end
    end
end

disp(['There are ' num2str(CountIndex) ' refined trajectories']);