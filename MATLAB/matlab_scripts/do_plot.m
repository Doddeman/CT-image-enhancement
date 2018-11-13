function do_plot(vec,nr,tit,ylab)

x = ones(length(vec),1);
for i = 1:length(x)
    x(i) = i;
end

trend = fit(x,vec,'poly2');

figure(nr)
plot(vec);
hold on
plot(trend, x, vec);
title(tit)
xlabel('Epochs')
ylabel(ylab)