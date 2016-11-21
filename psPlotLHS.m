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
%               Default: {'name','intervention'}
% 
%               If more than 7  settings are plotted, the 1st fnlabel
%               determines the marker and the 2nd fnlabel determines th
%               color
% 
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


cstr = cell(size(ars));
labF1 = cell(size(ars));
labF2 = cell(size(ars));
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
        if f==1
            labF1{i} = tmp;
        elseif f==2
            labF2{i} = tmp;            
        end
    end
    cstr{i} = strrep(cstr{i},'_','\_');
    
    nfit = length(ars{i}.chi2s);
end

uni = unique(cstr);
nfitmax = max(nfit);

%% colors and markers:
markers = {'.','o','x','v','^','<','>','d','s','+'};
icol = NaN(size(uni));  % [1 x length(uni)], indicates which color is used
imarker = NaN(size(uni));  % [1 x length(uni)], indicates which marker is used


if length(uni)<=7
    cols = colormap('lines');
    % color determined by level of uni
    for i=1:length(uni)
        icol(strmatch(uni{i},cstr,'exact')) = i;
    end
    % only a single marker
    markers = '.-';
    imarker(:) = 1;
elseif length(fnlabel)>=2
    unif1 = unique(labF1);
    unif2 = unique(labF2);
    
    if length(unif2)<=7
        cols = colormap('lines');
    else
        cols = colormap('jet');
        cols = cols(round(interp1([1,length(unif2)],[1,size(cols,1)], 1:length(unif2))),:);
    end
    % color determined by level of labF2
    for i=1:length(labF2)
        icol(i) = strmatch(labF2{i},unif2,'exact');
    end
    % marker determined by level of labF1
    for i=1:length(labF1)
        imarker(i) = strmatch(labF1{i},unif1,'exact');
    end
else
    cols = colormap('jet');
    cols = cols(round(interp1([1,length(uni)],[1,size(cols,1)], 1:length(uni))),:);
    % each setting has different color
    icol = 1:length(uni);
    % only first marker used
    imarker(:)=1;
end


%% do plotting
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
        tmp = plot(linspace(1,nfitmax,length(chi2s{ind(j)})), chi2s{ind(j)},'-','Color',cols(icol(ind(j)),:),'Marker', markers{imarker(ind(j))});
        h(i) = tmp(1);
    end        
end
legend(h,uni{:},'Location','NorthWest');
ylim([0,ymax])





    