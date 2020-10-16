

function coordinates=fringe_sorting(I8)

cc=bwconncomp(I8,8); % store the new info of connected fringes after eliminating H, Y, T connections
numPixels = cellfun(@numel,cc.PixelIdxList); %number of pixels on each fringe

%Pixel connection are defined as    a.  d.  .f
%                                   b.   .  .g  
%                                   c.  e.  .h                

for i=1:length(numPixels)
    fring= cell2mat(cc.PixelIdxList(i));
    [row col]=ind2sub(size(I8),fring);
    cont=0; pxl=0;conn=zeros(length(fring),8);Nconn=zeros(size(fring));
    fr_T_Y=0; %count for fringes that has Y or T (three connection)
    for j=1:length(fring);
        a=I8(row(j)-1,col(j)-1);b=I8(row(j)-1,col(j));c=I8(row(j)-1,col(j)+1);d=I8(row(j),col(j)-1);e=I8(row(j),col(j)+1);f=I8(row(j)+1,col(j)-1);g=I8(row(j)+1,col(j));h=I8(row(j)+1,col(j)+1); % there are 8 possible connections of each fringe a,b,c,d,e,f,g,h if more than 2 are true then the fringe has a branch
        conn(j,:)= [a b c d e f g h];
        Nconn(j)=a+b+c+d+e+f+g+h;       
    end
    
    % Fringe sorting
    if isempty(find(Nconn==1))==1
    else
     if Nconn(1)~=1  % If the first pixel is not a starting/end point then change it
        k=find(Nconn==1);
        changeR=row(1);changeC=col(1);
        row(1)=row(k(1));col(1)=col(k(1));row(k(1))=changeR;col(k(1))=changeC;
     end
     conn=zeros(length(fring),8);Nconn=zeros(size(fring)); %re-start the connectivities
     for j=1:length(fring)-1;
        a=I8(row(j)-1,col(j)-1);b=I8(row(j)-1,col(j));c=I8(row(j)-1,col(j)+1);d=I8(row(j),col(j)-1);e=I8(row(j),col(j)+1);f=I8(row(j)+1,col(j)-1);g=I8(row(j)+1,col(j));h=I8(row(j)+1,col(j)+1); % there are 8 possible connections of each fringe a,b,c,d,e,f,g,h if more than 2 are true then the fringe has a branch
        conn(j,:)= [a b c d e f g h];
        Nconn(j)=a+b+c+d+e+f+g+h; 
        m=find(conn(j,:)); %find the position where there is a connection
     
        if Nconn(j)==1
       % For pixels with two connections find the previous and discard it, take pthe forward connectivity 
        elseif Nconn(j)==2 
            if row(j)-1==prevR && col(j)-1==prevC %position a
               m(find(m==1))=0;
               m=m(m~=0);               
            elseif row(j)-1==prevR && col(j)==prevC %position b
               m(find(m==2))=0;
               m=m(m~=0);               
            elseif row(j)-1==prevR && col(j)+1==prevC %position c
               m(find(m==3))=0;
               m=m(m~=0);                               
            elseif row(j)==prevR && col(j)-1==prevC %position d
               m(find(m==4))=0;
               m=m(m~=0);               
            elseif row(j)==prevR && col(j)+1==prevC %position e
               m(find(m==5))=0;
               m=m(m~=0);               
            elseif row(j)+1==prevR && col(j)-1==prevC %position f
               m(find(m==6))=0;
               m=m(m~=0);                               
            elseif row(j)+1==prevR && col(j)==prevC %position g
               m(find(m==7))=0;
               m=m(m~=0);                              
            elseif row(j)+1==prevR && col(j)+1==prevC %position h
               m(find(m==8))=0;
               m=m(m~=0);                                  
            end
        end
            if m==1 %position a
                row(j+1)=row(j)-1; col(j+1)=col(j)-1;
            elseif m==2 %position b
                row(j+1)=row(j)-1; col(j+1)=col(j);
            elseif m==3 %position c
                row(j+1)=row(j)-1; col(j+1)=col(j)+1;
            elseif m==4 %position d
                row(j+1)=row(j); col(j+1)=col(j)-1;
            elseif m==5 %position e
                row(j+1)=row(j); col(j+1)=col(j)+1;
            elseif m==6 %position f
                row(j+1)=row(j)+1; col(j+1)=col(j)-1;
            elseif m==7 %position g
                row(j+1)=row(j)+1; col(j+1)=col(j);
            elseif m==8 %position h
                row(j+1)=row(j)+1; col(j+1)=col(j)+1;    
            end
        prevR=row(j);
        prevC=col(j);
     end
    end
 coordinates(i).XY=[row col];

end

return
