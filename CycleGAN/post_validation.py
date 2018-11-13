import os

os.system("python script2.py")

for i in range(80):
    os.system("python main.py --phase=test --checkpoint=%d" % i)
