
function [curv_nm r_nm] = tot_curvature(curve,px_nm)


for i=22:length(curve)
x= curve(i).XY(:,1);
y= curve(i).XY(:,2);
mx = mean(x);
my = mean(y);
X = x - mx; Y = y - my; 

dx2 = mean(X.^2);
dy2 = mean(Y.^2);

% Set up linear equation for derivative and solve
RHS=(X.^2-dx2+Y.^2-dy2)/2; 
M=[X,Y];
t = M\RHS;

% t is the centre of the circle [a0;b0]
a0 = t(1); b0 = t(2);

% from which we can get the radius
r(i) = sqrt(dx2+dy2+a0^2+b0^2); 

% return to given coordinate system
a = a0 + mx;b = b0 + my; 

% get the curvature
curv(i) = 1/r(i);
end
r_nm= r/px_nm;
curv_nm= 1./r_nm;

end

