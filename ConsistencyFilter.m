function [ Score] = ConsistencyFilter(Ir,Iellipse,Resly,Ycnt,Ierea,Fract, Thresh)   
%{
This check the consistency of the relative intensity change normal to the curve Iellipse in image Ir (mostly grayscale image). 
The function return 1 if more than Fract percent of the curve point show relative intensity change that pass Thresh value to the same direction (with the same sign). 
The rest of the parameters are the same as in MatchEllipse.
See section 4.4.1 of the paper.
%}
%Given an image binary border mage of ellipse or line (Iellipse) and
%monochrome image Ir of the same size, check if the prpuse border pass
%consistency criterion and return 1 if yes and zero if no
% this help get rid of bad surfaces
%NOTE THAT MATCHELLIPSE 1-4 have consistency check embedded in the function
%and dont use this Function (altough they use the consistency filter)
%=======================================working mode===========================================================================
%for every pixel take the difference of intensity above and below/on the border in absolute value
%point divided by the maximum intensity of the two
%avs(up-down)/max(up,down). check if ate least Fract border point pass value of Thresh
% return one if so and zero if not
%for every pixel take the difference of intensity above and below/on the border
%point divided by the maximum intensity of the two (up-down)/max(up,down).
%If more the Fract precent of the points pass value of Thresh return 1 els
%0
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

%Hightd_To_Width_Ellipse_Ratio=0.3; recomanded value
if (nargin<6) Fract=0.85;%change later
  if (nargin<7) Thresh=1.1; end;
Reslx=1;% resolution of scan around point int the x axis
[y,x]=find(Iellipse>0);%find all points in the border
Ifilled=imfill(Iellipse,4);%filled ellipse
Score=double(0);

sumpix=double(0);%number of use border points
nposdif=double(0);%number of points where the intensity decrease with hight
 nnegdif=double(0); 
 
  
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
          
           if double(up/dn)>=Thresh % does intensity higher above the border?
               nposdif=nposdif+1;% thefraction of points inwhich the differrential is from up to down
              
           elseif double(dn/up)>=Thresh
               nnegdif=nnegdif+1;% thefraction of points inwhich the differrential is from up to down
           end;
        end;
     %........................................................................................................................................   
        
    end
end
%=======================================calculate score of lower ellipse parts========================================================================================================

 %---------------------check the  score of the upper part of the ellipse--------------------------------------------------------
 fractup=max(nposdif/sumpix,nnegdif/sumpix); % check the consistency of the differential  direction along the border 0.5 is completely random 
 if sumpix>15 && fractup>Fract%check if enough points were used to make reliable prediction and if so normalize the score according to the number of points used
     Score=1;
 else 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%if consistecy check fail for upper ellipse part check lower ellipse part%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

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
           
           if double(up/dn)>=Thresh % does intensity higher above the border?
               nposdif=nposdif+1;% thefraction of points inwhich the differrential is from up to down
           elseif double(dn/up)>=Thresh
               nnegdif=nnegdif+1;% thefraction of points inwhich the differrential is from up to down
           end;
        
        end;
        
        
    end;
end;

 %======================================check the score of the lower ellipse==================================================================================
  fractup=max(nposdif/sumpix,nnegdif/sumpix); % check the consistency of the differential  direction along the border 0.5 is completely random 
 if sumpix>15 && fractup>Fract%check if enough points were used to make reliable prediction and if so normalize the score according to the number of points used
      Score=1;% passs consistency check
 end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
end
 
%{
% see paper for better description
Check That the direction of the intensity changes around the propused border is consistent in its direction this is unlike noise that can show sharp changes in intensity but not consistent manner. The check basically demand that the intensity change along the propused border will be for single direction form high to low or low to high for at least  85% of the surface points. And that the size of this change for each of these points  will be larger than  10% o (relative to the average intensity around this point). This check is not give Score but to act as another filter from removing bad potential surface line (even if they score is high) adding it can allow lower threshold in various of scoring methods described here. 
%}

