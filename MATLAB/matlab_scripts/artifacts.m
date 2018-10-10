%%%%%%%%%CLASSIFY IMAGES INTO DIFFERENT FOLDERS BASED ON ARTIFACTS%%%%%%%%

%Should probably add code to mask out ROI here
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

