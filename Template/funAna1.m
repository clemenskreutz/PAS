% ars = funAna1(arIn, study, option)
% 
%     Template for 
%     Study specific commands, e.g. chossing different algorithms.
% 
% 
%   option      in the template, the following options are available:
%           'test'
%           'first'
%           'hyper'
%           'final'

function ars = funAna1(arIn, study, option)
if(~exist('option','var') || isempty(option))
    option = '';
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
niter = 1000;
switch lower(option)
    case 'test'
        n = 3;
        dohyper = 0;
        niter = 20;
    case 'first'
        n = 100;
        dohyper = 0;
        
    case 'hyper'
        n = 100;
        dohyper = 1;
        
    case 'final'
        n = 1000;
        dohyper = 0;
                
    otherwise
        option
        error('funAna1.m: option flag unknown.')
end

randomseed = 0;

%% Now evaluate interventions and comparator:

% ar.config.optimizer = 1;  % here lsqnonlin
ar.config.nCVRestart= 1;
ar.config.optim.MaxIter = niter;

arFitLHS(n, randomseed);
close all
ar.intervention = 0; % label the comparator setting
arSave(['funAna1_LHS_comparator_',option])
ars{end+1} = arDeepCopy(ar);


%% adapt the following lines for defining the comparator
% ar.config.optimizer = 2;   % here, fmincon
% ar.config.nCVRestart = 1; % only a single restart

arFitLHS(n, randomseed);
close all
ar.intervention = 1;  % optional step: consecutive number can be used to label different interventions
arSave(['funAna1_LHS_intervention_',option])
ars{end+1} = arDeepCopy(ar);


if dohyper
    arComparator = arDeepCopy(ar);
    
    ex = psD2Doptions;
    fn = fieldnames(ex);
    for f=1:length(fn)
        ar = arDeepCopy(arComparator);
        
        disp(ex.(fn{f}));
        eval(ex.(fn{f}));

        arFitLHS(n, randomseed);
    
        close all
        ar.intervention = fn{f};  % optional step: consecutive number can be used to label different interventions
        arSave(['funAna1_LHS_intervention_',option,'_',fn{f}])
        ars{end+1} = ar;
    end

end
