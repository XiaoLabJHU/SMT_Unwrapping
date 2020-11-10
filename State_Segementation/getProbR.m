function Prob = getProbR(R_sample,Bin,epsl)
%getProbR take a simulated(or experiment) sample, and return the
%probability of the sample in a region[Bin(1),Bin(2)];
% arguments: R_sample： a random sample set of a certain random variable
%            Bin: a two element list, define the region to calculate the
%            probability
%            epsl: a small number to assign, in case you don't want
%            generate a 0 probability. default: 0.00001
% return: Prob: the probability of the random virable been located in the
% region of Bin
if nargin < 3
    epsl = 0.00001;
end
N_tot = length(R_sample); % the total number of the sample, used for normalization
N_p = sum(R_sample>=min(Bin)&R_sample<=max(Bin)); % number of the samples in the region
Prob = N_p/N_tot + epsl;
%make sure the probability is smaller than 1
if Prob > 1;
    Prob = 1;
end
end

