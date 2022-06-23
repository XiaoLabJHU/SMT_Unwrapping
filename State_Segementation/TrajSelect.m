% take a structure, select and truncate trajectories to n length regardless
% if the frames are continuous or discontinous
% 

function s_n=TrajSelect(s, n)

cts=0;

for i=1:length(s)
    len=length(s(i).frames);
    if len>=n
        cts=cts+1;
        s_n(cts).frames=s(i).frames(1:n);
        s_n(cts).coordinates=s(i).coordinates(1:n,:);
        %s_n(cts).intensity=s(i).intensity(1:n,:);
        %s_n(cts).mol_id=s(i).mol_id;
        %s_n(cts).data_id=s(i).data_id;
    else
    end
end
