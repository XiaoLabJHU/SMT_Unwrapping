function Add_Comments(Ind_path, com_path)

I = load(Ind_path);

C = readmatrix(com_path, Delimiter = '\t', OutputType = 'string');

end

            elseif strcmp(response,'Flag for review')
                %TD prompt for comment

                %ThreshN = inputdlg('Threshold = Ipeak+XIstd, please input X','Threshold Input (# SDs)');
                %ThreshN = str2num(ThreshN{1});
                comment = inputdlg('Why is this flagged?','Comment');
                comment = comment{1};

                review_list = [review_list; [string(Index) comment]];

                %TD write new line at the end of review list
                %[num2str(Index) comment]

                %
