%%After the detections have been saved, this script finds the
%%correspondences and triangulates the detections.
%%
v1=VideoReader('rect_l.avi');   %video objects
v2=VideoReader('rect_r.avi');

lf=readFrame(v1);	%initialize first frame
rt=readFrame(v2);
s=size(Det_left);
s=Det_left(s);  %amount of frames


for i=1:s %frames
    sub_l=Det_left(Det_left(:,1)==i,:);
    [sl,~]=size(sub_l);
    sub_r=Det_right(Det_right(:,1)==i,:);
    [sr,~]=size(sub_r);
    
    subplot(2,1,1); %just to visualize correspondences/can be skipped.
    imshow(lf);
    hold on
    
    Dist=Inf(sl(1),sr(1));  %initialize distance matrix with infinity.
    
    for j=1:sl %#detections
        P=sub_l(j,:);
        Line=ret*[P(2);P(3);1]; %calculate epiline. ret is the Fundamental matrix after its calculation.
        
        subplot(2,1,1);   %plots points and corresponding eplines
        plot(P(2),P(3),'mo');
        
        for k=1:sr  %detections
            Q=sub_r(k,:);
            ds=abs(Line(1)*Q(2)+Line(2)*Q(3)+Line(3))/sqrt(Line(1)^2+Line(2)^2);    %calculate distance between the epiline and points.
            if ds<500       %discard distances greater than 500.
                Dist(j,k)=ds;
            end
        end
    end
    
    
    a=munkres(Dist);    %calculate assignment with Hungarian algo.
    asize=size(a);
    
    sub_l(a==0,:)=[];   %clear non matches
    a(a==0)=[];

    [xl,~]=stereo_triangulation(sub_l(:,2:3)',sub_r(a,2:3)',om,T,fc_left,cc_left,kc_left,alpha_c_left,fc_right,cc_right,kc_right,alpha_c_right);    %Use the function provided with the Calibration toolbox.
    xl=xl';
    
    ThD=[ThD;[ones(asize(2),1)*i,xl(:,1),xl(:,2),xl(:,3)]]; %Save the triangulated coordinates.
end