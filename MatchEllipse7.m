function [ Score] = MatchEllipse7(Ir,Iel,Resl,Ycnt,Ierea)   
%Given an image binary border mage of ellipse or line (Iellipse) and
%monochrome or binary image Ir of the same size, check if the match of Iel as
%phase seperation surface of liquid in Ir
%=======================================working mode===========================================================================
% Check if there clear liquid border  or surface along Iel which is either ellipse or line 
% Cross correlate the dilated border line Iel with image Iel or (cold be monochrome or binary edge image)
% if the border is ellipse cut it to upper and lower ellipse and use each seperately as border and pick the one with best score


%the Resl is the the resolution  which the scanning will be done, which is basically the dilation of the upper and lower parts of the borders 
%Hence  number of lines above and below the seperation line in which the differential will be taken
%Ir monochrome image of the system 
%Iel Shape of the potential liquid surface  (horizontal line or ellipse in cylindrical vessel)
% Ycnt Y center of Iel (Iel is symetrical in both x and y Ycnt is its Y ceneter of symmetry
%Ierea is the area of the vessel marked in one in binary image the scanning will be done only within this images
  %Paper Table Entries 7,13,18,30

              Iel=dilate(Iel,Resl-1).*Ierea;%dilate ellipse  in resl and keep the parts that dont exceed vessel
           
%========================scan the upper part of the ellipse================================================================================================================================
  IelHlf=Iel;
  Ss=size(Iel);
  IelHlf(Ycnt+1:Ss(1),:)=0;% zero out everything above Ycnt keep lower ellipse parabola

  Si=sum(sum(IelHlf));%sum of pixel in the ellipse part
 
 ScoreUp=abs(sum(sum(double(Ir).*double(IelHlf))))/Si;  % score of the lower parabola of surface by cross correlation with Ir
 %=======================================calculate score of lower ellipse parts========================================================================================================
%========================scan the upper part of the ellipse================================================================================================================================
  IelHlf=Iel;
  
  IelHlf(1:Ycnt-1,:)=0;% zero out everything below Ycnt keep upper ellipse parabola

  Si=sum(sum(IelHlf));%sum of pixel in lower ellipse part
 
 ScoreDn=abs(sum(sum(double(Ir).*double(IelHlf))))/Si; % score of the upper parabola of surface by cross correlation with Ir

 %======================================Get Best Score==================================================================================
 
 Score=max( ScoreUp,ScoreDn);% the final score is the best score of the upper and lower ellipse
 
 end
%{
 %Description
 %for better description see paper
This method simply cross correlate the border line dilated by n-1 with the  image  and give the  average intensity on the  border line (the assumption here is that the  border line is brighter brighter and hence its pixel have higher intensity in average), the main limitation of this approach is that high intensity can be resulted from reason. Simalrly the dilated border can be correlated with the edge  image of the system base on the assumption that this that on the phase separation the gradient will be stronger which is again true but fail to address things like high noise and consistency of the intensity change along the border (the edge image can be canny sobel or simple gradient size map).
Algorithm
1) Take the bordser line (dilate it by n-1 (n=1) ) crosscorelate  by pixel by pixel mltipication with the image which could be monochrome image binary edge image or none binary edge image (gradient size map)
2) Divide the result by the number of pixels in the border line and take absolute  value as score

 %}

