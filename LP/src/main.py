from minizinc import Instance, Model, Solver
from PlotMap import PlotMap

filename = "ins-1.txt"
allow_rotation = False

model = Model("./model_rotation.mzn" if allow_rotation else "./model.mzn")
solver = Solver.lookup("chuffed")
instance = Instance(solver, model)

f = open("../../instances/" + filename, "r")
input = f.read().splitlines()
input[2:] = sorted(input[2:], key = lambda item: int(item.split(" ")[0]) * int(item.split(" ")[1]), reverse = True)
instance["width"] = int(input[0])
instance["n"] = int(input[1])
instance["dimensions"] = [tuple(map(int, input[i + 2].split(" "))) for i in range(instance["n"])]
result = instance.solve()

dimensions = instance["dimensions"] if not allow_rotation else result["actual_dimensions"]

result_out = input[0] + " " + str(result["height"]) + "\n" + input[1] + "\n"
for i in range(int(input[1])):
    result_out += (str(dimensions[i][0]) + " " + str(dimensions[i][1]) + " " +
        str(result["positions"][i][0]) + " " + str(result["positions"][i][1]) + "\n")

print("Result:")
print(result_out)

f = open("../out/" + filename.replace("ins", "out"), "w")
f.write(result_out)
f.close()

pm = PlotMap(
    int(input[0]),
    result["height"],
    result["positions"],
    dimensions
)
pm.plot()