import random
import os
from shutil import copyfile

#print (os.getcwd())
FROM_PATH = 'images/low'
TO_PATH = 'images_test/low'

counter = 0
for file in os.listdir(FROM_PATH):
    if file.endswith(".png"):
    	counter+=1

N_FILES = counter
print("Number of files:", counter)
N_TEST_FILES = int(round(N_FILES*0.3))
print("Number of test files:", N_TEST_FILES)
sample_indices = random.sample(range(N_FILES), N_TEST_FILES)
#print(sample_indices)

test_files = []
for i in range(N_FILES):
	if i in sample_indices:
		file = os.listdir(FROM_PATH)[i]
		if file.endswith(".png"):
			print(file)
			test_files.append(file)
			copyfile(os.path.join(FROM_PATH, file), os.path.join(TO_PATH, file))

for file in test_files:
	os.remove(os.path.join(FROM_PATH, file))
