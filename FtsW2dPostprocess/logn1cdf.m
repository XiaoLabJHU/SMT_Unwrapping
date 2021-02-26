function CDF_res = logn1cdf(P,xdata)
% calculate the cdf curve of single lognormal distribution 
% xdata: the x axis 
% P: parameters for calculation
% [percentage of the first population, u1,sigma1,u2,sigma2]
CDF_res = P(1)*logncdf(xdata,P(2),P(3));