% This code calculates the SNR and CNR of images and 
% plots them against each other. It then performs a 
% regression (linear right now) to make an estimation 
% of which images have high quality and which have low.
% Works best if the images have been sampled beforehand.
% Use the sampling script to get middle slices for patients

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
maskedImage = image .* mask;
maskedImage = maskedImage(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX);

figure(1)
%imshow(image), [0 255];
imshow(image);
hold on;
plot(centerX,centerY,'r.');

figure(2)
imshow(maskedImage);
title('masked image')

copy = image;
copy(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX) = 2;
%sum = sum(copy(:) == 2)
backgroundIndices = find(copy < 2);
backgroundValues = image(backgroundIndices);

figure(3)
imshow(copy);

meanROI = mean(mean(maskedImage));
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


%%
clear all;
%close all;
images = dir('P:\Shared\ImagesFromVikas\middle_slices/*.png');

SNRvector = zeros(length(images),1);
CNRvector = zeros(length(images),1);
for i = 1:length(images)
    i
    name = images(i).name;
    path = strcat('P:\Shared\ImagesFromVikas\middle_slices/', name);
    %path = strcat('E:\david\development\MATLAB\to_matlab/', name);
    %path = strcat('C:\Users\davwa\Desktop\Exjobb\Development\MATLAB\to_matlab/', name);
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
    maskedImage = image .* mask;
    maskedImage = maskedImage(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX);

    %Values in image range from 0 to 1, so by assigning the values
    %of ROI to 2, the background can be found
    image(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX) = 2;
    %twos = sum(image(:) == 2)
    backgroundIndices = find(image < 2);
    backgroundValues = image(backgroundIndices);

    meanROI = mean(mean(maskedImage));
    %sdROI = std(std(masked));
    sdBackground = std(backgroundValues);
    meanBackground = mean(backgroundValues);

    signal = meanROI;
    noise = sdBackground;
    snr = signal/noise;
    cnr = meanROI-meanBackground;
    
    %contrast = meanROI-meanBackground;
    %c = contrast/noise;
 
    SNRvector(i) = snr;
    CNRvector(i) = cnr;
end

%%

figure(58)
imshow(image);

figure(59)
plot(SNRvector);                                      
title('SNR')
xlabel('Samples')
ylabel('SNR')

figure(69)
plot(CNRvector);
title('CNR')
xlabel('Samples')
ylabel('CNR')


SNRmean = mean(SNRvector);
CNRmean = mean(CNRvector);


%%

fitmodel = fit(SNRvector, CNRvector,'poly1')
%%
close all;
p1 = 0.009172;
p2 = 0.08573;
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