import os

for i in range(0,80,5): #How many epochs/checkpoints?
	print("\n STARTING NEW TEST")
	print("python main.py --phase=test --checkpoint=%d" % i)
	os.system("python main.py --phase=test --checkpoint=%d" % i)

print("python main.py --phase=test --checkpoint=79")
os.system("python main.py --phase=test --checkpoint=%d" % 79)
