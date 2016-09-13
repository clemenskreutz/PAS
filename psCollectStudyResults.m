% ars = psCollectStudyResults(studies,patterns)
% 
%   Example:
% ars = psCollectStudyResults(studies,'LHS')
function ars = psCollectStudyResults(studies,patterns)

if(isempty(patterns))
    patterns = '';
end
if ~iscell(patterns)
    patterns = {patterns};
end

if exist('fileChooser')~=2
    arCheck;
end

pw = pwd;
ars = cell(size(studies));
for s=1:length(studies)
    studies(s).path = strrep(studies(s).path,'/',filesep);
    studies(s).path = strrep(studies(s).path,'\',filesep);

    [~, ~, file_list] = fileChooser([studies(s).path,filesep,'Results'], [], -1);
    ind = 1:length(file_list);
    for i=1:length(patterns)
        ind = intersect(ind,find(~cellfun(@isempty,regexp(file_list,patterns{i}))));
    end
    
    for i=1:length(ind)
        ars{s}{end+1} = load([studies(s).path,filesep,'Results',filesep,file_list{ind(i)},filesep,'workspace.mat'],'ar');
    end
end
