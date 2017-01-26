function [ Is ] = gradient_direction_sobel( i3 )

%GRADIENT_direction return the absolute direction from -pi/2 to pi/2 sobel
%gradient in every point of the gradient (only half circle does not have
%negative directionss
%the picture

i3=double(i3);%convert image to double to accumolate for negative values
soby=fspecial('sobel');% create sobel 3 by 3 filter
sobx=soby';
%-------------------------------------------------------------------
Dy=imfilter(i3,sobx,'same');%x first derivative  sobel mask
Dx=imfilter(i3,soby,'same');% y sobel first derivative
Is=double(atan(Dy./Dx));%gradient direction map going from 0-180
%--------------------show the image-----------------------------------------------
%%{
imshow(Is,[]);% the ,[]  make sure the display will be feeted to doube image
%colormap jet
%colorbar
pause;
%}
end