from minizinc import Instance, Model, Solver
from PlotMap import PlotMap
import sys
import os
from datetime import timedelta

path = os.path.abspath(os.path.dirname(__file__))

filename = "ins-" + (str(sys.argv[1]) if len(sys.argv) == 2 else "1") + ".txt"
allow_rotation = False

model = Model("./model_rotation.mzn" if allow_rotation else "./model.mzn")
# solver = Solver.lookup("gecode")
solver = Solver.lookup("chuffed")
instance = Instance(solver, model)

f = open(os.path.join(path, "..\\instances\\" + filename), "r")
input = f.read().splitlines()
instance["width"] = int(input[0])
instance["n"] = int(input[1])
instance["dimensions"] = [tuple(map(int, input[i + 2].split(" "))) for i in range(instance["n"])]
result = instance.solve(timeout=timedelta(seconds=301))
# result = instance.solve()

dimensions = instance["dimensions"] if not allow_rotation else result["actual_dimensions"]

result_out = input[0] + " " + str(result["height"]) + "\n" + input[1] + "\n"
for i in range(int(input[1])):
    result_out += (str(dimensions[i][0]) + " " + str(dimensions[i][1]) + " " +
        str(result["positions_x"][i]) + " " + str(result["positions_y"][i]) + "\n")

print("Result:")
print(result_out)

f = open(os.path.join(path, "..\\outputs\\CP\\") + filename, "w")
f.write(result_out)
f.close()

pm = PlotMap(
    int(input[0]),
    result["height"],
    [(result["positions_x"][i], result["positions_y"][i]) for i in range(len(result["positions_x"]))],
    dimensions
)

if len(sys.argv) == 2:
    pm.plot(savepath = os.path.join(path, "..\\images\\CP\\ins-" + str(sys.argv[1]) + ".png"))
else:
    pm.plot()