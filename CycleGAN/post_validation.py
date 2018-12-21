import os

#make this into cross validation?
#In that case, split the validation set into e.g. 5
#equally large parts. Use one of the parts randomly
#for each epoch

for i in range(0,80,5): #How many epochs/checkpoints?
	print("\n STARTING NEW TEST")
	print("python main.py --phase=test --checkpoint=%d" % i)
	os.system("python main.py --phase=test --checkpoint=%d" % i)

#print("python main.py --phase=test --checkpoint=79")
#os.system("python main.py --phase=test --checkpoint=%d" % 79)
