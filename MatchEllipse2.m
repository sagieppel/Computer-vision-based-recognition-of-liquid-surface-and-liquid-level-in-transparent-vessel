function [ Score] = MatchEllipse2(Ir,Iellipse,Resly,Ycnt,Ierea)   
%Given an image binary border mage of ellipse or line (Iellipse) and
%monochrome image Ir of the same size, check if the match of Iellipse as
%phase seperation surface of liquid in Ir
%=======================================working mode===========================================================================
% basically take the sum of the pixels above the  boundary and substract it
% from the sum of pixels intensity below and on the boundary normalized by mean intensity
%
% Check if there clear liquid border there  or surface along Iellipsse which is either ellipse o line . This is done by
% checking the difference/in color in the two side of the potential border Iellipse 
%for every pint on the border check the average intesnsity above the  border (in some radious around the point (usually one))  and below the border 
%sum the average intsnity above the border and below the border  the  their difference  divided by the average intensity  of
%the border is the score.
% Another filter is that the direction of the intensity gradient and normazlize gradient size must be consistent minfractgrad percent of the cases and pass threshold thresh (hence the intensity in on side of the border must be higher in at least thresh for  at least minfractgrad of the cases);
% if the border is ellipse divide symmterically to two parabolas (top and
% bottum) check each seperately and peak the maximum

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
%Paper Table entries 23-4

Reslx=1;% resolution of scan around point int the x axis
[y,x]=find(Iellipse>0);%find all points in the border
Ifilled=imfill(Iellipse,4);%filled ellipse
Score=double(0);
Scoreup=double(0);%sum of intensity above border
Scoredn=double(0);% sum of intensities below borders
sumpix=double(0);%number of ignored points
nposdif=double(0);%number of points where the intensity decrease with hight
 nnegdif=double(0); 
  thresh=1.1;
  minfractgrad=0.85; fraction for consitency check
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
                    end
                %end
                else %optional if one pixel outside is  out of frame  ignore the entire point
                    up=0; dn=0; sy=y(f)+Resly+1;sx=x(f)+Reslx+1;npixup=0; npixdn=0;
                end;
             end
        end
        %.......................add intensities to above and below intensity  sums or their difference to score...............................................................................................
        if npixup>0 &&   npixdn>0 % the average itnensity above and below borders
           up=double(up)/double(npixup);
           dn=double(dn)/double(npixdn);
           sumpix=sumpix+1; 
           if double(up/dn)>thresh % does intensity higher above the border?
               nposdif=nposdif+1;% thefraction of points inwhich the differrential is from up to down
           elseif double(dn/up)>thresh
               nnegdif=nnegdif+1;% thefraction of points inwhich the differrential is from up to down
           end;
        else % if there no pixels above or below ignore this point
            up=double(0);
            dn=double(0); 
        end;
        
   % the score is the difference between sum of intensities above and below border the border were the sums performed are for the entire border 
            Scoreup=double(Scoreup)+double(up);
             Scoredn=double(Scoredn) +double(dn);
        
    end
end
%=======================================calculate score of lower ellipse parts========================================================================================================
 
     Score=double(abs(double(Scoreup)-double(Scoredn)))/max(double(mean([Scoreup Scoredn])),1); % find score as diffrence in sum of intensiies above and below border normalized according to sum of intensies
     Scoreup=double(0);
     Scoredn=double(0);

 %---------------------check the  score of the upper part of the ellipse--------------------------------------------------------
 fractup=max(nposdif/sumpix,nnegdif/sumpix); % check the consistency of the differential  direction along the border 0.5 is completely random 
 if sumpix>12 && fractup>minfractgrad%check if enough points were used to make reliable prediction and if so normalize the score according to the number of points used
     Score1=double(Score);%/sumpix;
  else Score1=0;
  end;
Score=0;%restart score for lower part of ellipse
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
        if npixup>0 &&   npixdn>0 % the average itnensity above and below borders
           up=double(up)/double(npixup);
           dn=double(dn)/double(npixdn);
           sumpix=sumpix+1;%deleting this line give advantage to ellipse surface over line surface   
           if double(up/dn)>thresh % does intensity higher above the border?
               nposdif=nposdif+1;% thefraction of points inwhich the differrential is from up to down
           elseif double(dn/up)>thresh
               nnegdif=nnegdif+1;% thefraction of points inwhich the differrential is from up to down
           end;
        else % if there no pixels above or below ignore this point
            up=double(0);
            dn=double(0);
           
        end;
        
        % the score is the difference between sum of intensities above and below border the border were the sums performed are for the entire border 
            Scoreup=double(Scoreup)+double(up);
             Scoredn=double(Scoredn)+double(dn);
       
    end
end

%===============================================================================================================================================

       Score=double(abs(double(Scoreup)-double(Scoredn)))/max(double(mean([Scoreup Scoredn])),1); % find score as diffrence in sum of intensiies above and below border normalized according to sum of intensies

 %======================================check the score of the lower ellipse==================================================================================
  fractup=max(nposdif/sumpix,nnegdif/sumpix); % check the consistency of the differential  direction along the border 0.5 is completely random 
 if sumpix>12 && fractup>minfractgrad%check if enough points were used to make reliable prediction and if so normalize the score according to the number of points used
     Score=double(Score);%/sumpix;
 else
     Score=0;% not enough points to make reliable prediction ignore this border
 end
 Score=max(Score1,Score);% the final score is the best score of the upper and lower ellipse
 
end
 
%{
See paper for better description
1)	Matchellipse2,13,4
A) For each point P(n) on the suggested surface line the intensity of all the points  inside a square of  2r+1X2r+1 pixels center around  the point P   are examined
b) the  average intensity of all pixels in this square above surface is divided by  intensity of all pixels in the square below the surface(Up(n)/Dn(n)) if this value pass 1.1 then UpGradient counter is increase by one, else if the value (Up(n)/Dn(n)) smaller then (1/(1.1)) then the DownGradient counter increase by one. This is done for all point on the surface line. If 85% or mord of the surface point have down gradient (DownGradientCounter/NumSurfacePoint>=85%) or 85% or more of the surface point have up gradient  UpGradientCounter/NumSurfacePoint>=85% then the surface is accepted and is score is determined by the appropriate function. Else the surface is ignored and it�s score set for zero.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sceond description

Method 2:Match ellipse 2 taking the difference average  of intensity directly above the propuse surface line and the intensity on and directly below the surface, this difference is divided  by the average intensity of pixels in this two regions. And taken in absulote values as the score. The difference between this and method 1. Is that in this case the total intensity difference are used and not relative intesities (Hence this case is the relative differance of the average intensities above and below the surface while method 1 was the was the average of relative intensities difference along each point (difference of some vs some of difference) hence part of the  with high intensity are much more dominant in determination of the score than part of low intensity. (while in the first method all region of the border line contributed equally). 
Again consistency check is made  remove noise improve result.
(note that this and method 1-4 take into consideration the gradient by taken the change of intensity perpentigular to the surface line)
Algorithm  Matchellipse2 


A) For each point P(n) on the suggested surface line the intensity of all the points  inside a square of  2r+1X2r+1 pixels center around  the point P   are examined. When examining the upper parabola  examine only pixels in the line of P or above. When examine the lower parabola take only pixel in the line of P or below.

b) For the upper parabola ellipse line the  average intensity of all pixels in this square above surface are add to the sum of all intensities above the border  SumIup=SumIup+Iup(p). Also the average intensities 
of pixels in this squar that lies on or below the  surface are is added to the sum of intensities below and on  the surface SumIdn=SumIdn+Idn(p).
(For the lower Parabola  of the surface ellipse line take the average intensity of all pixels on the surface or above as upper side intensity, and intensity of all pixel in area below the surface is taken as the down verage intensity).
c) The difference between  the sum of intensities above the surface and below and on the surface is take and the result is divided by the average intensity in the area of the surface. Score=2abs(SumIdn-SumIup)/(SumIdn+sumIup)
 
e) cons2stency check is made on the surface gradient and if failed the score is set to zero.

%}

%



