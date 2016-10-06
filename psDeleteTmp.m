% this funciton deletes the tmp-workspace save for continuing non-finished
% analyses
stack = dbstack;

if ~isempty(StudyName)
    if length(stack)>1  % call from a function
        tmp_file = [StudyName,'_',stack(2).file(1:end-2),'.mat'];
        if exist(tmp_file,'file')  % process not finished => load workspace and continue
            delete(tmp_file);
        end
    else % call from matlab command line
        tmpvar = dir;
        tmpvar = tmpvar([tmpvar.isdir]==0);
        tmpvar = {tmpvar.name};
        
        fprintf('%s \n',tmpvar{:});
        in = input('Enter file name for beeing deleted: ','s');
        if ~isempty(in)
            delete(deblank(in));
        end
        
    end
end

