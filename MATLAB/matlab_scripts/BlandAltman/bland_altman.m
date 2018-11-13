%%%%%%%%%%%ONLY GET BLAND ALTMAN %%%%%%%%%%%%%%%%%%%%%


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

%%
origSNRvector = zeros(images_per_epoch,1);
fakeSNRvector = zeros(images_per_epoch,1);
origCNRvector = zeros(images_per_epoch,1);
fakeCNRvector = zeros(images_per_epoch,1);
ind = 1;
one_epoch = L1-images_per_epoch
for i = one_epoch+1:L1
    i
    %Get original
    originalName = originals(i).name;
    originalPath = strcat('../to_matlab/origs_R_8/', originalName);
    original = im2double(imread(originalPath));
%     original = imresize(original,[256,256]);
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
    origCopy = original;
    origCopy(originalCenterY-maskSizeY:originalCenterY+maskSizeY,originalCenterX-maskSizeX:originalCenterX+maskSizeX) = 2;
    %twos = sum(image(:) == 2)
    backgroundIndices = origCopy < 2;
    backgroundValues = origCopy(backgroundIndices);
   
    originalStdBackground = std(backgroundValues);
    originalMeanBackground = mean(backgroundValues);

    % Get fake image
    fakeName = fakes(i).name;
    fakePath = strcat('../to_matlab/fakes_R_8/', fakeName);
    fake = im2double(imread(fakePath));
%     fake = rgb2gray(fake);
%     fake(fake<0) = 0;

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
    %twos = sum(image(:) == 2)
    backgroundIndices = fakeCopy < 2;
    backgroundValues = fakeCopy(backgroundIndices);
    
    fakeStdBackground = std(backgroundValues);
    fakeMeanBackground = mean(backgroundValues);
    
    originalSNR = originalMeanROI / originalStdBackground;
    fakeSNR = fakeMeanROI / fakeStdBackground;
        
    originalCNR = originalMeanROI - originalMeanBackground;
    fakeCNR = fakeMeanROI - fakeMeanBackground;
    
    origSNRvector(ind) = originalSNR;
    fakeSNRvector(ind) = fakeSNR;
    origCNRvector(ind) = originalCNR;
    fakeCNRvector(ind) = fakeCNR;
    
    ind = ind + 1;
end

%%
close all;
[rpc, ~, stats] = BlandAltman(orig_SNRvector, fake_SNRvector, {'Orig SNR','Fake SNR'},...
    'Correlation plot and Bland Altman', 'data', 'baYLimMode', 'Auto', 'data1Mode', 'Truth');
[rpc, ~, stats] = BlandAltman(orig_CNRvector, fake_CNRvector, {'Orig CNR','Fake CNR'},...
    'Correlation plot and Bland Altman', 'data', 'baYLimMode', 'Auto', 'data1Mode', 'Truth');