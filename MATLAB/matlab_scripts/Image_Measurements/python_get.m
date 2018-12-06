function [SNR, CNR] = python_get(fake_path,orig_path)
% disp('HEUIAH matlab');
fake = get_image(fake_path);
orig = get_image(orig_path);
size = 256;
outside = get_outside(orig,size,size);
[orig_SNR, orig_CNR] = get_SNR_CNR(orig,outside, size, size);
[fake_SNR, fake_CNR] = get_SNR_CNR(fake,outside, size, size);

%returns improvement divided by original value
SNR_diff = fake_SNR - orig_SNR;
SNR_ratio = SNR_diff / orig_SNR;
if sign(SNR_diff) ~= sign(SNR_ratio)
    SNR_ratio = SNR_ratio * -1;
end

CNR_diff = fake_CNR - orig_CNR;
CNR_ratio = CNR_diff / orig_CNR;
if sign(CNR_diff) ~= sign(CNR_ratio)
    CNR_ratio = CNR_ratio * -1;
end

SNR = SNR_ratio;
CNR = CNR_ratio;

% SNR = (fake_SNR - orig_SNR)/orig_SNR;
% CNR = (fake_CNR - orig_CNR)/orig_CNR;