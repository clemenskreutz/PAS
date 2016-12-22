%  psCopyExamples
%  psCopyExamples(pattern)
%  psCopyExamples(pattern,withoutQuestions,std_examples)
%
%
%   This function goes through all examples in the D2D folder 'Examples'
%   and asks the user whether the individual application should be copied
%   into a folder 'Studies' for performing furhter analyses like a
%   performance-study.
%
%   pattern         pattern for specifying a subset of example models which
%                   are presented for selection.
%                   The pattern is only evaluated for the standard
%                   examples!
%
% Example:
%   psCopyExamples
% psCopyExamples('Swa')
% psCopyExamples([],1)  % without asking questions

function psCopyExamples(pattern,withoutQuestions,std_examples)
if(~exist('pattern','var') || isempty(pattern))
    pattern = '';
end
if ~exist('withoutQuestions','var') || isempty(withoutQuestions)
    withoutQuestions = 0;
end
if ~exist('std_examples','var') || isempty(std_examples)
    std_examples = {'Bachmann_MSB2011',...
        'Becker_Science2010',...
        'Boehm_JProteomeRes2014',...
        'Bruno_Carotines_JExpBio2016',...
        'Dream6',...
        'Merkle_JAK2STAT5_PCB2016',...
        'Raia_CancerResearch2011',...
        'Swameye_PNAS2003',...
        'Schwen_InsulinMouseHepatocytes_PlosOne2014',...
        'Toensing_InfectiousDiseaseModels2016'};
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
            suc = doCopy([examplePath,ds{i}],['Studies',filesep,ds{i}],ds{i});
            if(~suc)
                warning('%s could not be copied.',ds{i})
            end
        end
    end
    
else  % use std_examples
    ds = intersect(ds,std_examples);
    for i=1:length(ds)
        suc = doCopy([examplePath,ds{i}],['Studies',filesep,ds{i}],ds{i});
    end
end


% this function can handle special cases
function suc = doCopy(source,target,option)
if ~exist('option','var') || isempty(option)
    option = '';
end

switch option
    case 'Merkle_JAK2STAT5_PCB2016'
        
        newtarget = strrep(target,option,[option,'_CFUE']);
        suc = doCopySingle(source,newtarget);
        if suc
            delfils = strcat(newtarget,filesep,{'SetupComprehensive.m','SetupFinal.m','SetupH838.m','SetupSens.m'});
            delete(delfils{:});
        end
        
        newtarget = strrep(target,option,[option,'_H838']);
        suc = doCopySingle(source,newtarget);
        if suc
            delfils = strcat(newtarget,filesep,{'SetupComprehensive.m','SetupFinal.m','SetupCFUE.m','SetupSens.m'});
            delete(delfils{:});
        end
        
        newtarget = strrep(target,option,[option,'_CFUE+H838']);
        suc = doCopySingle(source,newtarget);
        if suc
            delfils = strcat(newtarget,filesep,{'SetupComprehensive.m','SetupCFUE.m','SetupH838.m','SetupSens.m'});
            delete(delfils{:});
        end
        
    otherwise
        suc = doCopySingle(source,target);
end


% this function applies the copy command
function suc = doCopySingle(source,target)
if ~exist(target,'dir')
    suc = copyfile(source,target);
    
    if(~suc)
        warning('%s could not be copied.',source)
    else
        fprintf('Example %s copied to %s.\n',source,target);
    end
else
    fprintf('%s already exists.\n',target);
end
