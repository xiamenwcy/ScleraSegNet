function  overlay_img=hard_show_complete(img,gt,msk) 

interaction =and(msk,gt);  %tp  blue
g_left=xor(gt,interaction);  %fn red
msk_left=xor(msk,interaction); %fp  green

[m,n]=size(msk);
alpha=0.6;   %foreground 
beta=0.4;    %background
for i=1:m;
    for j=1:n;
        if(g_left(i,j)==1)   %fn
            img(i,j,1)=255*alpha+img(i,j,1)*beta;
            img(i,j,2)=0*alpha+img(i,j,2)*beta;
            img(i,j,3)=0*alpha+img(i,j,3)*beta;
        elseif(msk_left(i,j)==1)  %fp
            img(i,j,1)=0*alpha+img(i,j,1)*beta;
            img(i,j,2)=255*alpha+img(i,j,2)*beta;
            img(i,j,3)=0*alpha+img(i,j,3)*beta;
        elseif(interaction(i,j)==1) %tp
             img(i,j,1)=0;
            img(i,j,2)=0;
            img(i,j,3)=255;
        end
    end
end
overlay_img = img;
%imshow(img);