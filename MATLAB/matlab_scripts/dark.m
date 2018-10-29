%% Remove images containing a lot of dark background %%%

%path = strcat('../PNG_Images_AC/', 'H12_T1_S14.png')
%image = imread(path);

images = dir('../PNG_Images_AC/*.png');
L = length(images);

for i=1:L
    name = images(i).name;
    path = strcat('../PNG_Images_AC/', name);
    image = imread(path);
    
    pixels = prod(size(image));
    nonzeros = nnz(image);
    density = nonzeros/pixels;
    
    if density < 0.5
        movefile (path, '../dark');
        i
    end
end


