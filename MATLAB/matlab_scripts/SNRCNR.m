%%%%%%%%%%%%%% INITIATE DATA STRUCTURES %%%%%%%%%%%%

clear all
%close all

%Get images and sort after date modified
originals = dir('../to_matlab/origs_terrible/*.png');
fields = fieldnames(originals);
cells = struct2cell(originals);
sz = size(cells);
cells = reshape(cells, sz(1), []);
cells = cells';
% Sort by field "date"
cells = sortrows(cells, 3);
cells = reshape(cells', sz);
originals = cell2struct(cells, fields, 1);

fakes = dir('../to_matlab/fakes_terrible/*.png');
fields = fieldnames(fakes);
cells = struct2cell(fakes);
sz = size(cells);
cells = reshape(cells, sz(1), []);
cells = cells';
% Sort by field "date"
cells = sortrows(cells, 3);
cells = reshape(cells', sz);
fakes = cell2struct(cells, fields, 1);

L1 = length(originals);
L2 = length(fakes);

if L1 ~= L2
    disp('Not same length of directories');
    disp('Terminating script');
    return
end

%check for errors
for i = 1:L1
    i
    orig = originals(i).name;
    orig = strsplit(orig,'_');
    n1 = orig{4};
    fak = fakes(i).name;
    fak = strsplit(fak,'_');
    n2 = fak{4};
    if ~strcmp(n1,n2)
        disp('Not same image!!!');
        return
    end
end


%%%%% Testing
%% 
n = 10000;
figure(80)
original = originals(n).name
originalPath = strcat('../to_matlab/origs_terrible/', original);
imshow(originalPath)

figure(81)
fake = fakes(n).name
fakepath = strcat('../to_matlab/fakes_terrible/', fake);
imshow(fakepath)

%%%%%%%%%%%%%% GIANT FOR LOOP, FILL VECTORS %%%%%%%%%%%%
%%
images_per_epoch = 1478;
%images_per_epoch = 12628;
% images_per_epoch = 12624;
n_of_epochs = floor(L1/images_per_epoch); %data sampled from X epochs 


SNRvector = zeros(n_of_epochs,1);
CNRvector = zeros(n_of_epochs,1);
roiSNRvector = zeros(n_of_epochs,1);
epochSNR = 0;
epochCNR = 0;
epochSNRroi = 0;

epoch = 1;
for i = 1:L1
    i
    %Get original
    originalName = originals(i).name;
    originalPath = strcat('../to_matlab/origs_terrible/', originalName);
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

    originalMeanROI = mean(originalROI(:));
    originalStdROI = std(originalROI(:));
    
    %Get original background.
    %Values in image range from 0 to 1, so by assigning the values
    %of ROI to 2, the background can be found
    original(originalCenterY-maskSizeY:originalCenterY+maskSizeY,originalCenterX-maskSizeX:originalCenterX+maskSizeX) = 2;
    %twos = sum(image(:) == 2)
    backgroundIndices = find(original < 2);
    backgroundValues = original(backgroundIndices);
   
    %Add 1 to normalize over all pixels
    originalStdBackground = std(backgroundValues, 1);
    originalMeanBackground = mean(backgroundValues);

    % Get fake image
    fakeName = fakes(i).name;
    fakePath = strcat('../to_matlab/fakes_terrible/', fakeName);
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
    fakeStdROI = std(fakeROI(:));
    
    %Get fake background.
    %Values in image range from 0 to 1, so by assigning the values
    %of ROI to 2, the background can be found
    fake(fakeCenterY-maskSizeY:fakeCenterY+maskSizeY,fakeCenterX-maskSizeX:fakeCenterX+maskSizeX) = 2;
    %twos = sum(image(:) == 2)
    backgroundIndices = find(fake < 2);
    backgroundValues = fake(backgroundIndices);
    
    %Add 1 to normalize over all pixels
    fakeStdBackground = std(backgroundValues, 1);
    fakeMeanBackground = mean(backgroundValues);

    originalSNR = originalMeanROI / originalStdBackground;
    fakeSNR = fakeMeanROI / fakeStdBackground;
    SNRdifference = fakeSNR - originalSNR;
    
    originalCNR = originalMeanROI - originalMeanBackground;
    fakeCNR = fakeMeanROI - fakeMeanBackground;
    CNRdifference = fakeCNR - originalCNR;
    
    originalSNRroi = originalMeanROI / originalStdROI;
    fakeSNRroi = fakeMeanROI / fakeStdROI;
    roiSNRdiff = fakeSNRroi - originalSNRroi;

    epochSNR = epochSNR + SNRdifference;
    epochCNR = epochCNR + CNRdifference;
    epochSNRroi = epochSNRroi + roiSNRdiff;

    if mod(i,images_per_epoch) == 0 % End of epoch?
        %i
        meanSNR = epochSNR / images_per_epoch;
        meanCNR = epochCNR / images_per_epoch;
        meanSNRroi = epochSNRroi / images_per_epoch;
        SNRvector(epoch) = meanSNR;
        CNRvector(epoch) = meanCNR;
        roiSNRvector(epoch) = meanSNRroi;
        epochSNR = 0;
        epochCNR = 0;
        epochSNRroi = 0;
        epoch = epoch + 1;
    end
end

%%%%%%%%%%%%%% PLOT RESULTS WITH TRENDS%%%%%%%%%%%%
%%
x = ones(length(SNRvector),1);
for i = 1:length(x)
    x(i) = i;
end
SNRtrend = fit(x,SNRvector,'poly2');
CNRtrend = fit(x,CNRvector,'poly2');
roiSNRtrend = fit(x,roiSNRvector,'poly2');

close all

figure(3)
plot(SNRvector);
hold on
plot(SNRtrend, x, SNRvector);
title('SNR Progression')
xlabel('Epochs')
ylabel('SNR difference')

figure(4)
plot(CNRvector);
hold on
plot(CNRtrend, x, CNRvector);
title('CNR Progression')
xlabel('Epochs')
ylabel('CNR difference')

figure(5)
plot(roiSNRvector);
hold on
plot(roiSNRtrend, x, roiSNRvector);
title('roi SNR Progression')
xlabel('Epochs')
ylabel('SNR difference')

%%%%%%%%%%%%%% PLOT RESULTS WITHOUT TRENDS%%%%%%%%%%%%
%%
close all

figure(4)
plot(SNRvector);
title('SNR Progression')
xlabel('Epochs')
ylabel('SNR difference')

figure(5)
plot(CNRvector);
title('CNR Progression')
xlabel('Epochs')
ylabel('CNR difference')

figure(3)
plot(roiSNRvector);
title('roi SNR Progression')
xlabel('Epochs')
ylabel('CNR difference')


%%
%Save workspace
total_epochs = 30;
saved_every = 1;
save('terrible', 'SNRvector', 'CNRvector', 'roiSNRvector', 'total_epochs', 'saved_every')
