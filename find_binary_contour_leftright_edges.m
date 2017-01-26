function [y,x1,x2,np]=find_binary_contour_leftright_edges(BW)% 
%{
This function take the binary image  BW that contain the contour of the vessel (Figure S1 center), and find the left and right edges (in image coordinates) of every line inside the contour given in BW.
x1[n] array that contain the left most x coordinate of line n, in the vessel region of the image.
image).
x2[n] array that contain the right most x coordinate of line n, in the vessel region of the image.
y[n] array that contain the y coordinate of line n, in the vessel region of the image.
np the number of lines in the vessel region of the image.

%}
%get binary contour image and create array with accending y order  in which
%the x1(f) and x2(f) are the left and right borders of the contour in lines
%y(f), assume only two points in each line/y value
% note the x1,x2,y share the same index.
%np number of lines found

 d = size(BW);% get image dimension
   
np=0;% the index of the arrays y,x1,x2
for fy=1:1:d(1)% scan every line y
    m=0;
    for fx=1:1:d(2) % scan along the line x values
        if (BW(fy,fx)==1)
        if (m==0) 
            np=np+1;
            x1(np)=fx;  x2(np)=fx; y(np)=fy; m=1;
        else
            x2(np)=fx;
        end
    end
    end
    
   %{
   for f=1:np
        BW(y(f),x1(f):1:x2(f))=1;
        imshow(BW);
        pause(0.01);
    end;
    %}
end