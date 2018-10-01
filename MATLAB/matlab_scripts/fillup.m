%%%%%%% Fill up high/low folders with all images %%%%%%%%


%%%%%%%%%%%%%%%%%% good quality %%%%%%%%%%%%%%%%%
clear all

sample_images = dir('../sample_high_quality/*.png');
all_images = dir('../PNG_Images_AC/*.png');

for i=1:length(sample_images)
   i
   sample_name = sample_images(i).name;
   sample_patient = strsplit(sample_name,'_');
   sample_patient = sample_patient{1};
   
   for j=1:length(all_images)
       j
       all_name = all_images(j).name;
       all_patient = strsplit(all_name,'_');
       all_patient = all_patient{1};
       if strcmp(sample_patient, all_patient)
           copyfile (all_name, '../high_quality');
       end
   end
end

%%%%%%%%%%%%%%% bad quality %%%%%%%%%%%%%%%%%%%%%%
%%
clear all

sample_images = dir('../sample_low_quality/*.png');
all_images = dir('../PNG_Images_AC/*.png');

for i=1:length(sample_images)
   i
   sample_name = sample_images(i).name;
   sample_patient = strsplit(sample_name,'_');
   sample_patient = sample_patient{1};
   
   for j=1:length(all_images)
       j
       all_name = all_images(j).name;
       all_patient = strsplit(all_name,'_');
       all_patient = all_patient{1};
       if strcmp(sample_patient, all_patient)
           copyfile (all_name, '../low_quality');
       end
   end
end