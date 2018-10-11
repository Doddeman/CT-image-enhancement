%%%%%%%%%%%%%% INITIATE DATA STRUCTURES %%%%%%%%%%%%

clear all
%close all

%Get images and sort after date modified
%images = dir('E:\david\development\MATLAB\to_matlab/*.png');
originals = dir('../to_matlab/originals/*.png');
fields = fieldnames(originals);
cells = struct2cell(originals);
sz = size(cells);
cells = reshape(cells, sz(1), []);
cells = cells';
% Sort by field "date"
cells = sortrows(cells, 3);
cells = reshape(cells', sz);
originals = cell2struct(cells, fields, 1);

fakes = dir('../to_matlab/fakes/*.png');
fields = fieldnames(fakes);
cells = struct2cell(fakes);
sz = size(cells);
cells = reshape(cells, sz(1), []);
cells = cells';
% Sort by field "date"
cells = sortrows(cells, 3);
cells = reshape(cells', sz);
fakes = cell2struct(cells, fields, 1);

if length(originals) ~= length(fakes)
    disp('Not same length of directories');
    disp('Terminating script');
    return
end

L = length(originals);

%%%%% Testing
%% 
n = 1000;
figure(80)
original = originals(n).name;
originalPath = strcat('../to_matlab/originals/', original)
imshow(originalPath)

figure(81)
fake = fakes(n).name;
fakepath = strcat('../to_matlab/fakes/', fake)
imshow(fakepath)



%%%%%%%%%%%%%% GIANT FOR LOOP, FILL VECTORS %%%%%%%%%%%%
%%
images_per_epoch = 1478;
n_of_epochs = length(originals)/images_per_epoch;

PSNRvector = zeros(n_of_epochs,1);
SNRvector = zeros(n_of_epochs,1);
CNRvector = zeros(n_of_epochs,1);
epochPSNR = 0;
epochSNR = 0;
epochCNR = 0;

% SNRactual = zeros(n_of_epochs,1);
% CNRactual = zeros(n_of_epochs,1);
% epochSNRactual = 0;
% epochCNRactual = 0;

epoch = 1;

for i = 1:L
    i
    %Get original
    originalName = originals(i).name;
    originalPath = strcat('../to_matlab/originals/', originalName);
    %path = strcat('E:\david\development\MATLAB\to_matlab/', name);
    %path = strcat('C:\Users\davwa\Desktop\Exjobb\Development\MATLAB\to_matlab/', name);
    original = im2double(imread(originalPath));
    original = imresize(original,[256,256]);
    original(original<0) = 0;

    %Get original ROI
    [origHeight,origWidth] = size(original);
    originalC = centerOfMass(original);
    originalCenterX = round(originalC(2));
    originalCenterY = round(originalC(1));

    mask = double(zeros(origHeight, origWidth));
    maskSizeX = round(origWidth/4);
    maskSizeY = round(origHeight/4);
    mask(originalCenterY-maskSizeY:originalCenterY+maskSizeY,originalCenterX-maskSizeX:originalCenterX+maskSizeX) = 1;
    maskedImage = original .* mask;
    originalROI = maskedImage(originalCenterY-maskSizeY:originalCenterY+maskSizeY,originalCenterX-maskSizeX:originalCenterX+maskSizeX);

    %Get original background
    %Values in image range from 0 to 1, so by assigning the values
    %of ROI to 2, the background can be found
    original(originalCenterY-maskSizeY:originalCenterY+maskSizeY,originalCenterX-maskSizeX:originalCenterX+maskSizeX) = 2;
    %twos = sum(image(:) == 2)
    backgroundIndices = find(original < 2);
    backgroundValues = original(backgroundIndices);
   
    originalMeanROI = mean(mean(originalROI));
    %Add 1 to normalize over number of pixels
    originalStdBackground = std(backgroundValues, 1);
    originalMeanBackground = mean(backgroundValues);

    % Get fake image
    fakeName = fakes(i).name;
    fakePath = strcat('../to_matlab/fakes/', fakeName);
    %path = strcat('E:\david\development\MATLAB\to_matlab/', name);
    %path = strcat('C:\Users\davwa\Desktop\Exjobb\Development\MATLAB\to_matlab/', name);
    fake = im2double(imread(fakePath));
    fake = rgb2gray(fake);

    %Get fake ROI
    [fakeHeight,fakeWidth] = size(fake);
    fakeC = centerOfMass(fake);
    fakeCenterX = round(fakeC(2));
    fakeCenterY = round(fakeC(1));

    mask = double(zeros(fakeHeight, fakeWidth));
    maskSizeX = round(fakeWidth/4);
    maskSizeY = round(fakeHeight/4);
    mask(fakeCenterY-maskSizeY:fakeCenterY+maskSizeY,fakeCenterX-maskSizeX:fakeCenterX+maskSizeX) = 1;
    maskedImage = fake .* mask;
    fakeROI = maskedImage(fakeCenterY-maskSizeY:fakeCenterY+maskSizeY,fakeCenterX-maskSizeX:fakeCenterX+maskSizeX);

    fakeMeanROI = mean(mean(fakeROI));

    originalSNR = originalMeanROI / originalStdBackground;
    originalCNR = originalMeanROI - originalMeanBackground;
    fakeSNR = fakeMeanROI / originalStdBackground;
    fakeCNR = fakeMeanROI - originalMeanBackground;

    SNRdifference = fakeSNR - originalSNR;
    CNRdifference = fakeCNR - originalCNR;
 
    %Weird SNR, should be 10log10
    nominator = 0;
    denominator = 0;
    for i = 1:n_of_pixels 
        curr = original(i)^2;
        curr2 = (original(i)-fake(i))^2;
        nominator = nominator + curr;
        denominator = denominator + curr2;
    end
    snr = nominator/denominator; 
    
    %PSNR
%     peak = max(max(fake))^2;
%     denominator = (sum(sum(fake))-sum(sum(original)))^2;
%     denominator = denominator/(origHeight*origWidth*fakeHeight*fakeWidth);
    %nindices = find(original<0);
    %nvalues = original(nindices);
%     nofindices1 = length(find(fake<0));
%     
%     nofindices2 = length(find(original<0));
    
    [peaksnr] = psnr(fake,original);

    epochPSNR = epochPSNR + peaksnr;
    epochSNR = epochSNR + snr;
    epochCNR = epochCNR + CNRdifference;

%     epochSNRactual = epochSNRactual + fakeSNR;
%     epochCNRactual = epochCNRactual + fakeCNR;

    % End of epoch?
    if mod(i,images_per_epoch) == 0
        i
        meanPSNR = epochPSNR / images_per_epoch;
        meanSNR = epochSNR / images_per_epoch;
        meanCNR = epochCNR / images_per_epoch;
        PSNRvector(epoch) = meanPSNR;
        SNRvector(epoch) = meanSNR;
        CNRvector(epoch) = meanCNR;
        epochPSNR = 0;
        epochSNR = 0;
        epochCNR = 0;

%         meanSNR = epochSNRactual / images_per_epoch;
%         meanCNR = epochCNRactual / images_per_epoch;
%         SNRactual(epoch) = meanSNR;
%         CNRactual(epoch) = meanCNR;
%         epochSNRactual = 0;
%         epochCNRactual = 0;

        epoch = epoch + 1;
    end
end

%%%%%%%%%%%%%% PLOT RESULTS %%%%%%%%%%%%
%%
figure(70)
hist(SNRvector);
title('SNR improvement')
xlabel('SNR difference')
ylabel('Epochs')

figure(77)
hist(CNRvector);
title('CNR improvement')
xlabel('CNR difference')
ylabel('Epochs')

%%
figure(1)
plot(SNRvector);
title('SNR improvement')
xlabel('Epoch')
ylabel('SNR difference')

figure(2)
plot(CNRvector);
title('CNR improvement')
xlabel('Epoch')
ylabel('CNR difference')

figure(3)
plot(PSNRvector);
title('PSNR')
xlabel('Epoch')
ylabel('CNR difference')

% figure(3)
% plot(SNRactual);
% title('Actual SNR')
% xlabel('Epoch')
% ylabel('SNR')
% 
% figure(4)
% plot(CNRactual);
% title('Actual CNR')
% xlabel('Epoch')
% ylabel('CNR')
