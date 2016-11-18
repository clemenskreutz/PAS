% ex = psD2Doptions
% ex = psD2Doptions(whichone)
% 
%   This function defines matlab expressions executed to alter modelling
%   options in D2D.
% 
%   whichone        flag indicating the set of options
%       'hyper1'    default: a set of options as one standard procedure for
%                   evaluating the impact of hyper-parameters
% 
% 


function ex = psD2Doptions(whichone)
if ~exist('whichone','var') || isempty(whichone)
    whichone = 'hyper1';
end

ex = struct;

switch lower(whichone)
    case 'hyper1'
        ex.tol_1over10 = 'ar.config.atol = ar.config.atol/10;ar.config.atol = ar.config.atol/10;';
        ex.tol_times10 = 'ar.config.atol = ar.config.atol*10;ar.config.rtol = ar.config.rtol*10;';
        ex.tolV_negotiated = 'ar.config.atolV = double(~ar.config.atolV);ar.config.atolV_Sens = double(~ar.config.atolV_Sens);';

        ex.fiterrors_negotiated = 'ar.config.fiterrors = double(~ar.config.fiterrors);';

        ex.maxsteps_twice = 'ar.config.maxsteps = ar.config.maxsteps*2;';

        ex.tolX_1over100 = 'ar.config.optim.TolX = ar.config.optim.TolX/100;';
        ex.tolX_times100 = 'ar.config.optim.TolX = ar.config.optim.TolX*100;';

    case 'tolfun1'
        ex.tolFun_1over1e4 = 'ar.config.optim.TolFun = 1e-4;';
        ex.tolFun_1over1e6 = 'ar.config.optim.TolFun = 1e-6;';
        ex.tolFun_1over1e8 = 'ar.config.optim.TolFun = 1e-8;';        
        
    case 'odetols1'
        ex.atol_1over10 = 'ar.config.atol = ar.config.atol/10;';
        ex.rtol_1over10 = 'ar.config.rtol = ar.config.rtol/10;';
        ex.atol_times10 = 'ar.config.atol = ar.config.atol*10;';
        ex.rtol_times10 = 'ar.config.rtol = ar.config.rtol*10;';
        
        ex.atol_1over100 = 'ar.config.atol = ar.config.atol/100;';
        ex.rtol_1over100 = 'ar.config.rtol = ar.config.rtol/100;';
        ex.atol_times100 = 'ar.config.atol = ar.config.atol*100;';
        ex.rtol_times100 = 'ar.config.rtol = ar.config.rtol*100;';

    case 'lsqnonlin1'
        ex.optimizer_fmincon = 'ar.config.optimizer = 2;';
        ex.Algorithm_LM = 'ar.config.optim.Algorithm = ''levenberg-marquardt'';';

end

