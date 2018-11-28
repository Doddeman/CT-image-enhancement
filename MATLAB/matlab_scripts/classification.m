% This code calculates the SNR and CNR of images and 
% plots them to classify into high and low quality.
% Works best if the images have been sampled beforehand.
% Use the sampling script to get middle slices for patients
% https://www.mathworks.com/help/images/ref/grayconnected.html
% https://www.mathworks.com/help/images/morphological-filtering.html

%%%%%%%%%%%%% CALCULATE SNR AND CNR %%%%%%%%%%%%%%%%%%%%%
%%
clear all;
close all;
% images = dir('E:\david\R_middle_slices/*.png');
images = dir('C:\Users\davwa\Desktop\R3-R28_middle_slices/*.png');
L = length(images);
size = 256;
% SNR_vector = zeros(length(images),1);
% roi_SNR_vector = zeros(length(images),1);
CNR_vector = zeros(length(images),1);
for i = 1:L
    i
    name = images(i).name;
    path = strcat('C:\Users\davwa\Desktop\R3-R28_middle_slices/', name);
    image = get_image(path);
    outside = get_outside(image,size,size);
    [SNR,CNR] = get_SNR_CNR(image,outside,size,size);    
    
%     roi_SNR = meanROI/sdROI;
%     roi_SNR_vector(i) = roi_SNR;
%     SNR_vector(i) = SNR;
    CNR_vector(i) = CNR;
end

%%%%%%%%%% SEE THE IMAGES %%%%%%%%%%%%%%%
%%
name = images(169).name;
path = strcat('C:\Users\davwa\Desktop\R3-R28_middle_slices/', name);
image = im2double(imread(path));
figure(58)
imshow(image);

name = images(260).name;
path = strcat('C:\Users\davwa\Desktop\R3-R28_middle_slices/', name);
image = im2double(imread(path));
figure(59)
imshow(image);

%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%
%%
close all;

% figure(1)
% plot(SNR_vector);                                      
% title('SNR')
% xlabel('Samples')
% ylabel('SNR')
% 
% figure(2)
% hist(SNR_vector);
% title('SNR hist')
% xlabel('SNR')
% ylabel('Samples')
% 
% figure(3)
% boxplot(SNR_vector);
% title('SNR box')

figure(4)
plot(CNR_vector);
title('CNR')
xlabel('Samples')
ylabel('CNR')

figure(5)
hist(CNR_vector);
title('CNR hist')
xlabel('CNR')
ylabel('Samples')

figure(6)
boxplot(CNR_vector);
title('CNR box')

% figure(7)
% plot(roiSNRvector);
% title('SNR')
% xlabel('Samples')
% ylabel('roiSNR')
% 
% figure(8)
% hist(roiSNRvector);
% title('roiSNR hist')
% xlabel('altSNR')
% ylabel('Samples')
% 
% figure(9)
% boxplot(roiSNRvector);
% title('roiSNR box')

% SNRmean = mean(SNR_vector);
CNRmean = mean(CNR_vector);
% roiSNRmean = mean(roiSNRvector);

%%%%%%%%%%%% FIND 30% TOP & BOTTOM %%%%%%%%%%%%%
%%
top_portion = round(L*0.3);
% [~, snr_top_i] = maxk(SNRvector, portion);
% [~, snr_top_i] = maxk(roiSNRvector, top_portion);
[~, cnr_top_i] = maxk(CNR_vector, top_portion);
% top_intersection = intersect(snr_top_i, cnr_top_i);

bottom_portion = round(L*0.7);
% [~, snr_low_i] = mink(SNRvector, portion);
% [~, snr_low_i] = mink(roiSNRvector, bottom_portion);
[~, cnr_low_i] = mink(CNR_vector, bottom_portion);
% low_intersection = intersect(snr_low_i, cnr_low_i);

%%%%%%%%%%% CLASSIFY INTO FOLDERS %%%%%%%%%%%%
%%
for i = 1:length(cnr_top_i)
    i
    index = cnr_top_i(i);
    name = images(index).name;
    source = strcat('C:\Users\davwa\Desktop\R3-R28_middle_slices/', name);
    dest = strcat('C:\Users\davwa\Desktop\R_top/', name);
    [status, msg, ~] = copyfile(source, dest);
    if ~strcmp(msg,'')
        disp('PROBLEM')
        return
    end    
end
j = i;
for i = 1:length(cnr_low_i)
    j
    index = cnr_low_i(i);
    name = images(index).name;
    source = strcat('C:\Users\davwa\Desktop\R3-R28_middle_slices/', name);
    dest = strcat('C:\Users\davwa\Desktop\R_bottom/', name);
    [status, msg, ~] = copyfile(source, dest);
    if ~strcmp(msg,'')
        disp('PROBLEM')
        return
    end
    j = j + 1;
end