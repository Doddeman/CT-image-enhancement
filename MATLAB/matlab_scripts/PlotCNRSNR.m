clear all
close all

images = dir('../samples/*.png');

%snr1 = snr(masked,masked);
%snrdb = mag2db(snr);
%snrdb = 10*log10(snr);

SNRvector = [];
SNRDBvector = [];
CNRvector = [];
for i = 1:length(images)
    i
    name = images(i).name;
    path = strcat('../samples/', name);
    image = double(imread(path));
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
    snrdb = mag2db(snr);
    %cnr = meanROI-meanBackground;
    cnr = meanROI-sdBackground;

    SNRvector = [SNRvector; snr];
    SNRDBvector = [SNRDBvector; snrdb];
    CNRvector = [CNRvector; cnr]; 
end
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