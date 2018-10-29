%%%%%DOWNSAMPLING IMAGES FOR FASTER TRAINING %%%%%%%%%%%%%%%%
images = dir('E:\david\R_data/*.png');
L = length(images);

for i = 1:L
    name = images(i).name;
    path = strcat('E:\david\R_data/', name);
    image = imread(path);
    
    down = image(1:2:end,1:2:end);
    dest = strcat('E:\david\R_downsampled/', name);
    imwrite(down, dest);
end

% figure(1);
% imshow(image);
% 
% Xdown = image(1:2:end,1:2:end);
% 
% figure(2)
% imshow(Xdown);
% 
% Xdown2 = image(1:4:end,1:4:end);
% 
% figure(3)
% imshow(Xdown2);