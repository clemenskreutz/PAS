% chi2s = psPlotLHS(ars,ymax,fnlabel)
%   
%   ars         cell of ar-structs
% 
%   ymax        maximal value on the vertical axis (-2 log-likelhood)
%               Default: 1e4
% 
%   fnlabel     used for legend (and colors)
%               fieldname of ar{} or ar{}.PerformanceStudy
%               string or cell of strings 
% Examples:
% ars = psPerformStudies(studies,'first');
% psPlotLHS([ars{:}],100)
% psPlotLHS([ars{:}],100,'checkstr')

function chi2s = psPlotLHS(ars,ymax,fnlabel)
if ~exist('ymax','var') || isempty(ymax)
    ymax = 1e4;
end
if ~exist('fnlabel','var') || isempty(fnlabel)
    fnlabel = cell(0);
%     fnlabel{1} = 'checkstr';
    fnlabel{1} = 'name';
    if isfield(ars{1},'intervention')
        fnlabel{2} = 'intervention';
    end
end

if ischar(fnlabel)
    fnlabel = {fnlabel};
end


cols = colormap('lines');

cstr = cell(size(ars));
for i=1:length(ars)
    cstr{i} = '';
    for f=1:length(fnlabel)
        if isfield(ars{i},fnlabel{f})
            tmp = ars{i}.(fnlabel{f});
        elseif isfield(ars{i}.PerformanceStudy,fnlabel{f})
            tmp = ars{i}.PerformanceStudy.(fnlabel{f});
        else
            warning([fnlabel{f},' not found'])
            tmp = '';
        end            
        if isnumeric(tmp)
            tmp = [fnlabel{f},'=',num2str(tmp)];
        end
        cstr{i} = [cstr{i},' ',tmp];
    end
    cstr{i} = strrep(cstr{i},'_','\_');
    
    nfit = length(ars{i}.chi2s);
end

uni = unique(cstr);
nfitmax = max(nfit);

close all
hold on
for i=1:length(uni)
    ind = strmatch(uni{i},cstr,'exact');
    chi2min = Inf;
    for j=1:length(ind)
        chi2min = min(chi2min,min(ars{ind(j)}.chi2s));
    end
    
    for j=1:length(ind)
        chi2s{ind(j)} = sort(ars{ind(j)}.chi2s) - chi2min;
%         chi2s{ind(j)}(chi2s{ind(j)}>ymax) = NaN;
        tmp = plot(linspace(1,nfitmax,length(chi2s{ind(j)})), chi2s{ind(j)},'.-','Color',cols(i,:));
        h(i) = tmp(1);
    end        
end
legend(h,uni{:},'Location','NorthWest');
ylim([0,ymax])





    