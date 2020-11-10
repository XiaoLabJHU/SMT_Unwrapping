function [approxsum]=ApproxSum(Coeff, t)

% set acceptable error
err=1.e-7;

L=Coeff(1);
s=Coeff(2);

i=1;
sum=0;
diff=inf;
while abs(diff) > err
    last_sum=sum;
    sum=sum+1/(i^4)*exp(-0.5*i^2*pi^2*s^2/L^2*t);
    %fprintf('%i %f\n',i,sum);
    diff=sum-last_sum;
    i=i+2;
    if i>1000
        error('Sum did not converge after 1000 iterations')
    end
end

if sum ~= inf
    approxsum=sum;
else
    error('Sum did not converge');
end

end

%%