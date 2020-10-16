% Author: Maria Botero
% The program is developed for the automatic mapping of fringes in 
% high resolution transmission electron microscopy (HRTEM) images of soot. 
% It applies a series of image transformations to the original TEM image 
% to map the fringes. Fringes length, tortuosity, curvature and 
% inter-fringe spacing are measured by this code.  
% A detailed description can be found in the papers: 
% Botero et al., Carbon, 2016, [doi:10.1016/j.carbon.2015.09.077]
% Botero et al., Carbon, 2019, [doi:10.1016/j.carbon.2018.09.063]


clear all;
close all;
clc;

%% FOLDER and IMAGE definitions
fileLoc='.\Example\';
fileName='ExampleImage';
fileExt= '.tif'; %define the extension of images .png or .jpg or .tiff etc
locImage = [fileLoc,fileName,fileExt];
locImageInfo = [fileLoc,fileName,'.txt']; %this is for images that also come with a txt file containing the px to nm ratio

%% INPUT Parameters
%--%Image transformation parameters. Uncomment if you want to load
% %new parameters and comment out lines 106 to 108
bw_fac=1; %Thresholding factor to binarise image
sigma=1;
hsize=2*ceil(3*sigma)+1; %Gaussian filter
bothat=2; %Bottom-hat disk size

%--%Minimun fringe size allowed and Min and Max interfringe spacings
% %allowed
min_len=0.483;
min_spa=0.3354;
max_spa=0.6;

%--$For curvature calculations according to Wang-Mathews 2016
% $http://pubs.acs.org/doi/abs/10.1021/acs.energyfuels.5b02907
n_seg= 2; %segmentate every nth pixel
minAngle=0; %minimum angle accepted between segments
maxAngle=180; %maximum angle accepted between segments
minsize=0.2; %minimum accepted segment size 
curvature_params= [n_seg;minAngle;maxAngle;minsize];

%% LOAD FILE
%-%Check if image and info exists
lImage = (exist(locImage) == 2);
lImageInfo = (exist(locImageInfo) == 2);
if (~(lImage))
    warning('Image not found! Check the defined file locations.')
    return
end
[fc, map]= imread([fileLoc,fileName,fileExt]);
fc=rgb2gray(fc); % uncomment if the image is not in grey scale
imshow(fc)

%% PIXEL to nm DEFINITION
% %Get scale from ImageInfo (SCALE-X)
% %--To obtain from a txt file containing the information of the scale X and 
% %scale Y:
% imageInfo = fileread(locImageInfo);
% i = findstr(imageInfo,'SCALE-X');
% j = findstr(imageInfo,'SCALE-Y');
% scaleStr = imageInfo(i+8:j-1);
% scale = str2num(scaleStr);
% px_nm= 1/scale;%pixelTOnanometer(TEM, eKV, mol);

%--%To obtain from the bar scale in the image:
% %the following 3 lines:
%[x y]=getpts; %select a point at each side of the scale bar in the image 
%bar_length= str2double(inputdlg('Scale bar length (nm)')); %write the bar length in [nm]
%px_nm=abs(x(2)-x(1))/bar_length
%save(regexprep(locImage,fileExt,strcat('_','px-nm','.mat')), 'px_nm');

%--%For known px_nm ratio type it or load it
% px_nm=18.0194;
load(regexprep(locImage,fileExt,strcat('_','px-nm','.mat')), 'px_nm');

%%  ROI
%--%Select the region of interest ROI
% %You can select multiple ROI in the same image. The program saves the ROI
% %in the the same folder of the image and gives ascending number to each
% %ROI. You can then load a pre-selected ROI by using its number

% %Check if there is an existent ROI
NumRoi=1;
if isempty(dir([fileLoc,fileName,'*_roi.mat'])) ==0
    button = questdlg('Do you want to select a new ROI?','ROI selection','Yes','No','default');
    if isequal(button,'Yes')==1
        Rois=dir([fileLoc,fileName,'*_roi.mat']);
        NumRoi=str2num(Rois(length(Rois)).name(end-8))+1;
%        NumRoi=length(dir([fileLoc,fileName,'*_roi.mat']))+1;
        uiwait(msgbox({'Click at different points around the region you want to analyse. Make sure to close the loop and avoid reaching the edges of the Image.';...
        'To accept the selected ROI, right click and select "Create Mask".'},...
        'Select ROI','help'));      
        [I,c,r] =roipoly(fc);
        if isempty(I)
          c=[2;2;size(fc,1)-1;size(fc,1)-1;2];r=[2;size(fc,2)-1;size(fc,2)-1;2;2];
          roi=[c,r];
          save(regexprep(locImage,fileExt,strcat('_',num2str(NumRoi),'_roi','.mat')), 'roi');
        else
          roi=[c,r];
          save(regexprep(locImage,fileExt,strcat('_',num2str(NumRoi),'_roi','.mat')), 'roi');
        end
        clear button
    else        str = inputdlg('Which ROI number you want to analyse');
        if isempty(str)
             warning('The ROI selected does not exist.')
            return
        else
        load(regexprep(locImage,fileExt,strcat('_',str,'_roi','.mat')), 'roi')
        c=roi(:,1); r=roi(:,2);
        NumRoi=str2double(str);
        clear str
        end
    end
else
    uiwait(msgbox({'Click at different points around the region you want to analyse. Make sure to close the loop and avoid reaching the edges of the Image.';...
        'To accept the selected ROI, right click and select "Create Mask".'},...
        'Select ROI','help'));      
    [I,c,r] =roipoly(fc);
    if isempty(I)
      c=[2;2;size(fc,1)-1;size(fc,1)-1;2];r=[2;size(fc,2)-1;size(fc,2)-1;2;2];
      roi=[c,r];
      save(regexprep(locImage,fileExt,strcat('_',num2str(NumRoi),'_roi','.mat')), 'roi');
    else
      roi=[c,r];
      save(regexprep(locImage,fileExt,strcat('_',num2str(NumRoi),'_roi','.mat')), 'roi');
    end
end

%% IMAGE TRANSFORMATIONS
% %Analysis parameters
%--%load parameters previously used with that ROI
if isempty(dir([fileLoc,fileName,'_',num2str(NumRoi),'_Data.mat'])) ==0
    load([fileLoc,fileName,'_',num2str(NumRoi),'_Data']);
    bw_fac=Data.params(1);
    sigma=Data.params(2);hsize=Data.params(3);bothat=Data.params(4);
else
end

%--%Store Parameters
fringes.params= [bw_fac;sigma;hsize;bothat];

% %Image transformations
%--%Mask ROI
[N,M]=size(fc);
I=(poly2mask(c,r,N,M)); %roi
g=fc;
g(~I)=0;
imshow(g)
clear N M g

%--%Constrast enhancement (histogram equalization)
hgram=sqrt(imhist(fc));
g2=histeq(fc,hgram);
g2(~I)=0;
imshow(g2)

%--%Gaussian lowpass filter
g3=imgaussfilt(g2,sigma,'FilterSize',hsize);
imshow(g3);

%--%Bottom hat transformation
se = strel('disk',bothat);
g4 = imbothat(g3,se);
imshow(g4);

%--%Thresholding to obtain binary images
level = graythresh(g4);
level = level*bw_fac;
g5 = im2bw(g4,level);
imshow(g5);

% %Morphological operations
%--%Eliminate 8-conn of background pixels
g6= bwmorph(g5,'diag');
imshow(g6);

%--%Skeletonization
g7=bwskel(g6);
imshow(g7);

%--%Eliminate single isolated pixels adn break H connections
g8= bwmorph(g7,'hbreak');
g9= bwmorph(g8,'clean');
imshow(g9);
I8=g9;
clear g2 g3 g4 g5 g6 g7 g8 g9


%% BRANCHES ELIMINATION
%--%Branch cleaning algorithm: screens each fringe with branches and
%  %eliminates the shorter branch to keep the main bone of the fringe
branchpoints=length(nonzeros(bwmorph(I8,'branchpoints')));
I8=branch_cleaning(I8,px_nm,min_len);
imshow(I8);

export_fig([fileLoc,fileName,'_',num2str(NumRoi),'_mappedfringes.png'],'-transparent')


%% FRINGE LENGTH and TORTUOSITY Calculation 
%--%Sort fringes
coordinates=fringe_sorting(I8);

%--%Calculate fringe length and tortuosity, and give feedback on each fringe orientation
[numNM,linlength,orientation,coords,I8]= ...
    fringe_length_tortuosity(I8,coordinates,px_nm,min_len);

%--%Store Fringe information
fringes.length = nonzeros(numNM);
fringes.orientation=nonzeros(orientation);
fringes.Linlength = nonzeros(linlength)/px_nm;
fringes.number= length(nonzeros(numNM));
fringes.tortuosity= fringes.length./fringes.Linlength;
fringes.coordinates = coords;


%% Overlaid IMAGES of fringes
%--%Plot fringes on top of the TEM image
figure(2)
imshow(fc);
hold on
for i=1:numel(coords);
c=coords(i).XY;
scatter(c(:,2),c(:,1),2,'r','filled','o')   
end
hold off

%--%Export image with overlaid fringes
export_fig([fileLoc,fileName,'_',num2str(NumRoi),'_overlaidfringes.png'],'-transparent')

%--%Plot fringes on white backgroud
figure(3)
blank=255*ones(size(I8));
imshow(blank)
hold on
for i=1:numel(coords);
coor=coords(i).XY;
plot(coor(:,2),coor(:,1),'k')%,'filled','o')
end
hold off
clear coordinates coor

%--%Export image if fringes in white background 
export_fig([fileLoc,fileName,'_',num2str(NumRoi),'_clearfringes.png'],'-transparent')


%% CURVATURE Calculation 

%--%Using Menger curvature
%[curvatures,rad_curv,avg_curv,avg_rad,infl] = ...
%   menger_curvature(fringes.coordinates,px_nm,fringes.orientation);

%--%Using total curvature
%[curv_nm,r_nm] = tot_curvature(fringes.coordinates,px_nm);

%--%Using method of Wang-Mathews 2016
%  %http://pubs.acs.org/doi/abs/10.1021/acs.energyfuels.5b02907
%curvature = angle_curvature(fringes.coordinates,px_nm,curvature_params);

%--%[Only for Angle Curvature]Plot fringes segments on white backgroud 
% figure(4)
% blank=255*ones(size(I8));
% imshow(blank)
% hold on
% for i=1:numel(coords);
% coor=coords(i).XY;
% plot(coor(:,2),coor(:,1),'k');
% end
% for i=1:numel(curvature);
%     segments=curvature(i).seg;
%     plot(segments(:,2),segments(:,1),'r',segments(:,4),segments(:,3),'r');
% end
% hold off
%export_fig([fileLoc,fileName,'_',num2str(NumRoi),'_curvaturefringes.png'],'-transparent')

%--%Store Fringe information
%fringes.curvatures = curvature;

%% INTERFRINGE SPACING Calculation
% %For each fringe compare to all the following to see if there
% %is one or more adjacent (or parts of a fringe adjacent)
figure
imshow(fc);
hold on
spacing = interfringe_spacing(fringes,I8,px_nm,min_len,min_spa,max_spa,fc,fileName);
hold off

%--%Export overlaid image of stacked fringes 
export_fig([fileLoc,fileName,'_',num2str(NumRoi),'_overlaidstacks.png'],'-transparent')

%--%Store Fringe information
fringes.spacing=nonzeros(spacing)/px_nm;

%% MEAN and MEDIAN
medL=median(fringes.length)
meaL=mean(fringes.length)
stdL= std(fringes.length)
medT=median(fringes.tortuosity)
meaT=mean(fringes.tortuosity)
stdT=std(fringes.tortuosity)
medS=median(fringes.spacing)
meaS=mean(fringes.spacing)
stdS=std(fringes.spacing)
nsl=((fringes.number-length(fringes.spacing))/fringes.number)*100
highFT= (length(nonzeros(fringes.tortuosity > 1.5))/fringes.number)*100
num_stacks=length(fringes.spacing)/2
Stats=[fringes.number num_stacks branchpoints meaL medL meaT medT meaS medS highFT nsl]';

%% Fringes distance to particle CENTER

button = questdlg(['Do you want to caclulate the fringes position in relation', ...
         ' to the particle centre? (if YES, then select the particle centre and radius',...
         ', the press right click)']...
         ,'Map fringes with respect to particle centre','Yes','No','default');

if isequal(button,'Yes')==1
    [FL_dist,center,radius] = fringes_position(fc,fringes,spacing,px_nm);
    
    for i=1:length(spacing)-1
        n=nonzeros(spacing(i,:));
        if isempty(n)
            spa_pos(i)=0;
        else
            spa_pos(i)=min(n);
        end
    end
    add=length(fringes.length)-length(spacing(:,1));
    spa_pos(length(spacing(:,1))+add)=0;
    spa_pos=spa_pos/px_nm;
    clear n i add
else
 FL_dist=[]; center=[];radius=[];
 spa_pos=[];
end

%--Store Fringe information
fringes.distcenter = FL_dist;
fringes.minspacing= spa_pos;
fringes.radius= radius;
fringes.center= center;


%% SAVE DATA
% % save all fringes structure data
 save(regexprep(locImage,fileExt,strcat('_',num2str(NumRoi),'_fringes','.mat')), 'fringes');
