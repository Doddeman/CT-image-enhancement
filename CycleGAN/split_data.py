import random
import os
from shutil import copyfile

#print (os.getcwd())
#FROM_PATH = 'C:\\Users\\davwa\\Desktop\\CT-image-enhancement\\CycleGAN\\datasets\\ct_lq2hq_new\\trainA'
#TO_PATH = 'C:\\Users\\davwa\\Desktop\\CT-image-enhancement\\CycleGAN\\datasets\\ct_lq2hq_new\\testA'

FROM_PATH = 'datasets/ct_lq2hq_new/trainB'
TO_PATH = 'datasets/ct_lq2hq_new/testB'

N_FILES = len([file for file in os.listdir(FROM_PATH) if file.endswith(".png")])
#N_FILES = 18251
N_TEST_FILES = int(round(N_FILES*0.3))

sample_indices = random.sample(range(N_FILES), N_TEST_FILES)
print(len(sample_indices))

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
