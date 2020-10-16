function [FL_dist,center,radius] = fringes_position(fc,fringes,spacing,px_nm)

figure(6)  
imshow(fc)
escape = 0; 
while escape == 0
    [x(1),y(1), button(1)] = ginput(1);
    if max(button(1)) == 3
        % right click to finish adding
        break
    elseif max(button(1)) == 27
        % press ESC to discard
        continue
    end
    [x(2),y(2), button(2)] = ginput_custom(1,x(1),y(1));
    if max(button(2)) == 3
        % right click to finish adding
        break
    elseif max(button(2)) == 27
        % press ESC to discard
        imshow(fc)
        continue
    end
    
    % Calculate radius and center of new measurement
    center = [x(1), y(1)];
    radius = sqrt((x(2)-x(1))^2+(y(2)-y(1))^2)/px_nm;
    
    % Annotate the figure
    viscircles(center,radius,'Color','b', 'lineWidth', 0.5);
end

for i=1:length(fringes.coordinates)
distance_px(i)= mean(sqrt((fringes.coordinates(i).XY(:,1)-center(1,2)).^2+(fringes.coordinates(i).XY(:,2)-center(1,1)).^2));
end
FL_dist=distance_px/px_nm;

return