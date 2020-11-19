%% bootstrap 1000 times of the velocity to calculate the cdf curves
% fit the cdf curves by single population and calculate the mean speed and percentage
clear
clc
Nbin = 30; % Bin size of the CDF curve
LowB = -1.5; % lower bound of X axis = 10^LowB
HighB = 3; % upper bound of X axis = 10^LowB
N = 1000; % bootstrapping time
[filename_cdf pathname_cdf] = uigetfile('.mat','input the unwrapped trajectory files','multiselect','on');
Fit_single = [];
for idT = 1 : length(filename_cdf)
    h = figure('position',[100,50,1200,900])
    load([filename_cdf{idT}]);
    filenameTemp = filename_cdf{idT};
    ConditionName = filenameTemp(strfind(filenameTemp,'VT') + 2 : find(filenameTemp == '.')-1);
    xbin = logspace(LowB, HighB, Nbin);
    [bootV,bootVdir] = bootstrp(N,@mean,Vdirx);
    [bootTr] = bootstrp(N,@sum,Tdir);
    [bootTc] = bootstrp(N,@sum,Tdif);
    Pt = bootTr./(bootTc + bootTr); % percentage of moving population
    FractT = [mean(Pt), std(Pt)];
    for idB = 1 : N
        VdirxT = Vdirx(bootVdir(:,idB));
        CDF = CDF_logCalc(VdirxT,xbin);
        CDFboot(:,idB) = CDF;
            % single population fitting
            P_fit1 = lsqcurvefit(@logn1cdf,[0.5,2,0.5],xbin,CDF,[0.99,0,0],[1,5,5]);
            CDF_fit1_boot = logn1cdf(P_fit1,xbin);
            Fit_Vdirx1 = [P_fit1(1),exp(P_fit1(2)+P_fit1(3)^2/2),sqrt((exp(P_fit1(3)^2)-1)*exp(2*P_fit1(2)+P_fit1(3)^2)) ];
    end
    Fit_final_mean = mean(Fit_Vdirx1_boot,1);
    Fit_final_sem = std(Fit_Vdirx1_boot,[],1);
    CDF_mean = mean(CDFboot,2);
    CDF_sem = std(CDFboot,[],2);
    CDF_fit_mean = mean(CDF_fit1_boot,2);
    CDF_fit_sem = std(CDF_fit1_boot,[],2);
    semilogx(xbin,CDF_fit_mean,'m','linewidth',2);
    hold on
    errorbar(xbin,CDF_mean,CDF_sem);
    title(ConditionName);
%     legend({'data',['V1 = ' num2str(Fit_Vdirx1(2)) 'nm/s'], ['V2 = ' num2str(Fit_Vdirx2(1,2)) ' and ' num2str(Fit_Vdirx2(1,5)) 'nm/s']},'location','southeast')
    set(gca,'fontsize',20);
    ylabel('CDF','fontsize',24);
    xlim([2,300])
    saveas(h,['cdfFit_' ConditionName '.jpg'],'jpg');
    close all
%     Fit_single = [Fit_single; Fit_Vdirx1];
%     Fit_double_free = [Fit_double_free; Fit_Vdirx2];
    C{idT,1} =  ConditionName;
    doubleF = [doubleF; P_fit2];
    save([filename_cdf{idT}],'xbin','CDFboot', 'CDF_mean','CDF_sem','CDF_fit_mean','CDF_fit_sem','P_fit2_boot','CDF_fit2_boot','Fit_Vdirx2_boot','Fit_final_mean','Fit_final_sem','-append');
end
%% bootstrap 1000 times of the velocity to calculate the cdf curves
% fit the cdf curves by double population and calculate the mean speed and percentage
clear
clc
Nbin = 30; % Bin size of the CDF curve
LowB = -1.5; % lower bound of X axis = 10^LowB
HighB = 3; % upper bound of X axis = 10^LowB
N = 1000; % bootstrapping time
[filename_cdf pathname_cdf] = uigetfile('.mat','input the unwrapped trajectory files','multiselect','on');
Fit_double_free = [];
doubleF = [];
for idT = 1 : length(filename_cdf)
    h = figure('position',[100,50,1200,900])
    load([filename_cdf{idT}]);
    filenameTemp = filename_cdf{idT};
    ConditionName = filenameTemp(strfind(filenameTemp,'VT') + 2 : find(filenameTemp == '.')-1);
    xbin = logspace(LowB, HighB, Nbin);
    [bootV,bootVdir] = bootstrp(N,@mean,Vdirx);
    [bootTr] = bootstrp(N,@sum,Tdir);
    [bootTc] = bootstrp(N,@sum,Tdif);
    Pt = bootTr./(bootTc + bootTr);
    FractT = [mean(Pt), std(Pt)];
    for idB = 1 : N
        VdirxT = Vdirx(bootVdir(:,idB));
        CDF = CDF_logCalc(VdirxT,xbin);
        CDFboot(:,idB) = CDF;
        P_fit2 = lsqcurvefit(@logn2cdf,[0.5,2,0.5,3,2],xbin,CDF,[0,0,0,0,0],[1,5,5,5,5]);
        CDF_fit2 = logn2cdf(P_fit2,xbin);
        P_fit2_boot(idB,:) = P_fit2;
        CDF_fit2_boot(:,idB) = CDF_fit2;
        Fit_Vdirx2 = [P_fit2(1)*100,exp(P_fit2(2)+P_fit2(3)^2/2),sqrt((exp(P_fit2(3)^2)-1)*exp(2*P_fit2(2)+P_fit2(3)^2)),(1 - P_fit2(1))*100,exp(P_fit2(4)+P_fit2(5)^2/2),sqrt((exp(P_fit2(5)^2)-1)*exp(2*P_fit2(4)+P_fit2(5)^2)) ];
        Fit_Vdirx2_boot(idB,:) = Fit_Vdirx2;
    end
    Fit_final_mean = mean(Fit_Vdirx2_boot,1);
    Fit_final_sem = std(Fit_Vdirx2_boot,[],1);
    CDF_mean = mean(CDFboot,2);
    CDF_sem = std(CDFboot,[],2);
    CDF_fit_mean = mean(CDF_fit2_boot,2);
    CDF_fit_sem = std(CDF_fit2_boot,[],2);
    semilogx(xbin,CDF_fit_mean,'m','linewidth',2);
    hold on
    errorbar(xbin,CDF_mean,CDF_sem);
    title(ConditionName);
%     legend({'data',['V1 = ' num2str(Fit_Vdirx1(2)) 'nm/s'], ['V2 = ' num2str(Fit_Vdirx2(1,2)) ' and ' num2str(Fit_Vdirx2(1,5)) 'nm/s']},'location','southeast')
    set(gca,'fontsize',20);
    ylabel('CDF','fontsize',24);
    xlim([2,300])
    saveas(h,['cdfFit_' ConditionName '.jpg'],'jpg');
    close all
%     Fit_single = [Fit_single; Fit_Vdirx1];
%     Fit_double_free = [Fit_double_free; Fit_Vdirx2];
    C{idT,1} =  ConditionName;
    doubleF = [doubleF; P_fit2];
    save([filename_cdf{idT}],'xbin','CDFboot', 'CDF_mean','CDF_sem','CDF_fit_mean','CDF_fit_sem','P_fit2_boot','CDF_fit2_boot','Fit_Vdirx2_boot','Fit_final_mean','Fit_final_sem','-append');
end