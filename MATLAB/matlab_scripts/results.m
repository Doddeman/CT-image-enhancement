%%%%%%%%%%%%%% INITIATE DATA STRUCTURES %%%%%%%%%%%%

clear all
%close all

%Get images and sort after date modified
originals = dir('../to_matlab/origs_8_50/*.png');
fakes = dir('../to_matlab/fakes_8_50/*.png');
[originals, fakes] = get_data(originals, fakes);

%%%%% Testing
%% 
n = 100000;
figure(80)
orig = originals(n).name
orig_path = strcat('../to_matlab/origs_8_50/', orig);
imshow(orig_path)

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

% orig_SNRvector = zeros(images_per_epoch,1);
% fake_SNRvector = zeros(images_per_epoch,1);
% orig_CNRvector = zeros(images_per_epoch,1);
% fake_CNRvector = zeros(images_per_epoch,1);

orig_SNR_vector = zeros(n_of_epochs,1);
orig_CNR_vector = zeros(n_of_epochs,1);
SNR_vector = zeros(n_of_epochs,1);
CNR_vector = zeros(n_of_epochs,1);
roi_SNR_vector = zeros(n_of_epochs,1);
ratio_SNR_vector = zeros(n_of_epochs,1);
ratio_CNR_vector = zeros(n_of_epochs,1);
ratio_roi_SNR_vector = zeros(n_of_epochs,1);
UIQI_vector = zeros(n_of_epochs,1);

orig_SNR_epoch = 0;
orig_CNR_epoch = 0;
SNR_epoch = 0;
CNR_epoch = 0;
roi_SNR_epoch = 0;
ratio_SNR_epoch = 0;
ratio_CNR_epoch = 0;
ratio_roi_SNR_epoch = 0;
UIQI_epoch = 0;

epoch = 1;
j=1;
for i = 1:L1
    i
    % GET IMAGES ROIS AND BACKGROUNDS
    %Get original
    orig_name = originals(i).name;
    orig_path = strcat('../to_matlab/origs_8_50/', orig_name); 
    orig = im2double(imread(orig_path));
    [orig_mean_ROI, orig_std_ROI, orig_outside, orig_mean_background, ...
        orig_std_background] = get_roi_background(orig);

    % Get fake
    fake_name = fakes(i).name;
    fake_path = strcat('../to_matlab/fakes_8_50/', fake_name);
    fake = im2double(imread(fake_path));
    [fake_mean_ROI, fake_std_ROI, ~, fake_mean_background, ...
        fake_std_background] = get_roi_background(fake, orig_outside); 
       
    % CALCULATIONS
    % SNR
    orig_SNR = orig_mean_ROI / orig_std_background;
    fake_SNR = fake_mean_ROI / fake_std_background;
    SNR_diff = fake_SNR - orig_SNR;
    SNR_ratio = SNR_diff / orig_SNR;
    if sign(SNR_diff) ~= sign(SNR_ratio)
        SNR_ratio = SNR_ratio * -1;
    end
    orig_SNR_epoch = orig_SNR_epoch + orig_SNR;
    SNR_epoch = SNR_epoch + SNR_diff;
    ratio_SNR_epoch = ratio_SNR_epoch + SNR_ratio;
    % CNR
    orig_CNR = orig_mean_ROI - orig_mean_background;
    fake_CNR = fake_mean_ROI - fake_mean_background;
    CNR_diff = fake_CNR - orig_CNR;
    CNR_ratio = CNR_diff / orig_CNR;
    if sign(CNR_diff) ~= sign(CNR_ratio)
        CNR_ratio = CNR_ratio * -1;
    end
    orig_CNR_epoch = orig_CNR_epoch + orig_CNR;
    CNR_epoch = CNR_epoch + CNR_diff;
    ratio_CNR_epoch = ratio_CNR_epoch + CNR_ratio;
    % roi SNR
    orig_SNR_roi = orig_mean_ROI / orig_std_ROI;
    fake_SNR_roi = fake_mean_ROI / fakeStdROI;
    roi_SNR_diff = fake_SNR_roi - orig_SNR_roi;
    roi_SNR_ratio = roi_SNR_diff / orig_SNR_roi;
    if sign(roi_SNR_diff) ~= sign(roi_SNR_ratio)
        roi_SNR_ratio = roi_SNR_ratio * -1;
    end 
    roi_SNR_epoch = roi_SNR_epoch + roi_SNR_diff;
    ratio_roi_SNR_epoch = ratio_roi_SNR_epoch + roi_SNR_ratio;
    % UIQI
    [UIQI, ~] = get_uiqi(orig, fake);
    UIQI_epoch = UIQI_epoch + UIQI;

    if mod(i,images_per_epoch) == 0 % End of epoch?
        %CALCULATE MEAN
        mean_orig_SNR = orig_SNR_epoch / images_per_epoch;
        mean_orig_CNR = orig_CNR_epoch / images_per_epoch;
        mean_SNR = SNR_epoch / images_per_epoch;
        mean_CNR = CNR_epoch / images_per_epoch;
        mean_SNR_roi = roi_SNR_epoch / images_per_epoch;
        mean_SNR_ratio = ratio_SNR_epoch / images_per_epoch;
        mean_CNR_ratio = ratio_CNR_epoch / images_per_epoch;
        mean_SNR_ratio_roi = ratio_roi_SNR_epoch / images_per_epoch;
        mean_UIQI = UIQI_epoch / images_per_epoch;
        %ADD TO VECTOR
        orig_SNR_vector(epoch) = mean_orig_SNR;
        orig_CNR_vector(epoch) = mean_orig_CNR;
        SNR_vector(epoch) = mean_SNR;
        CNR_vector(epoch) = mean_CNR;
        roi_SNR_vector(epoch) = mean_SNR_roi;
        ratio_SNR_vector(epoch) = mean_SNR_ratio;
        ratio_CNR_vector(epoch) = mean_CNR_ratio;
        ratio_roi_SNR_vector(epoch) = mean_SNR_ratio_roi;
        UIQI_vector(epoch) = mean_UIQI;
        %RESET EPOCH VALUE
        orig_SNR_epoch = 0;
        orig_CNR_epoch = 0;
        SNR_epoch = 0;
        CNR_epoch = 0;
        roi_SNR_epoch = 0;
        ratio_SNR_epoch = 0;
        ratio_CNR_epoch = 0;
        ratio_roi_SNR_epoch = 0;
        UIQI_epoch = 0;
        %STEP EPOCH
        epoch = epoch + 1;
    end
    
    %If it is the last epoch, start saving for BA
%     if i > (L1-images_per_epoch+1)
%         orig_SNRvector(j) = orig_SNR;
%         fake_SNRvector(j) = fake_SNR;
%         orig_CNRvector(j) = orig_CNR;
%         fake_CNRvector(j) = fake_CNR;
%         j = j + 1;
%     end
    
end

%%%%%%%%%%%%%% PLOT RESULTS WITH TRENDS%%%%%%%%%%%%
%%
close all;

do_plot(SNR_vector,'' , 1, 'SNR', 'SNR difference');
do_plot(ratio_SNR_vector,'', 2, 'SNR ratio', 'SNR difference / original SNR');
do_plot(CNR_vector,'', 3, 'CNR', 'CNR difference');
do_plot(ratio_CNR_vector,'', 4, 'CNR', 'CNR difference / original CNR');
% do_plot(roi_SNR_vector,'', 5, 'ROI-based SNR', 'SNR difference');
% do_plot(ratio_roi_SNR_vector,'', 6, 'ROI-based SNR ratio', 'SNR difference / original SNR');
% do_plot(UIQI_vector,'', 7, 'UIQI', 'UIQI');
do_plot(orig_SNR_vector,ratio_SNR_vector,8,'SNR ratio vs orig','SNR difference / original SNR','orig');
do_plot(orig_CNR_vector,ratio_CNR_vector,9,'CNR ratio vs orig','CNR difference / original CNR','orig');

%%%%%%%%%%%%%% BLAND ALTMAN AND CORRELATION %%%%%%%%%%%%
%%
close all;
[rpc, ~, stats] = BlandAltman(orig_SNRvector, fake_SNRvector, {'Orig SNR','Fake SNR'},...
    'Correlation plot and Bland Altman', 'data', 'baYLimMode', 'Auto', 'data1Mode', 'Truth');
[rpc, ~, stats] = BlandAltman(orig_CNR_vector, fake_CNRvector, {'Orig CNR','Fake CNR'},...
    'Correlation plot and Bland Altman', 'data', 'baYLimMode', 'Auto', 'data1Mode', 'Truth');

%%
%Save workspace
total_epochs = 17;
saved_every = 4;
save('batch8_17epochs', 'SNRvector', 'CNRvector', 'roiSNRvector', 'ratioSNRvector',...
    'ratioCNRvector', 'ratioroiSNRvector', 'total_epochs', 'saved_every',...
    'UIQIvector', 'origSNRvector', 'fakeSNRvector', 'origCNRvector', 'fakeCNRvector')