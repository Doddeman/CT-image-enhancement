import random
import os
from shutil import copyfile
#from glob import glob
#N_FILES = len(glob('./datasets/{}/*.png*'.format('Full_Quality' + '/testA')))
#print (N_FILES)

#print (os.getcwd())
#FROM_PATH = 'datasets/R/trainA'
#TO_PATH = 'datasets/R/testA'
FROM_PATH = 'datasets/Quality/mostA'
TO_PATH = 'datasets/Quality/testA'
#FROM_PATH = 'E:\david\A1-A12'
#TO_PATH = 'E:\david\A1-A12_35%'

N_FILES = len([file for file in os.listdir(FROM_PATH) if file.endswith(".png")])
N_TEST_FILES = int(round(N_FILES*0.3))
sample_indices = random.sample(range(N_FILES), N_TEST_FILES)

test_files = []
for i in range(N_FILES):
	if i in sample_indices:
		file = os.listdir(FROM_PATH)[i]
		if file.endswith(".png"):
			print(i, file)
			test_files.append(file)
			copyfile(os.path.join(FROM_PATH, file), os.path.join(TO_PATH, file))

for file in test_files:
	os.remove(os.path.join(FROM_PATH, file))

print("Number of files:", N_FILES)
print("Number of test files:", N_TEST_FILES)
print("Number of training files:", N_FILES-N_TEST_FILES)
