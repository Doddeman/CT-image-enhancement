function image = get_image(path)

image = im2double(imread(path));
[height,width,dim] = size(image);
if height ~= 256 || width ~= 256
    image = imresize(image,[256,256]);
%     [height,width] = size(image);
end
if dim ~= 1
    image = rgb2gray(image);
end
image(image<0) = 0;