import re
import os
import SimpleITK as sitk
import numpy as np
from scipy.misc import imsave
import imageio

FROM_PATH = "to_png/"
TO_PATH ="to_mhd/"

#
fname = "to_png/mhd_t1_s5.png"
image = sitk.ReadImage(fname)
image_matrix = sitk.GetArrayFromImage(image) #get numpy ndarray
#multi_channel_3Dimage = sitk.Image([2,4,8], sitk.sitkVectorFloat32, 5)
'''print("i_m",image_matrix)
height, width = image_matrix.shape
print("h:", int(height))
print("w:", width)


3d = np.zeros((2, int(height), int(width)))
print("hej",hej)
hej[1] = image_matrix
print("hej",hej)'''

#print("m", multi_channel_3Dimage)
#mat = sitk.matrix[itk.D]()
#image = fname.split("\\")[-1]
#path, image = os.path.split(fname)
#print(path,image)
#patient = image.split("_")[0]
#print("jek", patient)

def atoi(text):
    return int(text) if text.isdigit() else text

def natural_keys(text):
    '''
    alist.sort(key=natural_keys) sorts in human order
    http://nedbatchelder.com/blog/200712/human_sorting.html
    (See Toothy's implementation in the comments)
    '''
    return [ atoi(c) for c in re.split('(\\d+)', text) ]

def png_to_mhd(sourceDir, destDir):
    # If the output path doesn't exist, create it
    if not os.path.exists(destDir):
        os.makedirs(destDir)

    patient_list = []
    my_dict = {}
    for sub_folder, subdirs, files in os.walk(sourceDir):
        for file in os.listdir(sub_folder):
            #print("file,",file)
            file_path = os.path.join(sub_folder, file)
            currPatient = None
            if os.path.isfile(file_path) and file_path.endswith(".png"):

                #path, image_name = os.path.split(file_path)
                #print("image_name,",image_name)
                # or just use file ?
                patient = file.split("_")[1]
                #print("patient,",patient)
                if patient not in patient_list:
                    patient_list.append(patient)
                if patient in my_dict:
                    my_dict[patient].append(file)
                    my_dict[patient].sort(key=natural_keys)
                else:
                    my_dict[patient] = [file]

    patient_list.sort(key=natural_keys)
    print(patient_list)
    '''for patient, images in my_dict.items():
        print ("patient:", patient)
        print("Images:")
        for image in images:
            print (image)'''

    result = []
    width = 256
    height = 256
    for patient in patient_list:
        print("patient,",patient)
        images = my_dict[patient]
        n_of_slices = len(images)
        mhd = np.zeros((n_of_slices, height, width))
        saveFileName = destDir +  'd' + patient + '.mhd'
        print(n_of_slices)
        slice = 0
        for image in images:
            image = sitk.ReadImage(fname)
            #get numpy ndarray
            image_matrix = sitk.GetArrayFromImage(image)
            mhd[slice] = image_matrix
            slice += 1
            #print(image)

        print (mhd.shape)
        #result.append(mhd)
        #imsave(saveFileName, mhd)
        #imageio.imwrite('filepath', 'image', 'format')
        #format = ITK
        #Probably just add ".mhd" to the filepath
        # See imageio.show_formats()
        # (there is also DICOM)
        print('Saved {}'.format(saveFileName))
    #print("result:",result)

    

print(png_to_mhd(FROM_PATH,TO_PATH))

'''
import imageio
dirname = 'path/to/dicom/files'

# Read as loose images
ims = imageio.mimread(dirname, 'DICOM')
# Read as volume
vol = imageio.volread(dirname, 'DICOM')
# Read multiple volumes (multiple DICOM series)
vols = imageio.mvolread(dirname, 'DICOM')'''