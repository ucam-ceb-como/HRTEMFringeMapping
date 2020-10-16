% Last change (can be reversed by uncommenting lines): the criteria for
% acceptance of two fringes to be stacked is no longer that the mean
% distance between the fringes is within the min and max limits. Now the
% distance between each adyacent pixel of the two fringes has to be below
% the max limit.

function spacing = interfringe_spacing(fringes,I8,px_nm,min_len,min_spa,max_spa,fc,fileName)

cc=bwconncomp(I8,8);

for i=1:fringes.number-1;    
    for j=i+1:fringes.number;
        fringe1=fringes.coordinates(i).XY;
        row1=fringe1(:,1); col1=fringe1(:,2);
        fringe2=fringes.coordinates(j).XY;
        row2=fringe2(:,1); col2=fringe2(:,2);
        % If the fringe i is SMALLER thant the fringe j and the fringes
        % orientation is between -45 and 45 degrees (tending to horizontal)
        if length(fringe1) <= length(fringe2); 
            if fringes.orientation(i) <= 45 && fringes.orientation(i) >= -45; 
            %find the fringe i respect to the fringe j
            %trimming process
                disI=sqrt((row2-row1(1)).^2+(col2-col1(1)).^2);
                disF=sqrt((row2-row1(length(row1))).^2+(col2-col1(length(col1))).^2);
                pxi2=find(disI==min(disI)); %pxi2=find(row2==row1(1));
                pxf2=find(disF==min(disF)); %pxf2=find(row2==row1(length(row1)));
              if isempty(pxi2)==1 && isempty(pxf2)==1;
              else
                if isempty(pxi2)==1;
                    pxi1=find(col1==col2(1));
                    pxi2=1;
                else
                   pxi2=pxi2(1);
                    pxi1=1;
                end
                if isempty(pxf2)==1;
                    pxf1=find(col1==col2(length(col2)));
                   pxf2=length(col2);
                else
                   pxf2=pxf2(length(pxf2));
                   pxf1=length(col1);
                end
                if pxf1-pxi1 <= pxf2-pxi2;
                   rowa=row1(pxi1:pxf1);
                   cola=col1(pxi1:pxf1);
                   rowb=row2(pxi2:(pxi2+pxf1-pxi1));         
                   colb=col2(pxi2:(pxi2+pxf1-pxi1));
                else
                 rowa=row1(pxi1:(pxi1+pxf2-pxi2));
                 cola=col1(pxi1:(pxi1+pxf2-pxi2));
                 rowb=row2(pxi2:pxf2);         
                 colb=col2(pxi2:pxf2);
                end
                %having trimmed the two "paralell" fringes to the same lenght find the distance between the two pieces   
                % (only if the paralell part has more than min_len)
                dist=0; distn=0;
                if length(rowa)>= round(0.8*min_len*px_nm) && length(rowb)>= round(0.8*min_len*px_nm)
                 for k=1:length(rowa);
                   for l=1:length(rowb);
                    dist(l)=sqrt((rowa(k)-rowb(l))^2+(cola(k)-colb(l))^2);
                   end
                   distn(k)=min(dist);        
                 end
                 %distance=mean(distn);
                 distance=(distn);
                else
                 distance = 0;
                end
                %If the distance between the two fringes is less than max spacing allowed nm then
                 %they are stacked
                if sum(distance< (max_spa*px_nm))/numel(distance)==1 && mean(distance)>= min_spa*px_nm
                %if distance<= max_spa*px_nm && distance>= min_spa*px_nm; 
                spacing(i,j)=mean(distance);
                %spacing(i,j)=(distance)/px_nm;
                %figure
                %imshow(fc);
                %hold on
                scatter(cola,rowa,2,'g','filled','o');
                scatter(colb,rowb,2,'g','filled','o');
                %export_fig(['C:\Users\Maria\Documents\Postdoc UdeA\HRTEM images\Cristian Avila - Imagenes TEM\HRTEM\Spacing\',fileName,'_',num2str(spacing(i,j)),'.tif'],'-transparent');
                %hold on
                else
                spacing(i,j)=0;    
                end
              end               
        % If the fringe i is SMALLER thant the fringe j and the fringes
        % orientation is less -45 or more 45 degrees (tending to vertical)
            else
            %find if the fringe i respect to the fringe j
            %trimming process
                disI=sqrt((row2-row1(1)).^2+(col2-col1(1)).^2);
                disF=sqrt((row2-row1(length(row1))).^2+(col2-col1(length(col1))).^2);
                pxi2=find(disI==min(disI)); %pxi2=find(row2==row1(1));
                pxf2=find(disF==min(disF)); %pxf2=find(row2==row1(length(row1)));
                if isempty(pxi2)==1 && isempty(pxf2)==1;
                else
                    if isempty(pxi2)==1;
                        pxi1=find(row1==row2(1));
                        pxi2=1;
                    else
                        pxi2=pxi2(1);
                        pxi1=1;
                    end
                    if isempty(pxf2)==1;
                        pxf1=find(row1==row2(length(row2)));
                        pxf2=length(row2);
                    else
                        pxf2=pxf2(length(pxf2));
                        pxf1=length(row1);
                    end
                    if isempty(pxf1)==1 || isempty(pxf2)==1 || isempty(pxi1)==1 || isempty(pxi2)==1;
                           rowa=100; rowb=0; cola=100; colb=0;
                    elseif pxf1-pxi1 <= pxf2-pxi2;
                         rowa=row1(pxi1:pxf1);
                         cola=col1(pxi1:pxf1);
                         rowb=row2(pxi2:(pxi2+pxf1-pxi1));         
                         colb=col2(pxi2:(pxi2+pxf1-pxi1));
                    else
                         rowa=row1(pxi1:(pxi1+pxf2-pxi2));
                         cola=col1(pxi1:(pxi1+pxf2-pxi2));
                         rowb=row2(pxi2:pxf2);         
                         colb=col2(pxi2:pxf2);
                    end
                    %having trimmed the two "paralell" fringes to the same lenght find the distance between the two pieces    
                    % (only if the paralell part is larger than min_len)
                    dist=0; distn=0;
                    if length(rowa)>= round(0.8*min_len*px_nm) && length(rowb)>= round(0.8*min_len*px_nm)
                     for k=1:length(rowa);
                       for l=1:length(rowb);
                        dist(l)=sqrt((rowa(k)-rowb(l))^2+(cola(k)-colb(l))^2);
                       end
                       distn(k)=min(dist);       
                     end
                     distance=(distn);
                     %distance=mean(distn);
                    else
                     distance=0;
                    end
                    %If the distance between the two fringes is less than max spacing allowednm then
                    %they are stacked
                    if sum(distance< (max_spa*px_nm))/numel(distance)==1 && mean(distance)>= min_spa*px_nm
                    %if distance<= (max_spa*px_nm) && distance>= min_spa*px_nm; 
                       %spacing(i,j)=(distance)/px_nm;
                       spacing(i,j)=mean(distance);
                       %figure
                       %imshow(fc);
                       %hold on
                       scatter(cola,rowa,2,'g','filled','o')
                       scatter(colb,rowb,2,'g','filled','o')
                       %export_fig(['C:\Users\Maria\Documents\Postdoc UdeA\HRTEM images\Cristian Avila - Imagenes TEM\HRTEM\Spacing\',fileName,'_',num2str(spacing(i,j)),'.tif'],'-transparent');
                       % hold on
                    else
                        spacing(i,j)=0; 
                    end       
                end
            end
            
        % If the fringe i is BIGGER than the fringe j and the fringes
        % orientation is between -45 and 45 degrees (tending to horizontal)
        else 
            if fringes.orientation(i) <= 45 && fringes.orientation(i) >= -45; 
                    %find if the fringe j respect to the fringe i
                    %trimming process
                disI=sqrt((row1-row2(1)).^2+(col1-col2(1)).^2);
                disF=sqrt((row1-row2(length(row2))).^2+(col1-col2(length(col2))).^2);
                pxi1=find(disI==min(disI)); %find(row1==row2(1));
                pxf1=find(disF==min(disF)); %find(row1==row2(length(row2)));
                if isempty(pxi1)==1 && isempty(pxf1)==1;
                else
                    if isempty(pxi1)==1;
                        pxi2=find(col2==col1(1));
                        pxi1=1;
                    else
                        pxi1=pxi1(1);
                        pxi2=1;
                    end
                    if isempty(pxf1)==1;
                        pxf2=find(col2==col1(length(col1)));
                        pxf1=length(col1);
                    else
                        pxf1=pxf1(length(pxf1));
                        pxf2=length(col2);
                    end
                    if isempty(pxf1)==1 || isempty(pxf2)==1 || isempty(pxi1)==1 || isempty(pxi2)==1;
                           rowa=100; rowb=0; cola=100; colb=0;
                    elseif pxf1-pxi1 <= pxf2-pxi2;
                         rowa=row1(pxi1:pxf1);
                         cola=col1(pxi1:pxf1);
                         rowb=row2(pxi2:(pxi2+pxf1-pxi1));         
                         colb=col2(pxi2:(pxi2+pxf1-pxi1));
                    else
                        rowa=row1(pxi1:(pxi1+pxf2-pxi2));
                        cola=col1(pxi1:(pxi1+pxf2-pxi2));
                        rowb=row2(pxi2:pxf2);         
                        colb=col2(pxi2:pxf2);
                    end
                    %having trimmed the two "paralell" fringes to the same lenght find the distance between the two pieces    
                    % (only if the paralell part is larger than min_len)
                    dist=0; distn=0;
                    if length(rowa)>= round(0.8*min_len*px_nm) && length(rowb)>= round(0.8*min_len*px_nm)
                     for k=1:length(rowa);
                       for l=1:length(rowb);
                        dist(l)=sqrt((rowa(k)-rowb(l))^2+(cola(k)-colb(l))^2);
                       end
                       distn(k)=min(dist);       
                     end
                     %distance=mean(distn);
                     distance=(distn);
                    else
                     distance=0;
                    end
                     %If the distance between the two fringes is less than max allowed space then
                    %they are stacked
                    if sum(distance< (max_spa*px_nm))/numel(distance)==1 && mean(distance)>= min_spa*px_nm
                    %if distance<= max_spa*px_nm && distance>= min_spa*px_nm; 
                        %spacing(i,j)=(distance)/px_nm;
                        spacing(i,j)=mean(distance);
                        %figure
                        %imshow(fc);
                        %hold on
                        scatter(cola,rowa,2,'g','filled','o')
                        scatter(colb,rowb,2,'g','filled','o')
                        %export_fig(['C:\Users\Maria\Documents\Postdoc UdeA\HRTEM images\Cristian Avila - Imagenes TEM\HRTEM\Spacing\',fileName,'_',num2str(spacing(i,j)),'.tif'],'-transparent');
                        % hold on
                    else
                        spacing(i,j)=0; 
                    end         
                end
            
        % If the fringe i is BIGGER thant the fringe j and the fringes
        % orientation is less -45 or more 45 degrees (tending to vertical)
            else fringes.orientation(i) >= 45 && fringes.orientation(i) <= -45; 
            %find if the fringe j respect to the fringe i
            %trimming process
            disI=sqrt((row1-row2(1)).^2+(col1-col2(1)).^2);
            disF=sqrt((row1-row2(length(row2))).^2+(col1-col2(length(col2))).^2);
            pxi1=find(disI==min(disI)); %find(row1==row2(1));
            pxf1=find(disF==min(disF)); %find(row1==row2(length(row2)));
               if isempty(pxi1)==1 && isempty(pxf1)==1;
               else
                   if isempty(pxi1)==1;
                        pxi2=find(row2==row1(1));
                        pxi1=1;
                    else
                        pxi1=pxi1(1);
                        pxi2=1;
                    end
                    if isempty(pxf1)==1;
                        pxf2=find(row2==row1(length(row1)));
                        pxf1=length(row1);
                    else
                        pxf1=pxf1(length(pxf1));
                        pxf2=length(row2);
                    end
                    if isempty(pxf1)==1 || isempty(pxf2)==1 || isempty(pxi1)==1 || isempty(pxi2)==1;
                           rowa=100; rowb=0; cola=100; colb=0;
                    elseif pxf1-pxi1 <= pxf2-pxi2
                         rowa=row1(pxi1:pxf1);
                         cola=col1(pxi1:pxf1);
                         rowb=row2(pxi2:(pxi2+pxf1-pxi1));         
                         colb=col2(pxi2:(pxi2+pxf1-pxi1));
                    else
                         rowa=row1(pxi1:(pxi1+pxf2-pxi2));
                         cola=col1(pxi1:(pxi1+pxf2-pxi2));
                         rowb=row2(pxi2:pxf2);         
                         colb=col2(pxi2:pxf2);
                    end
                    %having trimmed the two "paralell" fringes to the same lenght find the distance between the two pieces    
                    % (only if the paralell part is larger than min_len)
                    dist=0; distn=0;
                    if length(rowa)>= round(0.8*min_len*px_nm) && length(rowb)>= round(0.8*min_len*px_nm)
                     for k=1:length(rowa);
                       for l=1:length(rowb);
                        dist(l)=sqrt((rowa(k)-rowb(l))^2+(cola(k)-colb(l))^2);
                       end
                       distn(k)=min(dist);       
                     end
                     distance=(distn);
                     %distance=mean(distn);
                    else
                     distance=0;
                    end
                    %If the distance between the two fringes is less than max allowed space then
                    %they are stacked
                    if sum(distance< (max_spa*px_nm))/numel(distance)==1 && mean(distance)>= min_spa*px_nm
                    %if distance<= max_spa*px_nm && distance>= min_spa*px_nm; 
                        %spacing(i,j)=(distance)/px_nm;
                        spacing(i,j)=mean(distance);
                        %figure
                        %imshow(fc);
                        %hold on
                        scatter(cola,rowa,2,'g','filled','o')
                        scatter(colb,rowb,2,'g','filled','o')         
                        %export_fig(['C:\Users\Maria\Documents\Postdoc UdeA\HRTEM images\Cristian Avila - Imagenes TEM\HRTEM\Spacing\',fileName,'_',num2str(spacing(i,j)),'.tif'],'-transparent');
                        % hold on
                    else
                        spacing(i,j)=0; 
                    end
                end          
            end                
        end    
    end
%close all    
end

return