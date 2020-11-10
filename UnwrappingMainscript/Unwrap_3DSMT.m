function Unwrap_3DSMT(filename,pathname);
options = optimoptions('lsqnonlin','Display','off');
display('Processing the data...')
for ii = 1 : length(filename)
    filenameX = filename{ii};
    load([pathname filenameX]);
    for jj = 1 : length(TraceInfo);
        BFim = TraceInfo(jj).TraceInfo.BFrot;
        Track = TraceInfo(jj).TraceInfo.TrackcOR;
        Center = TraceInfo(jj).TraceInfo.Center;
        Radius = TraceInfo(jj).TraceInfo.Radius;
        Zcell = TraceInfo(jj).TraceInfo.CRadius;
        for kk = 1 : length(Track)
            Time = Track(kk).Time;
            XYZCoord = Track(kk).XYZCoord;
            Intensity = Track(kk).Intensity;
            % unwrap the 3D coordinates by fit the trajectory to the center and radius
            CircleL = [Center(1),max(Zcell,Radius(1)),Radius(1)];
            CircleM = [Center(1),max(Zcell,Radius(2)),Radius(2)];
            CircleS = [Center(1),max(Zcell,Radius(3)),Radius(3)];
            TraceX = XYZCoord(:,1);
            TraceZ = XYZCoord(:,3);
            Z0 = 0;
            lb = -5;
            ub = 5;               
            % fit 
            [ZL,resnorm,residual,exitflag,output,lambda,jacobian] = lsqnonlin(@(x)circleDist(x,CircleL, TraceX, TraceZ),Z0,lb,ub,options);
            ciL = nlparci(ZL,residual,'jacobian',jacobian);
            [ZM,resnorm,residual,exitflag,output,lambda,jacobian] = lsqnonlin(@(x)circleDist(x,CircleM, TraceX, TraceZ),Z0,lb,ub,options);
            ciM = nlparci(ZM,residual,'jacobian',jacobian);
            [ZS,resnorm,residual,exitflag,output,lambda,jacobian] = lsqnonlin(@(x)circleDist(x,CircleS, TraceX, TraceZ),Z0,lb,ub,options);
            ciS = nlparci(ZS,residual,'jacobian',jacobian); 
            TraceZL = TraceZ + ZL;
            TraceZM = TraceZ + ZM;
            TraceZS = TraceZ + ZS;
            % projrct the X-Z to the circle
            TraceXL_R = circleProject(CircleL,TraceX,TraceZL);
            TraceXM_R = circleProject(CircleM,TraceX,TraceZM);
            TraceXS_R = circleProject(CircleS,TraceX,TraceZS);
            % add to 2D
            XYCoord_large = [TraceXL_R,XYZCoord(:,2)];
            XYCoord_median = [TraceXM_R,XYZCoord(:,2)];
            XYCoord_small = [TraceXS_R,XYZCoord(:,2)];
            trace_unwrap = [XYCoord_large,XYCoord_median,XYCoord_small];
            Track(kk).XYCoord = trace_unwrap;
        end
        Track = rmfield(Track,'XYZCoord');
        TraceInfo(jj).TraceInfo.TrackcOR_unwrap = Track;
    end
    save([pathname filenameX],'TraceInfo');
end
display('Finished!')
end