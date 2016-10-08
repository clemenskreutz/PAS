function psRemoveLhsDuplicates(pfad)
if ~exist('pfad','var') || isempty(pfad)
    pfad = 'Results';
end

d = dir(pfad);
folders = {d([d.isdir]).name};
folders = folders(3:end);

isdup = [];
lhsdone = zeros(size(folders));
ars = cell(size(folders));

for i=1:length(folders)
    if exist([pfad,filesep,folders{i},filesep,'workspace.mat'],'file')
        tmp = load([pfad,filesep,folders{i},filesep,'workspace.mat'],'ar');
        ars{i}  = tmp.ar;
        lhsdone(i) = isfield(ars{i},'chi2s');
        
        if lhsdone(i)
            refs = find(lhsdone(1:i-1));
            for iref=1:length(refs)
                if length(ars{refs(iref)}.chi2s) == length( ars{i}.chi2s)
                    bol_chi2s =  nansum(abs(ars{refs(iref)}.chi2s - ars{i}.chi2s))<1e-10; % same
                else
                    bol_chi2s = false;
                end
                if length(ars{refs(iref)}.chi2s_start) == length( ars{i}.chi2s_start)
                    bol_chi2s_start =  nansum(abs(ars{refs(iref)}.chi2s_start - ars{i}.chi2s_start))<1e-10; % same
                else
                    bol_chi2s_start = false;
                end
                
                if bol_chi2s && bol_chi2s_start
                    isdup = [isdup,i];
                    lhsdone(i) = 0;  % do not compare any more
                    break
                end
            end
        end
        if sum(isdup==i)>0
            fprintf('%s is a duplicate LHS and is now deleted.\n', [pfad,filesep,folders{i}])
            rmdir([pfad,filesep,folders{i}],'s')
        end
    end 
end
    