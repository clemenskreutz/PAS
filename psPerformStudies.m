% ars = psPerformStudies(studies, flag)
% 
%   flag        ''  normal mode
%               'test' = test mode, i.e. a fast version used to check the
%               code
% 
%   StudyName   important for tmp-workspace (for restarting in case of
%               segmentation fault)
% 
% Examples:
%   studies = psDefineStudyExamples;
%   psPerformStudies(studies, 'test')
%   ars = psPerformStudies(studies);
% 

function ars = psPerformStudies(studies, flag, StudyName)
if(~exist('flag','var') || isempty(flag))
    flag = '';
    %     flag = 'test';
end
if(~exist('StudyName','var') || isempty(StudyName))
    StudyName = '';
end

global ar
diary(['psPerformStudies_',flag,'.log'])

ars = cell(size(studies));

sstart = 1;
psLoadSaveTmp  % if tmp-workspace available, this function overwrites sstart to start at the point were last analysis finished

pw = [pwd,filesep];
for s=sstart:length(studies)
    %     cd(studies(s).path)
    sstart = s;

    if s>1  % otherwise it has been done already (in any case)
        psSaveTmp
    end
    
    oldpath = pwd;
    
    
    try
        cd(strrep(studies(s).path,pw,''))
    
        %     try
        if(~isempty(studies(s).fun_setup))

            doEvalSetup(studies(s).fun_setup);
                            
            close all
            if(~isempty(studies(s).workspace))
                try
                    arLoadPars(studies(s).workspace)
                catch
                    warning('psPerformStudies.m: Parameter from workspace %s cound not be loaded: %s \n',studies(s).workspace,'arLoadPars(studies(s).workspace)')
                end
                close all
            end
        else
            if(~isempty(studies(s).workspace))
                try
                    arLoad(studies(s).workspace)
                catch
                    warning('psPerformStudies.m: Parameter from workspace %s cound not be loaded: %s \n',studies(s).workspace,'arLoad(studies(s).workspace)')
                end
                close all
            end
        end
        
        if(~isempty(studies(s).fun_analysis))
            fprintf('psPerformStudies, iteration %i, name=%s started ...\n',s,studies(s).name);
            ars{s} = feval(studies(s).fun_analysis,ar, studies(s), flag);            
        end
        
        save([studies(s).date,'_psPerformStudies_Result_',flag])
        
    catch err
        cd(oldpath)
        diary off
        rethrow(err)
    end
    
    cd(pw)
    psDeleteTmp
    
    %     catch err
    %         diary Error
    %         disp(lasterror)
    %         diary off
    %         save Error
    %         cd(pw);
    %     end
    
    diary off
end

function doEvalSetup(fun_setup)
% evaluation of the setup script has to be hidden in a function to not
% overwrite variables and to prevent clearing the workspace by potential
% clear all command

feval(fun_setup);

