from PlotMap import PlotMap

FROM = 27
TO = 40

for i in range(FROM, TO + 1):
    filename = "out-" + str(i) + ".txt"
    f = open("./" + filename, "r")
    input = f.read().splitlines()

    print(i)
    """ print(int(input[0].split(" ")[0]))
    print(int(input[0].split(" ")[1]))
    print([(int(input[i+2].split(" ")[2]), int(input[i+2].split(" ")[3])) for i in range(int(input[1]))])
    print([(int(input[i+2].split(" ")[0]), int(input[i+2].split(" ")[1])) for i in range(int(input[1]))]) """

    pm = PlotMap(
        int(input[0].split(" ")[0]),
        int(input[0].split(" ")[1]),
        [(int(input[i+2].split(" ")[2]), int(input[i+2].split(" ")[3])) for i in range(int(input[1]))],
        [(int(input[i+2].split(" ")[0]), int(input[i+2].split(" ")[1])) for i in range(int(input[1]))]
    )
    pm.plot()