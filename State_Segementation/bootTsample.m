function [T1 T2 R] = bootTsample(Tdir,Tdif,Nb)
% bootstrap the time in directional and stationary state.
% for ftsw tracking experiment
%   T1 and T2 are the bootstrapped sum of the Tdir and Tdif (mean and Std)
%   R is the precentage of Tdir in total (mean and Std)
bootT1 = bootstrp(Nb,@sum,Tdir);
bootT2 = bootstrp(Nb,@sum,Tdif);
T1 = [mean(bootT1),std(bootT1)];
T2 = [mean(bootT2),std(bootT2)];
bootR = bootT1./(bootT1 + bootT2);
R = [mean(bootR),std(bootR)];
end

