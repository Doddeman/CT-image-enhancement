%%%%%%%%%%%%%% GET DATA %%%%%%%%%%%%

%clear all
%close all

%Get images and sort after date modified
originals = dir('..\..\CycleGAN\datasets\artifacts\testA/*.png');
fakes = dir('..\..\CycleGAN\test_artifacts/*.png');
test = true;
[originals, fakes, L] = get_data(originals, fakes, test);

%%%%% Testing
%%
%n = 1812;
%figure
%orig = originals(n).name
%orig_path = strcat('..\..\CycleGAN\datasets\Full_Quality\testA/', orig);
%imshow(orig_path)

%figure
%fake = fakes(n).name
%fakepath = strcat('..\..\CycleGAN\test_final_snrcnr/', fake);
%imshow(fakepath)

%%%%%%%%%%%%%% INITIATE DATA STRUCTURES %%%%%%%%%%%%
%%
images_per_epoch = 3000;
n_of_epochs = floor(L/images_per_epoch); %data sampled from X epochs

SNR_vector = zeros(n_of_epochs,1);
ratio_SNR_vector = zeros(n_of_epochs,1);
CNR_vector = zeros(n_of_epochs,1);
ratio_CNR_vector = zeros(n_of_epochs,1);
UIQI_vector = zeros(n_of_epochs,1);

SNR_epoch = 0;
ratio_SNR_epoch = 0;
CNR_epoch = 0;
ratio_CNR_epoch = 0;
UIQI_epoch = 0;

%%%%%%%%%%%%%% GIANT FOR LOOP, FILL VECTORS %%%%%%%%%%%%
%%
size = 256;
epoch = 1;
j=1;
for i = 1:L
    i
    % GET IMAGES ROIS AND BACKGROUNDS
    %Get original
    if test
        orig_index = mod(i-1,images_per_epoch)+1;
        orig_name = originals(orig_index).name;
    else
        orig_name = originals(i).name;
    end
    orig_path = strcat('C:\Users\davwa\Desktop\CT-image-enhancement\CycleGAN\datasets\artifacts\testA\', orig_name);
    orig = get_image(orig_path);
    orig_outside = get_outside(orig, size, size);
    [orig_SNR,orig_CNR] = get_SNR_CNR(orig,orig_outside,size,size);
    % Get fake
    fake_name = fakes(i).name;
    fake_path = strcat('..\..\CycleGAN\test_artifacts/', fake_name);
    fake = get_image(fake_path);
    [fake_SNR,fake_CNR] = get_SNR_CNR(fake,orig_outside,size,size);
    %%% CALCULATIONS %%%
    %%% SNR
    SNR_diff = fake_SNR - orig_SNR;
    SNR_ratio = SNR_diff / orig_SNR;
    if sign(SNR_diff) ~= sign(SNR_ratio)
        SNR_ratio = SNR_ratio * -1;
    end
    SNR_epoch = SNR_epoch + SNR_diff;
    ratio_SNR_epoch = ratio_SNR_epoch + SNR_ratio;
    %%% CNR
    CNR_diff = fake_CNR - orig_CNR;
    CNR_ratio = CNR_diff / orig_CNR;
    if sign(CNR_diff) ~= sign(CNR_ratio)
        CNR_ratio = CNR_ratio * -1;
    end
    CNR_epoch = CNR_epoch + CNR_diff;
    ratio_CNR_epoch = ratio_CNR_epoch + CNR_ratio;
    %%% UIQI
    [UIQI, ~] = get_uiqi(orig, fake);
    UIQI_epoch = UIQI_epoch + UIQI;

    if mod(i,images_per_epoch) == 0 % End of epoch?
        %CALCULATE MEAN
        mean_SNR = SNR_epoch / images_per_epoch;
        mean_SNR_ratio = ratio_SNR_epoch / images_per_epoch;
        mean_CNR = CNR_epoch / images_per_epoch;
        mean_CNR_ratio = ratio_CNR_epoch / images_per_epoch;
        mean_UIQI = UIQI_epoch / images_per_epoch;
        %ADD TO VECTOR
        SNR_vector(epoch) = mean_SNR;
        ratio_SNR_vector(epoch) = mean_SNR_ratio;
        CNR_vector(epoch) = mean_CNR;
        ratio_CNR_vector(epoch) = mean_CNR_ratio;
        UIQI_vector(epoch) = mean_UIQI;
        %RESET EPOCH VALUE
        SNR_epoch = 0;
        ratio_SNR_epoch = 0;
        CNR_epoch = 0;
        ratio_CNR_epoch = 0;
        UIQI_epoch = 0;
        %STEP EPOCH
        epoch = epoch + 1;
    end
    end

%%%%%%%%%%%%%% PLOT RESULTS WITH TRENDS%%%%%%%%%%%%
%%
do_plot('Average values',SNR_vector,ratio_SNR_vector,CNR_vector,ratio_CNR_vector);

%%%%%%% Save workspace %%%%%%
%%

total_epochs = 80;
saved_every = 5;
save('artifacts', 'total_epochs', 'saved_every', 'images_per_epoch', ...
    'SNR_vector', 'CNR_vector', 'ratio_SNR_vector', 'ratio_CNR_vector',...
    'UIQI_vector')
