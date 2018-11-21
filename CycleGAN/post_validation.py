import os

#make this into cross validation?
#In that case, split the validation set into e.g. 5
#equally large parts. Use one of the parts randomly
#for each epoch

for i in range(55, 80): #How many epochs/checkpoints?
	print("\n STARTING NEW TEST")
	print("python main.py --phase=test --checkpoint=%d" % i)
	os.system("python main.py --phase=test --checkpoint=%d" % i)
