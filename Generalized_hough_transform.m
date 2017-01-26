function [score,  y, x ] = Generalized_hough_transform(Is,Itm,thresh )
%Use generalized hough transform to find Template image Itm in the canny edge image of system image Is 
%Is is grey  picture Itm is bool edge image of the vessel
%Return the location of the maximum point in y and x as well as all point
%which score above thresh fraction of the maximum point ( were thresh is between 0 and 1)
%Also return the score of each point found
if (nargin<3)
thresh=0.99;%
end;

%--------------------------create vessel system and system edge images------------------------------------------------------------------------------------------------------------------------
%clear all;
%close all;
%imtool close all;
%Itm=imread('C:\Users\mithycow\Documents\MATLAB\symmetry_score x sqrt(ysize).tif'); % vessel contour image
%imtool(Itm);
%Is=imread('C:\Users\mithycow\Documents\MATLAB\symmetry_score x sqrt(ysize).tif');
%Iedg=Is;% temperary for checking only
%
%Is=imread('C:\Users\mithycow\Desktop\trial pictures glassware\edited\moor cut\DSC_0016.jpg'); % system image
%Is=rgb2gray(Is);
highthresh=0.12;
Iedg=edge(Is,'canny',[highthresh/3,highthresh],1.1); % system edge images
%}
%--------------------------------------------------------------------------------------------------------------------------------------
[y x]=find(Itm>0); % find all points on vessel template
nvs=size(x);% number of points in the vessel template
%-------------------find center of mass----------------------------------------------
Cy=1;%round(mean(y));% find object y center, note that any reference point will do so the origin of axis hence 1 could be used just as well
Cx=1;%round(mean(x));% find object z center, note that any reference point will do so the origin of axis hence 1 could be used just as well
%---------------------------------------------------------------------------------
Idir=gradient_direction(Itm); % create gradient map of object distrobotion between zero to pie
%imtool(Idir);
%---------------------------create vessel contour descriptor array------------------------------------
MaxAngelsBins=30;% devide the angel space to MaxAngelsBins uniformed space bins
MaxPointsPerangel=nvs(1);% maximal amount of points corresponding to specific angel

pc=zeros(MaxAngelsBins);% counter for the amount of edge points associate with each angel gradient
r=zeros(MaxAngelsBins,MaxPointsPerangel,2); % assume maximum of 100 points per angle with MaxAngelsBins angles bins between zero and pi and x,y for the vector to the center of each point
% the third adimension are vector from the point to the center of the vessel

%------------------fill the  angel bins with points---------------------------------------------------------
for f=1:1:nvs(1)
    bin=round((Idir(y(f), x(f))/pi)*(MaxAngelsBins-1))+1; % transform from continues gradient angles to discrete angle bins and 
    pc(bin)=pc(bin)+1;% add one to the number of points in the bin
    if (pc(bin)>MaxPointsPerangel)
        disp('exceed max bin in hugh transform');
    end;
    r(bin, pc(bin),1)= Cy-y(f);% add the vector from the point to the object center to the bin
    r(bin, pc(bin),2)= Cx-x(f);% add the vector from the point to the object center to the bin
end;
%plot(pc);
%pause;
%=======================================================================================================================================================================
%------------------------create and populate hough space-----use the array in previous image to identify the template in the system image----------------------------------------
[y x]=find(Iedg>0); % find all edg point in the system----------------------------------------------------
np=size(x);% find number of edge points in the system
Idir=gradient_direction(Is); % create gradient direction  map of the system
Ss=size(Is); % Size of the system image
houghspace=zeros(size(Is));% the hiugh space assume to be in size of the image but it should probably be smaller
    for f=1:1:np(1)
          bin=round((Idir(y(f), x(f))/pi)*(MaxAngelsBins-1))+1; % transform from continues gradient angles to discrete angle bins and 

          for fb=1:1:pc(bin)
              ty=r(bin, fb,1)+ y(f);
              tx=r(bin, fb,2)+ x(f);
               if (ty>0) && (ty<Ss(1)) && (tx>0) && (tx<Ss(2))  
                   houghspace(r(bin, fb,1)+ y(f), r(bin, fb,2)+ x(f))=  houghspace(r(bin, fb,1)+ y(f), r(bin, fb,2)+ x(f))+1; % add point in were the center of the image should be according to the pixel gradient
               end;        
          end;
    end;
%--------------------------------------------find best match in hough space and matches above threshold----------------------------------------------------------------------------------------------------------
%{
imtool(houghspace);
imshow(houghspace,[]);
colormap jet
colorbar
pause
%}

%---------------------------------------------------------------------------normalized according to template size (fraction of the template points that was found)------------------------------------------------------------------------------------------------
Itr=houghspace./sqrt(sum(sum(Itm))); % Itr become the new score matrix
%---------------------------------------------------------------------------find  the location best score all scores which are close enough to the best score
%imtool(Itr,[]);
mx=max(max(Itr));% find the max score location
%best_loc=find(Itr==mx);

%[ xy(1),xy(2)]
[y,x]=find(Itr>=thresh*mx,  10, 'first'); % find the location first 10 best matches which their score is at least thresh percents of the maximal score and pot them in the x,y array
%xy= [y x];

score=Itr(y,x); % find score for all cordinates might fail if so use the loop below
%{
score=zeros(size(y));
ss=size(Itm);

 
for i=1:1:size(y)% find the score of the best matches found (parallel to  y,x array
   %score(i)=Itr(xy(i,1),xy(i,2));
   score(i)=Itr(y(i),x(i));
  
end;
%}
%-------------------------------------mark the best result on the system image---------------------------------------------------------------------------
 k =find2(Itm,1);
 
  %mrk=set2(Is,k,0,round(y(1)-ss(1)/2),round(x(1)-ss(2)/2));
mrk=set2(Is,k,0,y(1),x(1));
    %figure, 
  % imtool(mrk);
%pause();
end

