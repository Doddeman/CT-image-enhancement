function [SNR, CNR] = python_get(path)
% disp('HEUIAH matlab');
image = get_image(path);
size = 256;
outside = get_outside(image,size,size);
[SNR, CNR] = get_SNR_CNR(image,outside, size, size);