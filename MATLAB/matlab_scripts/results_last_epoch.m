%Get results and measurements from last
%epoch for bland altman, correlation and
%Vikas bland altman variation
%%
%%%%%%%%%%%%%% INITIATE DATA STRUCTURES %%%%%%%%%%%%
clear all
%close all

%Get images and sort after date modified
originals = dir('../to_matlab/origs_terrible/*.png');
fakes = dir('../to_matlab/fakes_terrible/*.png');
[originals, fakes, L] = get_data(originals, fakes);
%%
images_per_epoch = 1478;
% images_per_epoch = 12628;
% images_per_epoch = 12624;
% images_per_epoch = 4096;

origSNRvector = zeros(images_per_epoch,1);
fakeSNRvector = zeros(images_per_epoch,1);
origCNRvector = zeros(images_per_epoch,1);
fakeCNRvector = zeros(images_per_epoch,1);
ind = 1;
one_epoch = L-images_per_epoch
for i = one_epoch+1:L
    i
    % GET IMAGES ROIS AND BACKGROUNDS
    %Get original
    orig_name = originals(i).name;
    orig_path = strcat('../to_matlab/origs_terrible/', orig_name); 
    orig = im2double(imread(orig_path));
    [orig_mean_ROI, orig_std_ROI, orig_outside, orig_mean_background, ...
        orig_std_background] = get_roi_background(orig);

    % Get fake
    fake_name = fakes(i).name;
    fake_path = strcat('../to_matlab/fakes_terrible/', fake_name);
    fake = im2double(imread(fake_path));
    [fake_mean_ROI, fake_std_ROI, ~, fake_mean_background, ...
        fake_std_background] = get_roi_background(fake, orig_outside); 
    
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