import time
import subprocess
import os

# From root (above cdmo-project directory) call "python -m cdmo-project.tests.tests"

def print_progress(current, tot, instance):
    print("\r[", end = "")
    for i in range(0, current + 1):
        print("#", end="")
    for i in range(current + 1, tot):
        print(" ", end="")
    print("] " + str(current + 1) + "/" + str(tot) + " (instance " + str(instance) + ")", end = "")

INSTANCE_FROM = 8
INSTANCE_TO = 12
METHOD = "CP"

f = open("cdmo-project/tests/times/times_" + str(INSTANCE_FROM) + "_" + str(INSTANCE_TO) + "_" + METHOD + ".csv", "w")
f.write("INSTANCE;TIME\n")

os.chdir("cdmo-project/" + METHOD)

print_progress(0, (INSTANCE_TO - INSTANCE_FROM + 1), INSTANCE_FROM)

for i in range(INSTANCE_FROM, INSTANCE_TO + 1):
    start_time = time.time()

    p = subprocess.call(["python", "main.py", str(i)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    f.write(str(i) + ";" + str(time.time() - start_time) + "\n")

    print_progress(i - INSTANCE_FROM, (INSTANCE_TO - INSTANCE_FROM + 1), i)

f.close()    