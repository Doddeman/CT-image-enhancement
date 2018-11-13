function [mean_ROI,std_ROI, outside, mean_background,std_background] = get_roi_background(image, orig_outside)

[height,width,dim] = size(image);
% image = imresize(image,[256,256]);
% image(image<0) = 0;
if dim ~= 1
    image = rgb2gray(image);
end

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
std_ROI = std(ROI(:));

%%%%%%%%% BACKGROUND %%%%%%%%%%
if nargin == 1 %original image
    image(center_y-mask_size_y:center_y+mask_size_y,center_x-mask_size_x:center_x+mask_size_x) = 2;
    upper_left = grayconnected(image,1,1,0);
    upper_right = grayconnected(image,1,width,0);
    lower_left = grayconnected(image,height,1,0);
    lower_right = grayconnected(image,height,width,0);
    outside = 2*(upper_left + upper_right + lower_left + lower_right);
else %use original outside
    outside = orig_outside;
end

image = image + outside;
%twos = sum(image(:) >= 2) 
background_indices = image < 2;
background_values = image(background_indices);

mean_background = mean(background_values);
std_background = std(background_values);