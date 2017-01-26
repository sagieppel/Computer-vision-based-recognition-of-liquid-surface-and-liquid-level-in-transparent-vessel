function boolim=resize_border3(boolim, sy, sx) 
% resize binarry image of the vessel border boolim  to smaller (sz fraction) bolean border image if sx is used then change to specific number 
% first refill the image then transfrom it to double shrink and take every
% pixel that is not zero to be one the take the border again
%this function have 3 variation this one is the second best
%boolim=imread('C:\Users\mithycow\Documents\MATLAB\symmetry_score power(1 dive ysize).tif');
%figure, imshow(boolim);
boolim=imfill(boolim,4,'holes');% fill image 4 is the connectivity

if (nargin==3)

    boolim=imresize(boolim,[sy sx]);
else
boolim=imresize(boolim,[sy NaN]);%,'bilinear');
end;
    
boolim= bwmorph(boolim,'remove');% remove blobe interior and leave edges;
%figure,imshow(boolim,[])
end