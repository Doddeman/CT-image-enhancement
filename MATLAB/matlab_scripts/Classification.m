%%%%%%%%%%%%%%%%%%%%%%Classification of PNG:s%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

images = dir('../PNG_Images_AC/*.png');
L = length(images);

all_images = [];
for i=1:L
   i
   name = images(i).name;
   patient = strsplit(name,'_');
   patient = patient{1};
   all_images = [all_images,patient,','];
end

all_images = all_images(1:length(all_images)-1); %cut away last ','
all_patients = strsplit(all_images,',');
patients = unique(all_patients);

image_indices = [];
numbers = [];
current_indice = 0;
for i=1:length(patients)
    patient = patients{i};
    patient = strcat(patient,',');
    number = count(all_images, patient);
    numbers = [numbers, number];
    specific_indice = round(number/2);
    actual_indice = current_indice + specific_indice;
    image_indices = [image_indices, actual_indice];
    current_indice = current_indice + number;
end


%%
close all;
images = dir('P:\Shared\ImagesFromVikas\samples/*.png');
path = strcat('P:\Shared\ImagesFromVikas\samples/', images(10).name)
%path = strcat('../PNG_Images_AC/', 'R21_T1_S6.png')
%path = strcat('../PNG_Images_AC/', 'A10_T1_S103.png')
%path = strcat('../PNG_Images_AC/', 'A12_T1_S109.png')
%path = strcat('../PNG_Images_AC/', 'R3_T1_S28.png')
%path = strcat('../PNG_Images_AC/', 'T1_T1_S2.png')


image = double(imread(path));
[height,width] = size(image);
image1 = imresize(image,[256 256]);
[height1,width1] = size(image1);
c = centerOfMass(image1);
centerX = round(c(2));
centerY = round(c(1));

mask = double(zeros(height1, width1));

%newmask = double(ones(width));
if height1 < 130 && width1 < 130 && height1 ~= width1
    maskSizeX = 50;
    maskSizeY = 40;
else
    maskSizeX = round(width1/5);
    maskSizeY = round(height1/7);
end
mask(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX) = 1;
%[hej,hej1] = size(mask)

masked = image1 .* mask;
masked = masked(centerY-maskSizeY:centerY+maskSizeY,centerX-maskSizeX:centerX+maskSizeX);

figure(3);
imshow(image,[0 255]);
hold on;
plot(centerX,centerY,'r.');

figure(4);
imshow(masked, [0 255]);
hold on;
plot(centerX,centerY,'r.');

figure(5);
imshow(image1, [0 255]);
hold on;
plot(centerX,centerY,'r.');

%%
%%%%%%%%%%%%%% Clean out ROI and classified folders %%%%%%%%%%%%



%%
%%%%%%%%%CLASSIFY INTO DIFFERENT FOLDERS BASED ON ARTIFACTS%%%%%%%%
images = dir('../ROI/*.png');
L = length(images); 
for i=1:L
    i
    name = images(i).name;
    %path = strcat('../ROI/', name);
    image = imread(name);
    
    %maxvector = max(image);
    %maxvalue = max(maxvector);
    
    meanvector = mean(image);
    meanvalue = mean(meanvector);
    
    binaryImage = image >= 210;
    numberOfWhitePixels = sum(binaryImage(:));
    
    %if numberOfWhitePixels < 10
    if meanvalue < 80
        copyfile (name, '../Lowquality');
    else
        copyfile (name, '../Highquality');
    end
end

