function do_plot(super,SNR_vector, ratio_SNR_vector,CNR_vector,ratio_CNR_vector)%,histeq_SNR_diff_mean, histeq_SNR_ratio_mean,histeq_CNR_diff_mean,histeq_CNR_ratio_mean)
%function do_plot(vec1,nr,tit,ylab,xlab)

close all;

x = (1:5:(length(SNR_vector)-1)*5)';
x(length(x)+1) = 80;

% histeq_SNR_diff_mean_vector = histeq_SNR_diff_mean .* ones(80,1);
% histeq_SNR_ratio_mean_vector = histeq_SNR_ratio_mean .* ones(80,1);
% histeq_CNR_diff_mean_vector = histeq_CNR_diff_mean .* ones(80,1);
% histeq_CNR_ratio_mean_vector = histeq_CNR_ratio_mean .* ones(80,1);

% figure
% subplot(2,2,1);
% trend = fit(x,SNR_vector,'poly2');
% plot(x,SNR_vector);
% hold on
% plot(trend,x,SNR_vector)
% % hold on
% % plot(histeq_SNR_diff_mean_vector)
% title('SNR Increase');
% xlabel('Epochs')
% ylabel('Increase')
% legend('off')

subplot(2,1,1);
trend = fit(x,ratio_SNR_vector,'poly2');
plot(x,ratio_SNR_vector,'white','LineWidth',3)
set(gca, 'color', 'k')

ax = gca;
ax.XColor = 'white';
ax.YColor = 'white';
% hold on
% plot(trend,x,ratio_SNR_vector)
% hold on
% plot(histeq_SNR_ratio_mean_vector)
% axis([0 80 -0.3 0.2])


title('{\color{white}SNR Evolution}');
xlabel('Epochs')
ylabel('Difference (%)')
legend('off')

% subplot(2,2,3);
% trend = fit(x,CNR_vector,'poly2');
% plot(x,CNR_vector)
% hold on
% plot(trend,x,CNR_vector)
% % hold on
% % plot(histeq_CNR_diff_mean_vector)
% title('CNR Increase');
% xlabel('Epochs')
% ylabel('Increase')
% legend('off')

subplot(2,1,2);
trend = fit(x,ratio_CNR_vector,'poly2');
plot(x,ratio_CNR_vector,'white','LineWidth',3)
set(gca, 'color', 'k')
set(gcf, 'color', 'k')
% hold on
% plot(trend,x,ratio_CNR_vector)
% hold on
% plot(histeq_CNR_ratio_mean_vector)
% axis([0 80 -0.6 0.8])

ax = gca;
ax.XColor = 'white';
ax.YColor = 'white';



title('{\color{white}CNR Evolution}');
xlabel('Epochs')
ylabel('Difference (%)')
legend('off')
suptitle('{\color{white}Average epoch values}')

% title('{\color{white}SNR Evolution}');


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
