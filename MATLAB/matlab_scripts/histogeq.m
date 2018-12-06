path = 'C:\Users\davwa\Desktop\CT-image-enhancement\histeq\';

originals = dir(strcat(path, 'originals/*.png'));
L = length(originals);

for i = 1:L
    i
    orig_name = originals(i).name;
    orig_path = strcat(path,'originals/', orig_name); 
    orig_im = get_image(orig_path);
    histed_im = histeq(orig_im);
    
%     figure
%     subplot(2,2,1)
%     imshow(orig)
%     subplot(2,2,2)
%     plot(imhist(orig))
%     subplot(2,2,3)
%     imshow(histed)
%     subplot(2,2,4)
%     plot(imhist(histed))
    
    dest = strcat('C:\Users\davwa\Desktop\CT-image-enhancement\histeq\histeq\', orig_name);
    imwrite(histed_im, dest);
end

%%%% SNR CNR for histeq %%%%
%%

CGANs = dir(strcat(path, 'CGAN/*.png')); 
% histeq = dir(strcat(path, 'histeq/*.png')); 
size = 256;

for i = 1:L
    orig_name = originals(i).name;
    orig_path = strcat(path,'originals/', orig_name); 
    orig_im = get_image(orig_path);
    histed_im = histeq(orig_im);
    CGAN_name = CGANS(i).name;
    CGAN_path = strcat(path,'CGAN/', CGAN_name); 
    CGAN_im = get_image(CGAN_path);
    orig_outside = get_outside(orig_im, size, size);
    [orig_SNR,orig_CNR] = get_SNR_CNR(orig_im,orig_outside,size,size);
    [histeq_SNR,histeq_CNR] = get_SNR_CNR(histeq_im,orig_outside,size,size);
    [orig_SNR,orig_CNR] = get_SNR_CNR(orig,orig_outside,size,size);
    
    
end