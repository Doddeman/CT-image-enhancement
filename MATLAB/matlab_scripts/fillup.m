%%%%%%% Fill up high/low folders with all images %%%%%%%%
% After sampling and classification with regression,
% use this script to get all the images of one patient
% into the desired folder depending on its quality. 

%%%%%%%%%%%%%%%%%% good quality %%%%%%%%%%%%%%%%%
clear all

sample_images = dir('P:\Shared\ImagesFromVikas\sample_high_quality2/*.png');
all_images = dir('P:\Shared\ImagesFromVikas\NewData/*.png');

for i=1:length(sample_images)
   i
   sample_name = sample_images(i).name;
   sample_name = strsplit(sample_name,'_');
   sample_patient = sample_name{1};
   sample_tf = sample_name{2};
   sampat_tf = strcat(sample_patient, '_', sample_tf);
   
   for j=1:length(all_images)
       %j
       all_name = all_images(j).name;
       all_split = strsplit(all_name,'_');
       all_patient = all_split{1};
       all_tf = all_split{2};
       allpat_tf = strcat(all_patient, '_', all_tf);
       
       if strcmp(allpat_tf, sampat_tf)
           source = strcat('P:\Shared\ImagesFromVikas\NewData\', all_name);
           des = strcat('P:\Shared\ImagesFromVikas\high_quality2\', all_name);
           copyfile (source, des);
       end
   end
end

%%%%%%%%%%%%%%% bad quality %%%%%%%%%%%%%%%%%%%%%%
%%
%get list of low patiens+tf
low_sample_images = dir('P:\Shared\ImagesFromVikas\sample_low_quality2/*.png');
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
high_sample_images = dir('P:\Shared\ImagesFromVikas\sample_high_quality2/*.png');
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
excluded = [];
all_images = dir('P:\Shared\ImagesFromVikas\NewData/*.png');
for i=1:length(all_images)
   i
   all_name = all_images(i).name;
   all_split = strsplit(all_name,'_');
   all_patient = all_split{1};
   all_tf = all_split{2};
   allpat_tf = strcat(all_patient, '_', all_tf);
   
   if any(strcmp(high_patients,allpat_tf))
       source = strcat('P:\Shared\ImagesFromVikas\NewData\', all_name);
       des = strcat('P:\Shared\ImagesFromVikas\high_quality2\', all_name);
       copyfile (source, des);
   elseif any(strcmp(low_patients,allpat_tf))
       source = strcat('P:\Shared\ImagesFromVikas\NewData\', all_name);
       des = strcat('P:\Shared\ImagesFromVikas\low_quality2\', all_name);
       copyfile (source, des);
   else
       excluded = [excluded, all_name];
   end
end

%%

exluded_cells = strsplit(excluded, '.');
% for i=1:length(sample_images)
%    i
%    sample_name = sample_images(i).name;
%    sample_name = strsplit(sample_name,'_');
%    sample_patient = sample_name{1};
%    sample_tf = sample_name{2};
%    sampat_tf = strcat(sample_patient, '_', sample_tf);
%    
%    for j=1:length(all_images)
%        %j
%        all_name = all_images(j).name;
%        all_split = strsplit(all_name,'_');
%        all_patient = all_split{1};
%        all_tf = all_split{2};
%        allpat_tf = strcat(all_patient, '_', all_tf);
%        
%        if strcmp(allpat_tf, sampat_tf)
%            source = strcat('P:\Shared\ImagesFromVikas\NewData\', all_name);
%            des = strcat('P:\Shared\ImagesFromVikas\low_quality2\', all_name);
%            copyfile (source, des);
%        end
%    end
% end