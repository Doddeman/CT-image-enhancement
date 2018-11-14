import os

for i in range(34): #How many epochs/checkpoints?
	print("\n STARTING NEW TEST")
	print("python main.py --phase=test --checkpoint=%d" % i)
	os.system("python main.py --phase=test --checkpoint=%d" % i)
