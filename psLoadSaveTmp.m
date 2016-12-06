% this script checks whether there is a tmp workspace saved by the same
% function. If available it is loaded. Otherwise a workspace is saved.
% 
% Works also in case of segmentation fault, PC crash, externally stopped
% matlab ...

stack = dbstack;

if length(stack)<2
    callingFunction = 'CommandLine';
else
    callingFunction = stack(2).file(1:end-2);
end

if ~isempty(StudyName)
    
    tmp_file = ['unfinished_',StudyName,'_',callingFunction,'.mat'];
    if exist(tmp_file,'file')  % process not finished => load workspace and continue
        warning('Last run seems not finished properly. The following workspace is now loaded (and overwrites existing variables) for finishing analysis: %s ',tmp_file)
        load(tmp_file)
    else
        save(tmp_file)
    end
end
