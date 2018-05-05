%%Function that creates a background, subsequently subtracts each frame
%from it and applies LOG and binarization to find the detections.
%%
function pre_proc(left_cam, right_cam)  %Input: left and right video sequence.
%% Video objects.
v1=VideoReader(left_cam);
v2=VideoReader(right_cam);
v3=VideoWriter('max_subtract_l.avi');
v3.FrameRate=150;
v4=VideoWriter('max_subtract_r.avi');
v4.FrameRate=150;

%% Calculate maximum intensity projection - currently over all frames for testing. If you take a good background shot before
%video capture, this block can be omitted.
Max_l=readFrame(v1);    %Variable to accumulate the background.
im1=Max_l;              %Initialize with first frame.
Max_r=readFrame(v2);
im2=Max_r;
frame=im1;
i=1;
while hasFrame(v1)&&hasFrame(v2)    %Aggregate max value.
    im1=readFrame(v1);
    Max_l=max(Max_l,im1);
    
    im2=readFrame(v2);
    Max_r=max(Max_r,im2);
    
    i=i+1;
end

%% Subtract maximum intensity - equals background subtraction.
mxx=imread('MAX_10-10-17_18-49-41.000-l.bmp');   %delete after testing.
mxy=imread('MAX_10-10-17_18-49-41.000-r.bmp');   %delete after testing.

v1=VideoReader(left_cam);
v2=VideoReader(right_cam);
i=1;
open(v3);
open(v4);

while hasFrame(v1)&&hasFrame(v2) %Loop over all frames
    im1=readFrame(v1);
    frame=mxx-im1;  %%using the image with edited out flies. Should be replaced back with Max_l if the block above was not skipped.
    writeVideo(v3,frame);
    
    im2=readFrame(v2);
    frame=mxy-im2;  %%using the image with edited out flies. Should be replaced back with Max_r
    writeVideo(v4,frame);
    
    i=i+1;
end
close(v3);
close(v4);
%% Convolution
hsizeh=20; sig=5.5;     %Define LoG convolution. H and sigma correspond to the relative fly appearance.
h=fspecial('log',hsizeh,sig);

v5=VideoReader('rect_l.avi');       %Here the previously calculated background subtractions were rectified for lens distortions
v6=VideoReader('rect_r.avi');       %manually with the undistort.m function and those videos are taken as input.
i=1;

Det_left=zeros(0,3);    %Datastructure to store detections.
Det_right=zeros(0,3);


for j=1:300 %while hasFrame(v5)&&hasFrame(v6) %get blobs and coords
    im1=rgb2gray(readFrame(v5));    %Make sure we take the grayvalues.
    im1=imgaussfilt(im1,2);         %good to discuss why gauss works better than median in thesis :)
    c1=convn(imcomplement(im1),h,'same');   %apply convolution, 'same' means overlay result over original.
    c1=im2bw(c1,0.05);                      %binarization with threshold.
    c1=bwareaopen(c1-bwareaopen(c1,160),10);    %filter only blobs between 10-160 pizel area.
    labeledImage=bwlabel(c1,8);                 %get image labels.
    blobMeasurements=regionprops(labeledImage,'Centroid'); %get properties.
    centroids=[blobMeasurements.Centroid];  %find centroids.
    centroidsX=centroids(1:2:end-1);        %get X of centroids.
    centroidsY=centroids(2:2:end);          %get Y of centroids.
    [~,s]=size(centroidsX);                 %get number of elements.
    
    Det_left=[Det_left;i*ones(s,1),centroidsX',centroidsY'];    %Write all detections in the data structure.
    
    im2=rgb2gray(readFrame(v6));       %Exactly the same as above for the second camera.
    im2=imgaussfilt(im2,2);
    c2=convn(imcomplement(im2),h,'same');
    c2=im2bw(c2,0.05);
    c2=bwareaopen(c2-bwareaopen(c2,160),10);
    labeledImage=bwlabel(c2,8);
    blobMeasurements=regionprops(labeledImage,'Centroid');
    centroids=[blobMeasurements.Centroid];
    centroidsX=centroids(1:2:end-1);
    centroidsY=centroids(2:2:end);
    [~,s]=size(centroidsX);
    
    Det_right=[Det_right;i*ones(s,1),centroidsX',centroidsY'];
    
    i=i+1;
end
save('Det_left.mat','Det_left');    %Export the data.
save('Det_right.mat','Det_right');

end