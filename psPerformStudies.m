% ars = psPerformStudies(studies, flag)
% 
%   flag        ''  normal mode
%               'test' = test mode, i.e. a fast version used to check the
%               code
% 
% Examples:
%   studies = psDefineStudyExamples;
%   psPerformStudies(studies, 'test')
%   ars = psPerformStudies(studies);
% 

function ars = psPerformStudies(studies, flag)
if(~exist('flag','var') || isempty(flag))
    flag = '';
    %     flag = 'test';
end

global ar

ars = cell(size(studies));

pw = [pwd,filesep];
for s=1:length(studies)
    %     cd(studies(s).path)
    oldpath = pwd;
    
    
    try
        psLoadSaveTmp
    
        cd(strrep(studies(s).path,pw,''))
        
        %     try
        if(~isempty(studies(s).fun_setup))

            doEvalSetup(studies(s).fun_setup);
                            
            close all
            if(~isempty(studies(s).workspace))
                arLoadPars(studies(s).workspace)
                close all
            end
        else
            if(~isempty(studies(s).workspace))
                arLoad(studies(s).workspace)
                close all
            end
        end
        
        if(~isempty(studies(s).fun_analysis))
            ars{s} = feval(studies(s).fun_analysis,ar, studies(s), flag);            
        end
        
        save([studies(s).date,'_psPerformStudies_Result_',flag])
    
        psDeleteTmp
    
    catch err
        cd(oldpath)
        rethrow(err)
    end
    
    cd(pw)
    
    %     catch err
    %         diary Error
    %         disp(lasterror)
    %         diary off
    %         save Error
    %         cd(pw);
    %     end
    
end

function doEvalSetup(fun_setup)
% evaluation of the setup script has to be hidden in a function to not
% overwrite variables and to prevent clearing the workspace by potential
% clear all command

feval(fun_setup);

