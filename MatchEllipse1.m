function [ Score] = MatchEllipse1(Ir,Iellipse,Resly,Ycnt,Ierea)   
%Given an image binary border mage of ellipse or line (Iellipse) and
%monochrome image Ir of the same size, check if the match of Iellipse as
%phase seperation surface of liquid in Ir
%=======================================working mode===========================================================================
%for every pixel take the difference of intensity above and below/on the border in absolute value
%point divided by the maximum intensity of the two avs(up-down)/max(up,down). Sum the this difference  for every border point  and divde by number of border pixels and use as border. 

%for every pixel take the difference of intensity above and below/on the border
%point divided by the maximum intensity of the two (up-down)/max(up,down). Sum the this values (not absulte)  for every point  take the absolute divde by number of border pixels and use as border. 

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
%Paper entries 1,2,22,25-28-35
%Hightd_To_Width_Ellipse_Ratio=0.3; recomanded value

Reslx=1;% resolution of scan around point int the x axis
[y,x]=find(Iellipse>0);%find all points in the border
Ifilled=imfill(Iellipse,4);%filled ellipse
Score=double(0);

sumpix=double(0);%number of use border points
nposdif=double(0);%number of points where the intensity decrease with hight
 nnegdif=double(0); 
  thresh=1.1;
  minfractgrad=0.85;%0.85;%for consistency check
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
        %.......................add intensities to above and below intensity  sums or their difference to score...............................................................................................
        if npixup>0 &&   npixdn>0 % the average itnensity above and below borders
           up=double(up)/double(npixup);% average intenisty above and below point
           dn=double(dn)/double(npixdn);% average intenisty above and below point
           sumpix=sumpix+1; 
            Score=double(Score)+(double(up)-double(dn))/double(max(max([up dn]), 1));% the score is the sum of difference in every point along the border

           if double(up/dn)>=thresh % does intensity higher above the border?
               nposdif=nposdif+1;% thefraction of points inwhich the differrential is from up to down
              
           elseif double(dn/up)>=thresh
               nnegdif=nnegdif+1;% thefraction of points inwhich the differrential is from up to down
           end;
        end;
     %........................................................................................................................................   
        
    end
end
%=======================================calculate score of lower ellipse parts========================================================================================================

 %---------------------check the  score of the upper part of the ellipse--------------------------------------------------------
 fractup=max(nposdif/sumpix,nnegdif/sumpix); % check the consistency of the differential  direction along the border 0.5 is completely random 
 if sumpix>15 && fractup>minfractgrad%check if enough points were used to make reliable prediction and if so normalize the score according to the number of points used
     Score1=double(abs(double(Score)/double(sumpix)));%/sumpix;
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
             Score=double(Score)+(double(up)-double(dn))/double(max(max([up dn]), 1));% the score is the sum of difference in every point along the border    end

           if double(up/dn)>=thresh % does intensity higher above the border?
               nposdif=nposdif+1;% thefraction of points inwhich the differrential is from up to down
           elseif double(dn/up)>=thresh
               nnegdif=nnegdif+1;% thefraction of points inwhich the differrential is from up to down
           end;
        
        end;
        
        
    end;
end;

 %======================================check the score of the lower ellipse==================================================================================
  fractup=max(nposdif/sumpix,nnegdif/sumpix); % check the consistency of the differential  direction along the border 0.5 is completely random 
 if sumpix>15 && fractup>minfractgrad%check if enough points were used to make reliable prediction and if so normalize the score according to the number of points used
      Score=double(abs(double(Score)/double(sumpix)));% the score is the sum of difference in every point along the border
 else
     Score=0;% not enough points to make reliable prediction ignore this border
 end
 Score=max(Score1,Score);% the final score is the best score of the upper and lower ellipse
 
end
 


%{

 See paper for better description
 Basically take the change in intensity across the  surface, in every surface point divided by average intensity around this point. And take the average for all surface points.
Algorithm
2)	Matchellipse1
a) For each pixel(B(I,j))   on the propused border line scan the intensity of all pixels in the direct environment   ( all pixels in range  from x=i-1 to x=i+1  and for y=j-1 to y=j  around border point  B(I,j)). Which mean all direct neighbours of the pixel (9 way connection) including the pixel itself. If scanning the upper parabola of the surface  ellipse then only pixels  in vicinity of (B(i,j))  in  line of the pixel or above y=(j,j-1 x=i-1,I,i+1) are examine. For the lower part of the llipse (bottom parabola) scan only pixels in this range in the line of the pixel or below   y=(j+1,j x=i-1,I,i+1)
A) Alternative less good don’t use For each point P(n) on the suggested surface line the intensity of all the points  inside a square of  2r+1X2r+1 pixels center around  the point P   are examined (if some of this pixels are out side the vessel or image contour ignore this point) Less good
b) For the surface upper part the  average intensity of all pixels in the pixel area  above surface are subtracted from the average intensity of all pixel in this square on the surface line or below (not in absolute value).  (For the lower part the elllipse take average  intensity of all pixel in this area on the border line and above as up intensity and average intensity of all pixels below the border line in this area ).
The sum of thes values (that can be negative) for   is divided by the average intensity of all pixels in the area S(n)=(Up(n)-Dn(n))/Av(n). 
d) The sum of this value for all points on the proposed surface line is divide by the number of pixels in the propused surface  and taken in absolute values as  the score.
e) consistency check is made on the surface gradient and if failed the score is set to zero.

 % second description
 Algorithm
1)	Matchellipse1
a) For each pixel(B(I,j))   on the propused border line scan the intensity of all pixels in the direct environment   ( all pixels in range  from x=i-1 to x=i+1  and for y=j-R to y=j+R-1)  around border point  B(I,j), where R is the scanning width resolution in the Y axis). Which mean all direct neighbours of the pixel (2R*3 way connection) including the pixel itself. If scanning the upper parabola of the surface  ellipse then only pixels  in vicinity of (B(i,j))  in  line of the pixel or above y=(j+R-1,j-R x=i-1,I,i+1) are examine. For the lower part of the llipse (bottom parabola) scan only pixels in this range in the line of the pixel or below   y=(j+R-1,j =j-R), x=i-1,I,i+1)
b) For the surface upper part the  average intensity of all pixels in the pixel area  above surface are subtracted from the average intensity of all pixel in this square on the surface line or below (not in absolute value).  (For the lower part the elllipse take average  intensity of all pixel in this area on the border line and above as up intensity and average intensity of all pixels below the border line in this area ).
The sum of thes values (that can be negative) for   is divided by the average intensity of all pixels in the area S(n)=(Up(n)-Dn(n))/Av(n). 
d) The sum of this value for all points on the proposed surface line is divide by the number of pixels in the propused surface  and taken in absolute values as  the score.
e) consistency check is made on the surface gradient and if failed the score is set to zero.


 %}
