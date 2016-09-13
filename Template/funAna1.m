function ars = funAna1(arIn, study, flag)
if(~exist('flag','var') || isempty(flag))
    flag = '';
end

global ar
ar = arIn;
ar.PerformanceStudy = study;
ar.PerformanceStudy.computer = computer;
ar.PerformanceStudy.dateOfAnalysis = datestr(now,30);

arSave('funAna1');

ars = cell(0);

%% which run mode?
% mode 'test' should always be implemented as for quickly checking whether
% the analysis works without errors
switch lower(flag)
    case 'test'
        n = 3;
    otherwise
        n = 1000;
end

randomseed = 0;

%% Now evaluate interventions and comparator:
ar.config.optimizer = 1; 
ar.config.nCVRestart= 1;

arFitLHS(n, randomseed);
close all
arSave('funAna1_comparator')
ars{end+1} = ar;

ar.config.optimizer = -1;   % lb and ub ar ignored during fitting
ar.config.nCVRestart = 1; % No restarts
arFitLHS(n, randomseed);
close all
arSave('funAna1_useLHS_intervention_NoBounds')
ars{end+1} = ar;

