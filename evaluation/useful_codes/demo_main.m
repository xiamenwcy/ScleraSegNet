% show the predcition results of hard examples based on the gt  

clear;clc;
imgpath= 'path_of_the_image\'; % original images
gtpath = 'path_of_the_gt\'; % bindary mask
msk_dir = 'path_of_the_prediction'; % bindary mask
save_dir = 'path_of_the_save';
 
files = dir([imgpath, '*.jpg']);
n = length(files);

for i = 1:n
    [filename, type] = strtok(files(i).name, '.');
    img = imread([imgpath, files(i).name]);
    gt = imread([gtpath, filename,'.bmp']);
    msk= imread([msk_dir, filename,'.bmp']);
    
    overlay_img=hard_show_complete(img,gt,msk); 
    
    overlay_img_savename = [save_dir, filename,'_over','.bmp'];
    
    imwrite(overlay_img,overlay_img_savename);
end


