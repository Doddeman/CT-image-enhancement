%%%%%%%%%CLASSIFY IMAGES INTO DIFFERENT FOLDERS BASED ON ARTIFACTS%%%%%%%%

%Should probably add code to mask out ROI here
%or maybe not, then you miss artifacts outside
%images = dir('../ROI/*.png'); 

%Maybe now good enough to fix the rest manually

images = dir('P:\Shared\ImagesFromVikas\PNG_Images_AC\*.png');
L = length(images); 
for i=1:L
    i
    name = images(i).name;
    path = strcat('P:\Shared\ImagesFromVikas\PNG_Images_AC\', name);
    image = imread(path);
    
           
    % Either use the mean value (Will theoretically
    % be low if artifacts exist, but will not cover
    % all cases)
    meanvalue = mean(mean(image));
        
    % Or use number of "white" pixels, which should
    %  be lower if artifacts exist
    binaryImage = image >= 220;
    numberOfWhitePixels = sum(binaryImage(:));
    
    if numberOfWhitePixels <= 23
    %if meanvalue < 80
        copyfile (path, 'artifacts');
    else
        copyfile (path, 'clean');
    end
end

arti = dir('artifacts\*.png');
n_of_arti = length(arti)

clean = dir('clean\*.png');
n_of_clean = length(clean)

