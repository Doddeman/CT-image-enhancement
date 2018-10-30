% This code calculates the SNR and CNR of images and 
% plots them to classify into high and low quality.
% Works best if the images have been sampled beforehand.
% Use the sampling script to get middle slices for patients


%%%%%%%%% SECTION FOR TESTING CALCULATIONS %%%%%%%%%%%%%%
%%
clear all
%close all

% Get images and sort after date modified
%images = dir('E:\david\development\MATLAB\to_matlab/*.png');
images = dir('../to_matlab/*.png');
fields = fieldnames(images);
cells = struct2cell(images);
sz = size(cells);
cells = reshape(cells, sz(1), []);
cells = cells';
% Sort by field "date"
cells = sortrows(cells, 3);
cells = reshape(cells', sz);
images = cell2struct(cells, fields, 1);

path = strcat('..\to_matlab/', images(4000).name);
image = imread(path);
image = im2double(image);
image = rgb2gray(image);

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

figure(1)
%imshow(image), [0 255];
imshow(image);
hold on;
plot(centerX,centerY,'r.');

figure(2)
imshow(ROI);
title('masked image')

copy = image;
copy(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX) = 2;
%sum = sum(copy(:) == 2)
backgroundIndices = find(copy < 2);
backgroundValues = image(backgroundIndices);

figure(3)
imshow(copy);

meanROI = mean(mean(ROI));
%sdROI = std(std(masked));
sdBackground = std(backgroundValues);
meanBackground = mean(backgroundValues);

signal = meanROI;
contrast = meanROI-meanBackground;
noise = sdBackground;
snr = signal/noise;
c = contrast/noise;
cnr = log10(c);
cnr2 = 20*cnr;
%cnr = meanROI-sdBackground;


%%%%%%%%%%%%% CALCULATE SNR AND CNR %%%%%%%%%%%%%%%%%%%%%
%%
clear all;
%close all;
images = dir('E:\david\middle_slices/*.png');
L = length(images);
SNRvector = zeros(length(images),1);
altSNRvector = zeros(length(images),1);
CNRvector = zeros(length(images),1);
for i = 1:L
    i
    name = images(i).name;
    path = strcat('E:\david\middle_slices/', name);
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
    background = image;
    background(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX) = 2;
    %twos = sum(image(:) == 2)
    backgroundIndices = find(background < 2);
    backgroundValues = background(backgroundIndices);

    meanROI = mean(mean(ROI));
    sdROI = std(std(ROI));
    sdBackground = std(backgroundValues);
    meanBackground = mean(backgroundValues);

    altsnr = meanROI/sdROI;
    snr = meanROI/sdBackground;
    cnr = meanROI-meanBackground;
    altSNRvector(i) = altsnr;
    SNRvector(i) = snr;
    CNRvector(i) = cnr;
end

%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%
%%

% figure(58)
% imshow(image);

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

SNRmean = mean(SNRvector);
CNRmean = mean(CNRvector);
altSNRmean = mean(altSNRvector);

%%%%%%%%%%%% FIND 30% TOP & BOTTOM %%%%%%%%%%%%%
%%
top30 = round(L*0.3);
[snr_top, snr_top_i] = maxk(altSNRvector, top30);
[cnr_top, cnr_top_i] = maxk(SNRvector, top30);
top_intersection = intersect(snr_top_i,cnr_top_i);

low30 = round(L*0.3);
[snr_low, snr_low_i] = mink(altSNRvector, low30);
[cnr_low, cnr_low_i] = mink(SNRvector, low30);
low_intersection = intersect(snr_low_i,cnr_low_i);

%%%%%%%%%%% CLASSIFY INTO FOLDERS %%%%%%%%%%%%
%%
for i = 1:length(top_intersection)
    i
    index = top_intersection(i);
    name = images(index).name;
    source = strcat('E:\david\middle_slices/', name);
    dest = strcat('E:\david\R_high_roi/', name);
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
    source = strcat('E:\david\middle_slices/', name);
    dest = strcat('E:\david\R_low_roi/', name);
    [status, msg, ~] = copyfile(source, dest);
    if ~strcmp(msg,'')
        disp('PROBLEM')
        return
    end    
end



























%%%%% REGRESSION (old method)%%%%%%
%%

fitmodel = fit(SNRvector, CNRvector,'poly1')
%%
close all;
p1 = 0.002343;
p2 = 0.1204;
goodX = [];
badX = [];
goodY = [];
badY = [];
for i=1:length(CNRvector)
    i
    name = images(i).name;
    fromPath = strcat('P:\Shared\ImagesFromVikas\middle_slices\', name);
    toPathLow = strcat('P:\Shared\ImagesFromVikas\sample_low_quality2\', name);
    toPathHigh = strcat('P:\Shared\ImagesFromVikas\sample_high_quality2\', name);
    image = double(imread(path));
    x = SNRvector(i);
    y = CNRvector(i);
    if y < p1*x + p2
        badY = [badY;y];
        badX = [badX;x];
        copyfile (fromPath, toPathLow);
    else
        goodY = [goodY;y];
        goodX = [goodX;x];
        copyfile (fromPath, toPathHigh);
    end
end

figure(59)
plot(fitmodel,goodX,goodY,'g*');
hold on
plot(badX,badY,'*');
title('SNR vs CNR')
xlabel('SNR')
ylabel('CNR')

figure(56)
plot(fitmodel,SNRvector,CNRvector,'*');
title('SNR vs CNR')
xlabel('SNR')
ylabel('CNR')