function chi2s = psPlotLHS(ars,ymax,fnlabel)
if ~exist('ymax','var') || isempty(ymax)
    ymax = 1e4;
end
if ~exist('fnlabel','var') || isempty(fnlabel)
    fnlabel = 'checkstr';
end

if ~iscell(fnlabel)
    fnlabel = {fnlabel};
end


cols = colormap('lines');

cstr = cell(size(ars));
for i=1:length(ars)
    for f=1:length(fnlabel)
        if f>1
            cstr{i} = [cstr{i},' '];
        end        
        cstr{i} = [cstr{i},ars{i}.(fnlabel{f})];
    end
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
legend(h,uni{:});
ylim([0,ymax])





    