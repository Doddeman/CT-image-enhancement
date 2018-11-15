function do_plot(vec1,vec2,nr,tit,ylab,xlab)

x = ones(length(vec1),1);
for i = 1:length(x)
    x(i) = i;
end

trend = fit(x,vec1,'poly2');

figure(nr)
title(tit)
if nargin == 5
    plot(vec1,vec2);
    xlabel('Epochs')
    hold on
    plot(trend, x, vec1);
else
    plot(x,vec2);
    xlabel(xlab)
end
ylabel(ylab)

%what am i doing