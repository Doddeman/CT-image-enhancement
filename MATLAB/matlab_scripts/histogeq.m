path = 'C:\Users\davwa\Desktop\CT-image-enhancement\histeq\';

originals = dir(strcat(path, 'test_originals/*.png'));
L = length(originals);

for i = 1:L
    i
    orig_name = originals(i).name;
    orig_path = strcat(path,'test_originals/', orig_name); 
    orig_im = get_image(orig_path);
    histed_im = adapthisteq(orig_im);
    
%     figure
%     subplot(2,2,1)
%     imshow(orig)
%     subplot(2,2,2)
%     plot(imhist(orig))
%     subplot(2,2,3)
%     imshow(histed)
%     subplot(2,2,4)
%     plot(imhist(histed))
    
    dest = strcat('C:\Users\davwa\Desktop\CT-image-enhancement\histeq\test_adapthisteq\', orig_name);
    imwrite(histed_im, dest);
end

%%%% SNR CNR for histeq %%%%
%%

% CGANs = dir(strcat(path, 'CGAN/*.png')); 
% histeq = dir(strcat(path, 'histeq/*.png')); 
size = 256;
histeq_SNR_diff_vector = zeros(L,1);
histeq_CNR_diff_vector = zeros(L,1);
% CGAN_SNR_diff_vector = zeros(L,1);
% CGAN_CNR_diff_vector = zeros(L,1);
histeq_SNR_ratio_vector = zeros(L,1);
histeq_CNR_ratio_vector = zeros(L,1);
% CGAN_SNR_ratio_vector = zeros(L,1);
% CGAN_CNR_ratio_vector = zeros(L,1);
for i = 1:L
    i
    orig_name = originals(i).name;
    orig_path = strcat(path,'test_originals/', orig_name); 
    orig_im = get_image(orig_path);
    histeq_im = adapthisteq(orig_im);
%     CGAN_name = CGANs(i).name;
%     CGAN_path = strcat(path,'CGAN/', CGAN_name); 
%     CGAN_im = get_image(CGAN_path);
    orig_outside = get_outside(orig_im, size, size);
    [orig_SNR,orig_CNR] = get_SNR_CNR(orig_im,orig_outside,size,size);
    [histeq_SNR,histeq_CNR] = get_SNR_CNR(histeq_im,orig_outside,size,size);
%     [CGAN_SNR,CGAN_CNR] = get_SNR_CNR(CGAN_im,orig_outside,size,size);
    
    histeq_SNR_diff = (histeq_SNR - orig_SNR);
    histeq_SNR_ratio = histeq_SNR_diff/orig_SNR;
    if sign(histeq_SNR_diff) ~= sign(histeq_SNR_ratio)
        histeq_SNR_ratio = histeq_SNR_ratio * -1;
    end
    histeq_CNR_diff = (histeq_CNR - orig_CNR);
    histeq_CNR_ratio = histeq_CNR_diff /orig_CNR;
    if sign(histeq_CNR_diff) ~= sign(histeq_CNR_ratio)
        histeq_CNR_ratio = histeq_CNR_ratio * -1;
    end
%     CGAN_SNR_diff = (CGAN_SNR - orig_SNR);
%     CGAN_SNR_ratio = CGAN_SNR_diff/orig_SNR;
%     if sign(CGAN_SNR_diff) ~= sign(CGAN_SNR_ratio)
%         CGAN_SNR_ratio = CGAN_SNR_ratio * -1;
%     end  
%     CGAN_CNR_diff = (CGAN_CNR - orig_CNR);
%     CGAN_CNR_ratio = CGAN_CNR_diff/orig_CNR;
%     if sign(CGAN_CNR_diff) ~= sign(CGAN_CNR_ratio)
%         CGAN_CNR_ratio = CGAN_CNR_ratio * -1;
%     end      
    histeq_SNR_diff_vector(i) = histeq_SNR_diff;
    histeq_CNR_diff_vector(i) = histeq_CNR_diff;
%     CGAN_SNR_diff_vector(i) = CGAN_SNR_diff;
%     CGAN_CNR_diff_vector(i) = CGAN_CNR_diff;
    histeq_SNR_ratio_vector(i) = histeq_SNR_ratio;
    histeq_CNR_ratio_vector(i) = histeq_CNR_ratio;
%     CGAN_SNR_ratio_vector(i) = CGAN_SNR_ratio;
%     CGAN_CNR_ratio_vector(i) = CGAN_CNR_ratio;
    
end

%%
histeq_SNR_diff_mean = mean(histeq_SNR_diff_vector)
% CGAN_SNR_diff_mean = mean(CGAN_SNR_diff_vector)

histeq_CNR_diff_mean = mean(histeq_CNR_diff_vector)
% CGAN_CNR_diff_mean = mean(CGAN_CNR_diff_vector)

histeq_SNR_ratio_mean = mean(histeq_SNR_ratio_vector)
% CGAN_SNR_ratio_mean = mean(CGAN_SNR_ratio_vector)

histeq_CNR_ratio_mean = mean(histeq_CNR_ratio_vector)
% CGAN_CNR_ratio_mean = mean(CGAN_CNR_ratio_vector)

%%% PLOT %%%
%%
% do_plot('Histeq vs CGAN',histeq_SNR_vector,histeq_CNR_vector,CGAN_SNR_vector,CGAN_CNR_vector);
x = (1:L)';

figure
subplot(2,1,1);
trend = fit(x,histeq_SNR_diff_vector,'poly2');
plot(histeq_SNR_diff_vector);
hold on
plot(trend,x,histeq_SNR_diff_vector)
% title('histeq SNR Increase');
% xlabel('Images')
% ylabel('Increase')

% trend = fit(x,CGAN_SNR_vector,'poly2');
% hold on
% plot(CGAN_SNR_vector)
% hold on
% plot(trend,x,CGAN_SNR_vector)
% title('SNR Increase');
% xlabel('Images')
% ylabel('Increase')
% legend('off')

subplot(2,1,2);
trend = fit(x,histeq_CNR_diff_vector,'poly2');
plot(histeq_CNR_diff_vector)
hold on
plot(trend,x,histeq_CNR_diff_vector)
% title('Histeq CNR Increase');
% xlabel('Images')
% ylabel('Increase')
% legend('off')

% subplot(2,2,4);
% trend = fit(x,CGAN_CNR_vector,'poly2');
% hold on
% plot(CGAN_CNR_vector)
% hold on
% plot(trend,x,CGAN_CNR_vector)
% title('CNR Increase');
% xlabel('Images')
% ylabel('Increase')
% % legend('off')
suptitle(super)

%%
%Save workspace
save('histogeq_test', 'histeq_SNR_diff_mean', 'histeq_SNR_ratio_mean',...
    'histeq_CNR_diff_mean', 'histeq_CNR_ratio_mean')