function [CDF] = CDF_logCalc(Data,xbin)
%   CDF_logCalc calculate the cdf from raw data with a defined x bin
% CDF = ones(size(xbin));
N_tot = length(Data);
for ii = 1 : length(xbin)
    B_x = xbin(ii);
    N_temp = sum(Data <= B_x);
    CDF(ii) = N_temp/N_tot;
end

end

