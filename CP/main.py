from minizinc import Instance, Model, Solver
from PlotMap import PlotMap

filename = "ins-1.txt"

model = Model("./model.mzn")
gecode = Solver.lookup("chuffed")
instance = Instance(gecode, model)

f = open("../instances/" + filename, "r")
input = f.read().splitlines()
instance["width"] = int(input[0])
instance["n"] = int(input[1])
instance["dimensions"] = [tuple(map(int, input[i + 2].split(" "))) for i in range(instance["n"])]
result = instance.solve()

result_out = input[0] + " " + str(result["height"]) + "\n" + input[1] + "\n"
for i in range(int(input[1])):
    result_out += (str(instance["dimensions"][i][0]) + " " + str(instance["dimensions"][i][1]) + " " +
        str(result["positions"][i][0]) + " " + str(result["positions"][i][1]) + "\n")

print("Result:")
print(result_out)

f = open("../outputs/" + filename, "w")
f.write(result_out)
f.close()

pm = PlotMap(
    int(input[0]),
    result["height"],
    result["positions"],
    instance["dimensions"]
)
pm.plot()