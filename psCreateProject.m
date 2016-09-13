% Similar to arCreateProject, this function creates a project folder and
% copies template source code to this folder which can be used as a
% starting point for a performance assessment study.

function psCreateProject(name)

if ~exist('name','var') || isempty(name)
    name = input('Please enter the project name: ','s');
end

suc = mkdir(name);
if ~suc
    fprintf('Directory %s could not be created.\n',name);

else
    ps_path = fileparts(which('psCreateProject.m'));
    source = [ps_path,filesep,'Template',filesep];
    suc = copyfile(source,name);
    if ~suc
        fprintf('Template files could not be copied.\n');
    else
        cd(name)
        edit PerformanceStudy
    end
end

