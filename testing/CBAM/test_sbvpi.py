# -*- coding: utf-8 -*-
"""
Created on Wed Jan 24 15:46:35 2018

@author: wcy
"""
import numpy as np
import scipy.misc
import cv2
import scipy.io
import os, sys, argparse
import time
from os.path import join, splitext, split, isfile
parser = argparse.ArgumentParser(description='Forward all testing images.')
parser.add_argument('--model', type=str, default='Sclera_sbvpi.caffemodel') 
parser.add_argument('--net', type=str, default='deploy_bottom_up.pt')
parser.add_argument('--gpu', type=int, default=4)
args = parser.parse_args()
caffe_root = 'path_of_caffe'
sys.path.insert(0, caffe_root + 'python')
import caffe
EPSILON = 1e-8

def forward(data):
  assert data.ndim == 3
  data -= np.array((104.00698793,116.66876762,122.67891434))
  data = data.transpose((2, 0, 1))
  net.blobs['data'].reshape(1, *data.shape)
  net.blobs['data'].data[...] = data
  return net.forward()

def load_scale_image(path, width=0,height=0):
    """
    Load image from a given path and pad it on the sides, so that eash side is divisible by 32 (newtwork requirement)
    
    if pad = True:
        returns image as numpy.array, tuple with padding in pixels as(x_min_pad, y_min_pad, x_max_pad, y_max_pad)
    else:
        returns image as numpy.array
    """
    img = cv2.imread(str(path)).astype(np.float32)
    if img.ndim == 2:
       img = img[:, :, np.newaxis]
       img = np.repeat(img, 3, 2)
    
    
    ori_height, ori_width, _ = img.shape
    
    img = cv2.resize(img, (width, height), interpolation=cv2.INTER_CUBIC).astype(np.float32)

    return img, (ori_width, ori_height)  

def scale_image(img, org_size):
    """
    img: numpy array of the shape (height, width)
    pads: (pad_height, pad_width) 
    
    @return padded image
    """
    img1 = cv2.resize(img, org_size, interpolation=cv2.INTER_CUBIC).astype(np.float32)
    return img1    
  
def load_image(path, width=0,height=0, pad=True):
    """
    Load image from a given path and pad it on the sides, so that eash side is divisible by 32 (newtwork requirement)
    
    if pad = True:
        returns image as numpy.array, tuple with padding in pixels as(x_min_pad, y_min_pad, x_max_pad, y_max_pad)
    else:
        returns image as numpy.array
    """
    img = cv2.imread(str(path)).astype(np.float32)
    if img.ndim == 2:
       img = img[:, :, np.newaxis]
       img = np.repeat(img, 3, 2)
    
    if not pad:
        return img
    
    ori_height, ori_width, _ = img.shape
    
    if width==0:   #选择距离标准最近的大小
            k = int(np.ceil((ori_width+31)/32.0))
            width = 32*k-31
    if height==0:
            k = int(np.ceil((ori_height+31)/32.0))
            height = 32*k-31
    
    pad_height = max(height - ori_height, 0);
    pad_width  = max(width - ori_width, 0);
    
    print("width:{},height:{}".format(width,  height ))
    
    img = cv2.copyMakeBorder(img, 0, pad_height, 0, pad_width, cv2.BORDER_REFLECT_101)

    return img, (pad_height, pad_width)  

def crop_image(img, pads):
    """
    img: numpy array of the shape (height, width)
    pads: (pad_height, pad_width) 
    
    @return padded image
    """
    (pad_height, pad_width)  = pads
    height, width = img.shape[-2:] 
    
    if len(img.shape) == 2:
        return img[0:height - pad_height, 0:width - pad_width]
    elif len(img.shape)==3:
        return img[:,0:height - pad_height, 0:width - pad_width]
    else:
        return img
    
def create_labels(map,threshold=0.5): #h*w
    labels=(map>=threshold).astype(np.float32)
    return labels


assert isfile(args.model) and isfile(args.net), 'file not exists'
USE_GPU = True
if USE_GPU:
   caffe.set_device(args.gpu)
   caffe.set_mode_gpu()
else:
   caffe.set_mode_cpu()

net = caffe.Net(args.net, args.model, caffe.TEST)
test_dir = '/data3/caiyong.wang/data/sclera/SBVPI/test/image/' # test images directory
save_mask_dir = join('/data3/caiyong.wang/ScleraSegNet/CBAM/test/SBVPI/', splitext(split(args.model)[1])[0],'mask/') # directory to save results
if not os.path.exists(save_mask_dir):
    os.makedirs(save_mask_dir) 
    
    
imgs = [i for i in os.listdir(test_dir) if '.jpg' in i]
nimgs = len(imgs)
print "totally "+str(nimgs)+" images"
start = time.time()
for i in range(nimgs):
  img_path = join(test_dir, imgs[i])
  img, org_size = load_scale_image(img_path,609,353)
  
  forward(img)
  
  
  mask_out1 = scale_image(net.blobs['sigmoid_fuse_mask_1'].data[0][0,:,:],org_size)

  
  fn, ext = splitext(imgs[i])
  scipy.misc.imsave(join(save_mask_dir, fn+'.jpg'),mask_out1)
  
  
  print "Saving to '" + join(save_mask_dir, imgs[i][0:-4]) + "', Processing %d of %d..."%(i + 1, nimgs) 
end = time.time()
avg_time = (end-start)/nimgs
print("average time is %f seconds"%avg_time)
