function psAnalyze(ars)

fn = fieldnames(D);
for i=1:length(fn)
    if(islogical(D.(fn{i})))
        if(sum(D.(fn{i})(1,:)) ~= sum(~D.(fn{i})(1,:)))
            warning('Effect %s is not balanced. ',fn{i});
        end
    end
end

%%
% applev = unique({studies.name})
applev = unique(app);  
applev  = applev([end,1:end-1]);  % change the order as intended, the first application will correspond to the intercept

for iy = 1:length(dchi2thresh)
    D.isMin{iy} = NaN(size(D.chi2s));
end

for i=1:length(applev)
    ind = strmatch(applev{i},app,'exact');
    chi2tmp = D.chi2s(:,ind);
    chi2min = min(chi2tmp(:));
    D.chi2min(:,ind) = chi2min;
    
    for iy = 1:length(dchi2thresh)  % here, logistic regression is performed for all thresholds !
        D.isMin{iy}(:,ind) = D.chi2s(:,ind)<chi2min+dchi2thresh(iy);
    end
        
    D.(['app',num2str(i)]) = zeros(size(D.chi2s));
    D.(['app',num2str(i)])(:,ind) = 1;
    
    D.(['app',num2str(i),'_AND_unLog10']) = zeros(size(D.chi2s));
    for j=1:length(ind)
        D.(['app',num2str(i),'_AND_unLog10'])(find(D.unLog10(:,ind(j))),ind(j)) = 1;
    end

    D.(['app',num2str(i),'_AND_qLog10']) = zeros(size(D.chi2s));
    for j=1:length(ind)
        D.(['app',num2str(i),'_AND_qLog10'])(find(D.qLog10(:,ind(j))),ind(j)) = 1;
    end

    D.(['app',num2str(i),'_AND_drawUnLog']) = zeros(size(D.chi2s));
    for j=1:length(ind)
        D.(['app',num2str(i),'_AND_drawUnLog'])(find(D.drawUnLog(:,ind(j))),ind(j)) = 1;
    end
    
    D.(['app',num2str(i),'_AND_fitLog_AND_drawLog']) = zeros(size(D.chi2s));
    for j=1:length(ind)
        D.(['app',num2str(i),'_AND_fitLog_AND_drawLog'])(find(~D.drawUnLog(:,ind(j)) & ~D.unLog10(:,ind(j))),ind(j)) = 1;
    end
    D.(['app',num2str(i),'_AND_fitLog_AND_drawUnLog']) = zeros(size(D.chi2s));
    for j=1:length(ind)
        D.(['app',num2str(i),'_AND_fitLog_AND_drawUnLog'])(find(D.drawUnLog(:,ind(j)) & ~D.unLog10(:,ind(j))),ind(j)) = 1;
    end
    D.(['app',num2str(i),'_AND_fitUnLog_AND_drawLog']) = zeros(size(D.chi2s));
    for j=1:length(ind)
        D.(['app',num2str(i),'_AND_fitUnLog_AND_drawLog'])(find(~D.drawUnLog(:,ind(j)) & D.unLog10(:,ind(j))),ind(j)) = 1;
    end
    D.(['app',num2str(i),'_AND_fitUnLog_AND_drawUnLog']) = zeros(size(D.chi2s));
    for j=1:length(ind)
        D.(['app',num2str(i),'_AND_fitUnLog_AND_drawUnLog'])(find(D.drawUnLog(:,ind(j)) & D.unLog10(:,ind(j))),ind(j)) = 1;
    end
end
D.chi2min = ones(N,1)*D.chi2min;

%%
clc

result = cell(0);

for ana = [1,4,5]  % for the paper, three logistic regression analyses were of interest
    logfile = sprintf('Analysis%i.txt',ana);
    system(['rm ',logfile]);
    diary(logfile);
    fprintf('ana=%i\n\n',ana);
    
    switch ana  % choosing predictors (which occur as field in D)
        case 1
            xnames =  {'qLog10_AND_drawUnLog','unLog10_AND_drawLog','unLog10_AND_drawUnLog'};
        
            
        case 4
            xnames = cell(0);
            for i=2:length(applev)
                xnames{end+1} = ['app',num2str(i)];
            end
            for i=1:length(applev)
                xnames{end+1} = ['app',num2str(i),'_AND_fitLog_AND_drawUnLog'];
            end
            for i=1:length(applev)
                xnames{end+1} = ['app',num2str(i),'_AND_fitUnLog_AND_drawLog'];
            end
            for i=1:length(applev)
                xnames{end+1} = ['app',num2str(i),'_AND_fitUnLog_AND_drawUnLog'];
            end
        case 5
            xnames =  {'qLog10_AND_drawUnLog','unLog10_AND_drawLog','unLog10_AND_drawUnLog'};
            for i=2:length(applev)
                xnames{end+1} = ['app',num2str(i)];
            end
    end
    
    
    namen = {'Intercept',xnames{:}}; % the intercept has to be added to the names
    for iy =1:length(dchi2thresh)
    
        X = ones(length(D.chi2s(:)),1);  % column for intercept 
        for i=1:length(xnames)
            X = [X,D.(xnames{i})(:)];
        end
    
        y = D.isMin{iy}(:);  % response
        
        [X,rfx] = sortrows(X);
        y = y(rfx);
        
        % plotting the "design" of the logistic regression:
        close all
        cm = colormap('gray');
        colormap(cm(end:-1:1,:));
        imagesc(X)
        colorbar
        title(sprintf('Analyis %i',ana))
        set(gca,'XTick',1:length(namen),'XTickLabel',namen);
        
        [b,dev,stats] = glmfit(X,y,'binomial','link','logit','constant','off');
        
        thresh = 1e4;  % threshold for display options of the output (%7.3f vs. >thresh)
        
        disp('----------------------------------------------')
        disp('              Effect      beta      SE     p-value:');
        fprintf('\n')
        for i=1:length(stats.beta)
            if(stats.se(i)<1e4)
                fprintf('%20s   %7.3f   %7.3f   %7.5f\n',namen{i},stats.beta(i),stats.se(i),stats.p(i));
            else
                fprintf('%20s   %7.3f   >%2.0e   %7.5f\n',namen{i},stats.beta(i),thresh,stats.p(i));
            end
        end
        disp('______________________________________________')
        
        disp('----------------------------------------------')
        disp('Regularized analysis (assuming that at least on fit converged for each predictor combination):')
        
        xuni = unique(X,'rows');
        [breg,devreg,statsreg] = glmfit([X;xuni],[y;ones(size(xuni,1),1)],'binomial','link','logit','constant','off');
        
        disp('              Effect      beta      SE     p-value:');
        fprintf('\n')
        for i=1:length(statsreg.beta)
            if(statsreg.se(i)<1e4)
                fprintf('%20s   %7.3f   %7.3f   %7.5f\n',namen{i},statsreg.beta(i),statsreg.se(i),statsreg.p(i));
            else
                fprintf('%20s   %7.3f   >%2.0e   %7.5f\n',namen{i},statsreg.beta(i),thresh,statsreg.p(i));
            end
        end
        disp('----------------------------------------------')
                
        result{ana,iy}.stats = stats;
        result{ana,iy}.statsreg = statsreg;
        result{ana,iy}.stats = stats;
        result{ana,iy}.stats = stats;
        result{ana,iy}.namen = namen;
    end
    diary off
end


%% Histogram for choosing a reasonable value for the threshold \Delta:
d = D.chi2s(:)-D.chi2min(:);
hist(log10(d(d<10)),100)
xlabel('\chi^2 - \chi^2_{min} [log10]')
ylim([0,50])
print -dpng HistForThreshold
saveas(gcf,'HistForThreshold')


dchi2thresh_used = 0.01; 
iy = find(dchi2thresh == dchi2thresh_used);

%% saving results
save result result iy dchi2thresh_used
