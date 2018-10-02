clear all
%close all

images = dir('E:\david\development\MATLAB\to_matlab/*.png');
fields = fieldnames(images);
cells = struct2cell(images);
sz = size(cells);
cells = reshape(cells, sz(1), []);
cells = cells';
% Sort by field "date"
cells = sortrows(cells, 3);
cells = reshape(cells', sz);
images = cell2struct(cells, fields, 1);

path = strcat('E:\david\development\MATLAB\to_matlab/', images(1).name);
image = imread(path);
image = im2double(image);
image = rgb2gray(image);
figure(58)
%imshow(image), [0 255];
imshow(image);
%%

SNRvector = [];
CNRvector = [];
%for i = 1:length(images)
for i = 1:2
    i
    name = images(i).name;
    path = strcat('E:\david\development\MATLAB\to_matlab/', name);
    image = im2double(imread(path));
    image = rgb2gray(image);
    [height,width] = size(image);
    c = centerOfMass(image);
    centerX = round(c(2));
    centerY = round(c(1));

    mask = double(zeros(height, width));
    newmask = double(ones(height, width));
    if height < 130 && width < 130 && height ~= width
        maskSizeX = 50;
        maskSizeY = 40;
    else
        maskSizeX = round(width/5);
        maskSizeY = round(height/7);
    end
    mask(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX) = 1;
    masked = image .* mask;
    masked = masked(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX);

    %newmask to cut out background
    newmask(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX) = inf;
    newmasked = image .* newmask;
    background = find(newmasked < inf);

    sdBackground = std(image(background));
    meanROI = mean(mean(masked));
    %sdROI = std(std(masked));
    meanBackground = mean(mean(image(background)));

    snr = meanROI/sdBackground;
    cnr = meanROI-meanBackground;
    %cnr = meanROI-sdBackground;

    SNRvector = [SNRvector; snr];
    CNRvector = [CNRvector; cnr]; 
end



figure(58)
imshow(image[background]);

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

p1 = 10.96;
p2 = 62.07;
goodX = [];
badX = [];
goodY = [];
badY = [];
for i=1:length(CNRvector)
    name = images(i).name;
    path = strcat('../samples/', name);
    image = double(imread(path));
    x = SNRvector(i);
    y = CNRvector(i);
    if y < p1*x + p2
        badY = [badY;y];
        badX = [badX;x];
        copyfile (path, '../sample_low_quality');
    else
        goodY = [goodY;y];
        goodX = [goodX;x];
        copyfile (path, '../sample_high_quality');
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