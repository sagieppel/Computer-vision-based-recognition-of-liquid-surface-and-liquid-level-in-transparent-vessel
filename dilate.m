% dilate binary image bw
function bw2=dilate(bw,n)
if (nargin<2) n=1; end
CE=strel('square',2*n+1);% create square mask of 3X3 for dilating

bw2=imdilate(bw,CE);%dilate image
end