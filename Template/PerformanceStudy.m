%%
try
   delete(gcp('nocreate'))
end
try
   parpool
end

if isunix
    if ~exist('arFramework3','dir')
        system('cp -r ~/arFramework3 .');
        try
            system('rm -rf ./arFramework3/.git');
        end
    end
    addpath([pwd,filesep,'arFramework3'])

    if ~exist('PAS','dir')
        system('cp -r ~/PAS .');
        try
            system('rm -rf ./PAS/.git');
        end
    end
    
    addpath([pwd,filesep,'PAS'])
    addpath('~/ck')

else
    warning('Attention, under non-unix systems the current versions of D2D and PAS are not copied and saved.')    
    warning('For having reproducibility this should be done.')    
end


clear all

StudyName = '';  % Name of the study (optionally)
if isempty(StudyName)
    warning('No StudyName specified. No workspace for restarting analyses are saved ...');
else
    fprintf('PerformanceStudy %s started ...\n',StudyName);
end

pw = pwd;
addpath([pw,filesep,'project_lib']);
addpath(pw)

file_studies_mat = [computer,'_studies.mat'];
file_test_mat = [computer,'_psPerformanceStudies_test.mat'];
%%  Copy Examples
if ~exist('Studies','dir')
    psCopyExamples([],1);
end

%% Define studies=example models and save
if ~exist(file_studies_mat,'file')
    studies = psDefineStudyExamples([],1);
    save(file_studies_mat,'studies')
end

%% load study design
load(file_studies_mat)
studies = studies([2:end,1]);  % mv Bachmann to the end
% studies = studies(3)  % usage of only a single model

for s=1:length(studies)
    studies(s).fun_analysis = @funAna1;  % this function has to be edited to implement the comparison
end

psLoadSaveTmp

if ~exist(file_test_mat,'file')
    ars = psPerformStudies(studies,'test');
    save(file_test_mat,'studies','ars');
end

ars = psPerformStudies(studies,'first');

% arsHyper = psPerformStudies(studies,'hyper');
% arsFinal = psPerformStudies(studies,'final');  % uncomment this line for the large study
% ars = [arsHyper,arsFinal];
save psPerformanceStudies_last

psDeleteTmp

%% Evaluation e.g. via logistic-regression (not yet fully implemented)
% % load psPerformanceStudies_last
% % ars = psCollectStudyResults(studies,patterns);
% 
% [arProp,fitProp] = psModelProperties([ars{:}]);
% 
% % load psPerformanceStudies_last ars studies
% 
% [arProp,iterProp] = psModelProperties(ars);

