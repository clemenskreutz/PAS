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
        cd(strrep(studies(s).path,pw,''))
        
        %     try
        if(~isempty(studies(s).fun_setup))

%             checkVariable = 1;
%             save('beforeSetup.mat');
            doEvalSetup(studies(s).fun_setup);
                            
% if ~exist('checkVariable','var')   % clear all has been executed
%     % reload existing variables is a 'clear all' command was in the
%     % setup file
%     vars_setup = who;
%     tmp = load('beforeSetup');
%     vars_before = fieldnames(tmp);
%     fn_load = setdiff(vars_before,vars_setup);
%     for f=1:length(fn_load)
%         eval([fn_load{f},' = tmp.',fn_load{f},';']);
%     end
% else
%     system('rm beforeSetup.mat');
% end
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
        
        save([studies(s).date,'_psPerformStudies_Result'])
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

