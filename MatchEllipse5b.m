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
 %Paper Table entries 29,8
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

 ScoreUp=ScoreUp/max((sum(sum(double(Ir).*double(IelInUp)))/Si),sum(sum(double(Ir).*double(IelOutUp)))/So); %normalize score by average intensity
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


