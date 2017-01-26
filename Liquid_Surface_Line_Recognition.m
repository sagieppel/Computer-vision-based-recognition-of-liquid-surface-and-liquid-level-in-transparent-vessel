function Liquid_Surface_Line_Recognition(Is,Iborder,outname,Mode,MinRes,MinWidth,MinScore, Hightd_To_Width_Ellipse_Ratio,MinFractScore)
%{
The main liquid surfaces recognition function.
Given image Is of liquid in vessel (in color) and binary edge image Iborder in which pixels on the boundary of the vessel region in the image Is have value of 1.  
The function recognize the borders and surfaces of each liquid surface inside the vessel,   this in include the top and floor of the vessel (which are always recognise as surfaces). 
As output the function write the recognised liquid-surface/phase-boundaries marked in black on the original image Is. It save this image as tif image in directory and name given by text sting outname
Other than Is, Iborder, outname all parameters are optional and could be left blank.
This function algorithm is explained in section 2 of the paper.

Parameters
(See section 2.1 of the paper for this parameters)

 Is is the original image of the liquid container in color. 

Iborder is the edge image (binary image) of the liquid container contour in image Is. Pixels in Iborder corresponding to the boundaries of the of the vessel in image Is have value of 1, and the rest of the pixels have value of zero.
(Iborder can be created as the _BORDERS.tif output of the vessel extraction function MAIN_find_object_in_image and Exctract_object_from_background)

MinFractScore is the minimal threshold score for curve to be accepted as surface compared to the best score achieve by all curves in the scan. The threshold score for accepting curve as liquid surface will be [Threshold Score]= MinFractScore•[Best score for all curve scanned]. See section 2.3 in the paper for more details.

MinScore is the minimum curve score needed for curve in to be accepted as liquid surface (this can used as alternative or in addition to MinFractScore ) it could be set to zero if MinFractScore used. MinScore is basically the threshold score for accepting curve as liquid surface. All curves with score higher than MinScore will be accepted. See section 2.3 in the paper for more details.


MinWidth is the minimal width of image regions in the vessel that will be scanned (as fraction of the maximal width of the vessel) in the image.  Areas of the vessel narrower than MinWidth•[Maximal vessel width] pixels will not be scanned (see section 2.1 of paper).

Width_To_Hight_Ellipse_Ratio give the maximal height of the ellipse scanned compared to the width of that line/ellipse.  The larger this parameter the lower the maximum ellipse height will be in the scaned. Values between 0.2 to 0.4 are recommended, values of one is the maximal which mean all possible ellipse from line to circle will be scanned for Width_To_Hight_Ellipse_Ratio=1.

MinRes is the minimal resolution in which the scanning will be done. Hence  the number of lines  (in pixels) above and below the curve line that will be used for evaluating the curve score. Value of 1 for MinRes give best results for most cases.

outname is text string in which the directory and file name for the output image files are written. For example “C:\output\file1” will lead to output image C:\output\file1.tif.

Function description.
(See section 2 of paper).
General what this function do is scan line by line in the area of the image belong to the vessel (Areas in Is inside the contour of Iborder).
 For each line it generated various of elliptic curves that correspond to possible shape of liquid surface centred in this line.
The curves are compared to the image to find score for its correspondence to liquid surface in the image. 
 

The liquid surface must look like either straight horizontal line or horizontal ellipse in order to be recognised. The curves with scores that pass some threshold given by MinFractScore or MinScore are accepted and marked on the image, which is saved as TIF image in location given by outname.

%}

%-------------------------------------------------------------initialized various of optional parameters parameters-----------------------------------------------------------------------------------------------------
close all;
imtool close all;
%Is=imread('C:\Users\mithycow\Desktop\GLassWare LAB PICTURES\Liquid Phases\sample\IMG_3951.jpg');
%Iborder=imread('C:\Users\mithycow\Desktop\GLassWare LAB PICTURES\Liquid Phases\sample\IMG_3951_BORDERS.tif');
%outname='C:\Users\mithycow\Desktop\GLassWare LAB PICTURES\Liquid Phases\sample\IMG_3951'; 
if (nargin<4) mode='pig';%'difference_sums';end
if (nargin<5) MinRes=1; end   %resolution of up to two percent in the image
if (nargin<6) MinWidth=0.4; end;%minimal width to be checked as part of the maximum vessel width
if (nargin<7) MinScore=0; end;%MinScore=80  minimal number of points in the ellipse to be recognise (to avoid narrow areas been recognize to of ofte)
if (nargin<8) Hightd_To_Width_Ellipse_Ratio=0.3; end; %Maximun ratio for the ellipse hight to width in the scan.  values of betwen 0.2-0.4 are reasonable values. The closer the range the image was taken from the hight value should be. note that the hight of the ellipse is actually double
if (nargin<9) MinFractScore=0.4; end;  %ratio for the maximum score achived for all curve, to the minimum score that will be accepted
%-------------------------------------------------RESIZE IMAGE TO MATCH BORDER IMAGE SIZE AND TRANSFORM TO GREY SCALE (OR SPLIT TO TRGB CHANNELS

Ifilled=imfill(Iborder,4,'holes');%Create filled boundariy image of the vessel (all pixels in the area of the container in the image marked 1) 
Iinterior=Ifilled-Iborder; %Use only the interior
  % figure, imshow(Ifilled);
    Ss=size(Iborder);% Size of the binary edge image of the vessel
    Is=imresize(Is,[Ss(1) NaN]);% resize Is to the size of Iborder so the borders will  match the image
     Igr=rgb2gray(Is); % transform Is to greyscale (if Is is greyscale remove this part)
     Sg=size(Igr); % Fins the size of the liquid vessel image
     %..............................verify match between border image and system image sizes............................
    if (Sg(1)~=Ss(1) || Sg(2)~=Ss(2))% check if image proportions are correct
        disp('##############################error images sizes not proprtional################################################################################');
        Ss
        Sg
        
        Igr=imresize(Igr,size(Iborder));% resize to the liquid image to feet the size of Iboreder size
    %    pause;
        %Iborder=Iborder*0;
    end;
    %................................................................
 %   Is=GaussianBlur( Is,1.2 ,3 );
 %   figure, imshow(Is);
    
 Rchannel = Is(:,:,1);%seperate color image to red green and blue channels (monochromes imagea)
 Gchannel = Is(:,:,2);
 Bchannel = Is(:,:,3);
 Icanny=edge(Igr,'canny');%Create edge image of the liquid vessel image
Igradient= gradient_size( Igr );% Creae sobel gradient image of the liquid image
%figure, imshow(Gchannel);
%figure,  imshow(Bchannel);
%figure,  imshow(Rchannel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%inialized some paramters for the scan%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[y,x1,x2,np]=find_binary_contour_leftright_edges(Iborder);%find the right most x1 and left most x values of every line in the vessel (vessel edges) and the y value corresponding to this line pot them in x1 x2 and y arrays respeticely , the total number of line is put in np--------------------------------------------------------------------------------------------

MinWidth=MinWidth*(max(abs(x2-x1))-2);% find the min width of the vessel that will be checked, area in the vessel narrower then this will not be examined
indx=1;% index of phases that were found the first phase seperation is the top of the vessel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%MARK THE VESSEL TOP LINE AS FIRST surface (the top and bottum of the vessel will always be registtered as surfaces irregardless of theis score%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Py(indx)=y(1); Pscore(indx)=-1000;  Pnormscore(indx)=-1000;  Phight(indx)=0;Pindx(indx)=1;Px1(indx)=x1(1);Px2(indx)=x2(1);Py1(indx)=y(1);Py2(indx)=y(1);% writing the phase 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%trace phases %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ymin=y(1);
ymax=y(np);
TopScore=MinScore;%the highest curve score recieved so far
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%SCAN THE VESSEL LINE BY LINE AND Phase seperation lines/surfaces(Section 2.1 paper)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mzain loop go line after line in the vessel and  search for phases seperation lines/surfaces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for f=1:np% scan the vessel line by line (Section 2.1 of the paper)
  if (abs(x2(f)-x1(f))-2)>MinWidth % only parts of the vessel that pass minimal width  are  examined.  others ignored regions are ignored
   %-----------------------------------Generated ELLIPSE WITH VARIOUS OF HIGHTs-------------------------------------------------------------------------------------
    for fh=0:(x2(f)-x1(f))*(Hightd_To_Width_Ellipse_Ratio/2); %scan and match ellipse with various of hights  on the line each ellipse represent ptential phases seperation surface (ellipse with  hight of one is straight line). 
        %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$draw ellipse in line y(f) line with hight of fh*2 and edge point x1,x2(f)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         if y(f)-fh<1 || y(f)+fh>Ss(1)  continue;  end; % if ellipse exceed top bottum exceed vessel skip this loop (ignore the curve)
      [Iellipse,soel ] = ELLIPSE( x1(f),x2(f),y(f)+fh,y(f)-fh,0,0 ,size(Iborder)); % create ellipse in vessel with in the (y(f) line with hight of fh*2
             %..........................................CHECK IF...................................................................................    
             if sum(sum(logical(Iellipse).*~Ifilled))>0 continue; end%if the ellipse exceed the the boundary of the vessel ignore it 
            
          %.............................................CHECK MATCH BETWEEN ELLIPSE AND IMAGE AND GET MATCH SCORE (COULD BE DONE IN VARIOUS OF RESOLUTION and by various of funtions)-----------------------------------   
        %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 
          % Resultion is the the radious around the curve that will be examined when rating the curve match to liquid surface. For must cases 1 pixel is good altough for blurry and emulsive surfaces lower resultion might be good 
        %  Resl=max(round(np*MinRes/100*2),1);        
        Resl=1;%eesolution of scan around the curve
        %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                      
          
                %score for color image
                    %Score=double(MatchEllipse1(Rchannel,Iellipse,Resl,y(f),Iinterior)+MatchEllipse1(Bchannel,Iellipse,Resl,y(f),Iinterior)+MatchEllipse1(Gchannel,Iellipse,Resl,y(f),Iinterior)); 
              
        
             %  if (ConsistencyFilter(Igr,Iellipse,Resl,y(f),Iinterior)==1) % use considency filter  to filter bad results matchellipse 1-4 and matchellipse13 have consistency filter embeded in them and dont need this function 
               Score=double(MatchEllipse1(Igr,Iellipse,Resl,y(f),Iinterior));% evaluate the curve corresponace to phase seperation surface contour or line in the image (could be done by various of funtions some alternative to this lines are given in the end of the paper all this alternative are diffrent methods for rating the curve) see section 2.2 and 3 of the paper
        %else Score=-1000; end;
          
        %............................................................................................................................. 
    
  %-----------------------------------------------------------------IS SCORE BETTER THEN PREVIOUS TOP SCORE IF SO UPDATE-----------------------------------------------------------------------------------------------------
 
%      
               
               if Score>TopScore % the best score achived so far is set as the new best score 
                                                   %&& indx>1 && Py2(indx)<y(np)-np/40 assuming this is not the vessel top (indx>1) or buttom (Py2(indx)<y(np)-np/40) thhis part only increase false recognition
                   TopScore=Score;  
               end
               
           %  Score  = MatchBinaryWithAngle( Is,Iellipse 'sobel' )
   % normscore=Score/soel; % normalized score compared to the ellipse size/sum
   %******************************************************************************************************************************************************************************************
   %------------------------------------WRITE  the curve AS NEW SURFACe, IF ITS SCORE PASS MINIMAL threshold---------------------------------------------------------------------------    
  %------------------------------------------------------------if score pass some minimal threshold write them t=down in array----------------------------------------------------------------------------------------------------------
      if(Score>MinScore && Score>TopScore*MinFractScore) %if score high enough write this as new phase
    
               indx=indx+1;% index number of scores registered so far
                Py(indx)=y(f);% ellipse line Y value
                Pscore(indx)=Score;
                Phight(indx)=fh;
                Pindx(indx)=f;% index
                Px1(indx)=x1(f);% left most and right most ellipse points
                Px2(indx)=x2(f);
                Py1(indx)=y(f)+fh;% bottum most and top most ellipse points
                Py2(indx)=y(f)-fh;
       end;
%******************************************************************************************************************************************************************************************

    end
  end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Write the top bouttom of the vessel as the surface n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%........................................if last phase boundary found is not the vessel bottum, then write vessel bouttm as last phase surface(the top and bottum of vessel are always excepted as surfaces)...........................................................
if Py2(indx)<y(np)-np/40  % if last phase boundary found is not the vessel bottum then write vessel bouttm as last phase boundary
     indx=indx+1;
    Py(indx)=y(np);
                Pscore(indx)=0;
                Phight(indx)=0;
                Pindx(indx)=np;% index
                Px1(indx)=x1(np);% left most and right most ellipse points
                Px2(indx)=x2(np);
                Py1(indx)=y(np);% bottum most and top most ellipse points in this case the ellipse is the bottum line
                Py2(indx)=y(np);

end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%REMOVE CURVES WITH SCORES  THAT DONT PASS THRESHOLD SCORE VALUES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%recheck phase seperations found and removed   cases who didnt pass the final threshold score(compared to the maximum)
%%%%%%%%%%%%%%%%%%this part is needed since the maximum score is updated in every part of the scan and some of the accepted curvesd base on lower %maximal score might not be valid (See section 2.3 of paper
   

pass=find(Pscore>=TopScore*MinFractScore); % find cases where score pass the threshold score ( calculated as fraction of the maxmial score receive)
if pass(1)~=1 pass=[1 pass]; end; % the top and bottum of the vessel will always be accepted irregardless of their score if not registred add them
if pass(length(pass))~=indx pass=[pass indx]; end; % add the last curve  (the bottum of the vessel) to the list of surfaces

                Py=Py(pass);
                Pscore=Pscore(pass);
                Phight= Phight(pass);
                Pindx=Pindx(pass);% index
                Px1=Px1(pass);% left most and right most ellipse points
                Px2=Px2(pass);
                Py1=Py1(pass);% bottum most and top most ellipse points
                Py2=Py2(pass);
     indx=length(pass);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%REMOVE OVERLAPING PHASE SEPERATION SURFACE (see section 2.3.1 in paper)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Curves WHICH TOO CLOSE PROBABLY MEAN THAT THE SAME PHASE SEPERATION WAS RECOGNISE TWICE REMOVE ONE with the lower score.  IF TWO ACCEPTED CURVES OVERLAP OR ARE TWO CLOSE REMOVE THE ONE WITH THE LOWER SCORE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 [~, order] = sort( Pscore(:),'descend');% Arranged curve according to their score from hgih to low score %order contain the rearranged indexs of score after sorting from high to low score (the first is the index of the highest score)
 for f1=1:length(order) %Scan curves from high to score 
    if order(f1)~=-1 % check if curve havent been marked for deletion
       for f2=f1+1:length(order) %scan all cutves with loqer score then curve f1
          if order(f2)~=-1  % check check if there no overlap and minimal gap betwen curve f1 and f2 
              if abs(Py(order(f1))-Py(order(f2)))<(Phight(order(f1))+Phight(order(f2)))+round(np/35)+Resl%max()+np/50% if the two phases are two close together delete the one with the lowest score (f2)
                  order(f2)=-1;% Curves that overlap with curves with higher scores are marked -1 (and later deleted)
              end
          end
      end;
    end
 end
 order=order(order~=-1); % copy all parts that does not marked -1  to new array, all the curve marked -1 are deleted
 order=sort( order(:),'ascend');% sort in from small to big
%.........................................copy only curves which not marked -1 (pass the the test).................................................................................................

                Py=Py(order);
                Pscore=Pscore(order);
                Phight= Phight(order);% hight of the ellipse
                Pindx=Pindx(order);% index
                Px1=Px1(order);% left most and right most ellipse points
                Px2=Px2(order);
                Py1=Py1(order);% bottum most and top most ellipse points
                Py2=Py2(order);
                indx=length(order);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WRITE OUTPUT%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%OUTPUT Write draw best phases found on system image in various of image files%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%WRITE OUTPUT files into file and diretory outname (outname is a text string used as input) 
% outname='C:\Users\mithycow\Desktop\trial pictures glassware\phases\black background\edited\Test -phases\img1975';
YSIZE=300;% size of the output image
RtY=double(YSIZE/Ss(1));
Imarked=rgb2gray(imresize(Is, [YSIZE NaN]));
% imwrite(Imarked,[outname '_GrayScale.tif']);
  Imarked2=Imarked;
  Iborder=resize_border3(Iborder,YSIZE);
 % imwrite(Iborder,[outname '_Iborder.tif']);
  %Iborder=dilate(logical(Iborder));
%  Iborder=dilate(imfill(Iborder,4,'holes'))-imfill(Iborder,4,'holes')+Iborder;
        Imarked(Iborder>0)=255; % mark the outer image border on image in white 255
       % imshow(Imarked,[]);
%imwrite(Imarked,[outname '_Vessel.tif']);
    for  f=1:1:indx
             [Iellipse,soel ] = ELLIPSE( round(Px1(f)*RtY),round(Px2(f)*RtY),round(Py1(f)*RtY),round(Py2(f)*RtY),0,0,size(Iborder)); % create ellipse in vessel with in the (y(f) line with hight of fh*2
             %Iellipse=dilate(logical(Iellipse));
       %  Iellipse=resize_border3(Iellipse,YSIZE);
             Imarked(Iellipse>0)=0;     %   mark ellipse on the image in white 255
               Imarked2(Iellipse>0)=0;  
              %  [Iellipse,soel ] = ELLIPSE( Px1(f),Px2(f),Py1(f)+1,Py2(f)-1,0,0,size(Iborder)); % create ellipse in vessel with in the (y(f) line with hight of fh*2
             %Iellipse=dilate(logical(Iellipse));
             %Imarked(Iellipse>0)=0;     %   mark ellipse on the image in white 255
              % Imarked2(Iellipse>0)=0;  
    end
    imwrite(Imarked,[outname '_OUTPUT_MARKED.jpg']);
    %  imwrite(Imarked2,[outname '_Marked_Liquid_Phases_only.tif']);
%    figure, imshow(Iedg);
 %    figure,imshow(Imarked,[]);   % pause;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%OUTPUT Write phases volume location and surfaces location into files%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% alternative rating methods for curves could be used in stead line 112
% (MatchEllipse). The various of methods discuess in the paper the Entry
% number is the entry number for the method in Tables 1-2 in the paper
%Entries 22,23,31,32,1 have gave best results in term false match to miss rate for recognition of phase bounaries/liquid surface (See paper)


%{
%Entry 1
 Score=double(MatchEllipse11(Igr,Iellipse,Resl,y(f),Iinterior));
 %consistency check embeded in the function need to be canceled to match the Entery 1 (altough the redcogntion is better with consistency check on
%}
%%-----------------------
%{
%Entry 2
 Score=double(MatchEllipse1(Igr,Iellipse,Resl,y(f),Iinterior));
%consistency check embeded in the function need to be canceled to match the Entery 1 (altough the redcogntion is better with consistency check on

%}
%%-----------------------
%{
%Entry 3
 Score=double(MatchEllipse12(Igr,Iellipse,Resl,y(f),Iinterior));
%consistency check embeded in the function need to be canceled to match the Entery 1 (altough the redcogntion is better with consistency check on

%}
%%-----------------------
%{
%Entry 4
   Score=double(MatchEllipse2(Igr,Iellipse,Resl,y(f),Iinterior));
%consistency check embeded in the function need to be canceled to match the Entery 1 (altough the redcogntion is better with consistency check on

%}
%%-----------------------
%{
%Entry 5
  Score=double(MatchEllipse3(Igr,Iellipse,Resl,y(f),Iinterior));
%consistency check embeded in the function need to be canceled to match the Entery 1 (altough the redcogntion is better with consistency check on

%}
%%-----------------------
%{
%Entry 6
Score=double(MatchEllipse4(Igr,Iellipse,Resl,y(f),Iinterior));
%consistency check embeded in the function need to be canceled to match the Entery 1 (altough the redcogntion is better with consistency check on

%}
%%-----------------------
%{
%Entry 7
 Score=double(MatchEllipse7(Igr,Iellipse,Resl,y(f),Iinterior));
%}
%%-----------------------
%{
%Entry 8
 Score=double(MatchEllipse5b(Igr,Iellipse,Resl,y(f),Iinterior));
%}
%%-----------------------
%{
%Entry 9
%  Score=double(MatchEllipse5(Igr,Iellipse,Resl,y(f),Iinterior));
%}
%%-----------------------
%{
%Entry 10
%  Score=double(MatchEllipse6(Igr,Iellipse,Resl,y(f),Iinterior));
%}
%%-----------------------
%{
%Entry 11
    Score=double(MatchEllipse8(Igr,Iellipse,Resl,y(f),Iinterior));
%}
%%-----------------------
%{
%Entry 12
%   Score=double(MatchEllipse1(Icanny,Iellipse,Resl,y(f),Iinterior));
%consistency check embeded in the function need to be canceled to match the Entery 1 (altough the redcogntion is better with consistency check on

%}
%%-----------------------
%{
%Entry 13
    Score=double(MatchEllipse7(Icanny,Iellipse,Resl,y(f),Iinterior));
%consistency check embeded in the function need to be canceled to match the Entery 1 (altough the redcogntion is better with consistency check on

%}
%%-----------------------
%{
%Entry 14
      Score=double(MatchEllipse9d(Igr,Iellipse,Resl,y(f),Iinterior));
%}
%%-----------------------
%{
%Entry 15
   Score=double(MatchEllipse6(Icanny,Iellipse,Resl,y(f),Iinterior));
%}
%%-----------------------
%{
%Entry 16
  Score=double(MatchEllipse15(Igr,Iellipse,Resl,y(f),Iinterior));
%}
%%-----------------------
%{
%Entry 17
   Score=double(MatchEllipse13(Igradient,Iellipse,Resl,y(f),Iinterior));
%}
%%-----------------------
%{
%Entry 18
MatchEllipse7(Igradient,Iellipse,Resl,y(f),Iinterior)
%}
%%-----------------------
%{
%Entry 19
Score=double(MatchEllipse10d(Igr,Iellipse,Resl,y(f),Iinterior));
%}
%%-----------------------
%{
%Entry 20
% Score=double(MatchEllipse6(Igradient,Iellipse,Resl,y(f),Iinterior));
%}
%}
%%-----------------------
%{
%Entry 21
   Score=double(MatchEllipse13(Igr,Iellipse,Resl,y(f),Iinterior)); % consitency check already embedede in the function
%}
%%-----------------------
%{
%Entry 22
      Score=double(MatchEllipse1(Igr,Iellipse,Resl,y(f),Iinterior));% consistency check embeded in the function
%}
%%-----------------------
%{
%Entry 23
  Score=double(MatchEllipse2(Igr,Iellipse,Resl,y(f),Iinterior));% consistency check embeded in the function
%}
%%-----------------------
%{
%Entry 24
          Score=double(MatchEllipse3(Igr,Iellipse,Resl,y(f),Iinterior));% consistency check embeded in the function
%}
%%-----------------------
%{
%Entry 25
     Score=double(MatchEllipse4(Igr,Iellipse,Resl,y(f),Iinterior));% consistency check embeded in the function
%}
%%-----------------------
%{
%Entry 26
  Score=double(MatchEllipse1(Igr,Iellipse,Resl,y(f),Iinterior));% consistency check embeded in the function
%}
%%-----------------------
%{
%Entry 27
  Score=double(MatchEllipse1(Igr,Iellipse,Resl,y(f),Iinterior));% consistency check embeded in the function
%}
%%-----------------------
%{
%Entry 28
  if (ConsistencyFilter(Igr,Iellipse,Resl,y(f),Iinterior)==1) 
                    Score=double(MatchEllipse1(Rchannel,Iellipse,Resl,y(f),Iinterior)+MatchEllipse1(Bchannel,Iellipse,Resl,y(f),Iinterior)+MatchEllipse1(Gchannel,Iellipse,Resl,y(f),Iinterior)); 
                else Score=-1000; end;
%}
%%-----------------------
%{
%Entry 29
  if (ConsistencyFilter(Igr,Iellipse,Resl,y(f),Iinterior)==1)
               Score=double(MatchEllipse13(Icanny,Iellipse,Resl,y(f),Iinterior));
        else Score=-1000; end;
%}
%%-----------------------
%{
%Entry 30
  if (ConsistencyFilter(Igr,Iellipse,Resl,y(f),Iinterior)==1)
               Score=double(MatchEllipse7(Icanny,Iellipse,Resl,y(f),Iinterior));
           else Score=-1000; end;
%}

%}
%%-----------------------
%{
%Entry 31
    if (ConsistencyFilter(Igr,Iellipse,Resl,y(f),Iinterior)==1)
               Score=double(MatchEllipse9d(Igr,Iellipse,Resl,y(f),Iinterior));
                else Score=-1000; end;
%}
%%-----------------------
%{
%Entry 32
 if (ConsistencyFilter(Igr,Iellipse,Resl,y(f),Iinterior)==1)
               Score=double(MatchEllipse6(Icanny,Iellipse,Resl,y(f),Iinterior));
                 else Score=-1000; end;
%}
%%-----------------------
%{
%Entry 33
 if (ConsistencyFilter(Igr,Iellipse,Resl,y(f),Iinterior)==1)
               Score=double(MatchEllipse10d(Igr,Iellipse,Resl,y(f),Iinterior));
               else Score=-1000; end;
%}
%%-----------------------
%{
%Entry 34
 if (ConsistencyFilter(Igr,Iellipse,Resl,y(f),Iinterior)==1)
               Score=double(MatchEllipse6(Igradient,Iellipse,Resl,y(f),Iinterior));
                 else Score=-1000; end;
%}
%%-----------------------
%{
%Entry 35
Score=double(MatchEllipse1(Igradient,Iellipse,Resl,y(f),Iinterior));
                if Score>BstScore%check if the score is better then pevous find and if so ue it
                    BstScore=Score;
%}
