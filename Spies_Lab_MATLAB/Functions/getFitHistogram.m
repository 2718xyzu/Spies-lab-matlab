function [fitModel, rateText, data] = getFitHistogram(data,dataType,fitType,order,timeStep)
%dataType is 1 if a histogram, 2 if a cumulative distribution
%fitType is 1 if linear, 2 if logarithmic
%order is 1 if a single-order fit is to be assumed, 2 if a double
%exponential distribution is desired





switch dataType
    case 1 %histogram fit
        %note that just choosing to use sqrt(N) bins is not optimal,
        %but the point of this software is not to rigorously analyze
        %data statistically, but to organize and show it
        data = data+rand(size(data))*timeStep-.5*timeStep;
        if fitType==2 %logarithmic histogram
            originalx = data;
            data(data<0) = []; %this shouldn't happen, but just in case
            data = log(data);
        end
        [y, binEdges] = histcounts(data,ceil(sqrt(length(data))));
        x = binEdges(1:end-1)+diff(binEdges)/2;
        dt = mean(diff(binEdges));
    case 2
        if fitType==2 %logarithmic histogram
            originalx = data;
            data(data<0) = []; %this shouldn't happen, but just in case
            data = log(data);
        end
        x = sort(data); %cumulative distribution
        y = linspace(0,1,length(data));
end

x = reshape(x,[length(x) 1]);
y = reshape(y,[length(y) 1]);

rateText = '';
switch fitType %linear or log
    case 1 %linear
        switch dataType %histogram or cumulative
            case 1 %histogram
                switch order
                    case 1
                        model = fittype(@(a1, k1, x) (a1*exp(-x*k1)));
                    case 2
                        model = fittype(@(a1, k1, a2, k2, x) (a1*exp(-x*k1)+a2*exp(-x*k2)));
                end
                fitLower = repmat([eps,eps],[1 order]);
                startingPoint = repmat([max(y)/2 mean(data)],[1 order]);
            case 2 %cumulative distribution
                switch order
                    case 1
                        model = fittype(@(k1, x) (-exp(-x*k1)+1));
                    case 2
                        model = fittype(@(a1, k1, k2, x) (-a1*exp(-x*k1)-(1-a1)*exp(-x*k2)+1));
                end
                fitLower = repmat(eps,[1 order*2-1]);
                startingPoint = [repmat(.5,[1 order-1]) repmat(mean(data),[1 order])];
        end
        fitModel = fit(x,y,model,'Lower',fitLower,'StartPoint',startingPoint);
        
    case 2 %log distribution
        switch dataType
            case 1
                y = sqrt(y);
                switch order
                    case 1
                        fitLower = [eps, eps];
                        model = fittype(@(a1,k1,x) (a1*exp(x+log(k1)+dt/2-exp(x+log(k1)+dt/2))));
                    case 2
                        fitLower = [eps, eps, eps, eps];
                        model = fittype(@(a1,k1,a2,k2,x) (a1*exp(x+log(k1)+dt/2-exp(x+log(k1)+dt/2))+...
                            a2*exp(x+log(k2)+dt/2-exp(x+log(k2)+dt/2))));
                end
                startingPoint = repmat([mean(originalx) max(y)],[1 order]);
            case 2 %cumulative
                switch order
                    case 1
                        fitLower = eps;
                        startingPoint = mean(originalx);
                        model = fittype(@(k1,x)(1-exp(-k1*exp(x))));
                    case 2
                        fitLower = [eps, eps, eps];
                        startingPoint = [.5 mean(originalx) mean(originalx)];
                        model = fittype(@(a1,k1,k2,x) (1-a1*exp(-k1*exp(x))-(1-a1)*exp(-k2*exp(x))));
                end
        end
        fitModel = fit(x,y,model,'Lower',fitLower,'StartPoint',startingPoint);
end

switch order
    case 1
        rate = fitModel.k1;
    case 2
        rate = [fitModel.k1 fitModel.k2];
end


for i = 1:order
    tempText = [rateText 'k' num2str(order) ' = ' num2str(rate(i)) newline];
    rateText = tempText;
end

end
