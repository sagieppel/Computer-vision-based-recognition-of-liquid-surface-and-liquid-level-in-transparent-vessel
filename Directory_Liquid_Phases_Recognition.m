%{
This script basically preform liquid surface recognition on every jpg image file in a given directory (SystemDir, line 24)
The directory must contain color images of the liquid containing vessel in jpg format (this format be change by changing “.jpg” in line 32)

For every color jpg image the directory most contain a  binary edge images of the vessel contour in the liquid vessel. 
The name of the edge file must be the same as the name of the liquid image for which this boundaries belong + _BORDERS.tif extension. 
For example “v1.jpg”  and “v1_BORDERS.tif”.  Images that do not have contour files with _BORDERS extension will be ignored.
Basically the script  scan for all files with color image of the system directory SystemDir
and find files with equivalent name which end by _Border.tif.
It then transfer this to files to the function Liquid_Surface_Line_Recognition  which performs  the recognition.
%}
%Preform recogntion of liquid surface for all images in directory SystemDir
%The directiory must contain color image of the liquid containing vessel in jpg mode (this could be change by changing line 32)
% And  binary edge images of the vessel contour in the liquid vessel directory
%The name of the edge file must be the same as the name of the liquid imagefor wich this border belong + _BORDERS.tif (this could be change by changing line 32)
%The contour of the vessel in the image could be founf already found by(Exctract_object_from_background or by MAIN_find_object_in_image) and being writen in _BORDER.tif image
% Basically the  scan for all files with color image of the system
% and find files with equivalent name which end by _Border.tif) which give
% the vessel borders on the image and then transfer this to file to
% %##$%#$%#$ which recognize phases and write them as output files
clear all; % clear all variable from work space
close all;
 imtool close all; 
SystemDir='EXAMPLE IMAGES';
%C:\Users\mithycow\Desktop\trial pictures glassware\phases\black background\edited\Test - Phases';
Slist = ls(SystemDir)%%Read list of files in System directory.Any image that will be added after this part (like image made by the programs will not be read to prevent endless loop
Ss=size(Slist);
%************************************************************************************************************************************************
for fs=1:Ss(1)% scan directory  all color image of the system (presumably i jpg format)
   close all;
   Slist(fs,:);
    if  ~isempty(strfind(Slist(fs,:),'.jpg')) || ~isempty(strfind(Slist(fs,:),'.JPG')) % if file is jpg image read this image and scan all template on this image
        Is=imread([SystemDir '\' Slist(fs,:)]);
      %  figure, imshow(Is);
 %-----------------------------------------------------------------------search for the matching border file for the image (presumably one that contain the same name with _border.tif ending)-----------------------------------------------------------------------------------------------------------------------------------------------        
 

 MainName= strrep(Slist(fs,1:length(Slist(fs,:))),'.jpg','');% remove the jpg from the file name
  MainName= strrep(MainName,'.JPG','');% remove the jpg from the file name
 MainName= strrep(MainName,' ','');% the file name contain many spaces which make it impossible to compare or use
            for ft=1:Ss(1)% scan directory 
              hh= strrep(Slist(ft,:),' ','');% the file name contain many spaces which make it impossible to compare or use
                    if  strcmp(hh,[ MainName '_BORDERS.tif']) || strcmp(hh,[ MainName '_BORDERS.TIF']) % if file is jpg image read this image and scan all template on this image
                            Iborder=imread([SystemDir '\' Slist(ft,:)]); % read the vessel border corresponding to the image border
                  %    figure, imshow(Iborder);
                  %    pause;
                           
                          disp(['started:' MainName]);

                          Liquid_Surface_Line_Recognition(Is,Iborder,[SystemDir '\' MainName]);
                             disp(['finished:' MainName]);
                        
                    end;
            end
%------------------------------------------------write best match for current image----------------------------------------------------------------------------------------
           
    end
%************************************************************************************************************************************************

end
