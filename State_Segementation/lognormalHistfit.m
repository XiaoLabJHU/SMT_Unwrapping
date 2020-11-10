function [pd1,I_peak,I_sd] = lognormalHistfit(I_all)
%lognormalHistfit    Fot a distribution using log-normal distribution
%(output the fitting result)
%   PD1 = lognormalHistfit(I_ALL)
%   Creates a plot, similar to the plot in the main distribution fitter
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with dfittool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  1
%   Number of fits:  1
%
%   See also FITDIST.

% This function was automatically generated on 14-Apr-2020 16:57:11

% Output fitted probablility distribution: PD1

% Data from dataset "I_all data":
%    Y = I_all

% Force all inputs to be column vectors
I_all = I_all(:);

% Prepare figure
clf;
hold on;
LegHandles = []; LegText = {};


% --- Plot data originally in dataset "I_all data"
[CdfF,CdfX] = ecdf(I_all,'Function','cdf');  % compute empirical cdf
BinInfo.rule = 1;
[~,BinEdge] = internal.stats.histbins(I_all,[],[],BinInfo,CdfF,CdfX);
[BinHeight,BinCenter] = ecdfhist(CdfF,CdfX,'edges',BinEdge);
hLine = bar(BinCenter,BinHeight,'hist');
set(hLine,'FaceColor','none','EdgeColor',[0.333333 0.666667 0],...
    'LineStyle','-', 'LineWidth',1);
xlabel('Data');
ylabel('Density')
LegHandles(end+1) = hLine;
LegText{end+1} = 'I_all data';

% Create grid where function will be computed
XLim = get(gca,'XLim');
XLim = XLim + [-1 1] * 0.01 * diff(XLim);
XGrid = linspace(XLim(1),XLim(2),100);


% --- Create fit "fit"

% Fit this distribution to get parameter values
% To use parameter estimates from the original fit:
%     pd1 = ProbDistUnivParam('lognormal',[ 4.063612788071, 0.6516716449438])
pd1 = fitdist(I_all, 'lognormal');
YPlot = pdf(pd1,XGrid);
hLine = plot(XGrid,YPlot,'Color',[1 0 0],...
    'LineStyle','-', 'LineWidth',2,...
    'Marker','none', 'MarkerSize',6);
LegHandles(end+1) = hLine;
LegText{end+1} = 'log-normal fit';


% get the mu and sigma from the fitting
mu = pd1.ParameterValues(1);
sigma = pd1.ParameterValues(2);
% calculate the mean and standard deviation
% I_mean = exp(mu+sigma^2/2);
I_peak = exp(mu - sigma^2);
I_sd = sqrt((exp(sigma^2)-1)*exp(2*mu+sigma^2));
% plot them out
xline(I_peak,'-k',['Ipeak = ' num2str(I_peak)]);
xline(I_peak + I_sd,'-b',['1 sigma = ' num2str(I_peak + I_sd)]);
xline(I_peak + 2*I_sd,'-r',['2 sigma = ' num2str(I_peak + 2*I_sd)]);
xline(I_peak + 3*I_sd,'-g',['3 sigma = ' num2str(I_peak + 3*I_sd)]);
% Adjust figure
box on;
hold off;

% Create legend from accumulated handles and labels
hLegend = legend(LegHandles,LegText,'Orientation', 'vertical', 'FontSize', 9, 'Location', 'northeast','Box','Off');
set(gca,'XColor','k','YColor','k','Box','Off','LineWidth',1.3,'TickDir','Out');

set(hLegend,'Interpreter','none');
