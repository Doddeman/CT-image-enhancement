%%%%%%%%%%%%%% INITIATE DATA STRUCTURES %%%%%%%%%%%%

clear all
%close all

%Get images and sort after date modified
originals = dir('../to_matlab/origs_8_50/*.png');
fields = fieldnames(originals);
cells = struct2cell(originals);
sz = size(cells);
cells = reshape(cells, sz(1), []);
cells = cells';
% Sort by field "date"
cells = sortrows(cells, 3);
cells = reshape(cells', sz);
originals = cell2struct(cells, fields, 1);

fakes = dir('../to_matlab/fakes_8_50/*.png');
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
n = 100000;
figure(80)
orig = originals(n).name
origPath = strcat('../to_matlab/origs_8_50/', orig);
imshow(origPath)

figure(81)
fake = fakes(n).name
fakepath = strcat('../to_matlab/fakes_8_50/', fake);
imshow(fakepath)

%%%%%%%%%%%%%% GIANT FOR LOOP, FILL VECTORS %%%%%%%%%%%%
%%
% images_per_epoch = 1478;
% images_per_epoch = 12628;
images_per_epoch = 12624;
% images_per_epoch = 4096;
n_of_epochs = floor(L1/images_per_epoch); %data sampled from X epochs 

origSNRvector = zeros(images_per_epoch,1);
fakeSNRvector = zeros(images_per_epoch,1);
origCNRvector = zeros(images_per_epoch,1);
fakeCNRvector = zeros(images_per_epoch,1);

SNRvector = zeros(n_of_epochs,1);
CNRvector = zeros(n_of_epochs,1);
roiSNRvector = zeros(n_of_epochs,1);
ratioSNRvector = zeros(n_of_epochs,1);
ratioCNRvector = zeros(n_of_epochs,1);
ratioroiSNRvector = zeros(n_of_epochs,1);
UIQIvector = zeros(n_of_epochs,1);

SNRepoch = 0;
CNRepoch = 0;
roiSNRepoch = 0;
ratioSNRepoch = 0;
ratioCNRepoch = 0;
ratioroiSNRepoch = 0;
UIQIepoch = 0;

epoch = 1;
j=1;
for i = 1:L1
    i
    % GET IMAGES ROIS AND BACKGROUNDS
    %Get original
    origName = originals(i).name;
    origPath = strcat('../to_matlab/origs_8_50/', origName);
    
    [origSNR, origCNR, origSNRroi] = get_snr_cnr(origPath);
    
    orig = im2double(imread(origPath));
%     original = imresize(original,[256,256]);
    orig(orig<0) = 0;

    %Get original ROI
    [origHeight,origWidth] = size(orig);
    originalC = centerOfMass(orig);
    originalCenterX = round(originalC(2));
    originalCenterY = round(originalC(1));

    mask = double(zeros(origHeight, origWidth));
    maskSizeX = round(origWidth/4);
    maskSizeY = round(origHeight/4);
    mask(originalCenterY-maskSizeY:originalCenterY+maskSizeY,originalCenterX-maskSizeX:originalCenterX+maskSizeX) = 1;
    maskedImage = orig .* mask;
    originalROI = maskedImage(originalCenterY-maskSizeY:originalCenterY+maskSizeY,originalCenterX-maskSizeX:originalCenterX+maskSizeX);

    originalMeanROI = mean(originalROI(:));
    originalStdROI = std(originalROI(:));
    
    %Get original background.
    %Values in image range from 0 to 1, so by assigning the values
    %of ROI to 2, the background can be found
    origCopy = orig;
    origCopy(originalCenterY-maskSizeY:originalCenterY+maskSizeY,originalCenterX-maskSizeX:originalCenterX+maskSizeX) = 2;
    
    upper_left = grayconnected(origCopy,1,1,0);
    upper_right = grayconnected(origCopy,1,width,0);
    lower_left = grayconnected(origCopy,height,1,0);
    lower_right = grayconnected(origCopy,height,width,0);
    outside = 2*(upper_left + upper_right + lower_left + lower_right);
    origCopy = origCopy + outside;
    
    %twos = sum(origCopy(:) >= 2) 
    backgroundIndices = origCopy < 2;
    backgroundValues = origCopy(backgroundIndices);
   
    originalStdBackground = std(backgroundValues);
    originalMeanBackground = mean(backgroundValues);

    % Get fake image
    fakeName = fakes(i).name;
    fakePath = strcat('../to_matlab/fakes_8_50/', fakeName);
    fake = im2double(imread(fakePath));
%     fake = rgb2gray(fake);

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
    
    fakeMeanROI = mean(fakeROI(:));
    fakeStdROI = std(fakeROI(:));
    
    %Get fake background.
    %Values in image range from 0 to 1, so by assigning the values
    %of ROI to 2, the background can be found
    fakeCopy = fake;
    fakeCopy(fakeCenterY-maskSizeY:fakeCenterY+maskSizeY,fakeCenterX-maskSizeX:fakeCenterX+maskSizeX) = 2;
    fakeCopy = fakeCopy + outside;
    
    %twos = sum(fakeCopy(:) >= 2)
    backgroundIndices = fakeCopy < 2;
    backgroundValues = fakeCopy(backgroundIndices);
    
    fakeStdBackground = std(backgroundValues);
    fakeMeanBackground = mean(backgroundValues);
    % START CALCULATIONS
    originalSNR = originalMeanROI / originalStdBackground;
    fakeSNR = fakeMeanROI / fakeStdBackground;
    SNRdifference = fakeSNR - originalSNR;
    SNRratio = SNRdifference / originalSNR;
    if sign(SNRdifference) ~= sign(SNRratio)
        SNRratio = SNRratio * -1;
    end
    
    originalCNR = originalMeanROI - originalMeanBackground;
    fakeCNR = fakeMeanROI - fakeMeanBackground;
    CNRdifference = fakeCNR - originalCNR;
    CNRratio = CNRdifference / originalCNR;
    if sign(CNRdifference) ~= sign(CNRratio)
        CNRratio = CNRratio * -1;
    end
    
    originalSNRroi = originalMeanROI / originalStdROI;
    fakeSNRroi = fakeMeanROI / fakeStdROI;
    roiSNRdiff = fakeSNRroi - originalSNRroi;
    roiSNRratio = roiSNRdiff / originalSNRroi;
    if sign(roiSNRdiff) ~= sign(roiSNRratio)
        roiSNRratio = roiSNRratio * -1;
    end 
    [UIQI ~] = get_uiqi(orig, fake);

    SNRepoch = SNRepoch + SNRdifference;
    CNRepoch = CNRepoch + CNRdifference;
    roiSNRepoch = roiSNRepoch + roiSNRdiff;
    
    ratioSNRepoch = ratioSNRepoch + SNRratio;
    ratioCNRepoch = ratioCNRepoch + CNRratio;
    ratioroiSNRepoch = ratioroiSNRepoch + roiSNRratio;
    
    UIQIepoch = UIQIepoch + UIQI;

    if mod(i,images_per_epoch) == 0 % End of epoch?
        %CALCULATE MEAN
        meanSNR = SNRepoch / images_per_epoch;
        meanCNR = CNRepoch / images_per_epoch;
        meanSNRroi = roiSNRepoch / images_per_epoch;
        meanSNRratio = ratioSNRepoch / images_per_epoch;
        meanCNRratio = ratioCNRepoch / images_per_epoch;
        meanSNRratioroi = ratioroiSNRepoch / images_per_epoch;
        meanUIQI = UIQIepoch / images_per_epoch;
        %ADD TO VECTOR
        SNRvector(epoch) = meanSNR;
        CNRvector(epoch) = meanCNR;
        roiSNRvector(epoch) = meanSNRroi;
        ratioSNRvector(epoch) = meanSNRratio;
        ratioCNRvector(epoch) = meanCNRratio;
        ratioroiSNRvector(epoch) = meanSNRratioroi;
        UIQIvector(epoch) = meanUIQI;
        %RESET EPOCH VALUE
        SNRepoch = 0;
        CNRepoch = 0;
        roiSNRepoch = 0;
        ratioSNRepoch = 0;
        ratioCNRepoch = 0;
        ratioroiSNRepoch = 0;
        UIQIepoch = 0;
        %STEP EPOCH
        epoch = epoch + 1;
    end
    
    %If it is the last epoch, start saving for BA
    if i > (L1-images_per_epoch+1)
        origSNRvector(j) = originalSNR;
        fakeSNRvector(j) = fakeSNR;
        origCNRvector(j) = originalCNR;
        fakeCNRvector(j) = fakeCNR;
        j = j + 1;
    end
    
end

% %%%%%%%%%%%ONLY GET BLAND ALTMAN %%%%%%%%%%%%%%%%%%%%%
% %%
% origSNRvector = zeros(images_per_epoch,1);
% fakeSNRvector = zeros(images_per_epoch,1);
% origCNRvector = zeros(images_per_epoch,1);
% fakeCNRvector = zeros(images_per_epoch,1);
% ind = 1;
% one_epoch = L1-images_per_epoch
% for i = one_epoch+1:L1
%     i
%     %Get original
%     originalName = originals(i).name;
%     originalPath = strcat('../to_matlab/origs_R_8/', originalName);
%     original = im2double(imread(originalPath));
% %     original = imresize(original,[256,256]);
%     original(original<0) = 0;
%     
% 
%     %Get original ROI
%     [origHeight,origWidth] = size(original);
%     originalC = centerOfMass(original);
%     originalCenterX = round(originalC(2));
%     originalCenterY = round(originalC(1));
% 
%     mask = double(zeros(origHeight, origWidth));
%     maskSizeX = round(origWidth/4);
%     maskSizeY = round(origHeight/4);
%     mask(originalCenterY-maskSizeY:originalCenterY+maskSizeY,originalCenterX-maskSizeX:originalCenterX+maskSizeX) = 1;
%     maskedImage = original .* mask;
%     originalROI = maskedImage(originalCenterY-maskSizeY:originalCenterY+maskSizeY,originalCenterX-maskSizeX:originalCenterX+maskSizeX);
% 
%     originalMeanROI = mean(originalROI(:));
%     originalStdROI = std(originalROI(:));
%     
%     %Get original background.
%     %Values in image range from 0 to 1, so by assigning the values
%     %of ROI to 2, the background can be found
%     origCopy = original;
%     origCopy(originalCenterY-maskSizeY:originalCenterY+maskSizeY,originalCenterX-maskSizeX:originalCenterX+maskSizeX) = 2;
%     %twos = sum(image(:) == 2)
%     backgroundIndices = origCopy < 2;
%     backgroundValues = origCopy(backgroundIndices);
%    
%     originalStdBackground = std(backgroundValues);
%     originalMeanBackground = mean(backgroundValues);
% 
%     % Get fake image
%     fakeName = fakes(i).name;
%     fakePath = strcat('../to_matlab/fakes_R_8/', fakeName);
%     fake = im2double(imread(fakePath));
% %     fake = rgb2gray(fake);
% %     fake(fake<0) = 0;
% 
%     %Get fake ROI
%     [fakeHeight,fakeWidth] = size(fake);
%     fakeC = centerOfMass(fake);
%     fakeCenterX = round(fakeC(2));
%     fakeCenterY = round(fakeC(1));
%     mask = double(zeros(fakeHeight, fakeWidth));
%     maskSizeX = round(fakeWidth/4);
%     maskSizeY = round(fakeHeight/4);
%     mask(fakeCenterY-maskSizeY:fakeCenterY+maskSizeY,fakeCenterX-maskSizeX:fakeCenterX+maskSizeX) = 1;
%     maskedImage = fake .* mask;
%     fakeROI = maskedImage(fakeCenterY-maskSizeY:fakeCenterY+maskSizeY,fakeCenterX-maskSizeX:fakeCenterX+maskSizeX);
%     
%     fakeMeanROI = mean(fakeROI(:));
%     fakeStdROI = std(fakeROI(:));
%     
%     %Get fake background.
%     %Values in image range from 0 to 1, so by assigning the values
%     %of ROI to 2, the background can be found
%     fakeCopy = fake;
%     fakeCopy(fakeCenterY-maskSizeY:fakeCenterY+maskSizeY,fakeCenterX-maskSizeX:fakeCenterX+maskSizeX) = 2;
%     %twos = sum(image(:) == 2)
%     backgroundIndices = fakeCopy < 2;
%     backgroundValues = fakeCopy(backgroundIndices);
%     
%     fakeStdBackground = std(backgroundValues);
%     fakeMeanBackground = mean(backgroundValues);
%     
%     originalSNR = originalMeanROI / originalStdBackground;
%     fakeSNR = fakeMeanROI / fakeStdBackground;
%         
%     originalCNR = originalMeanROI - originalMeanBackground;
%     fakeCNR = fakeMeanROI - fakeMeanBackground;
%     
%     origSNRvector(ind) = originalSNR;
%     fakeSNRvector(ind) = fakeSNR;
%     origCNRvector(ind) = originalCNR;
%     fakeCNRvector(ind) = fakeCNR;
%     
%     ind = ind + 1;
% end

%%%%%%%%%%%%%% PLOT RESULTS WITH TRENDS%%%%%%%%%%%%
%%
close all;
x = ones(length(SNRvector),1);
for i = 1:length(x)
    x(i) = i;
end
SNRtrend = fit(x,SNRvector,'poly2');
CNRtrend = fit(x,CNRvector,'poly2');
roiSNRtrend = fit(x,roiSNRvector,'poly2');
ratioSNRtrend = fit(x,ratioSNRvector,'poly2');
ratioCNRtrend = fit(x,ratioCNRvector,'poly2');
ratioroiSNRtrend = fit(x,ratioroiSNRvector,'poly2');
UIQItrend = fit(x,UIQIvector, 'poly2');
close all

figure(3)
plot(SNRvector);
hold on
plot(SNRtrend, x, SNRvector);
title('SNR Progression')
xlabel('Epochs')
ylabel('SNR difference')

figure(33)
plot(ratioSNRvector);
hold on
plot(ratioSNRtrend, x, ratioSNRvector);
title('SNR ratio Progression')
xlabel('Epochs')
ylabel('SNR difference / original SNR')

figure(4)
plot(CNRvector);
hold on
plot(CNRtrend, x, CNRvector);
title('CNR Progression')
xlabel('Epochs')
ylabel('CNR difference')

figure(44)
plot(ratioCNRvector);
hold on
plot(ratioCNRtrend, x, ratioCNRvector);
title('CNR ratio Progression')
xlabel('Epochs')
ylabel('CNR difference / original CNR')

figure(5)
plot(roiSNRvector);
hold on
plot(roiSNRtrend, x, roiSNRvector);
title('roi SNR Progression')
xlabel('Epochs')
ylabel('SNR difference')

figure(55)
plot(ratioroiSNRvector);
hold on
plot(ratioroiSNRtrend, x, ratioroiSNRvector);
title('roi SNR ratio Progression')
xlabel('Epochs')
ylabel('SNR difference / original SNR')

figure(6)
plot(UIQIvector);
hold on
plot(UIQItrend, x, UIQIvector);
title('UIQI Progression')
xlabel('Epochs')
ylabel('UIQI')


%%%%%%%%%%%%%% BLAND ALTMAN AND CORRELATION %%%%%%%%%%%%
%%
close all;
[rpc, ~, stats] = BlandAltman(origSNRvector, fakeSNRvector, {'Orig SNR','Fake SNR'},...
    'Correlation plot and Bland Altman', 'data', 'baYLimMode', 'Auto', 'data1Mode', 'Truth');
[rpc, ~, stats] = BlandAltman(origCNRvector, fakeCNRvector, {'Orig CNR','Fake CNR'},...
    'Correlation plot and Bland Altman', 'data', 'baYLimMode', 'Auto', 'data1Mode', 'Truth');

%%
%Save workspace
total_epochs = 17;
saved_every = 4;
save('batch8_17epochs', 'SNRvector', 'CNRvector', 'roiSNRvector', 'ratioSNRvector',...
    'ratioCNRvector', 'ratioroiSNRvector', 'total_epochs', 'saved_every',...
    'UIQIvector', 'origSNRvector', 'fakeSNRvector', 'origCNRvector', 'fakeCNRvector')