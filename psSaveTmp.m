% this script saves a temporariy workspace. 
% 
% Works also in case of segmentation fault, PC crash, externally stopped
% matlab ...

stack = dbstack;

if ~isempty(StudyName)
    
    tmp_file = ['unfinished_',StudyName,'_',stack(2).file(1:end-2),'.mat'];
    save(tmp_file)
    
end
