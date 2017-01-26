function [ Score] = MatchEllipse12(Ir,Iellipse,Resly,Ycnt,Ierea,Fract)   
%Given an image binary border mage of ellipse or line (Iellipse) and
%monochrome image Ir of the same size, check if the match of Iellipse as
%phase seperation surface of liquid in Ir
%=======================================working mode===========================================================================
%find the intensity difference along  each point in the border and find the value that Fract of  the
%border points are above it.

%for every pixel take the difference of intensity above and below/on the border
%point divided by the maximum intensity of the two (up-down).
%put in array IRatioArray.
%The score is Score=double(max([abs(IRatioArray(ceil((1-Fract)*sumpix))),abs(floor(Fract*sumpix))]))
%is the score in this point were sumpix are the number pixels examined in the curve.

% Fract: % The score is the  intensity difference that Fract (0<Fract<1) of the points have higher values.

%the Resly is the the resolution  which the scanning will be done, the range iny waround each where the average will be made. 
%Hence  number of lines above and below the seperation line in which the differential will be taken

% if the border is ellipse cut it to upper and lower ellipse and use each
% seperately as border and peak the one with best score


%the Resl is the the resolution  which the scanning will be done, which is basically the dilation of the upper and lower parts of the borders 
%Hence  number of lines above and below the seperation line in which the differential will be taken
%Ir monochrome image of the system 
%Iel Shape of the potential liquid surface  (horizontal line or ellipse in cylindrical vessel)
% Ycnt Y center of Iel (Iel is symetrical in both x and y Ycnt is its Y ceneter of symmetry
%Ierea is the area of the vessel marked in one in binary image the scanning will be done only within this images

%Hightd_To_Width_Ellipse_Ratio=0.3; recomanded value
  %Paper Table Entries 3
if (nargin<6) Fract=0.65; end;% The score is the  intensity difference that Fract (0<Fract<1) of the points have higher values.
Reslx=1;% resolution of scan around point int the x axis
[y,x]=find(Iellipse>0);%find all points in the border
Ifilled=imfill(Iellipse,4);%filled ellipse
ScoreUp=double(0); %score of upper ellipse curve

sumpix=double(0);%number used border points

 IRatioArray=double(ones(length(x),1)*10^5); % array of  intsnisty change across each border point
 
 

Ss=size(Ir);% size of image
%========================scan the upper part of the ellipse================================================================================================================================
for f=1:length(x)% scann all points on the ellipse contour but use only the upper part of th ellipse
    if y(f)>=Ycnt% upper half  of ellipse
        up=double(0); %value of the sum of intensities above the border line for specific border point
        dn=double(0); %value of the sum of intensities below the border line for specific border point
        npixup=double(0); %number of pixels sumed above border point
        npixdn=double(0);%number of pixels summed below border point
        %..........................................scan along cube or circle of radius resl(scan resultion) if below or touching or on the ellipse circle add the pixel inenstity to the dn intensity sum if above add to the up intensity sum the difference between this two will determine the strange of the border at this point............................................................................
        for sx=x(f)-Reslx:x(f)+Reslx
            for sy=y(f)-Resly+1:y(f)+Resly
                 %%
                if sy>0 && sy<=Ss(1) && sx>0 && sx<=Ss(2)&& Ierea(sy,sx)>0 %check that the scan is within image and vessel boundaries 
                %if sqr(sx-x(f))+sqr(sy-y(f))<Resl^2 %scan within a circle of radiuous Resl if this isnt apply then the program scan inside a box size (Resl*2)^2 pixels
                  
                    if sy<=Ycnt || Ifilled(sy,sx)>0 % if the point is within the ellipse below the center of the ellipse then it belong to lower part of the boundary
                      npixdn=npixdn+1;%counter for the number of pixels  sumed
                      dn=double(dn) +double(Ir(sy,sx));%sum intensity below border line
                    else % if the point is above the boundary add its intensity to the up sum
                      npixup=npixup+1;%counter for the number of pixels  sumed
                      up=double(up)+double(Ir(sy,sx));%%sum intensity above border line
                    end;
                %end
                else %optional if one pixel outside is  out of frame  ignore the entire point
                    up=0; dn=0; sy=y(f)+Resly+1;sx=x(f)+Reslx+1;npixup=0; npixdn=0;
                end;
             end
        end
        %.......................find  difference in score and add to the array...............................................................................................
        if npixup>0 &&   npixdn>0 % the average itnensity above and below borders
           up=double(up)/double(npixup);% average intenisty above and below point
           dn=double(dn)/double(npixdn);% average intenisty above and below point
           sumpix=sumpix+1; 
           
            IRatioArray(sumpix)=up-dn; % write   difference in intensity along this border point
  
        
        end;
     %........................................................................................................................................   
        
    end
end
%=======================================calculate score of lower ellipse parts========================================================================================================


 %---------------------check the  score of the upper part of the ellipse--------------------------------------------------------
  if sumpix>15 %check if enough points were used to make reliable prediction and if so normalize the score according to the number of points used
         IRatioArray = sort(IRatioArray);%Get the  difference that  Fract of the surface point are above it
         
         ScoreUp=max(-IRatioArray(round(Fract*sumpix)),IRatioArray(round((1-Fract)*sumpix)));
         
  end;
  %--------------------------------------------initialzize parameters for scanning lowe part of the ellipse-------------------------------------------------------------------------------------------------------------------------------------------
  
 IRatioArray=ones(length(x),1)*10^5; % array of  intsnisty change across each border point
ScoreDn=0;%restart score for lower part of ellipse
sumpix=0;%restart edge point count for lower part of ellipse
 %-------------------------------------------------------------------------------------
%========================scan the lower part of the ellipse================================================================================================================================
for f=1:length(x)% scann all points on the ellipse contour but use only the lower part of th ellipse
    if y(f)<=Ycnt% lower half  of ellipse
        up=double(0); %value of the sum of intensities above the border line for specific border point
        dn=double(0); %value of the sum of intensities below the border line for specific border point
        npixup=double(0); %number of pixels sumed above border point
        npixdn=double(0);%number of pixels summed below border point
        %..........................................scan along cube or circle of radius resl(scan resultion) if below or touching or on the ellipse circle add the pixel inenstity to the dn intensity sum if above add to the up intensity sum the difference between this two will determine the strange of the border at this point............................................................................
        for sx=x(f)-Reslx:x(f)+Reslx
            for sy=y(f)-Resly:y(f)+Resly-1
               if sy>0 && sy<=Ss(1) && sx>0 && sx<=Ss(2) && Ierea(sy,sx)>0 %check that the scan is within image and vessel boundaries 
                %if sqr(sx-x(f))+sqr(sy-y(f))<Resl^2 %scan within a circle of radiuous Resl if this isnt apply then the program scan inside a box size (Resl*2)^2 pixels
                    if sy>=Ycnt || Ifilled(sy,sx)>0 % if the point is within the ellipse above the center of the ellipse then it belong to upper part of the boundary
                        npixup=npixup+1;%counter for the number of pixels  sumed
                         up=double(up)+double(Ir(sy,sx));%%sum intensity above border line
                    else % if the point is below the boundary add its intensity to the dn sum              
                         npixdn=npixdn+1;%counter for the number of pixels  sumed
                        dn=double(dn)+double(Ir(sy,sx));%sum intensity below border line
                    end
                %end
                else %optional if one pixel outside is  out of frame  ignore the entire point
                    up=0; dn=0; sy=y(f)+Resly+1;sx=x(f)+Reslx+1;npixup=0; npixdn=0;
                end;
             end
        end
        %.......................add intensities to above and below intensity  sums or their difference to score...............................................................................................
          %.......................find  difference in score and add to the array...............................................................................................
        if npixup>0 &&   npixdn>0 % the average itnensity above and below borders
           up=double(up)/double(npixup);% average intenisty above and below point
           dn=double(dn)/double(npixdn);% average intenisty above and below point
           sumpix=sumpix+1; 
           
            IRatioArray(sumpix)=up-dn; % write   difference in intensity along this border point
  
        
        end;
     %........................................................................................................................................   
        
    end
end
%=======================================calculate score of lower ellipse parts========================================================================================================


 %---------------------check the  score of the upper part of the ellipse--------------------------------------------------------
  if sumpix>15 %check if enough points were used to make reliable prediction and if so normalize the score according to the number of points used
         IRatioArray = sort(IRatioArray);%Get the  difference that  Fract of the surface point are above it
         
         ScoreDn=max(-IRatioArray(round(Fract*sumpix)),IRatioArray(round((1-Fract)*sumpix)));
         
  end;
  %---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 Score=max(ScoreDn,ScoreUp);% the final score is the best score of the upper and lower ellipse
 
end
 %{
Description (Not very good see paper for better description
All approach examine so far were base on examine some property along each border point and taking the average of this property as score, the problem of this approach is that it does not examine the consistency of this property along the border only the average that can be determine base on relatively  few border point with strong score, for this reason a consistency filter need to be added to make this methods usefull. Alternative to the average  scoring one can use property like percentile or more accurate the score that fraction Fract of all border point have pass. This give less weight to some specific border points  with strong scores, and more to the consistency of the property along the border line. Two properties that were examine were relative change in inetesnity along border line and total change of intensity along border line. The fraction of points that need to pass the minimal score are given by Fract=0.5-0.8 (0.65 best)
Algorithm
1)	Matchellipse11-12
a) For each pixel(B(I,j))   on the propused border line scan the intensity of all pixels in the direct environment   ( all pixels in range  from x=i-1 to x=i+1  and for y=j-1 to y=j  around border point  B(I,j)). Which mean all direct neighbours of the pixel (9 way connection) including the pixel itself. If scanning the upper parabola of the surface  ellipse then only pixels  in vicinity of (B(i,j))  in  line of the pixel or above y=(j,j-1 x=i-1,I,i+1) are examine. For the lower part of the llipse (bottom parabola) scan only pixels in this range in the line of the pixel or below   y=(j+1,j x=i-1,I,i+1)
b) For the surface upper part the  average intensity of all pixels in the pixel area  above surface are subtracted from the average intensity of all pixel in this square on the surface line or below (not in absolute value).  (For the lower part the elllipse take average  intensity of all pixel in this area on the border line and above as up intensity and average intensity of all pixels below the border line in this area ).
The sum of thes values (that can be negative) for   is divided by the average intensity of all pixels in the area S(n)=(Up(n)-Dn(n))/Av(n) for method 11 and S(n)=(Up(n)-Dn(n)) for method 12. 
d)	Right Sn(n) value for all border point in the array  IRatioArray  and short in increase order.
The score is basically the value that fract  of the point are acor above it 
Hence if the re N border point in the line: Score= IRatioArray (1-Fn)
If the gradient change is in more consistentant in positive direction and   
Score= -IRatioArray (Fn) if the change  is in the negative direction.
In general :
Score=max(-IRatioArray(round(Fract*sumpix)),IRatioArray(round((1-Fract)*sumpix))
Were sumpix is the number of border point

%}


