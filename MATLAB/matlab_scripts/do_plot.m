function do_plot(vec1,nr,tit,ylab)
%function do_plot(vec1,nr,tit,ylab,xlab)

x = ones(length(vec1),1);
for i = 1:length(x)
    x(i) = i;
end

trend = fit(x,vec1,'poly2');

figure(nr)
plot(vec1);
hold on
plot(trend, x, vec1);
title(tit)
xlabel('Epochs')
ylabel(ylab)
