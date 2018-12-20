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
%   exist('replaceFun')==2 for user-defined replacements of the legend
%   labels
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
    fn_given = 0;
else
    fn_given = 1;
end

if ischar(fnlabel)
    fnlabel = {fnlabel};
end


if iscell(ars{1})
    close all
    chi2s = cell(size(ars));
    for i=1:length(ars)
        if ~isempty(ars{i})
            if fn_given ==0
                chi2s{i} = psPlotLHS([ars{i}],ymax);
            else
                chi2s{i} = psPlotLHS([ars{i}],ymax, fnlabel);
            end
        end
    end
    
else
    
    figure
    hold on
    
    cstr = cell(size(ars));
    labF1 = cell(size(ars));
    labF2 = cell(size(ars));
    namen = cell(size(ars));
    iplot = [];
    for i=1:length(ars)
        namen{i} = ars{i}.model(1).name;
        cstr{i} = '';
        for f=1:length(fnlabel)
            if isfield(ars{i},fnlabel{f})
                tmp = ars{i}.(fnlabel{f});                
            elseif isfield(ars{i},'PerformanceStudy') && isfield(ars{i}.PerformanceStudy,fnlabel{f})
                tmp = ars{i}.PerformanceStudy.(fnlabel{f});
                namen{i} = ars{i}.PerformanceStudy.name;
            else
                warning([fnlabel{f},' not found'])
                tmp = ars{i}.model(1).name;
            end
            if isnumeric(tmp)
%                 tmp = [fnlabel{f},'=',num2str(tmp)];
                tmp = [fnlabel{f},'=',sprintf('%3d',tmp)];
            end
            cstr{i} = [cstr{i},' ',tmp];
            if f==1
                labF1{i} = tmp;
            elseif f==2
                labF2{i} = tmp;
            end
        end
        cstr{i} = strrep(cstr{i},'_','\_');
        if exist('replaceFun')==2 % function exisets
            cstr{i} = replaceFun(cstr{i});
        end
        nfit = length(ars{i}.chi2s);
    end
    
    uni = unique(cstr);
    nfitmax = max(nfit);
    
    %% colors and markers:
    markers = {'.','o','x','v','^','<','>','d','s','+'};
    icol = NaN(size(uni));  % [1 x length(uni)], indicates which color is used
    imarker = NaN(size(cstr));  % [1 x length(uni)], indicates which marker is used
    
    
    if length(uni)<=7
        cols = colormap('lines');
        % color determined by level of uni
        for i=1:length(uni)
            icol(strmatch(uni{i},cstr,'exact')) = i;
        end
        % only a single marker
        markers = {'.'};
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
    uniname = unique(namen);
    chi2min = NaN(size(uniname));  % length and order like uniname;
    for i=1:length(uniname)
        % chi2min muss immer über 'name' berechnet werden.
        chi2min(i) = Inf;
        ind = strmatch(uniname{i},namen,'exact');
        for j=1:length(ind)
            chi2min(i) = min(chi2min(i),min(ars{ind(j)}.chi2s));
        end
    end
    
    h = [];
    for i=1:length(uni)
        ind = strmatch(uni{i},cstr,'exact');
        
        for j=1:length(ind)
            indname = strmatch(namen{ind(j)},uniname,'exact');            
            chi2s{ind(j)} = sort(ars{ind(j)}.chi2s) - chi2min(indname);
            
            %         chi2s{ind(j)}(chi2s{ind(j)}>ymax) = NaN;
%             tmp = plot(linspace(1,nfitmax,length(chi2s{ind(j)})), chi2s{ind(j)},'-','Color',cols(icol(ind(j)),:),'Marker', markers{imarker(ind(j))});
            tmp = plot(linspace(1,nfitmax,length(chi2s{ind(j)})), chi2s{ind(j)},'-','Color',cols(i,:),'Marker', markers{imarker(ind(j))});
            h(i) = tmp(1);
            iplot = [iplot,ind(j)];
        end
    end
%     legend(h,uni{:},'Location','NorthWest');
    set(legend(h,uni{:},'Location','best'),'FontSize',12);
    ylim([0,ymax])
    xlabel('Fit rank','FontSize',14)
    ylabel('Objective function','FontSize',14)
    set(gca,'FontSize',14)
    
    try
%         paperwidth('a4quer')
    end
end
