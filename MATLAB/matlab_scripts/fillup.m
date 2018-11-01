%%%%%%% Fill up high/low folders with all images %%%%%%%%
% After sampling and classification,
% use this script to get all the images of one patient
% into the desired folder depending on its quality. 
clear all
%%
%get list of low patiens+tf
low_sample_images = dir('E:\david\R_low/*.png');
low_images = [];
for i=1:length(low_sample_images)
   i
   name = low_sample_images(i).name;
   name = strsplit(name,'_');
   patient = name{1};
   time_frame = name{2};
   patient_tf = strcat(patient, '_', time_frame);
   low_images = [low_images,patient_tf,','];
end
low_images = low_images(1:length(low_images)-1); %cut away last ','
low_patients = strsplit(low_images,','); %split into cells
%low_patients = unique(all_patients); %Finally 

%get list of high patiens+tf
high_sample_images = dir('E:\david\R_high/*.png');
high_images = [];
for i=1:length(high_sample_images)
   i
   name = high_sample_images(i).name;
   name = strsplit(name,'_');
   patient = name{1};
   time_frame = name{2};
   patient_tf = strcat(patient, '_', time_frame);
   high_images = [high_images,patient_tf,','];
end
high_images = high_images(1:length(high_images)-1); %cut away last ','
high_patients = strsplit(high_images,','); %split into cells
%high_patients = unique(high_patients); %Finally 


%%
% excluded = [];
all_images = dir('E:\david\R_data/*.png');
for i=1:length(all_images)
   i
   all_name = all_images(i).name;
   all_split = strsplit(all_name,'_');
   all_patient = all_split{1};
   all_tf = all_split{2};
   allpat_tf = strcat(all_patient, '_', all_tf);
   
   if any(strcmp(high_patients,allpat_tf))
       source = strcat('E:\david\R_data\', all_name);
       des = strcat('E:\david\CT-image-enhancement\cycleGAN\datasets\R\trainB\', all_name);
       copyfile (source, des);
   elseif any(strcmp(low_patients,allpat_tf))
       source = strcat('E:\david\R_data\', all_name);
       des = strcat('E:\david\CT-image-enhancement\cycleGAN\datasets\R\trainA\', all_name);
       copyfile (source, des);
%    else
%        excluded = [excluded, all_name, ','];
   end
end

%%

% exluded_cells = strsplit(excluded, '.');
