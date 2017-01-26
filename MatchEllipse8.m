function [ Score] = MatchEllipse8(Ir,Iel,Resl,Ycnt,Ierea)   
%Given an image binary border mage of ellipse or line (Iellipse) and
%monochrome image Ir of the same size, check if the match of Iellipse as
%phase seperation surface of liquid in Ir
%=======================================working mode===========================================================================
% the difference of the average intensity inside the border  ellipse and the dillated region around it
% a Create mask surface  ellipse Iel filled and correlate it with the image Ir divided by number of pixel in the mask
% b Create Mask of the outer region and corrlate it with Ir divided by number of pixel in the mask
% The difference between a and b is the score (normalize by number of pixels BUT NOT ON average intensity on border) 

% if the border is ellipse cut it to upper and lower ellipse and use each
% seperately as border and peak the one with best score


%the Resl is the the resolution  which the scanning will be done, which is basically the dilation of the upper and lower parts of the borders 
%Hence  number of lines above and below the seperation line in which the differential will be taken
%Ir monochrome image of the system 
%Iel Shape of the potential liquid surface  (horizontal line or ellipse in cylindrical vessel)
% Ycnt Y center of Iel (Iel is symetrical in both x and y Ycnt is its Y ceneter of symmetry
%Ierea is the area of the vessel marked in one in binary image the scanning will be done only within this images
  %Paper Table Entries 11
             
             FilledSurf=imfill(Iel,4,'holes'); % inner part of the ellipse filled
              IelOut=(dilate(FilledSurf,Resl)- FilledSurf).*Ierea;%dilate ellipse  in resl and keep the parts that dont exceed image
             
             
              Si=sum(sum(FilledSurf));%sum of pixel in inner ellipse part
              So=sum(sum(IelOut));%sum of pixel in lower ellipse part
              Score=abs(sum(sum(double(Ir).*double(FilledSurf)))/Si-sum(sum(double(Ir).*double(IelOut)))/So); % score of the upper parabola of surface by difference  between intsnity  above and below surface


end

%{
%description
%see paper for better description
This method average intensity inside the entire surface instead of the surface line and substract from the vareage intensiyty direcly abover and below the surface (not divided by the vreage intensity) generally if the entire  liquid surface will so sharp change in colour/intensity then this method will show  advantage  examining the only the surface line. However both examination of pictures and the result of the  test show this method is inferior  and that the sharpest change in intensity is on border separation line and not surface) . This  method seem tow work well only with thin and line borders but fail when the surface look lie wide ellipse. ( (????? ?? ?????? ????? ??? ?????? ????

Algorthm	
Match ellipse 8
a)	Take the propuse border surface as filled binary image
b)	Examine the average in tensity of pixels within this reagion
c)	Dilate the original surface area by n pixel, and take the average intensity of pixels in thei s region that are outside the original surface but that are inside the vessel border.)


Method 9,10 (canny sobel with gradient)
%Take the edge image (canny) of Is and gradient direction  map of both Is
%and and Iel the correlation between both the gradient direction and the
%Iel and canny is the score
%Iel and combine  and use the 

Examine not only the edge intensity along the border but also its direction (methods 1-4 already take into consideration the gradient direction by taken the change across the border) this method correlate the propused border line  with both the border intensity (either  binary canny or absolute gradient size) but also use the  correlation between the gradient direction in the proused surface and on the image. The result are better then those of the method how just examine the crosss correlation with the image but worst then method 1-2 how axamine averageintensity change along the border). 
Generally combine the cross correlation between intensities and the match between gradient lines the difference between gradient lines direction is between 0 (complete match) and pi/2 ( the largest angle between lines on planes 
}%


