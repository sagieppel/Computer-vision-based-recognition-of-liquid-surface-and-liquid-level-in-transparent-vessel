function [ Score] = MatchEllipse10(Is,Iel,~,Ycnt,~)   
%Given an image binary border mage of ellipse or line (Iellipse) and
%monochrome image Ir of the same size, check if the match of Iellipse as
%phase seperation surface of liquid in Ir
%=======================================working mode===========================================================================
%Take the edge image (sobel ) of Is and gradient direction  map of both Is
%and and Iel the correlation between both the gradient direction and the
%Iel and gradient siza is the score
%Iel and combine  and use the 
%given two bnary Is Ir images of the same dimension give the score of the cross
%correlation  including angles cross correlation  return matching score
% if the border is ellipse cut it to upper and lower ellipse and use each
% seperately as border and peak the one with best score
% Ycnt Y center of Iel (Iel is symetrical in both x and y Ycnt is its Y ceneter of symmetry

dIs=gradient_direction(Is);% gradient dirction map in each point halfcrcle between 1 and pie 
dIt=gradient_direction(Iel);% gradient dirction map in each pointhalf circle  between 1 and pie    


   Is= gradient_size( Is );
 
     
      Is=double(Is/max(max(Is)));% normalize accorrding to the values in the picture so the value cnt be more then one
      

        
Ss=size(Iel);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scan upper part of ellipse POINT BY POINT and  get it's score %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IelUp=Iel;
IelUp(Ycnt+1:Ss(1),:)=0;

p=find(IelUp~=0);% find all point on Iel
ScoreUp=0;
   for f=1:length(p)%

 
       %for sobel mod
   
            ScoreUp=ScoreUp+IelUp(p(f))*Is(p(f))*(1-2*abs(mod((dIs(p(f))-dIt(p(f)))/pi(),0.5)));% the score value of x,y point  is increase or decrease according to how close the value of the gradient direction and image of this point the gradient difference could be between zero in which the value increase by 1 and 2pi in which the value decrease by one
    
    end;
    ScoreUp=ScoreUp/sum(sum(IelUp));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scan upper part of ellipse POINT BY POINT and  get it's score %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IelDn=Iel;
IelDn(1:Ycnt-1,:)=0;

p=find(IelDn~=0);% find all point on Iel
ScoreDn=0;
   for f=1:length(p)%

 
       %for sobel mod
   
            ScoreDn=ScoreDn+IelDn(p(f))*Is(p(f))*(1-2*abs(mod((dIs(p(f))-dIt(p(f)))/pi(),0.5)));% the score value of x,y point  is increase or decrease according to how close the value of the gradient direction and image of this point the gradient difference could be between zero in which the value increase by 1 and 2pi in which the value decrease by one
  % score=score+abs(cos((dIs(p(f))-dIt(p(f)))));% the score value of x,y point  is increase or decrease according to how close the value of the gradient direction and image of this point the gradient difference could be between zero in which the value increase by 1 and 2pi in which the value decrease by one
   
    end;
    ScoreDn=ScoreDn/sum(sum(IelUp));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Score=max(ScoreDn,ScoreUp);
    
        
   
end


%{
%Description 
(not very good see paper for better description)
Method 9,10 (canny sobel with gradient)
%Take the edge image (canny) of Is and gradient direction  map of both Is
%and and Iel the correlation between both the gradient direction and the
%Iel and canny is the score
%Iel and combine  and use the 

Examine not only the edge intensity along the border but also its direction (methods 1-4 already take into consideration the gradient direction by taken the change across the border) this method correlate the propused border line  with both the border intensity (either  binary canny or absolute gradient size) but also use the  correlation between the gradient direction in the proused surface and on the image. The result are better then those of the method how just examine the crosss correlation with the image but worst then method 1-2 how axamine averageintensity change along the border). 
Generally combine the cross correlation between intensities and the match between gradient lines the difference between gradient lines direction is between 0 (complete match) and pi/2 ( the largest angle between lines on planes 
Algorithm
Matchellipse 9-10
a)	The  gradient direction map is taken for both the propused border (binary image) and for the examined image ( the  gradient is limited to 0-1Pi  by ignoring the plus minus direction and taken only the gradient line). 
b)	The edge image  of the image system is taken as either binary canny or absolute gradient size (uint). 
c)	For each border pixel examine the correlation with the image  according to the formula:
d)	C) p(f))*Is(p(f))*abs(cos((dIs(p(f))-dIt(p(f)))( vector multiplications of gradient)(by far best method)
e)	Which to say abs(Img*Iellips*cos(angle-differrence))
Img Iellipse are the intensities of The ellipse image and system image in the surface point whileangle-difference is the angle difference between the gradient line of this tow points *that can be between 0-pi/4
Not that the ange difference is limted to pi/2 since this is the largest angle that can occur between two lines, and  that if the angles is bigger then 1/4Pi the score is negative. 
f)	The average socre for all pixels on the border is taken as the score (no absolute value use and the score can be negative). Two alterantives that were check are 
a) PixelIntensity*(1-2*abs(mod(BorderGradientDirection-Image_Gradient_direction)/pi(),0.5)));%*
not very good
b) ScoreDn=ScoreDn+IelDn(p(f))*Is(p(f))*(1-1*abs(mod((dIs(p(f))-dIt(p(f)))/pi(),0.5))); (same as a but value that cant be negative)
C) p(f))*Is(p(f))*abs(cos((dIs(p(f))-dIt(p(f)))( vector multiplications of gradient)(by far best method)



%}



