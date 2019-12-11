
% convert the mask to be binary
clear;clc;
msk_dir = 'mask';  
save_dir='mask_binary'; 
files = dir([msk_dir, '*.png']);
n = length(files);
if ~exist(save_dir,'dir') 
    mkdir(save_dir)
end

for i = 1:n
    [filename, type] = strtok(files(i).name, '.');
    msk = imread([msk_dir, filename,'.png']);  
    msk=im2bw(msk,0.5);
    imwrite(msk,[save_dir, filename,'.bmp']);
    progressbar(i/n);
end
 