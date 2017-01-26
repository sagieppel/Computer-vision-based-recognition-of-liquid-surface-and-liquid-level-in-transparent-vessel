% erode binary image K
CE=strel('square',3)% create square mask of 3X3 for oppening 
K=imerode(K,CE);
figure, imshow(K);