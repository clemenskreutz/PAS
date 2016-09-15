%%
if isunix
    addpath('~/arFramework3/')
    addpath('~/PAS/')
    addpath('~/ck')
end

clear all
pw = pwd;
addpath([pw,filesep,'project_lib']);
addpath(pw)

file_studies_mat = [computer,'_studies.mat'];
file_test_mat = [computer,'_psPerformanceStudies_test.mat'];
%%  Copy Examples
if ~exist('Studies','dir')
    psCopyExamples([],1);
end

%% Define studies and save
if ~exist(file_studies_mat,'file')
    studies = psDefineStudyExamples([],1);
    save(file_studies_mat,'studies')
end

%% load study design
load(file_studies_mat)
studies = studies([2:end,1]);  % mv Bachmann to the end
% studies = studies(3)

for s=1:length(studies)
    studies(s).fun_analysis = @funAna1;
end

if ~exist(file_test_mat,'file')
    ars = psPerformStudies(studies,'test');
    save(file_test_mat,'studies','ars');
end

ars = psPerformStudies(studies,'first');

% arsHyper = psPerformStudies(studies,'hyper');
% arsFinal = psPerformStudies(studies,'final');
% ars = [arsHyper,arsFinal];
save psPerformanceStudies_last

%%
% load psPerformanceStudies_last
% ars = psCollectStudyResults(studies,patterns);
[arProp,fitProp] = psModelProperties([ars{:}]);

% load psPerformanceStudies_last ars studies

[arProp,iterProp] = psModelProperties(ars);

