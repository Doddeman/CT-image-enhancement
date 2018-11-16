%Get results and measurements from last
%epoch for bland altman, correlation and
%Vikas bland altman variation. 
%Can be changed to any epoch
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

orig_SNR_vector = zeros(images_per_epoch,1);
fake_SNR_vector = zeros(images_per_epoch,1);
orig_CNR_vector = zeros(images_per_epoch,1);
fake_CNR_vector = zeros(images_per_epoch,1);
ratio_SNR_vector = zeros(images_per_epoch,1);
ratio_CNR_vector = zeros(images_per_epoch,1);
index = 1;
last_epoch = L-images_per_epoch
for i = last_epoch+1:L
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
    
    %SNR
    orig_SNR = orig_mean_ROI / orig_std_background;
    fake_SNR = fake_mean_ROI / fake_std_background;
    diff_SNR = fake_SNR - orig_SNR;
    ratio_SNR = diff_SNR / orig_SNR;
    if sign(diff_SNR) ~= sign(ratio_SNR)
        ratio_SNR = ratio_SNR * -1
    end
        
    %CNR
    orig_CNR = orig_mean_ROI - orig_mean_background;
    fake_CNR = fake_mean_ROI - fake_mean_background;
    diff_CNR = fake_CNR - orig_CNR;
    ratio_CNR = diff_CNR / orig_CNR;
    if sign(diff_CNR) ~= sign(ratio_CNR)
        ratio_CNR = ratio_CNR * -1
    end
    
    orig_SNR_vector(index) = orig_SNR;
    fake_SNR_vector(index) = fake_SNR;
    orig_CNR_vector(index) = orig_CNR;
    fake_CNR_vector(index) = fake_CNR;
    ratio_SNR_vector(index) = ratio_SNR;
    ratio_CNR_vector(index) = ratio_CNR;
    
    index = index + 1;
end

%%%%%%%%%%%%%% BLAND ALTMAN AND CORRELATION %%%%%%%%%%%%
%%
close all;
[rpc, ~, stats] = BlandAltman(orig_SNR_vector, fake_SNR_vector, {'Orig SNR','Fake SNR'},...
    'Correlation plot and Bland Altman', 'data', 'baYLimMode', 'Auto', 'data1Mode', 'Truth');
[rpc, ~, stats] = BlandAltman(orig_CNR_vector, fake_CNR_vector, {'Orig CNR','Fake CNR'},...
    'Correlation plot and Bland Altman', 'data', 'baYLimMode', 'Auto', 'data1Mode', 'Truth');

%%%%%%%%%%%% VIKAS BLAND ALTMAN VARIATION %%%%%%%%%%%%%
%%
figure(10)
plot(orig_SNR_vector, ratio_SNR_vector,'*')
title('SNR ratio vs original values')

figure(11)
plot(orig_CNR_vector, ratio_CNR_vector,'*')
title('CNR ratio vs original values')