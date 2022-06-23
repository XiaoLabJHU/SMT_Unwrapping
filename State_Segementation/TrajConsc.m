
%%
% rewrote the function to accomendate for up to n frames apart (120831)

% this function take the original s structure and break each trajectories
% into ones that only contain consecutive frames (when n= 1), or
% trajectories that contain frames <= n frames apart

% added 'uni' in the function if one wants to only isolate one longest trajectory
% per molecule . specify uni= any number to do so. If the 'uni' input is not there
% the default is to truncate one trajectory to multiple  conseceutic ones
% (JX121121)

function s_consc=TrajConsc(s, n, uni)

if nargin==2 % default, break one molecule's trajectory into multiple ones

    cts=0;
    for i = 1: length(s)
        f=s(i).frames;
    
        if length(f)==1
            cts=cts+1;
            s_consc(cts)=s(i);
        
        else
        
        f_diff=diff(f);
        ind=find(f_diff>n);
    
        if isempty(ind)
            cts=cts+1;
            s_consc(cts)=s(i);
        else
            
            for j =1: length(ind)+1
                if j == 1
                    cts=cts+1;
                    s_consc(cts).frames=f(1:ind(j));
                    s_consc(cts).coordinates=s(i).coordinates(1:ind(j), :);
                    s_consc(cts).intensity=s(i).intensity(1:ind(j));
                    s_consc(cts).mol_id=s(i).mol_id;
                    s_consc(cts).data_id=s(i).data_id;
                else
                    if j== length(ind)+1
                        cts=cts+1;
                        s_consc(cts).frames=f(ind(j-1)+1:end);
                        s_consc(cts).coordinates=s(i).coordinates(ind(j-1)+1:end, :);
                        s_consc(cts).intensity=s(i).intensity(ind(j-1)+1:end);
                        s_consc(cts).mol_id=s(i).mol_id;
                        s_consc(cts).data_id=s(i).data_id;
                    else
                        cts=cts+1;
                        s_consc(cts).frames=f(ind(j-1)+1:ind(j));
                        s_consc(cts).coordinates=s(i).coordinates(ind(j-1)+1:ind(j), :);
                        s_consc(cts).intensity=s(i).intensity(ind(j-1)+1:ind(j));
                        s_consc(cts).mol_id=s(i).mol_id;
                        s_consc(cts).data_id=s(i).data_id;
                    end
                end
            end
        end
        end
    end
    
    % if want to isolate one trajectory (longest) per molecule
else
        cts=0;
    for i = 1: length(s)
        
        f=s(i).frames;
    
        if length(f)==1
            cts=cts+1;
            s_consc(cts)=s(i);
        
        else
        
        f_diff=diff(f);
        ind=find(f_diff>n);
    
        if isempty(ind)
            cts=cts+1;
            s_consc(cts)=s(i);
        else
            
            cts=cts+1;
            cts_temp=0;
            f_temp=[];
            for j =1: length(ind)+1
                
                if j == 1
                    cts_temp=cts_temp+1;
                    f_temp(cts_temp).len=length(f(1:ind(j)));
                    f_temp(cts_temp).f_indx=1:ind(j);
                    
                else
                    if j== length(ind)+1
                        cts_temp=cts_temp+1;
                        f_temp(cts_temp).len=length(f(ind(j-1)+1:end));
                        f_temp(cts_temp).f_indx=ind(j-1)+1:length(f);
                    else
                        cts_temp=cts_temp+1;
                        f_temp(cts_temp).len=length(f(ind(j-1)+1:ind(j)));
                        f_temp(cts_temp).f_indx=ind(j-1)+1:ind(j);
                    end
                end
            end
            [len_max, I]=max([f_temp(:).len]);
            frames_indx=f_temp(I).f_indx;
            s_consc(cts).frames=f(frames_indx);
            s_consc(cts).coordinates=s(i).coordinates(frames_indx, :);
            s_consc(cts).intensity=s(i).intensity(frames_indx);
            s_consc(cts).mol_id=s(i).mol_id;
            s_consc(cts).data_id=s(i).data_id;
            
            
            
        end
        end
    end
    
        
end
    
    
end


    
                
                
                
        

