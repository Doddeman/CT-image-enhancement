% X = zeros(11);
% centerX = 3;
% centerY = 3;
% maskSize = 2;
% %X(centerY-maskSize:centerY+maskSize,centerX-maskSize:centerX+maskSize) = 1;
% X(2:5,2:6) = 1;
% %X([2,7],2:7,:) = 1;
% a = find(X > 0);

%%
%%%%%%%%%%%%% MASKING OUT THE ROI, adding to ROI folder%%%%%%%%%%%
images = dir('..//*.png');
L = length(images);
for i=1:L
    i
    name = images(i).name;
    path = strcat('..//', name);
    image = imread(path);
    %image = im2double(imread(path));
    
    [height,width] = size(image);
    c = centerOfMass(image);
    centerX = round(c(2));
    centerY = round(c(1));
    
    mask = zeros(height, width);
    maskSizeX = round(width/4);
    maskSizeY = round(height/4);
    mask(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX) = 1;
    masked = image .* mask;
    masked = masked(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX); % CUT OUT THE MASK SIZE OUT OF THE NEW IMAGE
    
    %newname = strcat('ROI_', name);
    %imwrite(masked, newname);
end