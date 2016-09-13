% studies = psDefineStudyExamples(studyfolder,withoutQuestions)
% 
% 
% Example
% psDefineStudyExamples([],1)  % without asking questions

function studies = psDefineStudyExamples(studyfolder,withoutQuestions)
if ~exist('studyfolder','var') || isempty(studyfolder)
    studyfolder = 'Studies';
end
if ~exist('withoutQuestions','var') || isempty(withoutQuestions)
    withoutQuestions = 0;
end

d = dir(studyfolder);

ds = {d.name};
ds = ds([d.isdir]);
ds = setdiff(ds(3:end),'project_lib');  % eliminate '.' and '..'

if exist('fileChooser')~=2
    arCheck
end


if withoutQuestions
    in = 'y';
else
    askstring = sprintf('Do you wish to standard setting?   [yes: Press button or ''y'', no=select/check options: type ''n'', CTRL+c for exit] ');
    in = deblank(input(askstring,'s'));
end

if strcmpi(in,'y') || strcmpi(in,'yes')
    useDefault = 1;
else
    useDefault = 0;
end

studies = [];
for i=1:length(ds)
    disp('---------------------------')
    fprintf('Study #%3i (''%s'') : ',i,ds{i});
    if ~useDefault
        in = lower(deblank(input('To be analyzed? [yes: Press button, no: type ''n''] ','s')));
    else
        in = 'y';
    end
    if(isempty(in) || strcmpi(in,'y')  || strcmpi(in,'yes'))
        fprintf('OK, %s selected.\n\n',ds{i})
        if isempty(studies)
            studies = newStudyDesign;
        else
            studies(end+1) = newStudyDesign;
        end
        studies(end).name = ds{i};
        studies(end).path = [studyfolder,filesep,ds{i}];
    
        d2 = dir(studies(end).path);
        fs = {d2.name};
        fs = fs(~[d2.isdir]);
        ind = strmatch('setup',lower(fs));
        
        if(isempty(ind))
            warning('No Setup file found => no fun_setup assigned.')
        
        elseif length(ind)==1            
            if ~useDefault
                in = input(sprintf('Assign %s as setup function ''fun_setup''? [yes: Press button or ''y'', no: type ''n'']',fs{ind}),'s');
            else
                in = 'y';
            end
            
            if(isempty(in) || strcmpi(in,'y')  || strcmpi(in,'yes'))
                [~,studies(end).fun_setup] = fileparts(fs{ind});
            else
                disp('No fun_setup assigned.')
            end
                
        else
            
            if ~useDefault
                disp('Please select the appropriate setup file: [type a number]');
                for j=1:length(ind)
                    fprintf(' #%3i : %s\n',j,fs{ind(j)});
                end
                in = str2num(input(sprintf('Please choose (1-%i) or empty for none: ',length(ind)),'s'));
            else
                in = 1;
            end
            
            if(~isempty(in))
                [~,studies(end).fun_setup] = fileparts(fs{ind(in)});
                fprintf('OK, setup %s selected.\n\n',studies(end).fun_setup);
            else
                disp('No fun_setup assigned.')
            end
        end
        
        
        d3 = dir([studies(end).path,filesep,'Results\']);
        ws = {d3.name};
        ws = ws([d3.isdir]);
        ws = ws(3:end);
        if ~isempty(ws)
            if ~useDefault
                disp('If parameters should be loaded, please choose one of the available workspaces:');
                for j=1:length(ws)
                    fprintf('#%3i : %s\n',j,ws{j});
                end
                in = str2num(input(sprintf('Please choose (1-%i) : ',length(ws)),'s'));
            else
                in = 1;
            end
            
            if(isempty(in))
                disp('No workspace selected');
            else
                studies(end).workspace = ws{in};
                fprintf('OK, parameters will be loaded from %s.\n',ws{in});
            end
        else
            disp('No workspaces available for loading parameters.')
        end

    end
    
end


function s = newStudyDesign
s.name = '';
s.date = datestr(now,30);
s.path = '';
s.fun_setup = '';
s.fun_analysis = '';
s.workspace = '';

