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
images = dir('E:\david\R_middle_slices/*.png');
L = length(images);
SNRvector = zeros(length(images),1);
roiSNRvector = zeros(length(images),1);
CNRvector = zeros(length(images),1);
for i = 1:L
    i
    name = images(i).name;
    path = strcat('E:\david\R_middle_slices/', name);
    image = im2double(imread(path));
    %image = rgb2gray(image);
    [height,width] = size(image);
    c = centerOfMass(image);
    centerX = round(c(2));
    centerY = round(c(1));
   
    mask = double(zeros(height, width));
    maskSizeX = round(width/4);
    maskSizeY = round(height/4);
    mask(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX) = 1;
    ROI = image .* mask;
    ROI = ROI(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX);

    %Values in image range from 0 to 1, so by assigning the values
    %of ROI to 2, the background can be found
    copy = image;
    copy(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX) = 2;
    
    upper_left = grayconnected(copy,1,1,0);
    upper_right = grayconnected(copy,1,width,0);
    lower_left = grayconnected(copy,height,1,0);
    lower_right = grayconnected(copy,height,width,0);
    outside = 2*(upper_left + upper_right + lower_left + lower_right);
    copy = copy + outside;
    
    figure(999)
    imshow(copy);
    
    %twos = sum(copy(:) >= 2)
    backgroundIndices = copy < 2;
    backgroundValues = copy(backgroundIndices);

    meanROI = mean(ROI(:));
    sdROI = std(ROI(:));
    sdBackground = std(backgroundValues);
    meanBackground = mean(backgroundValues);

    roiSNR = meanROI/sdROI;
    SNR = meanROI/sdBackground;
    CNR = meanROI-meanBackground;
    roiSNRvector(i) = roiSNR;
    SNRvector(i) = SNR;
    CNRvector(i) = CNR;
end

%%%%%%%%%% SEE THE IMAGES %%%%%%%%%%%%%%%
%%
name = images(169).name;
path = strcat('E:\david\R_middle_slices/', name);
image = im2double(imread(path));
figure(58)
imshow(image);

name = images(260).name;
path = strcat('E:\david\R_middle_slices/', name);
image = im2double(imread(path));
figure(59)
imshow(image);



%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%
%%
close all;

figure(1)
plot(SNRvector);                                      
title('SNR')
xlabel('Samples')
ylabel('SNR')

figure(2)
hist(SNRvector);
title('SNR hist')
xlabel('SNR')
ylabel('Samples')

figure(3)
boxplot(SNRvector);
title('SNR box')

figure(4)
plot(CNRvector);
title('CNR')
xlabel('Samples')
ylabel('CNR')

figure(5)
hist(CNRvector);
title('CNR hist')
xlabel('CNR')
ylabel('Samples')

figure(6)
boxplot(CNRvector);
title('CNR box')

figure(7)
plot(roiSNRvector);
title('SNR')
xlabel('Samples')
ylabel('roiSNR')

figure(8)
hist(roiSNRvector);
title('roiSNR hist')
xlabel('altSNR')
ylabel('Samples')

figure(9)
boxplot(roiSNRvector);
title('roiSNR box')

SNRmean = mean(SNRvector);
CNRmean = mean(CNRvector);
roiSNRmean = mean(roiSNRvector);

%%%%%%%%%%%% FIND 30% TOP & BOTTOM %%%%%%%%%%%%%
%%
portion = round(L*0.2);
% [~, snr_top_i] = maxk(SNRvector, portion);
[~, snr_top_i] = maxk(roiSNRvector, portion);
[~, cnr_top_i] = maxk(CNRvector, portion);
top_intersection = intersect(snr_top_i, cnr_top_i);

% [~, snr_low_i] = mink(SNRvector, portion);
[~, snr_low_i] = mink(roiSNRvector, portion);
[~, cnr_low_i] = mink(CNRvector, portion);
low_intersection = intersect(snr_low_i, cnr_low_i);

%%%%%%%%%%% CLASSIFY INTO FOLDERS %%%%%%%%%%%%
%%
for i = 1:length(top_intersection)
    i
    index = top_intersection(i);
    name = images(index).name;
    source = strcat('E:\david\R_middle_slices/', name);
    dest = strcat('E:\david\R_intersect_high/', name);
    [status, msg, ~] = copyfile(source, dest);
    if ~strcmp(msg,'')
        disp('PROBLEM')
        return
    end    
end

for i = 1:length(low_intersection)
    i
    index = low_intersection(i);
    name = images(index).name;
    source = strcat('E:\david\R_middle_slices/', name);
    dest = strcat('E:\david\R_intersect_low/', name);
    [status, msg, ~] = copyfile(source, dest);
    if ~strcmp(msg,'')
        disp('PROBLEM')
        return
    end    
end