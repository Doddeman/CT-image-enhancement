import os

FROM_PATH = "./png"
TO_PATH ="./mhd"

#
fname = "P:\Shared\ImagesFromVikas\low_quality\A10_T1_S1"
#image = fname.split("\\")[-1]
path, image = os.path.split(fname)
print(path,image)
patient = image.split("_")[0]
print("jek", patient)

def png_to_mhd(sourceDir, destDir):
    # If the output path doesn't exist, create it
    if not os.path.exists(destDir):
        os.makedirs(destDir)

    for sub_folder, subdirs, files in os.walk(sourceDir):
        currPatient = None
        for file in os.listdir(sub_folder):
            file_path = os.path.join(sub_folder, file)
            currPatient = None
            if os.path.isfile(file_path) and file_path.endswith(".png"):

                path, image_name = os.path.split(file_path)
                # or just use file ?
                patient = image_name.split("_")[0]
                #see if new patient
                if currPatient != patient:
                    #finish up old patient
                    currPatient = patient
