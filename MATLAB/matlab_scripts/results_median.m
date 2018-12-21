%%%%%%%%%%%%%% GET DATA %%%%%%%%%%%%

% clear all
%close all

%Get images and sort after date modified
% originals = dir('../to_matlab/origs_terrible/*.png');
% fakes = dir('../to_matlab/fakes_terrible/*.png');
originals = dir('C:\Users\davwa\Desktop\CT-image-enhancement\CycleGAN\datasets\snrcnr\testA/*.png');
fakes = dir('C:\Users\davwa\Desktop\CT-image-enhancement\CycleGAN\test_snrcnr/*.png');
test = true; 
[originals, fakes, L] = get_data(originals, fakes, test);

%%%%% Testing
%% 
n = 1812;
figure
orig = originals(n).name
orig_path = strcat('C:\Users\davwa\Desktop\CT-image-enhancement\CycleGAN\datasets\Sample_Quality\testA/', orig);
imshow(orig_path)

figure
fake = fakes(n).name
fakepath = strcat('C:\Users\davwa\Desktop\CT-image-enhancement\CycleGAN\test_Sample_Quality/', fake);
imshow(fakepath)

% size =256;
% orig = get_image(fakepath);
% hej = isnan(orig);
% orig_outside = get_outside(orig, size, size);
% [orig_SNR,orig_CNR] = get_SNR_CNR(orig,orig_outside,size,size);

%%%%%%%%%%%%%% INITIATE DATA STRUCTURES %%%%%%%%%%%%
%%
images_per_epoch = 1817;
% images_per_epoch = 1478;
% images_per_epoch = 12628;
% images_per_epoch = 12624;
% images_per_epoch = 4096;
n_of_epochs = floor(L/images_per_epoch); %data sampled from X epochs 

%For BA, takes all values from one (last) epoch
% orig_SNR_vector = zeros(images_per_epoch,1);
% fake_SNR_vector = zeros(images_per_epoch,1);
% orig_CNR_vector = zeros(images_per_epoch,1);
% fake_CNR_vector = zeros(images_per_epoch,1);

%all right now just only gather all the data. no calculations
SNR_diff_vector = zeros(n_of_epochs*images_per_epoch,1);
SNR_ratio_vector = zeros(n_of_epochs*images_per_epoch,1);
CNR_diff_vector = zeros(n_of_epochs*images_per_epoch,1);
CNR_ratio_vector = zeros(n_of_epochs*images_per_epoch,1);
UIQI_vector = zeros(n_of_epochs*images_per_epoch,1);

% SNR_epoch = 0;
% ratio_SNR_epoch = 0;
% CNR_epoch = 0;
% ratio_CNR_epoch = 0;
% UIQI_epoch = 0;

% nan1index_vector = [];
% nan1ame_vector = [];
% nan2index_vector = [];
% nan2ame_vector = [];

%%%%%%%%%%%%%% FOR LOOP FOR GETTING THE VECTOR VALUES %%%%%%%%%%%%
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
    orig_path = strcat('C:\Users\davwa\Desktop\CT-image-enhancement\CycleGAN\datasets\snrcnr\testA/', orig_name); 
    orig = get_image(orig_path);
    orig_outside = get_outside(orig, size, size);
    [orig_SNR,orig_CNR] = get_SNR_CNR(orig,orig_outside,size,size);
    %orig_SNR
    % Get fake
    fake_name = fakes(i).name;
    fake_path = strcat('C:\Users\davwa\Desktop\CT-image-enhancement\CycleGAN\test_snrcnr/', fake_name);
    fake = get_image(fake_path);
    [fake_SNR,fake_CNR] = get_SNR_CNR(fake,orig_outside,size,size);
%     fake_SNR
    % CALCULATIONS
    % SNR
%     if ~isnan(fake_SNR) && ~isnan(orig_SNR)
    SNR_diff = fake_SNR - orig_SNR;
    SNR_ratio = SNR_diff / orig_SNR;
    if sign(SNR_diff) ~= sign(SNR_ratio)
        SNR_ratio = SNR_ratio * -1;
    end
%     SNR_epoch = SNR_epoch + SNR_diff;
%     ratio_SNR_epoch = ratio_SNR_epoch + SNR_ratio;
    SNR_diff_vector(i) = SNR_diff;
    SNR_ratio_vector(i) = SNR_ratio;
%     else
%         nan1index_vector = [nan1index_vector, i];
%         nan1ame_vector= [nan1ame_vector, orig_name];
%         disp('Nan1');
%     end
    % CNR
%     if ~isnan(fake_SNR) && ~isnan(orig_SNR)
    CNR_diff = fake_CNR - orig_CNR;
    CNR_ratio = CNR_diff / orig_CNR;
    if sign(CNR_diff) ~= sign(CNR_ratio)
        CNR_ratio = CNR_ratio * -1;
    end
%     CNR_epoch = CNR_epoch + CNR_diff;
%     ratio_CNR_epoch = ratio_CNR_epoch + CNR_ratio;
    CNR_diff_vector(i) = CNR_diff;
    CNR_ratio_vector(i) = CNR_ratio;
%     else
%         nan2index_vector = [nan2index_vector, i];
%         nan2ame_vector= [nan2ame_vector, orig_name];
%         disp('NaN2');
%     end
    % UIQI
    [UIQI, ~] = get_uiqi(orig, fake);
%     UIQI_epoch = UIQI_epoch + UIQI;
    UIQI_vector(i) = UIQI;

end
    
%%%%% FOR LOOP FOR CALCULATING MEANS/MEDIANS FOR EACH EPOCH %%%%%
%%
SNR_diff_avg_vector = zeros(n_of_epochs,1);
SNR_ratio_avg_vector = zeros(n_of_epochs,1);
CNR_diff_avg_vector = zeros(n_of_epochs,1);
CNR_ratio_avg_vector = zeros(n_of_epochs,1);
UIQI_avg_vector = zeros(n_of_epochs,1);

SNR_diff_med_vector=zeros(images_per_epoch,1);
SNR_ratio_med_vector=zeros(images_per_epoch,1);
CNR_diff_med_vector=zeros(images_per_epoch,1);
CNR_ratio_med_vector=zeros(images_per_epoch,1);
UIQI_med_vector = zeros(n_of_epochs,1);

for i=1:n_of_epochs
% for i = 1:2
    i
    l = length(SNR_diff_vector(i:i+images_per_epoch-1));
    SNR_diff_epoch = SNR_diff_vector(i:i+images_per_epoch-1);
    SNR_diff_avg_vector(i) = mean(SNR_diff_epoch);
    SNR_diff_med_vector(i) = median(SNR_diff_epoch);
        
    SNR_ratio_epoch = SNR_ratio_vector(i:i+images_per_epoch-1);
    SNR_ratio_avg_vector(i) = mean(SNR_ratio_epoch);
    SNR_ratio_med_vector(i) = median(SNR_ratio_epoch);
    
    CNR_diff_epoch = CNR_diff_vector(i:i+images_per_epoch-1);
    CNR_diff_avg_vector(i) = mean(CNR_diff_epoch);
    CNR_diff_med_vector(i) = median(CNR_diff_epoch);
    
    CNR_ratio_epoch = CNR_ratio_vector(i:i+images_per_epoch-1);
    CNR_ratio_avg_vector(i) = mean(CNR_ratio_epoch);
    CNR_ratio_med_vector(i) = median(CNR_ratio_epoch);
        
    UIQI_epoch = UIQI_vector(i:i+images_per_epoch-1);
    UIQI_avg_vector(i) = mean(UIQI_epoch);
    UIQI_med_vector(i) = median(UIQI_epoch);
    
%     if mod(i,images_per_epoch) == 0 % End of epoch?
%         %CALCULATE MEAN
% %         mean_SNR = SNR_epoch / images_per_epoch;
% %         mean_SNR_ratio = ratio_SNR_epoch / images_per_epoch;
% %         mean_CNR = CNR_epoch / images_per_epoch;
% %         mean_CNR_ratio = ratio_CNR_epoch / images_per_epoch;
%         median_SNR = median(SNR_diff_med_vector);
%         median_SNR_ratio = median(SNR_ratio_med_vector);
%         median_CNR = median(CNR_diff_med_vector);
%         median_CNR_ratio = median(CNR_ratio_med_vector);
%         
%         mean_UIQI = UIQI_epoch / images_per_epoch;
%         %ADD TO VECTOR
% %         SNR_vector(epoch) = mean_SNR;
% %         ratio_SNR_vector(epoch) = mean_SNR_ratio;
% %         CNR_vector(epoch) = mean_CNR;
% %         ratio_CNR_vector(epoch) = mean_CNR_ratio;
%         SNR_diff_vector(epoch) = median_SNR;
%         SNR_ratio_vector(epoch) = median_SNR_ratio;
%         CNR_diff_vector(epoch) = median_CNR;
%         CNR_ratio_vector(epoch) = median_CNR_ratio;
%         UIQI_vector(epoch) = mean_UIQI;
%         %RESET EPOCH VALUE
% %         SNR_epoch = 0;
% %         ratio_SNR_epoch = 0;
% %         CNR_epoch = 0;
% %         ratio_CNR_epoch = 0;
%         SNR_diff_med_vector=zeros(images_per_epoch,1);
%         SNR_ratio_med_vector=zeros(images_per_epoch,1);
%         CNR_diff_med_vector=zeros(images_per_epoch,1);
%         CNR_ratio_med_vector=zeros(images_per_epoch,1);
%         UIQI_epoch = 0;
%         %STEP EPOCH
%         epoch = epoch + 1;
%     end
%     
%     %If it is the last epoch, start saving for BA
%     if i > (L-images_per_epoch+1)
%         orig_SNR_vector(j) = orig_SNR;
%         fake_SNR_vector(j) = fake_SNR;
%         orig_CNR_vector(j) = orig_CNR;
%         fake_CNR_vector(j) = fake_CNR;
%         j = j + 1;
%     end
end

%%%%%%%%%%%%%% PLOT RESULTS WITH TRENDS%%%%%%%%%%%%
%%
% close all;
%mean
do_plot('Average values',SNR_diff_avg_vector,SNR_ratio_avg_vector,CNR_diff_avg_vector,CNR_ratio_avg_vector);
%median
do_plot('Median values', SNR_diff_med_vector,SNR_ratio_med_vector,CNR_diff_med_vector,CNR_ratio_med_vector);


% do_plot(SNR_vector , 11, 'SNR', 'SNR difference');
% do_plot(ratio_SNR_vector, 22, 'SNR ratio', 'Percentage development');
% do_plot(CNR_vector, 33, 'CNR', 'CNR difference');
% do_plot(ratio_CNR_vector, 44, 'CNR ratio', 'Percentage development');
% do_plot(UIQI_vector, 77, 'UIQI', 'UIQI');

%%%%%%%%%%%%%% BLAND ALTMAN AND CORRELATION %%%%%%%%%%%%
%%
close all;
[rpc, ~, stats] = BlandAltman(orig_SNR_vector, fake_SNR_vector, {'Orig SNR','Fake SNR'},...
    'Correlation plot and Bland Altman', 'data', 'baYLimMode', 'Auto', 'data1Mode', 'Truth');
[rpc, ~, stats] = BlandAltman(orig_CNR_vector, fake_CNR_vector, {'Orig CNR','Fake CNR'},...
    'Correlation plot and Bland Altman', 'data', 'baYLimMode', 'Auto', 'data1Mode', 'Truth');

diff_SNR_last_vector = fake_SNR_vector - orig_SNR_vector;
diff_CNR_last_vector = fake_CNR_vector - orig_CNR_vector;
ratio_SNR_last_vector = diff_SNR_last_vector ./ orig_SNR_vector;
ratio_CNR_last_vector = diff_CNR_last_vector ./ orig_CNR_vector;

figure(10)
plot(orig_SNR_vector, diff_SNR_last_vector,'*')
title('SNR diff vs original values')
xlabel('Originals SNR')
ylabel('SNR diff')

figure(11)
plot(orig_CNR_vector, diff_CNR_last_vector,'*')
title('CNR diff vs original values')
xlabel('Originals CNR')
ylabel('CNR diff')

figure(12)
plot(orig_SNR_vector, ratio_SNR_last_vector,'*')
title('SNR ratio vs original values')
xlabel('Originals SNR')
ylabel('SNR ratio')

figure(13)
plot(orig_CNR_vector, ratio_CNR_last_vector,'*')
title('CNR ratio vs original values')
xlabel('Originals CNR')
ylabel('CNR ratio')
%%
%Save workspace
total_epochs = 80;
saved_every = 1;
save('full_R_test_median', 'total_epochs', 'saved_every', 'images_per_epoch', ...
    'SNR_vector', 'CNR_vector', 'ratio_SNR_vector', 'ratio_CNR_vector',... 
    'UIQI_vector', 'orig_SNR_vector', 'fake_SNR_vector', 'orig_CNR_vector', 'fake_CNR_vector')