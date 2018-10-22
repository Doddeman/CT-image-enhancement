%%%%%%%%%%%%%% INITIATE DATA STRUCTURES %%%%%%%%%%%%

%clear all
%close all

%Get images and sort after date modified
originals = dir('../to_matlab/origs_batch4/*.png');
fields = fieldnames(originals);
cells = struct2cell(originals);
sz = size(cells);
cells = reshape(cells, sz(1), []);
cells = cells';
% Sort by field "date"
cells = sortrows(cells, 3);
cells = reshape(cells', sz);
originals = cell2struct(cells, fields, 1);

fakes = dir('../to_matlab/fakes_batch4/*.png');
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
L2 = length(originals);

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
n = 200000;
figure(80)
original = originals(n).name
originalPath = strcat('../to_matlab/origs_batch4/', original);
imshow(originalPath)

figure(81)
fake = fakes(n).name
fakepath = strcat('../to_matlab/fakes_batch4/', fake);
imshow(fakepath)

%%%%%%%%%%%%%% GIANT FOR LOOP, FILL VECTORS %%%%%%%%%%%%
%%
%images_per_epoch = 1478;
images_per_epoch = 12628;
%images_per_epoch = 12624;
% number of epochs that produced images
n_of_epochs = floor(L1/images_per_epoch);

SNRvector = zeros(n_of_epochs,1);
CNRvector = zeros(n_of_epochs,1);
epochSNR = 0;
epochCNR = 0;

epoch = 1;
for i = 1:L1
    i
    %Get original
    originalName = originals(i).name;
    originalPath = strcat('../to_matlab/origs_batch4/', originalName);
    original = im2double(imread(originalPath));
    original = imresize(original,[256,256]);
    original(original<0) = 0;
    %nes1 = sum(original(:) < 0)

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
    fakePath = strcat('../to_matlab/fakes_batch4/', fakeName);
    fake = im2double(imread(fakePath));
    %fake = rgb2gray(fake);
    %fake(fake<0) = 0;
    %nes2 = sum(fake(:) < 0)

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
%     n_of_pixels = origHeight*origWidth;
%     nominator = 0;
%     denominator = 0;
%     for j = 1:n_of_pixels 
%         curr = original(j)^2;
%         curr2 = (original(j)-fake(j))^2;
%         nominator = nominator + curr;
%         denominator = denominator + curr2;
%     end
%     snr = nominator/denominator; 
    

    epochSNR = epochSNR + SNRdifference;
    epochCNR = epochCNR + CNRdifference;

    % End of epoch?
    if mod(i,images_per_epoch) == 0
        %i
        meanSNR = epochSNR / images_per_epoch;
        meanCNR = epochCNR / images_per_epoch;
        SNRvector(epoch) = meanSNR;
        CNRvector(epoch) = meanCNR;
        epochSNR = 0;
        epochCNR = 0;
        epoch = epoch + 1;
    end
end

%%%%%%%%%%%%%% PLOT RESULTS %%%%%%%%%%%%
%%
figure(3)
plot(SNRvector);
title('SNR improvement')
xlabel('Epoch')
ylabel('SNR difference')

figure(4)
plot(CNRvector);
title('CNR improvement')
xlabel('Epoch')
ylabel('CNR difference')

%%
%Save workspace
total_epochs = 61;
saved_every = 4;
save('batch4_61epochs', 'SNRvector', 'CNRvector', 'total_epochs', 'saved_every')
