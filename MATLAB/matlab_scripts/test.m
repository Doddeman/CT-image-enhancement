%Useful commands

clear all
% % m = [1 2 3; 0 0 0; 1 2 3];
% % backgroundIndices = find(m < 2);
% % hej = mean(m);
% % hej2=mean(hej);
% a = 1;
% if a == 1
%     disp('Returning nowqqq')
%     return
% end
% 
% b = 2
images = dir('../to_matlab/*.png');
n = length(images)
z = zeros(n,1);

z(6) = 40;

%[height, width, color] = size(image);
%imshow(image);
%[rowA, colA] = find(image > 200);
%names = cell(L,1);

%[max,I] = max(v);
%[I_row, I_col] = ind2sub(size(bw),I);
%figure(1);
%imshow(bw);
%figure(2);
%imshow(image);


%v = image(:);
%figure(2);
%histogram(image);