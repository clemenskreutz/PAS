%  psCopyExamples
%  psCopyExamples(pattern)
% 
%   This function goes through all examples in the D2D folder 'Examples'
%   and asks the user whether the individual application should be copied
%   into a folder 'Studies' for performing furhter analyses like a
%   performance-study.
% 
%   pattern         pattern for specifying a subset of example models which
%                   are presented for selection.
% 
% Example: 
%   psCopyExamples
% psCopyExamples('Swa')
% psCopyExamples([],1)  % without asking questions

function psCopyExamples(pattern,withoutQuestions)
if(~exist('pattern','var') || isempty(pattern))
    pattern = '';
end
if ~exist('withoutQuestions','var') || isempty(withoutQuestions)
    withoutQuestions = 0;
end

arpath = [fileparts(which('arInit')),filesep];
examplePath = [arpath,'Examples',filesep];
d = dir(examplePath);

ds = {d.name};
ds = ds([d.isdir]);
ds = setdiff(ds(3:end),'project_lib');  % eliminate '.' and '..'

if ~isempty(pattern)
    ind = find(~cellfun(@isempty,regexp(ds,pattern)));
    ds = ds(ind);
end

if(~exist('Studies','dir'))
    mkdir('Studies');
end

std_examples = {'Bachmann_MSB2011',...
    'Becker_Science2010',...
    'Boehm_JProteomeRes2014',...
    'Bruno_Carotines_JExpBio2016',...
    'Dream6',...
    'Raia_CancerResearch2011',...
    'Swameye_PNAS2003',...
    'Schwen_InsulinMouseHepatocytes_PlosOne2014',... 
    'Toensing_InfectiousDiseaseModels2016'};


if withoutQuestions
    in = 'y';
else
    disp('Performing the Method Evaluation Study based on the standard examples or on examples selected by hand?')
    fprintf('Current definition of the standard examples comprise the following models: \n');
    std_examples = intersect(ds,std_examples);
    if ~isempty(std_examples)
        fprintf('%s, ',std_examples{:})
        fprintf('\n');
        
        askstring = sprintf('Do you wish to copy these standard examples?   [yes: Press button or ''y'', no=use examples manually: type ''n'', CTRL+c for exit] ');
        in = deblank(input(askstring,'s'));
    else
        in = '';
    end
end


if ~isempty(in) && (strcmp(lower(in),'n') || strcmp(lower(in),'no'))   % copy by hand

    for i=1:length(ds)
        askstring = sprintf('Do you wish to copy example %20s?       [yes: Press button or ''y'', no: type ''n'', CTRL+c for exit] ',['''',ds{i},'''']);
        in = deblank(input(askstring,'s'));
        
        if(isempty(in) || strcmp(lower(in),'y')  || strcmp(lower(in),'yes'))
            %         evstr = sprintf('copy -r %s%s Studies',examplePath,ds{i});
            %         disp(evstr)
            %         system(evstr);
            suc = copyfile([examplePath,ds{i}],['Studies',filesep,ds{i}]);
            if(~suc)
                warning('%s could not be copied.',ds{i})
            end
        end                
    end
    
else  % use std_examples
    for i=1:length(std_examples)
        if ~exist(['Studies',filesep,std_examples{i}],'dir')
            suc = copyfile([examplePath,std_examples{i}],['Studies',filesep,std_examples{i}]);
            fprintf('Example copied to %s.\n',['Studies',filesep,std_examples{i}]);
            if(~suc)
                warning('%s could not be copied.',std_examples{i})
            end
        else
            fprintf('%s already exists.\n',['Studies',filesep,std_examples{i}]);
        end
    end
end

