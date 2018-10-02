from glob import glob
import tensorflow as tf
import numpy as np
import scipy.misc
import scipy.stats
imread = scipy.misc.imread

def snr(a, axis=0, ddof=0):
    a = np.asanyarray(a)
    mean = a.mean(axis)
    print("mean",mean)
    sd = a.std(axis=axis, ddof=ddof)
    print("sd:",sd)
    snr = np.where(sd == 0, 0, mean/sd)
    print("snr:",snr)
    return snr

data = glob('./datasets/{}/*.png*'.format('testing'))


images = []
for file in data:
    img = imread(file)
    images.append(img)
    print("img:", img)

#print("images:", images)

#probably not gonna work
snr_array = []
for img in images:
    curr_snr = snr(img, None)
    #print("snr:", curr_snr)
    snr_array.append(curr_snr)
