function [p,r,f1]=compute_image(msk,gt)
% msk: the results of prediction
% gt: ground truth mask

   interaction =and(msk,gt);
%   union = or(msk,gt);
   g_left=xor(gt,interaction);
   msk_left=xor(msk,interaction);
   
   tp=nnz(interaction)/numel(msk);
  % tn=nnz(~union)/numel(msk);
   fn=nnz(g_left)/numel(msk);
   fp=nnz(msk_left)/numel(msk); 
   
   if((tp+fp)<=eps||(tp+fn)<=eps||tp<eps)
      p=0;
      r=0;
      f1=0;
   else
       p=tp/(tp+fp);
       r=tp/(tp+fn);
       f1=2*p*r/(r+p);
   end