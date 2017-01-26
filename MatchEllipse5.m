function [ Score] = MatchEllipse5(Ir,Iel,Resl,Ycnt,Ierea)   
%similar to matchellipse2
%Given an image binary border mage of ellipse or line (Iellipse) and
%monochrome image Ir of the same size, check if the match of Iellipse as
%phase seperation surface of liquid in Ir
%=======================================working mode===========================================================================
% Check if there clear liquid border there  or surface along Iellipsse which is either ellipse or line 
% find the difference between the average intensity on the and below border
% and average intenisty in the line above border
% Create mask for the upper side of the surface line and the lower side of
% the surface border line corrleate them with the system image (or edge
% image of the system image) and substract to find the difference in
% intensity above and below the border (normalize by number of pixels and by average intensity on border) 

% if the border is ellipse cut it to upper and lower ellipse and use each
% seperately as border and peak the one with best score


%the Resl is the the resolution  which the scanning will be done, which is basically the dilation of the upper and lower parts of the borders 
%Hence  number of lines above and below the seperation line in which the differential will be taken
%Ir monochrome image of the system 
%Iel Shape of the potential liquid surface  (horizontal line or ellipse in cylindrical vessel)
% Ycnt Y center of Iel (Iel is symetrical in both x and y Ycnt is its Y ceneter of symmetry
%Ierea is the area of the vessel marked in one in binary image the scanning will be done only within this images
%Paper Table entries 9
 
Ss=size(Iel);
      
              IelOut=dilate(Iel,Resl).*Ierea;%dilate ellipse  in resl and keep the parts that dont exceed image
              FilledSurf=imfill(Iel,4,'holes'); % the filled ellipse
              IelIn=FilledSurf.*dilate(Iel,Resl-1);%.*Ielout%binary image the inner part of the ellipse 
              IelOut=IelOut-FilledSurf.*IelOut;%-IelIn;%binary image of the outer part of the ellipse
%========================scan the upper part of the ellipse================================================================================================================================
  IelInUp= IelIn;
  IelOutUp=IelOut;
  
  IelInUp(Ycnt+1:Ss(1),:)=0;% zero out everything above Ycnt keep lower ellipse parabola
  IelOutUp(Ycnt+1:Ss(1),:)=0;% zero out everything above Ycnt keep lower ellipse parabola
  Si=sum(sum(IelInUp));%sum of pixel in inner ellipse part
  So=sum(sum(IelOutUp));%sum of pixel in lower ellipse part
 ScoreUp=abs(sum(sum(double(Ir).*double(IelInUp)))/Si-sum(sum(double(Ir).*double(IelOutUp)))/So); %  caclulate the difference between the average intsnisty above and below surface curve

 ScoreUp=ScoreUp/(sum(sum(double(Ir).*double(IelInUp+IelOutUp)))/(Si+So)); %normalize score by average intensity
 %=======================================calculate score of lower ellipse parts========================================================================================================
IelInDn= IelIn;
  IelOutDn=IelOut;
  
  IelInDn(1:Ycnt-1,:)=0;% zero out everything below Ycnt keep upper ellipse parabola
  IelOutDn(1:Ycnt-1,:)=0;% zero out everything below Ycnt keep upper ellipse parabola
  Si=sum(sum(IelInDn));%sum of pixel in inner ellipse part
  So=sum(sum(IelOutDn));%sum of pixel in lower ellipse part
 ScoreDn=abs(sum(sum(double(Ir).*double(IelInDn)))/Si-sum(sum(double(Ir).*double(IelOutDn)))/So); % score of the lower parabola of surface by difference  between intsnity  above and below surface
 
 ScoreDn=ScoreDn/(sum(sum(double(Ir).*double(IelInDn+IelOutDn)))/(Si+So)); %normalize score by average intensity


 %======================================Get Best Score==================================================================================
 
 Score=max( ScoreUp,ScoreDn);% the final score is the best score of the upper and lower ellipse
 
end
 %{
%Description
%for better description see paper
Similar to method 2 only without the consistency check. Use mask/kernel to Take the difference between the average intensity on and directly below the borer and substract it  form the average intensity directly  above the border (divide  by the  mean intensity in this two areas combined).The absolute value of the result is the score This have some speed advantage since its allow the use of mask (consistency check slow the system by demanding pixel by pixel change.)
Algorithm
For upper ellipse parabola
1)create mask corresponding to the prrpused surface  and point below the surface dilated n-1 times (N usually 1). 
Crosscorrelate this mask with the image  and divide by the  number pixels  to get the average intensity below/on the border line.
2)	Create  mask of all pixels directly above  border line in radious N cross correlate it with the image nd divide by the number of image  in the mask  to get  the average intensity directly above the border in resolution N. 
Substract the average intensity  directly above the border from those directly below  the border and divide by the mean of this two  to get the relative difference take  the absolute value as the score.
For lower ellipse parabola
1)create mask corresponding to the prrpused surface  and point above the surface dilated n-1 times (N usually 1). 
2) Crosscorrelate this mask with the image  and divide by the  number pixels  to get the average intensity above/on the border line.
1)	Create  mask of all pixels directly above  below line in radious N cross correlate it with the image nd divide by the number of image  in the mask  to get  the average intensity directly below the border in resolution N. 
Substract the average intensity  directly above the border from those directly below  the border and divide by the mean of this two  to get the relative difference

%}


