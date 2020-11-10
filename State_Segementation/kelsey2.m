function [g]=kelsey2(Coeff, dataset)
% test function for Least Squares minimization
% Coeff(1) = Lx
% Coeff(2) = sx
Lx=Coeff(1);

g=0;
for i=1:length(dataset)
    t=dataset(i,1);
    F=Lx^2/6-16*Lx^2/pi^4*ApproxSum(Coeff, t);
    squared_diff=(dataset(i,2)-F)^2;
    g=g+squared_diff;
end

end
    


