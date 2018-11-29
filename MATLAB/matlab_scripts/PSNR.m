%%%%%%%%% ADD NOISE %%%%%%%%%%%
% Use test B images (dose modulated but "high" quality")
originals = dir('C:\Users\davwa\Desktop\CT-image-enhancement\CycleGAN\datasets\Quality\testA/*.png');
L = length(originals);

for i = 1:L
    orig_path = strcat('C:\Users\davwa\Desktop\CT-image-enhancement\CycleGAN\datasets\Quality\testB/', orig_name); 
    orig = get_image(orig_path);
    gauss = imnoise(orig,'gaussian');
    %poisson = imnoise(orig,'poisson');
    noisy = imnoise(gauss,'poisson');
    noisy_dest = strcat('C:\Users\davwa\Desktop\noisy/', orig_path);
    imwrite(noisy, noisy_dest);
end

%%%%%%%%% PYTHON %%%%%%%%%%%
%perhaps call python to send 
%noisy images through CGAN

%%%%%%%%% GET PSNR %%%%%%%%%%%
generated = dir('C:\Users\davwa\Desktop\CT-image-enhancement\CycleGAN\datasets\Quality\testA/*.png');

PSNR_vector = zeros(L,1);
for i = 1:L
    orig_path = strcat('C:\Users\davwa\Desktop\CT-image-enhancement\CycleGAN\datasets\Quality\testB/', orig_name); 
    orig = get_image(orig_path);
    gen_path = strcat('C:\Users\davwa\Desktop\CT-image-enhancement\CycleGAN\Quality_test/', orig_name); 
    gen = get_image(gen_path);
    %get psnr. Use original as reference
    peaksnr = psnr(gen,orig);
    PSNR_vector(i) = peaksnr;
end

%%%%%%%%% PLOT %%%%%%%%%%%
do_plot(PSNR_vector , 30, 'PSNR', 'PSNR');