function [ Score] = MatchEllipse15(Ir,Iel,Resl,Ycnt,Ierea)
%basically do  what matchellipse9e do but using hugh transform 
%Given an image binary border mage of ellipse or line (Iellipse) and
%monochrome image Ir of the same size, check if the match of Iellipse as
%phase seperation surface of liquid in Ir
%=======================================working mode===========================================================================
%Use generalized hough transform for to score curve

% if the border is ellipse cut it to upper and lower ellipse and use each
% seperately as border and peak the one with best score

%the Resl is the the resolution  which the scanning will be done, which is basically the dilation of Ir 
%Ir monochrome image of the liquid 
%Iel Shape of the potential liquid surface  (horizontal line or ellipse in cylindrical vessel)
% Ycnt Y center of Iel (Iel is symetrical in both x and y Ycnt is its Y ceneter of symmetry
%Ierea is the area of the vessel marked in one in binary image the scanning
%will be done only within this images (probably unused in this one)
%Ycnt
%I2 = imcrop(I, rect) crops the image I. rect is a four-element position vector[xmin ymin width height] that specifies the size and position of the crop rectangle.
   %Paper Table Entries 16

Ss=size(Iel);
  IelUp=Iel;
  IelUp(Ycnt+1:Ss(1),:)=0;% zero out everything above Ycnt keep lower ellipse parabola
  Np=sum(sum(IelUp));% number of points in the parabola
  IelUp=dilate(IelUp,Resl-1).*Ierea;%dilate ellipse  in resl and keep the parts that dont exceed image
  %'entet hough 1'
  [scoreup] = Generalized_Hough_Transform_Simple(Ir,IelUp);  % use generalized hough transform to found match  (y and x should be both 1 and are ignored)
 

   Iel(1:Ycnt-1,:)=0;% zero out everything below Ycnt keep upper ellipse parabola
   Iel=dilate(Iel,Resl-1).*Ierea;%dilate ellipse  in resl and keep the parts that dont exceed image
   % 'entet hough 2'
   [scoredn ] = Generalized_Hough_Transform_Simple(Ir,Iel); % use generalized hough transform to found match  (y and x should be both 1 and are ignored)
 
 
  %'exit hough 2'
   Score=double(max(scoreup(1),scoredn(1)))/double(Np); % found the best match of the two haldfs of the llipse and and use its score divided by the number of ellipse points

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [score] = Generalized_Hough_Transform_Simple(Is,Itm) 
%Find match  between template/shape Itm in greyscale image Is using
%generalize hough trasform ,Is and Itm should be of the same size

%Use generalized hough transform to find Template/shape binary image given in binary image Itm in grayscale image Is (greyscale image)

%Is is greyscale  picture were the template Itm should be found 
%Itm is bool edge image of the template with edges markedd ones
% itm size 

%--------------------------create edge and system edge images------------------------------------------------------------------------------------------------------------------------



Iedg=edge(Is,'canny'); % Take canny edge images of Is with automatic threshold
%}
%--------------------------------------------------------------------------------------------------------------------------------------
[y x]=find(Itm>0); % find all y,x cordinates of all points equal 1 inbinary template image Itm
nvs=size(x);% number of points in the  template image
if nvs==0  disp('ERROR input template image Is is empty');pause;end;
%-------------------Define Yc and Xc ----------------------------------------------
Cy=1;%round(mean(y));% find object y center, note that any reference point will do so the origin of axis hence 1 could be used just as well
Cx=1;%round(mean(x));% find object z center, note that any reference point will do so the origin of axis hence 1 could be used just as well

%------------------------------create gradient map of Itm, distrobotion between zero to pi %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GradientMap = gradient_direction1( Itm );

%%%%%%%%%%%%%%%%%%%%%%%Create an R-Table of Itm gradients to  parameter space in parameter space.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------------------create template descriptor array------------------------------------
MaxAngelsBins=12;% divide the angel space to MaxAngelsBins uniformed space bins
MaxPointsPerAngel=nvs(1);% maximal amount of points corresponding to specific angel

PointCounter=zeros(MaxAngelsBins);% counter for the amount of edge points associate with each angel gradient
Rtable=zeros(MaxAngelsBins,MaxPointsPerAngel,2); % assume maximum of 100 points per angle with MaxAngelsBins angles bins between zero and pi and x,y for the vector to the center of each point
% the third adimension are vector from the point to the center of the vessel

%------------------fill the  angel bins with points in the Rtable---------------------------------------------------------
for f=1:1:nvs(1)
    bin=round((GradientMap(y(f), x(f))/(2*pi))*(MaxAngelsBins-1))+1; % transform from continues gradient angles to discrete angle bins and 
    PointCounter(bin)=PointCounter(bin)+1;% add one to the number of points in the bin
    if (PointCounter(bin)>MaxPointsPerAngel)
        disp('exceed max bin in hugh transform');
    end;
    Rtable(bin, PointCounter(bin),1)= Cy-y(f);% add the vector from the point to the object center to the bin
    Rtable(bin, PointCounter(bin),2)= Cx-x(f);% add the vector from the point to the object center to the bin
end;
%plot(pc);
%pause;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%create and populate hough space%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------use the array in previous image to identify the template in the main image Is----------------------------------------
[y x]=find(Iedg>0); % find all edg point in the in edge image Iedg of the main image Is
np=size(x);% find number of edge points Is edge image
if np==0  disp('ERROR input  image itm is empty');pause;end;
GradientMap=gradient_direction1(Is); % create gradient direction  map of the Is
Ss=size(Is); % Size of the main image Is
houghspace=zeros(size(Is));% the hough space assume to be in size of the image but it should probably be smaller
    for f=1:1:np(1)
          bin=round((GradientMap(y(f), x(f))/(2*pi))*(MaxAngelsBins-1))+1; % transform from continues gradient angles to discrete angle bins and 

          for fb=1:1:PointCounter(bin)
              ty=Rtable(bin, fb,1)+ y(f);
              tx=Rtable(bin, fb,2)+ x(f);
               if (ty>0) && (ty<Ss(1)) && (tx>0) && (tx<Ss(2))  
                   houghspace(Rtable(bin, fb,1)+ y(f), Rtable(bin, fb,2)+ x(f))=  houghspace(Rtable(bin, fb,1)+ y(f), Rtable(bin, fb,2)+ x(f))+1; % add point in were the center of the image should be according to the pixel gradient
               end;        
          end;
    end;





score=houghspace(1,1); % given that the template image is of the same size  

end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [ Is ] = gradient_direction1( i3 )
%return map of the absolute direction from -pi/2 to pi/2  of gradient in every point of the gradient  i3(only half circle does not have negative directionss
%-------------------------------------------------------------------
Dy=imfilter(double(i3),[1; -1],'same');%x first derivative  sobel mask
Dx=imfilter(double(i3),[1  -1],'same');% y sobel first derivative
Is=atan2(Dy,Dx)+pi();
%Is=mod(atan2(Dy,Dx)+pi(), pi());%atan(Dy/Dx);%note that this expression can reach infinity if dx is zero mathlab aparently get over it but you can use the folowing expression instead slower but safer: 
%mod(atan2(Dy,Dx)+pi(), pi());%gradient direction map going from 0-180
%--------------------show the image-----------------------------------------------
%{
imshow(Is,[]);% the ,[]  make sure the display will be feeted to doube image
colormap jet
colorbar
pause;
%}
end


