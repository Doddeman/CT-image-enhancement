function do_plot(super,SNR_vector, ratio_SNR_vector,CNR_vector,ratio_CNR_vector)
%function do_plot(vec1,nr,tit,ylab,xlab)

x = (1:length(SNR_vector))';

figure
title('Average values')

subplot(2,2,1);
trend = fit(x,SNR_vector,'poly2');
plot(SNR_vector);
hold on
plot(trend,x,SNR_vector)
title('SNR Increase');
xlabel('Epochs')
ylabel('Increase')
legend('off')

subplot(2,2,2);
trend = fit(x,ratio_SNR_vector,'poly2');
plot(ratio_SNR_vector)
hold on
plot(trend,x,ratio_SNR_vector)
title('SNR Percentual Increase');
xlabel('Epochs')
ylabel('Percentual Increase')
legend('off')

subplot(2,2,3);
trend = fit(x,CNR_vector,'poly2');
plot(CNR_vector)
hold on
plot(trend,x,CNR_vector)
title('CNR Increase');
xlabel('Epochs')
ylabel('Increase')
legend('off')

subplot(2,2,4);
trend = fit(x,ratio_CNR_vector,'poly2');
plot(ratio_CNR_vector)
hold on
plot(trend,x,ratio_CNR_vector)
title('CNR Percentual Increase');
xlabel('Epochs')
ylabel('Percentual Increase')
legend('off')
suptitle(super)




%%
% x = ones(length(vec1),1);
% for i = 1:length(x)
%     x(i) = i;
% end
% 
% trend = fit(x,vec1,'poly2');
% 
% figure(nr)
% plot(vec1);
% hold on
% plot(trend, x, vec1);
% title(tit)
% xlabel('Epochs')
% ylabel(ylab)
