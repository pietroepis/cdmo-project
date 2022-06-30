from minizinc import Instance, Model, Solver

for ins in range(1, 41):
    model = Model("./model.mzn")
    gecode = Solver.lookup("chuffed")
    instance = Instance(gecode, model)

    filename = "ins-" + str(ins) + ".txt"
    f = open("../instances/" + filename, "r")
    input = f.read().splitlines()
    instance["width"] = int(input[0])
    instance["n"] = int(input[1])
    instance["dimensions"] = [tuple(map(int, input[i + 2].split(" "))) for i in range(instance["n"])]
    f.close()

    f = open("dzn/ins-" + str(ins) + ".dzn", "w")
    f.write("dimensions = [|")
    for d in instance["dimensions"]:
        f.write(str(d[0]) + ", " + str(d[1]) + "|")
    f.write("];\n")
    f.write("n = " + str(instance["n"]) + ";\n")
    f.write("width = " + str(instance["width"]) + ";")
    f.close()