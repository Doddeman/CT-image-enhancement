%%%%%%%%%%%%%% INITIATE DATA STRUCTURES %%%%%%%%%%%%

%clear all
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


%%%%%%%%%%%%%% GIANT FOR LOOP, FILL VECTORS %%%%%%%%%%%%
SNRvector = zeros(length(originals),1);
CNRvector = zeros(length(originals),1);
for i = 1:length(originals)
    i
    %Get original
    originalName = originals(i).name;
    originalPath = strcat('../to_matlab/originals/', originalName);
    %path = strcat('E:\david\development\MATLAB\to_matlab/', name);
    %path = strcat('C:\Users\davwa\Desktop\Exjobb\Development\MATLAB\to_matlab/', name);
    original = im2double(imread(originalPath));
    original = rgb2gray(original);
    
    %Get original ROI
    [height,width] = size(original);
    originalC = centerOfMass(original);
    originalCenterX = round(originalC(2));
    originalCenterY = round(originalC(1));
   
    mask = double(zeros(height, width));
    maskSizeX = round(width/4);
    maskSizeY = round(height/4);
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
    fakePath = strcat('../to_matlab/', fakeName);
    %path = strcat('E:\david\development\MATLAB\to_matlab/', name);
    %path = strcat('C:\Users\davwa\Desktop\Exjobb\Development\MATLAB\to_matlab/', name);
    fake = im2double(imread(fakePath));
    fake = rgb2gray(fake);
    
    %Get fake ROI
    [height,width] = size(fake);
    fakelC = centerOfMass(fake);
    fakeCenterX = round(fakeC(2));
    fakeCenterY = round(fakeC(1));
  
    mask = double(zeros(height, width));
    maskSizeX = round(width/4);
    maskSizeY = round(height/4);  
    mask(fakeCenterY-maskSizeY:fakeCenterY+maskSizeY,fakeCenterX-maskSizeX:fakeCenterX+maskSizeX) = 1;
    maskedImage = original .* mask;
    fakeROI = maskedImage(fakeCenterY-maskSizeY:fakeCenterY+maskSizeY,fakeCenterX-maskSizeX:fakeCenterX+maskSizeX);
    
    fakeMeanROI = mean(mean(fakeROI));
    
    originalSNR = originalMeanROI / originalStdBackground;
    originalCNR = originalMeanROI - originalMeanBackground;
    fakeSNR = fakeMeanROI / originalStdBackground;
    fakeCNR = fakeMeanROI - originalMeanBackground;
    
    SNRdifference = fakeSNR - originalSNR;
    CNRdifference = fakeCNR - originalCNR;
    
    SNRvector(i) = SNRdifference;
    CNRvector(i) = CNRdifference; 
end

%%%%%%%%%%%%%% PLOT RESULTS %%%%%%%%%%%%

figure(1)
plot(SNRvector);                                      
title('SNR improvement')
xlabel('Samples')
ylabel('SNR difference')

figure(2)
plot(CNRvector);
title('CNR improvement')
xlabel('Samples')
ylabel('CNR difference')

