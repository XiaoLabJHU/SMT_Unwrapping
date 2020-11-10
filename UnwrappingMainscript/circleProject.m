function TraceXL_R = circleProject(Circle,TraceX,TraceZ)
%   convert the trace in x-z to x' on the circle
%   Circle is the center and radius [X,Z,R]
%   TraceX is the X positions 
%   TraceZ is the Z positions 
%%
CenterX = Circle(1);
CenterZ = Circle(2);
R = Circle(3);
deltaZ = TraceZ - CenterZ;
deltaX = TraceX - CenterX;
[Theta,rho] = cart2pol(deltaX,deltaZ);
for ii = 2 : length(Theta)
    Diff = Theta(ii) - Theta(ii-1);
    if abs(Diff) > pi
        if Diff > 0
            Theta(ii) = Theta(ii) - 2*pi;
        else
            Theta(ii) = Theta(ii) + 2*pi;
        end
    end
end
TraceXL_R = R * Theta;
end

