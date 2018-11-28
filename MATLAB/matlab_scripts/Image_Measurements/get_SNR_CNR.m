function [SNR, CNR] = get_SNR_CNR(image, outside, height, width)

%%%%%% ROI %%%%%%%
C = centerOfMass(image);
center_x = round(C(2));
center_y = round(C(1));

mask = double(zeros(height, width));
mask_size_x = round(width/4);
mask_size_y = round(height/4);
mask(center_y-mask_size_y:center_y+mask_size_y,center_x-mask_size_x:center_x+mask_size_x) = 1;
masked_image = image .* mask;
ROI = masked_image(center_y-mask_size_y:center_y+mask_size_y,center_x-mask_size_x:center_x+mask_size_x);

mean_ROI = mean(ROI(:));
% std_ROI = std(ROI(:));

%%%%%%%%% BACKGROUND %%%%%%%%%%
image(center_y-mask_size_y:center_y+mask_size_y,center_x-mask_size_x:center_x+mask_size_x) = 2;
image = image + outside;
%twos = sum(image(:) >= 2) 
background_indices = image < 2;
background_values = image(background_indices);

std_background = std(background_values);
mean_background = mean(background_values);

signal = mean_ROI;
noise = std_background; 

SNR = signal / noise;
contrast = signal - mean_background;
CNR = contrast / noise;


