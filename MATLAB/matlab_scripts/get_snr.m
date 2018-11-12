function [snr,cnr,roisnr] = get_snr_cnr(image)

orig = im2double(imread(originalPath));
% original = imresize(original,[256,256]);
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