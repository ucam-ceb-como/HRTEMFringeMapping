
function [curv_nm,r_nm,avg_curv,avg_rad,infl] = menger_curvature(coordinates,px_nm,orientation)
% This is the curvature of three points calculated as the inverse of the
% radius of unique Euclidean circus that pases through the three points
% The radius of such circle is one fourth of the product of the three sides divided by its area  
%c = 1/R = (4*A) /(x-y)(y-z)(z-x)

for i=1:length(coordinates)
    M= coordinates(i).XY(:,1); %y coordinates of fringe i
    N= coordinates(i).XY(:,2); %x coordinates of fringe i       
    r=zeros(size(coordinates)); c=(size(coordinates)); inflection=0; cur(1)=0;
    for j=1:length(M)-2
    y= M(j:j+2);    
    x= N(j:j+2);
    
    side1=sqrt((x(2)-x(1))^2 + (y(2)-y(1))^2);
    side2=sqrt((x(3)-x(1))^2 + (y(3)-y(1))^2);
    side3=sqrt((x(3)-x(2))^2 + (y(3)-y(2))^2);

    A = 1/2*((x(1)*(y(2)-y(3))+ x(2)*(y(3)-y(1)) + x(3)*(y(1)-y(2)))); %Area of triangle
    r(j) = (side1*side2*side3)/(4*A); %radius of curvature
    c(j) = 1/r(j); %curvature
        cur(j+1)=c(j);
        if cur(j+1)>cur(j)&& cur(j+1)~=0
            inflection =inflection+1;  %detect changes in curvature from neg to pos
        end
    end

curv_nm(i).c = (px_nm*c);
r_nm(i).c = (r/px_nm);

avg_curv(i)= mean(abs(px_nm*c)); %average signed curvature 
avg_rad(i)= mean(abs(r(~isinf(r))/px_nm)); %average signed radius of curvature
infl(i)=length(nonzeros(diff(sign(nonzeros(c))))); %inflection points, changes in curvature sign

end

