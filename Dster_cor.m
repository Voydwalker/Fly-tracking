%%Script that takes the triangulated coordinates and attempts to
%%reconstruct the 3d tracks.
%%
sz=0;
[sz,~]=size(ThD);  %number of elements
fr=ThD(sz,1);
Active=[];  %active track id's
Ass={}; %assignments
Tracks={};  %track_Id X {x, y, z}
Trac=[];  %tracks as matrix vertical <- this one i need.
one=find(ThD(:,1)==1);
[sz,~]=size(one);

for i=1:sz  %fill in tracks for first frame
    Trac(i,1:5)=[1,i,ThD(one(i),2),ThD(one(i),3),ThD(one(i),4)];
    Tracks{i,1}=[ThD(one(i),2),ThD(one(i),3),ThD(one(i),4)];
end


maxid=sz;
for i=1:fr-1
    as=cellfun(@isempty,Tracks(:,1));   %check which id are empty in current frame
    one=find(Trac(:,1)==i);   %positions in first frame
    ids=Trac(one,2);    %id's for tracks in first frame
    two=find(ThD(:,1)==i+1); %positions in second frame
    D=edist(Trac(one,3:5),ThD(two,2:4)); %distance
    a=munkres(D);  %assignment for tracks.
    
    
    %TODO
    %replace the Nearest Neighbor approach with a Kalman Filter!
    
    %update tracks
    [~,sy]=size(a);

    for j=1:sy  %fill in tracks for first frame
        Tracks{j,i+1}=[ThD(two(j),2),ThD(two(j),3),ThD(two(j),4)];
        ab=a(j);
        if numel(ids)<ab %if more detections than track id's
            maxid=maxid+1;
            Trac(sz+j,1:5)=[i+1,maxid,ThD(two(j),2),ThD(two(j),3),ThD(two(j),4)];
        else if a(j)~=0 %if en element is assigned
                Trac(sz+j,1:5)=[i+1,ids(a(j)),ThD(two(j),2),ThD(two(j),3),ThD(two(j),4)];
            end     %unassigned entries end up as 0 rows and need to be discarded later
        end

    end
    sz=sz+sy;
end

Trac=Trac(any(Trac,2),:);   %deletes empty rows.


%% Euclidean distance function
function dist=edist(one,two) %euclidean distance between frames.
[y1,~]=size(one);  %[2,N]
[y2,~]=size(two); %[2,M]
dist=Inf(y1,y2);    %initialize distance.

l=one(1,:);  %first frame first pair xy
r=two(1,:);  %second frame first pair xy

for i=1:y1
    for j=1:y2
        l=one(i,:);
        r=two(j,:);
        a=sqrt(abs(r(1,1)-l(1,1))^2+abs(r(1,2)-l(1,2))^2+abs(r(1,3)-l(1,3))^2);
        if a<100
            dist(i,j)=a;
        end
    end
end

end
