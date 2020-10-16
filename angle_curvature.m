
function Curvature = angle_curvature(coordinates,px_nm,params)
% Segmentation according to Wang-Mathews 2016
% http://pubs.acs.org/doi/abs/10.1021/acs.energyfuels.5b02907
% There are three parameters:
% n = number of pixels per segmentation for the first segmentation stage
% minAngle and maxAngle = min and max angles accepted between two segments
% minsize = minimum segment size allowed in a segment
%

% Parameters 
n= params(1); %segmentate every nth pixel
minAngle=params(2); %minimum angle accepted between segments
maxAngle=params(3); %maximum angle accepted between segments
minsize=params(4)*px_nm; %minimum accepted segment size


%First segmentation
% The fringes are segmented according to the n
for j=1:length(coordinates);
 Y= coordinates(j).XY(:,1); %y coordinates of fringe i
 X= coordinates(j).XY(:,2); %x coordinates of fringe i       
 [seg Nseg angles segsize] = Angle_between_segments(X,Y,n);

 %Store first segmentation data
 segsize1=segsize; 
 seg1=seg;   
 Nseg1=Nseg;

 % If there is only one segment then go to the next fringe
if Nseg==1;
   segsize= sqrt((seg(1,1)-seg(1,3))^2+(seg(1,2)-seg(1,4))^2);  
else

% Second segmentation
 
%Segments that do not follow the angle and size criteria are unified
 %If the final segment don't follow criteria, unify with the previous seg
  while segsize(Nseg)<minsize;
   seg(Nseg-1,:)=[seg(Nseg-1,1),seg(Nseg-1,2),seg(Nseg,3),seg(Nseg,4)];
   seg(Nseg,:)=[]; %delete last segment
   segsize(Nseg)=[]; %delete last size
   angles(Nseg-1)=[]; %delete the last angle
   % New segments
   Nseg=size(seg,1); 
   if Nseg==1;
    segsize= sqrt((seg(1,1)-seg(1,3))^2+(seg(1,2)-seg(1,4))^2); 
    break
   else
    segsize(Nseg)= sqrt((seg(Nseg,1)-seg(Nseg,3))^2+...
       (seg(Nseg,2)-seg(Nseg,4))^2);
    v1= [seg(Nseg-1,3),seg(Nseg-1,4)]'-[seg(Nseg-1,1),seg(Nseg-1,2)]';
    v2= [seg(Nseg,3),seg(Nseg,4)]'-[seg(Nseg,1),seg(Nseg,2)]';
    angles(Nseg-1) = (180/pi)*atan2(abs(det([v1,v2])),dot(v1,v2));
   end
  end

 %Detect segments that do not follow the angle and size criteria
    angles(length(segsize))=minAngle; %make angles1 and segsize1 same size
    notseg=find(angles<minAngle | angles>maxAngle | segsize<minsize);
 
 % If there is only one segment then go to the next fringe
 if Nseg==1;
 %Unify segments that don't follow the criteria with the next seg until 
 %all segments follow it
 else
   while isempty(notseg)== 0;
    %For consecutive segments only choose the first to unify
    while sum(diff(notseg)==1)>= 1; 
      notseg(find(diff(notseg)==1,1,'first')+1)=0;
      notseg=nonzeros(notseg);
      sum(diff(notseg)==1);
    end
    %Unify all seg not following criteria
    for i=1:length(notseg);
      seg(notseg(i),:)=[seg(notseg(i),1),seg(notseg(i),2),...
          seg(notseg(i)+1,3),seg(notseg(i)+1,4)];
      seg(notseg(i)+1,:)=0;
    end
    %Delete data from old segment
    seg(notseg+1,:)=[];
    segsize(notseg+1)=[];
    angles(notseg)=[];
    %Size and angle of new segments
    Nseg=size(seg,1);
    % If there is only one segment then go to the next fringe
    if Nseg==1;
      segsize= sqrt((seg(1,1)-seg(1,3))^2+(seg(1,2)-seg(1,4))^2);  
    else
      for i=1:size(seg,1)-1;
        segsize(i)= sqrt((seg(i,1)-seg(i,3))^2+(seg(i,2)-seg(i,4))^2);
        segsize(i+1)= sqrt((seg(i+1,1)-seg(i+1,3))^2+(seg(i+1,2)-seg(i+1,4))^2);
        v1= [seg(i,3),seg(i,4)]'-[seg(i,1),seg(i,2)]';
        v2= [seg(i+1,3),seg(i+1,4)]'-[seg(i+1,1),seg(i+1,2)]';
        angles(i) = (180/pi)*atan2(abs(det([v1,v2])),dot(v1,v2));
      end
    end
    % Which segments do not follow the angle and size criteria?
    notseg=find(angles<minAngle | angles>maxAngle | segsize<minsize);
    Nseg=size(seg,1);
  end

 end 
end

% Calculate size and angles for the accepted segments
if size(seg,1)==1;
  segsize= sqrt((seg(1,1)-seg(1,3))^2+(seg(1,2)-seg(1,4))^2);  
  angles=[];
else
  for i=1:size(seg,1)-1;
        segsize(i)= sqrt((seg(i,1)-seg(i,3))^2+(seg(i,2)-seg(i,4))^2);
        v1= [seg(i,3),seg(i,4)]'-[seg(i,1),seg(i,2)]';
        v2= [seg(i+1,3),seg(i+1,4)]'-[seg(i+1,1),seg(i+1,2)]';
        angles(i) = (180/pi)*atan2(abs(det([v1,v2])),dot(v1,v2));
   end
  angles(length(angles))=[]; %delete the final angle artificially created
end

%Store segments information
Curvature(j).Nseg=Nseg;
Curvature(j).seg=seg;
Curvature(j).segsize=segsize;
Curvature(j).angles=angles;
end

end

function [seg Nseg angle segsize]=Angle_between_segments(Y,X,n);
    

NsegIni=(length(Y)-1)/n; % number of initial segments
Nseg=floor(NsegIni); %the number of equal size segments posible 
cont=1;

% If there is only one segment then go to the next fringe
if Nseg==1
  seg=[X(1),Y(1),X(length(X)),Y(length(Y))];
  segsize= sqrt((seg(1,1)-seg(1,3))^2+(seg(1,2)-seg(1,4))^2);  
  angle=[];
else
% If the fringe can be completely segmented
 if mod(NsegIni,1)==0; %if seg is an integer          
    for i=1:n:length(X)-(n+1);
    seg(cont,:)=[X(i),Y(i),X(i+n),Y(i+n)];
    seg(cont+1,:)=[X(i+n),Y(i+n),X(i+2*n),Y(i+2*n)];
    
    segsize(cont)= sqrt((seg(cont,1)-seg(cont,3))^2+...
        (seg(cont,2)-seg(cont,4))^2);
    segsize(cont+1)= sqrt((seg(cont+1,1)-seg(cont+1,3))^2+...
        (seg(cont+1,2)-seg(cont+1,4))^2);
    v1= [seg(cont,3),seg(cont,4)]'-[seg(cont,1),seg(cont,2)]';
    v2= [seg(cont+1,3),seg(cont+1,4)]'-[seg(cont+1,1),seg(cont+1,2)]';
    angle(cont) = (180/pi)*atan2(abs(det([v1,v2])),dot(v1,v2));
    cont=cont+1;
    end
    
% If there are remaining pixels at the end of the segmentation,
% add to the last segment    
else
   for i=1:n:((Nseg*n)-n);
    seg(cont,:)=[X(i),Y(i),X(i+n),Y(i+n)];
    seg(cont+1,:)=[X(i+n),Y(i+n),X(i+2*n),Y(i+2*n)];
    
    segsize(cont)= sqrt((seg(cont,1)-seg(cont,3))^2+...
        (seg(cont,2)-seg(cont,4))^2);
    segsize(cont+1)= sqrt((seg(cont+1,1)-seg(cont+1,3))^2+...
        (seg(cont+1,2)-seg(cont+1,4))^2);
    v1= [seg(cont,3),seg(cont,4)]'-[seg(cont,1),seg(cont,2)]';
    v2= [seg(cont+1,3),seg(cont+1,4)]'-[seg(cont+1,1),seg(cont+1,2)]';
    angle(cont) = (180/pi)*atan2(abs(det([v1,v2])),dot(v1,v2));
    cont=cont+1;
   end    
   %%add the remaining pixels to the last segment and calc angle
   seg(cont,:)=[X((Nseg*n)-(n-1)),Y((Nseg*n)-(n-1)),...
       X(length(X)),Y(length(Y))];
   v1= [seg(cont-1,3),seg(cont-1,4)]'-[seg(cont-1,1),seg(cont-1,2)]';
   v2= [seg(cont,3),seg(cont,4)]'-[seg(cont,1),seg(cont,2)]';
   segsize(cont)= sqrt((seg(cont,1)-seg(cont,3))^2+...
       (seg(cont,2)-seg(cont,4))^2);
   angle(cont-1) = (180/pi)*atan2(abs(det([v1,v2])),dot(v1,v2));    
 end
end
end


