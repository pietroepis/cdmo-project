from itertools import combinations
from z3 import *
import numpy as np
import matplotlib.pyplot as plt
import math

filename = "ins-1.txt"
allow_rotation = False

def at_most_one(bool_vars):
    return [Not(And(pair[0], pair[1])) for pair in combinations(bool_vars, 2)]

def at_least_one(bool_vars):
    return Or(bool_vars)

def exactly_one(bool_vars):
    return at_most_one(bool_vars) + [at_least_one(bool_vars)]

def flatten(xss):
    return [x for xs in xss for x in xs]

def lex_lesseq(x, y):
    return And([Implies(x[0], y[0])] +
        [Implies(And([x[i] == y[i] for i in range(k)]), Implies(x[k], y[k]))
        for k in range(1, len(x))])

def display_solution(model, h):
    print("h: " + str(h))

    grid = np.zeros((h, width))
    for i in range(h):
        for j in range(width):
            for k in range(n):
                if model[map[i][j][k]]:
                    grid[i, j] = k + 1
                    break
                
    fig = plt.figure()
    ax = fig.add_subplot(1, 1, 1)
    plt.imshow(grid, cmap='tab20c', extent=(0, width, 0, h))
    ax.set_xticks(range(width + 1))
    ax.set_yticks(range(h + 1))
    ax.grid(which='major', alpha=0.5)
    plt.xlabel("x coordinates")
    plt.ylabel("y coordinates")
    plt.tight_layout()
    plt.show()

def write_out(model, h):
    result_out = input[0] + " " + str(h) + "\n" + input[1] + "\n"

    for k in range(n):
        found = False

        for i in range(len(map) - 1, 0, -1):
            if found:
                break

            for j in range(width):
                if model[map[i][j][k]] and not found:
                    found = True
                    result_out += (str(dimensions[k][0]) + " " + str(dimensions[k][1]) + " " +
                        str(j) + " " + str(h - i - 1) + "\n")
                    break

    f = open("../out/" + filename.replace("ins", "out"), "w")
    f.write(result_out)
    f.close()

f = open("../../instances/" + filename, "r")
input = f.read().splitlines()
input[2:] = sorted(input[2:], key = lambda item: int(item.split(" ")[0]) * int(item.split(" ")[1]), reverse = True)

n = int(input[1])
dimensions = [tuple(map(int, input[i + 2].split(" "))) for i in range(n)]
rotated_dimensions = [(d2, d1) for (d1, d2) in dimensions]
width = int(input[0])
min_height = math.floor(sum([dim[0] * dim[1] for dim in dimensions]) / width) - 1
max_height = sum([dim[1] for dim in dimensions])
height = [Bool(f"h_{i}") for i in range(min_height, max_height + 1)]
rotated = [Bool(f"r_{i}") for i in range(n)]

def possible_positions(d):
    possible_plates = []

    for i in range(max_height - d[1] + 1):
        for j in range(width - d[0] + 1):
            ands = []

            for oy in range(max_height):
                for ox in range(width):
                    if i <= oy < i + d[1] and j <= ox < j + d[0]:
                        ands.append(map[oy][ox][k])
                    else:
                        ands.append(Not(map[oy][ox][k]))

            possible_plates.append(And(ands))

    return possible_plates

s = Optimize()

map = [[[Bool(f"x_{i}_{j}_{k}") for k in range(n)] for j in range(width)] for i in range(max_height + 1)]

# No overlapping
for i in range(max_height + 1):
    for j in range(width):
        s.add(at_most_one(map[i][j]))

# Position the rectangles
for k in range(n):
    possible_plates = possible_positions(dimensions[k])
    if allow_rotation:
        possible_plates_rotated = possible_positions(rotated_dimensions[k])
        s.add(Implies(Not(rotated[k]), at_least_one(possible_plates)))
        s.add(Implies(rotated[k], at_least_one(possible_plates_rotated)))
    else:
        s.add(at_least_one(possible_plates))

if not allow_rotation:
    s.add(Not(Or(rotated)))

# At least one rectangle for each depth layer
for k in range(n):
    s.add(at_least_one(flatten(map[:][:][k])))

# Bind height and map
s.add(exactly_one([height[i] for i in range(0, max_height - min_height + 1)]))
s.add([height[i] == And([Or(flatten(map[i + min_height]))] + [Not(Or(flatten(map[j + min_height]))) for j in range(i + 1, max_height - min_height + 1)])
    for i in range(0, max_height - min_height + 1)])

# Simmetry Breaking Constraints
s.add(lex_lesseq(flatten(map[:][:][0]), flatten(map[:][:][1])))

while True:
    if s.check() == sat:

        model = s.model()
        for k in range(max_height - min_height + 1):
            if model.evaluate(height[k]):
                length_sol = k

        s.add(at_least_one([height[i] for i in range(length_sol)]))

        solution_found = True
    else:
        break

write_out(model, length_sol + min_height + 1)
display_solution(model, length_sol + min_height + 1)