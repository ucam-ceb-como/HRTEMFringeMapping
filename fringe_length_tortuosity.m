
function [numNM linlength orientation coords I8] = fringe_length_tortuosity(I8,coordinates,px_nm,min_len)
%----------For each fringe find the pixels adjacent and diagonal to calculate
%distance between them accordingly (adyacent= 1 pixel; diagonal=sqrt(2)*1pixel) 
%    
%     ._._.           Total Pix =5
%    /     \          Distance= 1diag+2adjac+1diag = 2diag+2adyac = 2(sqrt(2)*pixel)+2pixel= 4.83pixel    
%   '       '
%
cc=bwconncomp(I8,8); % store the new info of connected fringes after eliminating H, Y, T connections
numPixels = cellfun(@numel,cc.PixelIdxList); %number of pixels on each fringe

% Calculation of number fringe length
for i=1:length(numPixels)
    c=coordinates(i).XY;
    row=c(:,1); col=c(:,2);
    infront=0;
    diagonal=0;
    for m=1:length(c)-1
        if row(m)-row(m+1)==0 || col(m)-col(m+1)==0 %if they are adyacent vertically or horizontal
            infront=infront+1; 
        else %if the pixels are diagonal
            diagonal=diagonal+1;
        end
    end
    numPixels(i)= infront + sqrt(2)*diagonal; %total distance between the pixels of the fringe considering adyacent or diagonal pixels
end
% conversion pixel to nm on each fringe
numNM= numPixels/px_nm; 

% Eliminating fringes below the boundary min_len
stats= regionprops(I8,'orientation');

%Calculates fringe number of pixels (length) and distance between first and 
%last pixel(linear length)
A=0;
for i=1:length(numNM);
    if numNM(i) <= min_len  %eliminating fringes below 0.483 nm (naphthalene)
        numNM(i)=0;                  
        stats(i,1).Orientation=0;
        I8(coordinates(i).XY(:,1),coordinates(i).XY(:,2))=0;
        coordinates(i).XY=[0 0];
        orientation(i)=0;
        
    else
        A=A+1;
        orientation(i)=stats(i,1).Orientation+0.00001;
        %Obtainig localization of each fringe and sorting it from
        %location(depending on orientation)
        coords(A).XY=coordinates(i).XY;
        row=coords(A).XY(:,1); col=coords(A).XY(:,2);      
        linlength(A) = sqrt((row(length(row))-row(1))^2+(col(length(col))-col(1))^2);      %calculating the end point distance of a fringe sqrt((x2-x1)^2 + (y2-y1)^2)
    end
end
imshow(I8);
return
        
