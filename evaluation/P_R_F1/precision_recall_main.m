% Given the path of prediction and ground truth, we finish the computation of statistic values as follows: 
% 1. binarize the predicted mask by using the fixed threshold like 0.5
% 2. calcate the P/R/F1, the F1 is the prior measure for ranking the algorithms
% 3. finish the stastic of all results and write the results to a file.
% 
predict_mask_path='path_of_the_prediction\'; % original network output by caffe model
gt_mask_path='path_of_the_gt\';  % gt needs to be converted to be binary in advanve!!, please refer to mask_2_bn.m
output_file_path='path_of_the_save\';

savepath=[output_file_path,'mask_binary_prf1_statics1.txt'];
fids= fopen(savepath,'w');

threshold_set =(0.5); % 0:0.01:1
m=length(threshold_set);

for k=1:m
    threshold = threshold_set(k);
    disp(sprintf('Performing %d th computation, threshold is %.2f',k,threshold));
    recall=[];
    precision=[];
    f_measure=[];
    files = dir([predict_mask_path, '*.png']);
    n = length(files);
    j=1;
    for i = 1:n
        [filename, type] = strtok(files(i).name, '.');
        msk = imread([predict_mask_path, filename,'.png']);
        msk=im2bw(msk,threshold);
        gt_file = [gt_mask_path,  filename,'.bmp'];
        gt_msk=imread(gt_file);
        [p,r,f1]=compute_image(msk,gt_msk);
        if(f1~=0)  % Do not Consider the prediction and gt mask are all background, namely out-of-sclera(f1=0) 
            recall(j)=r;
            precision(j)=p;
            f_measure(j)=f1;
            j=j+1;
        end
        progressbar(i/n);
    end
    num=length(recall);
    if(num~=0)
        recall_avg=mean(recall);
        recall_std=std(recall);  %standard deviation
        precision_avg=mean(precision);
        precision_std=std(precision);
        
        f_measure_avg=mean(f_measure);
        f_measure_std=std(f_measure);
        
        fprintf(fids,'threshold: %.2f  recall_avg: %.4f  recall_std: %.4f  precision_avg: %.4f  precision_std: %.4f  f_measure_avg: %.4f  f_measure_std: %.4f\n',threshold, recall_avg,...
            recall_std,precision_avg,precision_std,f_measure_avg,f_measure_std);
    end
end
fclose(fids);
