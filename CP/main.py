from minizinc import Instance, Model, Solver
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

filename = "ins-1.txt"

model = Model("./model.mzn")
gecode = Solver.lookup("gecode")
instance = Instance(gecode, model)

f = open("../instances/" + filename, "r")
input = f.read().splitlines()
instance["width"] = int(input[0])
instance["n"] = int(input[1])
instance["dimensions"] = [tuple(map(int, input[i + 2].split(" "))) for i in range(instance["n"])]

result = instance.solve()

f = open("../outputs/" + filename, "w")
print("Result:")
print(input[0] + " " + str(result["height"]))
f.write(input[0] + " " + str(result["height"]) + "\n")
print(input[1])
f.write(input[1] + "\n")
for i in range(int(input[1])):
    print(str(instance["dimensions"][i][0]) + " " + str(instance["dimensions"][i][1]) + " " +
        str(result["positions"][i][0]) + " " + str(result["positions"][i][1]))
    f.write(str(instance["dimensions"][i][0]) + " " + str(instance["dimensions"][i][1]) + " " +
        str(result["positions"][i][0]) + " " + str(result["positions"][i][1]) + "\n")
f.close()

fig = plt.figure()
ax = fig.add_subplot(1, 1, 1)

for i in range(int(input[1])):
    ax.add_patch(Rectangle(result["positions"][i], result["positions"][i][0], result["positions"][i][1]))

plt.xlim([0, int(input[0])])
plt.ylim([0, result["height"]])
  
plt.show()