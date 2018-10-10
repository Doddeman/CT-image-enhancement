%%%%%%%%% Pick out one image per patient %%%%%%%%%%%%%%
% BE SURE TO BE IN THE FIFTY FOLDER WHEN RUNNING
clear all
close all

images = dir('../PNG_Images_AC/*.png');
L = length(images);
% Create vector with the 50 patients
all_images = [];
for i=1:L
   name1 = images(i).name;
   patient = strsplit(name1,'_');
   patient = patient{1};
   all_images = [all_images,patient,','];
end
all_images = all_images(1:length(all_images)-1); %cut away last ','
all_patients = strsplit(all_images,',');
patients = unique(all_patients);

% Create vector with chosen indices
image_indices = [];
image_names = [];
numbers = [];
current_indice = 0;
for i=1:length(patients)
%     i
    patient = patients{i};
    patient = strcat(patient,',');
    if patient(1:1) == 'H'
        specific_indice = 90;
    elseif patient(1:2) == 'T3'
        specific_indice = 112;
    else
        number = count(all_images, patient);
        numbers = [numbers, number];
        specific_indice = round(number/2);
    end

    char_indice = num2str(specific_indice);
    patient = patient(1:length(patient)-1);
    image_name = strcat(patient,'_T1_S',char_indice);
    image_names = [image_names,image_name,','];
%     actual_indice = current_indice + specific_indice;
%     image_indices = [image_indices, actual_indice];
%     current_indice = current_indice + number;
end
fifty_images = image_names(1:length(image_names)-1); %cut away last ','
fifty_patients = strsplit(fifty_images,',');

%Add chosen images to fifty folder
images = dir('../PNG_Images_AC/*.png');
for i=1:length(fifty_patients)
    i
    %indice = image_indices(i);
%     name = images(indice).name;
    name = strcat(fifty_patients{i},'.png');
    path = strcat('../PNG_Images_AC/', name);
    image = imread(path);
    imwrite(image, name);
end

