%%%%%%%%% Pick out one slice per patient and time frame %%%%%%%%%%%%%%

clear all
close all

images = dir('E:\david\R_data/*.png');
L = length(images);
% Create vector with all the patients+time frames
all_images = [];
% hej = [];
for i=1:L
   i
   name = images(i).name;
   name = strsplit(name,'_');
   patient = name{1};
   time_frame = name{2};
   patient_tf = strcat(patient, '_', time_frame);
   all_images = [all_images,patient_tf,','];
%    hej = [hej, patient,','];
end
all_images = all_images(1:length(all_images)-1); %cut away last ','
all_patients = strsplit(all_images,','); %split into cells
unique_patients = unique(all_patients)';
% hej = strsplit(hej,',');
% hej = unique(hej)';


%%
% Current method for choosing of middle slices for new data
% control manually
chosen_images = [];
for i = 1:length(unique_patients)
    i
    current = unique_patients{i};
    cut = strsplit(current, '_');
    patient = cut{1};
    time_frame = cut{2};

    if strcmp(patient, 'R3') | strcmp(patient, 'R5') | strcmp(patient, 'R6') | strcmp(patient, 'R8') | strcmp(patient, 'R10')
        slice = '95';
    elseif strcmp(patient, 'R4') | strcmp(patient, 'R15')
        slice = '35';
    elseif strcmp(patient, 'R7') | strcmp(patient, 'R11')
        slice = '117';
    elseif strcmp(patient, 'R9')
        slice = '85';
    elseif strcmp(patient, 'R20') | strcmp(patient, 'R21')
        slice = '31';
    elseif strcmp(patient, 'R25')
        slice = '40';
    elseif strcmp(patient, 'R27')
        slice = '28';    
    elseif strcmp(patient, 'R28') | strcmp(patient, 'R29')
        slice = '86';
    elseif strcmp(patient, 'R32')
        slice = '63';
    elseif strcmp(patient, 'R34')
        slice = '45';
    else
        slice = '50';    
    end
    chosen_file = strcat(current, '_s', slice,'.png,');
    chosen_images = [chosen_images, chosen_file];
end
chosen_images = chosen_images(1:length(chosen_images)-1); %cut away last ','
chosen_images = strsplit(chosen_images,','); %split into cells

%Add chosen images to current folder
fromPath = 'E:\david\R_data\';
toPath = 'E:\david\middle_slices\';
for i=1:length(chosen_images)
    i
    %indice = image_indices(i);
%     name = images(indice).name;
    name = chosen_images{i};
    sour = strcat(fromPath, name);
    des = strcat(toPath, name);
    [status, msg, ~] = copyfile(sour, des);
    if ~strcmp(msg,'')
        disp('PROBLEM')
        return
    end
end

