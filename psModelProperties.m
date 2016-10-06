% [arProp,fitProp] = psModelProperties(ars)
% 
%   This function extracts some valueable infromation from ar which could
%   serve as predictors. 
% 
%   ars         - either an ar struct
%               - a cell of ar structs
%               - a cell with field .ar, 
%                       e.g. ars{1}.ar = ar;
%                       e.g. ars{1} = load('x.mat','ar');
% 
%   arProp      Properties for each model, e.g. each LHS
%   fitProp     Properties for each fit, e.g. each individual LHS fit
% 
% Example:
% ars = psCollectStudyResults(studies,'LHS')
% [arProp,fitProp] = psModelProperties([ars{:}])

function [arProp,fitProp] = psModelProperties(ars)

if(~iscell(ars))
    ar = ars;
    ars = cell(1);
    ars{1}.ar = ar;
end

%%
fitProp = struct;  % In this struct, properties of individual fits are collected.
arProp = struct; % In this struct, properties of the settings (i.e. of ar) are collected.


for i=1:length(ars)
    if(isstruct(ars{i}) && isfield(ars{i},'checkstr')) % ar-struct
        artmp = ars{i};
    elseif(isstruct(ars{i}) && isfield(ars{i},'ar'))
        artmp = ars{i}.ar;
    elseif(iscell(ars{i}))
        artmp = ars{i};
    elseif isempty(ars{i})
        continue
    else
        ars{i}
        i
        error('case not implemented.')
    end
    try
        arProp.qLog10_mean(i) = mean(artmp.qLog10(artmp.qFit==1));             % 1 for log
        arProp.qLog10{i}      = artmp.qLog10;             % 1 for log
        arProp.p{i}           = artmp.p;             % 1 for log
        arProp.qFit{i}        = artmp.qFit;             % 1 for log
        arProp.qFit_mean(i)   = mean(artmp.qFit(artmp.qFit==1));             % 1 for log
        arProp.mean{i}        = artmp.mean;             % 1 for log
        arProp.std{i}         = artmp.std;             % 1 for log
        arProp.type{i}        = artmp.type;             % 1 for log
        arProp.type_mean(i)   = mean(artmp.type(artmp.qFit==1));             % 1 for log
        arProp.lb{i}          = artmp.lb;             % 1 for log
        arProp.ub{i}          = artmp.ub;             % 1 for log
        
        arProp.np(i)          = sum(artmp.qFit==1);
        arProp.ndata(i)       = artmp.ndata;
        arProp.lhs_seed(i)    = artmp.lhs_seed;
        
        arProp.checkstr{i}    = artmp.checkstr;
        arProp.nmodels(i)     = length(artmp.model);
        arProp.ndatasets{i}   = NaN(1,length(artmp.model));
        for m=1:length(artmp.model)
            arProp.ndatasets{i}(m)  = length(artmp.model(m).data);
        end
        arProp.nconditions{i}   = NaN(1,length(artmp.model));
        for m=1:length(artmp.model)
            arProp.nconditions{i}(m)  = length(artmp.model(m).condition);
        end
        
        tmp = strcat({artmp.model.name},',');
        tmp{end} = tmp{end}(1:end-1);
        arProp.modelnames{i}     = strcat(tmp{:});
        
        arProp.datanames = cell(size(artmp.model));
        for m=1:length(artmp.model)
            tmp = strcat({artmp.model.name},',');
            tmp{end} = tmp{end}(1:end-1);
            arProp.datanames{m}     = strcat(tmp{:});
        end
        
        fitProp.chi2s{i}          = artmp.chi2s;
        fitProp.chi2sconstr{i}    = artmp.chi2sconstr;
        fitProp.chi2s_start{i}    = artmp.chi2s_start;        
        fitProp.ps{i}             = artmp.ps;
        fitProp.ps_start{i}       = artmp.ps_start;
        fitProp.fun_evals{i}      = artmp.fun_evals;
        fitProp.iter{i}           = artmp.iter;
        fitProp.optim_crit{i}     = artmp.optim_crit;
        fitProp.timing{i}         = artmp.timing;
        fitProp.exitflag{i}       = artmp.exitflag;
        
        bollog = artmp.qLog10==1 & artmp.qFit==1;
        bolun = artmp.qLog10==0 & artmp.qFit==1;
        
        ublb = NaN(size(artmp.p));
        ublb(bollog) = artmp.ub(bollog)-artmp.lb(bollog);
        ublb(bolun) = log10(artmp.ub(bolun))-log10(artmp.lb(bolun));
        arProp.parasize(i) = nanmean(ublb);
        
        plog = NaN(size(artmp.p));
        plog(bollog) = artmp.p(bollog);
        plog(bolun) = log10(artmp.p(bolun));
        
        arProp.pSD(i) = nanstd(plog);
        arProp.pRange(i) = range(plog);
        arProp.pMin(i) = nanmin(plog);
        arProp.pMax(i) = nanmax(plog);
        
        lbunlog = NaN(size(artmp.p));
        ubunlog = NaN(size(artmp.p));
        lbunlog(bollog) = 10.^artmp.lb(bollog);
        lbunlog(bolun) = artmp.lb(bolun);
        ubunlog(bollog) = 10.^artmp.ub(bollog);
        ubunlog(bolun) = artmp.ub(bolun);
        
        arProp.pLB{i} = lbunlog;
        arProp.pUB{i} = ubunlog;
        
        fn_config = {'atol','atolV','atolV_Sens','fiterrors_correction','fiterrors','optimizer','rtol','useFitErrorCorrection','useJacobian','useLHS','useMS','useParallel','useSensis','useSparseJac'};
        for f=1:length(fn_config)
            if( (isnumeric(artmp.config.(fn_config{f})) || islogical(artmp.config.(fn_config{f}))) && length(artmp.config.(fn_config{f}))==1)
                arProp.(fn_config{f})(i) = artmp.config.(fn_config{f});
            else
                arProp.(fn_config{f}){i} = artmp.config.(fn_config{f});
            end
        end
        
        fn_opt = {'Algorithm','DiffMinChange','Hessian','Jacobian','TypicalX','MaxTime','MaxIter','TolFun','TolX','PrecondBandWidth','ScaleProblem','TolPCG',};
        for f=1:length(fn_opt)
            if( (isnumeric(artmp.config.optim.(fn_opt{f})) || islogical(artmp.config.optim.(fn_opt{f}))) && length(artmp.config.optim.(fn_opt{f}))==1)
                arProp.(fn_opt{f})(i) = artmp.config.optim.(fn_opt{f});
            else
                arProp.(fn_opt{f}){i} = artmp.config.optim.(fn_opt{f});
            end
        end
    catch err
        artmp
        i
        rethrow(err)
    end
end

arProp.ndata_np_ratio = arProp.ndata./arProp.np;
