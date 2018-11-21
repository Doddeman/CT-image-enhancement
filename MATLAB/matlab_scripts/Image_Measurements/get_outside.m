function outside = get_outside(image, height, width)

upper_left = grayconnected(image,1,1,0);
upper_right = grayconnected(image,1,width,0);
lower_left = grayconnected(image,height,1,0);
lower_right = grayconnected(image,height,width,0);
outside = 2*(upper_left + upper_right + lower_left + lower_right);