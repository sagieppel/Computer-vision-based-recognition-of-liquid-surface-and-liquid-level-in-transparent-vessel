function [Iel,sumofpixels] = ELLIPSE( x1,x2,y1,y2, posdil,negdil,sizeim, PartsToDraw )
%{
Draw specific elliptic curve in an binary image (Iel). Create binary image with the ellipse drawn on it. 
x1,x2,y1,y2 are the leftmost rightmost top and bottom coordinates of the ellipse respectively.
Sizeim is the size of the binary image(Iel) in which the ellipse should be drawn (should be the same as the size of liquid container image). 
posdil and negdil parameters are not being used and should be set to zero. This parameters controls the positive and negative dilation of the ellipse curve generated.
PartsToDraw again parameter that isn’t being used and could be left blank. This parameter determines if to draw all the ellipse or only the top/bottom half. Draw all ellipse by default.
Iel The output binary image with the ellipse drawn. Pixel belong to ellipse line have value of 1. The rest have value of zero. The size of  Iel image is Sizeim.
Sumofpixels is the sum of all pixel in Iel which is basically the number of point on the ellipse drawn. This output parameter is not used.

%}
% create ellipse with edges x1,x2 y1,y2 , positive  dilation of posdil and
% negative dilation (-1) of negdil
% size is the size of the output image in which the result will be returned 
% return filter image in size sizeim with values 1 in the dilated ellipse
% and values -1 in the negative dilated ellipse around the dilated ellipse
% the dilation negative and positive ar only in the y axis
%sumofpixelsl sum of ellipse is the number of pixel in the ellipse
%PartsToDraw define wether to draw 'all' ellipse 'upper' curve or 'lower' curve 
if nargin<8
    PartsToDraw='all';
end;
%---------------------first examine to cases were the ellipse is acually a line --------------------------------------------------
Iel=zeros(sizeim);% will contain the image of the ellipse
if y2==y1 
    Iel(y1,x1:1:x2)=1; %soel=abs(x2-x1)+1;
    
elseif x1==x2
    Iel(y1:1:y2,x1)=1; 
else%---------------------------------if not line draw ellipse-------------------------------------------------------------

%------------------find ellipse major paramters center a and--------------------
% aX^2+bY^2=1  the ellipse equation. 
%edges x=+/-sqrt(1/a) width=2sqrt(1/a)  -> a=1/(width/2)^2

a=1/((x2-x1)/2)^2;
b=1/((y2-y1)/2)^2;
Xc=(x1+x2)/2;
Yc=(y1+y2)/2; %find ellipse center

%----------------------draw ellipse---------------------------------------------

  for fx=0:0.2:(x2-x1)/2 % draw ellipse on ie
      % Y=+/-sqrt((1-aX^2)/b)
      if not(strcmp(PartsToDraw,'lower')) % can also use ~ if not restrict to lower curve draw upper curve
           Iel(round(Yc-sqrt((1-a*fx^2)/b)),round(Xc+fx))=1; % draw right upper parts of ellipse
           Iel(round(Yc-sqrt((1-a*fx^2)/b)),round(Xc-fx))=1;% draw left upper part of ellipse
           
      end
     if not(strcmp(PartsToDraw,'upper')) % can also use ~ if not restrict to upper curve draw lower curve
          Iel(round(Yc+sqrt((1-a*fx^2)/b)),round(Xc+fx))=1; % draw left lower part of ellipse
            Iel(round(Yc+sqrt((1-a*fx^2)/b)),round(Xc-fx))=1;% draw right lower part of ellipse 
        
     end; 
  end;
end
  sumofpixels=sum(sum(Iel));
  
  %% dilate  ellipse in the y axis only with posdil as the number of pixels with positive corrleation
     CE=ones(posdil*2+1)'; % create dilation mask

      
         Iel=imdilate(Iel,CE);%dilate image


     %% dilate  ellipse with posdil with positive corrleation
    CE=ones(negdil*2+1)';
         BW2=imdilate(Iel,CE);%dilate image
 Iel=Iel*2-BW2; 
  
 % imshow(ie,[]);
 % pause();
 % pos=find2(ie,1);
 % neg=find2(~ie,1);
%  pos=[py px];
%  neg=[ny nx];
end

