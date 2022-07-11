from minizinc import Instance, Model, Solver
from PlotMap import PlotMap
import sys
import os
from datetime import timedelta

path = os.path.abspath(os.path.dirname(__file__))

filename = "ins-1.txt"
allow_rotation = True

model = Model("./model_rotation.mzn" if allow_rotation else "./model.mzn")
solver = Solver.lookup("chuffed")
instance = Instance(solver, model)

f = open("../../instances/" + filename, "r")
input = f.read().splitlines()
input[2:] = sorted(input[2:], key = lambda item: int(item.split(" ")[0]) * int(item.split(" ")[1]), reverse = True)
instance["width"] = int(input[0])
instance["n"] = int(input[1])
instance["w"] = [tuple(map(int, input[i + 2].split(" ")))[0] for i in range(instance["n"])]
instance["h"] = [tuple(map(int, input[i + 2].split(" ")))[1] for i in range(instance["n"])]

result = instance.solve()

dimensions = list(zip(instance["w"], instance["h"])) if not allow_rotation else list(zip(result["actual_w"], result["actual_h"]))

result_out = input[0] + " " + str(result["height"]) + "\n" + input[1] + "\n"
for i in range(int(input[1])):
    result_out += (str(dimensions[i][0]) + " " + str(dimensions[i][1]) + " " +
        str(result["positions_x"][i]) + " " + str(result["positions_y"][i]) + "\n")

print("Result:")
print(result_out)

f = open("../out/" + filename.replace("ins", "out"), "w")
f.write(result_out)
f.close()

pm = PlotMap(
    int(input[0]),
    result["height"],
    [(result["positions_x"][i], result["positions_y"][i]) for i in range(len(result["positions_x"]))],
    dimensions
)
pm.plot()