"""
Some codes from https://github.com/Newmu/dcgan_code
"""
from __future__ import division
import math
import pprint
import scipy.misc
import numpy as np
import copy
try:
    _imread = scipy.misc.imread
except AttributeError:
    from imageio import imread as _imread

### for calculating snr cnr in matlab
'''import matlab.engine
eng = matlab.engine.start_matlab()
eng.addpath(r'../MATLAB/matlab_scripts/')
eng.addpath(r'../MATLAB/matlab_scripts/Image_Measurements/')'''
###

pp = pprint.PrettyPrinter()

get_stddev = lambda x, k_h, k_w: 1/math.sqrt(k_w*k_h*x.get_shape()[-1])

# -----------------------------
# new added functions for cyclegan
class ImagePool(object):
    def __init__(self, maxsize=50):
        self.maxsize = maxsize
        self.num_img = 0
        self.images = []

    def __call__(self, image):
        if self.maxsize <= 0:
            return image
        if self.num_img < self.maxsize:
            self.images.append(image)
            self.num_img += 1
            return image
        if np.random.rand() > 0.5:
            idx = int(np.random.rand()*self.maxsize)
            tmp1 = copy.copy(self.images[idx])[0]
            self.images[idx][0] = image[0]
            idx = int(np.random.rand()*self.maxsize)
            tmp2 = copy.copy(self.images[idx])[1]
            self.images[idx][1] = image[1]
            return [tmp1, tmp2]
        else:
            return image

def load_test_data(image_path, fine_size=256, input_c_dim=1):
    img = imread(image_path)
    #Should already be 256x256
    img = scipy.misc.imresize(img, [fine_size, fine_size])
    img = img[:, :, :input_c_dim] #Changing to correct channel dim
    img = img/127.5 - 1
    return img

def load_train_data(image_path, load_size=286, fine_size=256, input_c_dim=1, output_c_dim=1, is_testing=False):
    #It seems that the load_size is used to crop down to fine_size safely
    img_A = imread(image_path[0])
    img_B = imread(image_path[1])

    flipped = False

    if not is_testing:
        img_A = scipy.misc.imresize(img_A, [load_size, load_size])
        img_B = scipy.misc.imresize(img_B, [load_size, load_size])
        h1 = int(np.ceil(np.random.uniform(1e-2, load_size-fine_size)))
        w1 = int(np.ceil(np.random.uniform(1e-2, load_size-fine_size)))
        #A tiny random part of the image, some part of the frame, is removed
        #Probably for image augmentation. Put into h1 and w1
        #print("h1",h1,"w1",w1)
        img_A = img_A[h1:h1+fine_size, w1:w1+fine_size]
        img_B = img_B[h1:h1+fine_size, w1:w1+fine_size]
        img_A = img_A[:, :, :input_c_dim] #Changing to correct channel dim
        img_B = img_B[:, :, :output_c_dim] #Changing to correct channel dim

        if np.random.random() > 0.5:
            img_A = np.fliplr(img_A)
            img_B = np.fliplr(img_B)
            flipped = True
    else:
        img_A = scipy.misc.imresize(img_A, [fine_size, fine_size])
        img_B = scipy.misc.imresize(img_B, [fine_size, fine_size])
        img_A = img_A[:, :, :input_c_dim] #Changing to correct channel dim
        img_B = img_B[:, :, :output_c_dim] #Changing to correct channel dim

    img_A = img_A/127.5 - 1.
    img_B = img_B/127.5 - 1.
    #print("A SHAPE:", img_A.shape)
    #print("B SHAPE:", img_B.shape)
    img_AB = np.concatenate((img_A, img_B), axis=2)

    #print("file names:", image_path)
    #print("AB SHAPE:", img_AB.shape)

    # img_AB shape: (fine_size, fine_size, input_c_dim + output_c_dim)
    return img_AB, flipped

# -----------------------------

def get_image(image_path, image_size, is_crop=True, resize_w=64, is_grayscale = True):
    return transform(imread(image_path, is_grayscale), image_size, is_crop, resize_w)

def save_images(images, size, image_path):
    return imsave(inverse_transform(images), size, image_path)

def imread(path, is_grayscale = False):
    if (is_grayscale):
        return _imread(path, flatten=True).astype(np.float)
    else:
        return _imread(path, mode='RGB').astype(np.float)

def merge_images(images, size):
    return inverse_transform(images)

def merge(images, size):
    h, w = images.shape[1], images.shape[2]
    img = np.zeros((h * size[0], w * size[1], 3))
    for idx, image in enumerate(images):
        i = idx % size[1]
        j = idx // size[1]
        img[j*h:j*h+h, i*w:i*w+w, :] = image

    return img

def imsave(images, size, path):
    return scipy.misc.imsave(path, merge(images, size))

def center_crop(x, crop_h, crop_w,
                resize_h=64, resize_w=64):
  if crop_w is None:
    crop_w = crop_h
  h, w = x.shape[:2]
  j = int(round((h - crop_h)/2.))
  i = int(round((w - crop_w)/2.))
  return scipy.misc.imresize(
      x[j:j+crop_h, i:i+crop_w], [resize_h, resize_w])

def transform(image, npx=64, is_crop=True, resize_w=64):
    # npx : # of pixels width/height of image
    if is_crop:
        cropped_image = center_crop(image, npx, resize_w=resize_w)
    else:
        cropped_image = image
    return np.array(cropped_image)/127.5 - 1.

def inverse_transform(images):
    return (images+1.)/2.

#gets improvement divided by original value
def get_snr_cnr(fake_path, orig_path):
    snr, cnr = eng.python_get(fake_path,orig_path,nargout=2)
    return snr, cnr

#Experiment. Adding it to cost
'''def signaltonoise(a, axis=None,ddof=0):
    a = np.asanyarray(a)
    m = a.mean(axis)
    sd = a.std(axis=axis, ddof=ddof)
    return np.where(sd == 0, 0, m/sd)'''
