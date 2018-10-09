# Author: Vikas Gupta, PhD
# This script converts 3D (slices) and 2D mhd to png for deep learning
# To do: Also write the code for reverse direction
import os
import sys
import numpy as np
from PIL import Image
import SimpleITK as sitk
from scipy.misc import imsave

# Save all mhd files (2d or 3d from sourceDir in destDir)
def mhd_to_png(sourceDir, destDir):
    # The size of the output image
    imageSizeOutput = [256, 256]

    # If the output path doesn't exist, create it
    if not os.path.exists(destDir):
        os.makedirs(destDir)

    # Get the directory structure
    # Recursively traverse all sub-folders in the path
    for mhd_sub_folder, subdirs, files in os.walk(sourceDir):
        for mhd_file in os.listdir(mhd_sub_folder):
            mhd_file_path = os.path.join(mhd_sub_folder, mhd_file)

            # Make sure path is an actual file
            if os.path.isfile(mhd_file_path) and mhd_file_path.endswith(".mhd"):

                try:
                    # Read MHD image
                    mhd_image = sitk.ReadImage(mhd_file_path)
                    # Get image matrix
                    mhd_image_matrix = sitk.GetArrayFromImage(mhd_image)
                    # Save all individual slices
                    for s in range(0, mhd_image_matrix.shape[0]):
                        print("n of slices:", mhd_image_matrix.shape[0])
                        sliceMat = mhd_image_matrix[s - 1, :, :]
                        # Convert to float to avoid overflow or underflow losses.
                        image_2d = sliceMat.astype(float)
                        # Rescaling grey scale between 0-255
                        image_2d_scaled = (np.maximum(image_2d, 0) / image_2d.max()) * 255.0
                        filePath, fileName = os.path.split(mhd_file_path)
                        # Get the patient name from file
                        fname = fileName.strip('.mhd')
                        # Get the patient name/id
                        _, subFolderName = os.path.split(mhd_sub_folder)
                        # Append time and slice number
                        saveFileName = os.path.join(destDir, subFolderName +'_' + fname + '_s'+ str(s+1)+".png")
                        # Save image
                        imsave(saveFileName, image_2d_scaled)
                        # Resize
                        resizeImageToMatchLargerDimension(saveFileName, imageSizeOutput[0],imageSizeOutput[1])
                        # Tell the user how was it saved
                        print('Saved {}'.format(saveFileName))

                except Exception as e:
                    print(e)

# Image resizer
def resizeImageToMatchLargerDimension(png_file_name,dim1,dim2):
    # Resize the image back to large dimension

    image = Image.open(png_file_name)
    img = image.resize((dim1, dim2), Image.ANTIALIAS)
    image.close()

    out = open(png_file_name, "w")
    try:
        img.save(png_file_name, "PNG")
    finally:
        out.close()

    return True


if __name__ == "__main__":
    if len(sys.argv) >1:
        # Get the source and dest dir from command line
        sourceDir = sys.argv[1]
        destDir = sys.argv[2]
    else:
        # User defined settings
        sourceDir = 'mhd'
        destDir = 'to_png'
        print('Using predefined sourceDir and destDir')

    # Call the function
    mhd_to_png(sourceDir, destDir)
