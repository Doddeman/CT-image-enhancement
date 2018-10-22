%%%%%%%%% Pick out one slice per patient and time frame %%%%%%%%%%%%%%

clear all
close all

images = dir('E:\david\DataForDavid1/*.png');
L = length(images);
% Create vector with all the patients+time frames
all_images = [];
for i=1:L
   i
   name = images(i).name;
   name = strsplit(name,'_');
   patient = name{1};
   patient = strcat(patient, '_dt1');
   %time_frame = name{2};
   %patient_tf = strcat(patient, '_', time_frame);
   all_images = [all_images,patient,','];
end
all_images = all_images(1:length(all_images)-1); %cut away last ','
all_patients = strsplit(all_images,','); %split into cells
patients = unique(all_patients);


%%
% old algorithm for choosing middle slices
% % Create vector with chosen indices
% image_indices = [];
% image_names = [];
% numbers = [];
% current_indice = 0;
% for i=1:length(patients)
% %     i
%     patient = patients{i};
%     patient = strcat(patient,',');
%     if patient(1:1) == 'H'
%         specific_indice = 90;
%     elseif patient(1:2) == 'T3'
%         specific_indice = 112;
%     else
%         number = count(all_images, patient);
%         numbers = [numbers, number];
%         specific_indice = round(number/2);
%     end
% 
%     char_indice = num2str(specific_indice);
%     patient = patient(1:length(patient)-1);
%     image_name = strcat(patient,'_T1_S',char_indice);
%     image_names = [image_names,image_name,','];
% %     actual_indice = current_indice + specific_indice;
% %     image_indices = [image_indices, actual_indice];
% %     current_indice = current_indice + number;
% end
% fifty_images = image_names(1:length(image_names)-1); %cut away last ','
% fifty_patients = strsplit(fifty_images,',');


%%
% Current method for choosing of middle slices for new data, dt1
% do this by hand...
path = 'E:\david\DataForDavid1/';
chosen_images = [];
for i = 1:length(patients)
    i
    current = patients{i};
    if current(1:2) == 'R4'
        slice = '300';
    elseif current(1:2) == 'R5'
        slice = '95';
    elseif current(1:2) == 'R6' | current(1:2) == 'R7' 
        slice = '117';
    elseif current(1:2) == 'R9'
        slice = '85';
    elseif current(1:3) == 'R25'
        slice = '40';
    elseif current(1:3) == 'R27'
        slice = '28';    
    elseif current(1:3) == 'R29'
        if length(current) == 8 & current == 'R29_dt10'
            slice = '20';
        else
            slice = '45';
        end
    else
        slice = '100';    
    end
    chosen_file = strcat(current, '_s', slice,'.png,');
    chosen_images = [chosen_images, chosen_file];
end
chosen_images = chosen_images(1:length(chosen_images)-1); %cut away last ','
chosen_images = strsplit(chosen_images,','); %split into cells

%%
%Add chosen images to current folder
fromPath = 'P:\Shared\ImagesFromVikas\NewData\';
toPath = 'P:\Shared\ImagesFromVikas\middle_slices\';
for i=1:length(chosen_images)
    i
    %indice = image_indices(i);
%     name = images(indice).name;
    name = chosen_images{i};
    sour = strcat(fromPath, name);
    des = strcat(toPath, name);
    [status, msg, msgID] = copyfile(sour, des);
    if msg ~= ''
        disp('PROBLEM')
    end
end

