% ars = psCollectLHS(pfad,minsize)
% 
%   This function recursively searches a path and collects all ar structs
%   containting lhs fits.
% 
%   All workspaces *.mat ar searched for a variable ar. Then existance and
%   size of ar.chi2s checked. If more than minsize fits are availabel, the
%   the variable ar is collected in the cell-array ars.
% 
%   pfad        Path where recursive search should start. 
%               Default pfad = pwd
%   
%   minsize     minimal sample size (number of fits) of LHS,
%               i.e. selection if length(ar.chi2s)>= minsize
%               Default: minsize = 100

function ars = psCollectLHS(pfad,minsize)
if ~exist('pfad','var') || isempty(pfad)
    pfad = pwd;
end
if ~exist('minsize','var') || isempty(minsize)
    minsize = 100; % minimal number of lhs fits
end

folders = dir_FoldersRecursive(pfad);
folders = [{pfad},folders];

ars = cell(0);

for f=1:length(folders)
    d = dir(folders{f});
    d = d([d.isdir]==0);
    matfiles = {d(find(~cellfun(@isempty,regexp({d.name},'\.mat$')))).name};
    for m=1:length(matfiles)
        tmpfolder = [folders{f},filesep,matfiles{m}];
        fprintf('%s',[tmpfolder,' ... '])
        tmp = load(tmpfolder);
        treffer = 0;
        if isfield(tmp,'ar')
            if isfield(tmp.ar,'chi2s')  && isfield(tmp.ar,'checkstr') && length(tmp.ar.chi2s)>=minsize
                ars{end+1} = tmp.ar;
                ars{end}.folder = [folders{f},filesep,matfiles{m}];
                treffer = 1;
            end
        end
        if treffer
            fprintf('\n -> %i LHS fits found.\n',length(tmp.ar.chi2s));
        else
            fprintf(' nothing found.\n');
        end
    end
end


