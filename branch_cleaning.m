
function I9=branch_cleaning(I8,px_nm,min_len)
%Algorithm to eliminate branch points: 
% - For each separate fringe find the branch points and delete them
% - Measure the size of the branches and delete the smaller ones
% - If there are still branches, iterate until no branches
% - If during the braking, a new non-branched fringe is generate, keep it


% -------  First rough elimination of fringes smaller than the criteria
cc1=bwconncomp(I8,8);% number of pixels on each fringe
numPixels1 = cellfun(@numel,cc1.PixelIdxList);
labels=bwlabeln(I8,8);
I8= bwmorph(I8,'skel');
min_pix= round(min_len*px_nm);
branchpoints=length(nonzeros(bwmorph(I8,'branchpoints')));
a=find(numPixels1*sqrt(2) <min_pix);
for k=1:length(a);
    b= cell2mat(cc1.PixelIdxList(a(k)));
    I8(b)=0;
end
cc1=bwconncomp(I8,8);% store all the info of the connected fringes
numPixels1 = cellfun(@numel,cc1.PixelIdxList);% number of pixels on each fringe
labels=bwlabeln(I8,8);
%imshow(I8);
for i=1:length(numPixels1);
    b= cell2mat(cc1.PixelIdxList(i));
    I9=I8;I9(:)=0;I9(b)=1;
    B=bwmorph(I9,'branchpoints');
    E=bwmorph(I9,'endpoints');
    [y,x]=find(bwmorph(I9,'branchpoints'));
    %While there are still branchpoint in the fringe/fringes
    while numel(x)>0;
        %Create a new image (branches) with eliminated branchpoints
        branches= I9 & ~B;
        bp=[y,x];
        %If there are still branchpoint then count them and eliminate them
        if ~isempty(find(bwmorph(branches,'branchpoints')));
            [y1,x1]=find(bwmorph(branches,'branchpoints'));
            bp=[y,x;y1,x1];
            branches= branches & ~bwmorph(branches,'branchpoints');
        end
        %Label and measure size in pixels of each branch
        branchLabels=bwlabel(branches,8);
        branchConn=bwconncomp(branches,8);
        %number of pixels per branch
        Branchpix = cellfun(@numel,branchConn.PixelIdxList);

        %Depending on the type of branches eliminate the branch or the branch
        %point
        % 1-If after breaking only two branches are generated then delete the
        %branch point
        if length(Branchpix)==2;
            I9(find(B==1))=0; %delete the branchpoint
            I8(find(B==1))=0; %delete the branchpoint
            % 2-If there are several branches and more than one branch is smallest
            % And those smaller branches are less than the minimum fringe size
            % allowed. Delete the branches
        elseif length(find(Branchpix==(min(Branchpix))))>1 ...
                && min(Branchpix)<=min_pix;
            mins=find(Branchpix==(min(Branchpix)));
            for j=1:length(mins);
                %delete smaller branch
                I9(find(branchLabels==mins(j)))=0;
                I8(find(branchLabels==mins(j)))=0;
            end
            % 3-If there are several branches and more than one branch is
            % smallest. And those smaller branches are larger than the minimum
            % fringe size allowed. Delete the branchpoint
        elseif length(find(Branchpix==(min(Branchpix))))>1 ...
                && min(Branchpix)>min_pix;
            mins=find(Branchpix==(min(Branchpix)));
            %for each smaller branch find the branch point to break it
            for j=1:length(mins);
                a=find(branchLabels==mins(j));
                mask=I8;mask(:)=false;mask(a)=true;
                %find the endpoints of the branch
                [epy,epx]=find(bwmorph(mask,'endpoints'));

                if isempty(epy); %if the branch is a closed loop
                    I9(a)=0;
                    I8(a)=0;
                else
                    %find the branchpoints next to the endpoints of the branch
                    bp1=find((bp(:,1)==epy(1)&bp(:,2)==epx(1)+1)|...
                        (bp(:,1)==epy(1)&bp(:,2)==epx(1)-1)|...
                        (bp(:,1)==epy(1)+1&bp(:,2)==epx(1)-1)|...
                        (bp(:,1)==epy(1)+1&bp(:,2)==epx(1))|...
                        (bp(:,1)==epy(1)+1&bp(:,2)==epx(1)+1)|...
                        (bp(:,1)==epy(1)-1&bp(:,2)==epx(1)-1)|...
                        (bp(:,1)==epy(1)-1&bp(:,2)==epx(1))|...
                        (bp(:,1)==epy(1)-1&bp(:,2)==epx(1)+1)|...
                        (bp(:,1)==epy(2)&bp(:,2)==epx(2)+1)|...
                        (bp(:,1)==epy(2)&bp(:,2)==epx(2)-1)|...
                        (bp(:,1)==epy(2)+1&bp(:,2)==epx(2)-1)|...
                        (bp(:,1)==epy(2)+1&bp(:,2)==epx(2))|...
                        (bp(:,1)==epy(2)+1&bp(:,2)==epx(2)+1)|...
                        (bp(:,1)==epy(2)-1&bp(:,2)==epx(2)-1)|...
                        (bp(:,1)==epy(2)-1&bp(:,2)==epx(2))|...
                        (bp(:,1)==epy(2)-1&bp(:,2)==epx(2)+1));
                    %if the branchpoint is not next to the endpoints, but next
                    %to any other pixel, then search each pixel of the branch
                    %to find the branch point
                    if isempty(bp1);
                        for p=1:length(a);
                            [epy1,epx1]=ind2sub(size(I8),a(p));
                            bp2=find((bp(:,1)==epy1(1)&bp(:,2)==epx1(1)+1)|...
                                (bp(:,1)==epy1(1)&bp(:,2)==epx1(1)-1)|...
                                (bp(:,1)==epy1(1)+1&bp(:,2)==epx1(1)-1)|...
                                (bp(:,1)==epy1(1)+1&bp(:,2)==epx1(1))|...
                                (bp(:,1)==epy1(1)+1&bp(:,2)==epx1(1)+1)|...
                                (bp(:,1)==epy1(1)-1&bp(:,2)==epx1(1)-1)|...
                                (bp(:,1)==epy1(1)-1&bp(:,2)==epx1(1))|...
                                (bp(:,1)==epy1(1)-1&bp(:,2)==epx1(1)+1));
                            if ~isempty(bp2);
                                bp1=[bp1,bp2'];
                            end
                        end
                        bp1=nonzeros(bp1');
                    end
                    %delete the branchpoint
                    I9(bp(bp1(length(bp1)),1),bp(bp1(length(bp1)),2))=0;
                    I8(bp(bp1(length(bp1)),1),bp(bp1(length(bp1)),2))=0;
                end
            end
            % 4-If there are several branches and the smallest branch is less
            % than the minimum fringe size allowed then delete that branch
        elseif min(Branchpix)<=min_pix;
            %delete smaller branch
            I9(find(branchLabels==(find(Branchpix==(min(Branchpix))))))=0;
            I8(find(branchLabels==(find(Branchpix==(min(Branchpix))))))=0;
            % 5-If there are several branches and the smallest branch is larger
            % than minimum fringe size allowed then only delete the branchpoint
        elseif min(Branchpix)>min_pix;
            % find the smallest branch
            a=find(branchLabels==find(Branchpix==(min(Branchpix))));
            mask=I8;mask(:)=false;mask(a)=true;
            %find the end points of the branch
            [epy,epx]=find(bwmorph(mask,'endpoints'));

            if isempty(epy); %if the branch is a closed loop
                I9(a)=0;
                I8(a)=0;
            else
                %find the branchpoints next to the endpoints of the branch
                bp1=find((bp(:,1)==epy(1)&bp(:,2)==epx(1)+1)|...
                    (bp(:,1)==epy(1)&bp(:,2)==epx(1)-1)|...
                    (bp(:,1)==epy(1)+1&bp(:,2)==epx(1)-1)|...
                    (bp(:,1)==epy(1)+1&bp(:,2)==epx(1))|...
                    (bp(:,1)==epy(1)+1&bp(:,2)==epx(1)+1)|...
                    (bp(:,1)==epy(1)-1&bp(:,2)==epx(1)-1)|...
                    (bp(:,1)==epy(1)-1&bp(:,2)==epx(1))|...
                    (bp(:,1)==epy(1)-1&bp(:,2)==epx(1)+1)|...
                    (bp(:,1)==epy(2)&bp(:,2)==epx(2)+1)|...
                    (bp(:,1)==epy(2)&bp(:,2)==epx(2)-1)|...
                    (bp(:,1)==epy(2)+1&bp(:,2)==epx(2)-1)|...
                    (bp(:,1)==epy(2)+1&bp(:,2)==epx(2))|...
                    (bp(:,1)==epy(2)+1&bp(:,2)==epx(2)+1)|...
                    (bp(:,1)==epy(2)-1&bp(:,2)==epx(2)-1)|...
                    (bp(:,1)==epy(2)-1&bp(:,2)==epx(2))|...
                    (bp(:,1)==epy(2)-1&bp(:,2)==epx(2)+1));
                %if the branchpoint is not next to the endpoints, but next
                %to any other pixel, then search each pixel of the branch
                %to find the branch point
                if isempty(bp1);
                    for p=1:length(a);
                        [epy1,epx1]=ind2sub(size(I8),a(p));
                        bp2=find((bp(:,1)==epy1(1)&bp(:,2)==epx1(1)+1)|...
                            (bp(:,1)==epy1(1)&bp(:,2)==epx1(1)-1)|...
                            (bp(:,1)==epy1(1)+1&bp(:,2)==epx1(1)-1)|...
                            (bp(:,1)==epy1(1)+1&bp(:,2)==epx1(1))|...
                            (bp(:,1)==epy1(1)+1&bp(:,2)==epx1(1)+1)|...
                            (bp(:,1)==epy1(1)-1&bp(:,2)==epx1(1)-1)|...
                            (bp(:,1)==epy1(1)-1&bp(:,2)==epx1(1))|...
                            (bp(:,1)==epy1(1)-1&bp(:,2)==epx1(1)+1));
                        if ~isempty(bp2);
                            bp1=[bp1,bp2'];
                        end
                    end
                    bp1=nonzeros(bp1');
                end
                %delete branch point
                I9(bp(bp1(length(bp1)),1),bp(bp1(length(bp1)),2))=0;
                I8(bp(bp1(length(bp1)),1),bp(bp1(length(bp1)),2))=0;
            end
        end
        % If new fringes are generated from the breaking, check whether they
        % also have branches, otherwise remove them from the breaking loop
        newConn=bwconncomp(I9,8);
        if newConn.NumObjects>1; % more than one fringe
            labels1=bwlabeln(I9,8);
            B1=0;
            % Analyse each fringe in a mask image and check if they have
            % branchpoint
            for k=1:newConn.NumObjects;
                Dmask=false(size(I9));
                Dmask(labels1 == k)=true;
                B1(k)=length(find(bwmorph(Dmask,'branchpoints')));
                %If they don't have branch points, then discard them
                if B1(k)==0;
                    I9(find(labels1==k))=false;
                end
            end

        else
        end
        % Check whether the remaining fringe/fringes have brnaches
        B=bwmorph(I9,'branchpoints');
        [y,x]=find(bwmorph(I9,'branchpoints'));
        bp=0;
    end
end


% --------  Eliminate single isolated pixels
I9= bwmorph(I8,'clean');



%********** OLD ALGORITHM ******
% --------  Eliminate H connections and Y and T connections (i.e pixels 
% --------  that are connected to four and three other pixels) and isolated
% --------  pixels that appear after breaking
% for i=1:length(numPixels1);
%     fring= cell2mat(cc1.PixelIdxList(i));
%     [row col]=ind2sub(size(I8),fring);
%     cont(i)=0;
%     pxl=0;
%     for j=1:length(fring);
%         
%     % there are 8 possible connections of each fringe a,b,c,d,e,f,g,h if 
%     % more than 2 are true then the fringe has a branch
%         a=I8(row(j)-1,col(j)-1);b=I8(row(j)-1,col(j));c=I8(row(j)-1,col(j)+1);
%         d=I8(row(j),col(j)-1);e=I8(row(j),col(j)+1);f=I8(row(j)+1,col(j)-1);
%         g=I8(row(j)+1,col(j));h=I8(row(j)+1,col(j)+1); 
%         conn=a+b+c+d+e+f+g+h; 
%         ConnFringe(i).Pixel(j)=conn;
%         if conn== 4 %H connection
%             I8(row(j),col(j))=0; %eliminate that pixel to break the branches
%             %I8(row(:),col(:))=0; %eliminate the fringe
%         elseif conn== 3 % Y or Tconnection
%             cont(i)=cont(i)+1;
%             pxl(cont(i))=j;
%             %I8(row(:),col(:))=0; %eliminate the fringe
%         end
%     end
%     if cont(i) >= 1  % number of Y or Tconnections (pixels that have three neighbours) allowed in a fringe
%        for k=1:length(pxl)
%            l=pxl(k);
%            I8(row(l),col(l))=0; %eliminate the pixel that causes Y or T branch
%        end
%     end
% end
% 
% % -------- Eliminate single isolated pixels
% I8= bwmorph(I8,'clean');
% imshow(I8);
return