function [ Score] = MatchEllipse(Ir,Iellipse,Resly,Ycnt,mode,Ierea)   
%Given an image binary border mage of ellipse or line (Iellipse) and
%monochrome image Ir of the same size, check if Borders of Iellipse
%=======================================working mode===========================================================================
% basically take the sum of the pixels above the  boundary and substract it
% from the sum of pixels intensity below the boundary
% Check if there clear liquid border there  or surface along Iellipsse which is either ellipse o line . This is done by
% checking the difference/in color in the two side of the potential border Iellipse
% line/ellipse the difference can be done point by point allong the line (mode='difference_point')or
% substracting the sum of intensity above the line from that below the line (mode='difference_sums')
%the Resly is the the resolution  which the scanning will be done, the range iny waround each where the average will be made. 
%Hence  number of lines above and below the seperation line in which the differential will be taken
%The border or surface Iellipse must look like either straight horizontal line or
%orizonatal ellipse of sum hight that start from one edge of the line and
%end in the other in the same Y axis the line edges found by Iborder  (assuming the vessel is cylindrical the liquid surface
%must be orizontal ellipse or line). 
%Ierea is the area of the vessel marked in one in binary image the scanning will be done only within this images
Reslx=Resly;% resolution of scan around point int the x axis
[y,x]=find(Iellipse>0);%find all points in the border
Ifilled=imfill(Iellipse,4);%filled ellipse
Score=double(0);
Scoreup=double(0);%sum of intensity above border
Scoredn=double(0);% sum of intensities below borders
sumpix=double(0);%number of ignored points
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
        else % if there no pixels above or below ignore this point
            up=double(0);
            dn=double(0);
           
        end;
        
        if strcmp(mode,'difference_sums')% the score is the difference between sum of intensities above and below border the border were the sums performed are for the entire border 
            Scoreup=double(Scoreup)+double(up);
             Scoredn=double(Scoredn) +double(dn);
        else
            Score=double(Score)+abs(double(up)-double(dn));% the score is the sum of difference in every point along the border
        end
    end
end
%=======================================calculate score of lower ellipse parts========================================================================================================
 if strcmp(mode,'difference_sums');
     Score=double(abs(double(Scoreup)-double(Scoredn)))/double(mean([Scoreup Scoredn])); % find score as diffrence in sum of intensiies above and below border normalized according to sum of intensies
     Scoreup=double(0);
     Scoredn=double(0);
 end;
 %---------------------check the  score of the upper part of the ellipse--------------------------------------------------------
  if sumpix>15%check if enough points were used to make reliable prediction and if so normalize the score according to the number of points used
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
        else % if there no pixels above or below ignore this point
            up=double(0);
            dn=double(0);
           
        end;
        
        if strcmp(mode,'difference_sums')% the score is the difference between sum of intensities above and below border the border were the sums performed are for the entire border 
            Scoreup=double(Scoreup)+double(up);
             Scoredn=double(Scoredn)+double(dn);
        else
            Score=double(Score)+abs(double(up)-double(dn));% the score is the sum of difference in every point along the border
        end
    end
end

%===============================================================================================================================================
 if strcmp(mode,'difference_sums');
       Score=double(abs(double(Scoreup)-double(Scoredn))/mean([Scoreup Scoredn])); % find score as diffrence in sum of intensiies above and below border normalized according to sum of intensies

 end;
 %======================================check the score of the lower ellipse==================================================================================
 if sumpix>15%check if enough points were used to make reliable prediction and if so normalize the score according to the number of points used
     Score=double(Score);%/sumpix;
 else
     Score=0;% not enough points to make reliable prediction ignore this border
 end
 Score=max(Score1,Score);% the final score is the best score of the upper and lower ellipse
 
 end


