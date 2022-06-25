from itertools import combinations
from z3 import *
import numpy as np
import matplotlib.pyplot as plt

def at_most_one(bool_vars):
    return [Not(And(pair[0], pair[1])) for pair in combinations(bool_vars, 2)]

def at_least_one(bool_vars):
    return Or(bool_vars)

def exactly_one(bool_vars):
    return at_most_one(bool_vars) + [at_least_one(bool_vars)]

def flatten(xss):
    return [x for xs in xss for x in xs]

def display_solution(model, h):
    print("SUCCESS")
    print("h: " + str(h))

    grid = np.zeros((h, width))
    for i in range(h):
        for j in range(width):
            for k in range(n):
                if model[map[i][j][k]]:
                    grid[i, j] = k + 1
                    break
    print(grid)
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

filename = "ins-3.txt"
f = open("../instances/" + filename, "r")
input = f.read().splitlines()

n = int(input[1])
dimensions = [tuple(map(int, input[i + 2].split(" "))) for i in range(n)]
rotated_dimensions = [(d2, d1) for (d1, d2) in dimensions]
width = int(input[0])
max_height = sum([dim[1] for dim in dimensions])
height = [Bool(f"h_{i}") for i in range(max_height)]
rotated = [Bool(f"r_{i}") for i in range(n)]

# s = Solver()
s = Optimize()

map = [[[Bool(f"x_{i}_{j}_{k}") for k in range(n)] for j in range(width)] for i in range(max_height)]

# No overlapping
for i in range(max_height):
    for j in range(width):
        s.add(at_most_one(map[i][j]))

def pippo(d):
    possible_plates = []

    for i in range(max_height - d[0] + 1):
        for j in range(width - d[1] + 1):
            ands = []

            for oy in range(max_height):
                for ox in range(width):
                    if i <= oy < i + d[0] and j <= ox < j + d[1]:
                        ands.append(map[oy][ox][k])
                    else:
                        ands.append(Not(map[oy][ox][k]))

            possible_plates.append(And(ands))

    return possible_plates

# Position the rectangles
for k in range(n):
    possible_plates = pippo(dimensions[k])
    possible_plates_rotated = pippo(rotated_dimensions[k])
            
    s.add(Implies(Not(rotated[k]), at_least_one(possible_plates)))
    s.add(Implies(rotated[k], at_least_one(possible_plates_rotated)))

# At least one rectangle for each depth layer
for k in range(n):
    s.add(at_least_one(flatten(map[:][:][k])))

# Bind height and map
s.add(exactly_one([height[i] for i in range(max_height)]))
# s.add(And([Implies(Or(flatten(map[i])), height[i]) for i in range(max_height)]))
s.add([height[i] == And([Or(flatten(map[i]))] + [Not(Or(flatten(map[j]))) for j in range(i + 1, max_height)])
    for i in range(max_height)])

while True:
    if s.check() == sat:

        model = s.model()
        for k in range(max_height):
            if model.evaluate(height[k]):
                length_sol = k

        s.add(at_least_one([height[i] for i in range(length_sol)]))

        solution_found = True
    else:
        break

print(solution_found)

print(model)
print(sorted([(d, model[d]) for d in model], key = lambda x: str(x[0])))
display_solution(model, length_sol + 1)

""" if s.check() == sat:
    m = s.model()
    print(m)
    display_solution(m, max_height)
    print(sorted([(d, m[d]) for d in m], key = lambda x: str(x[0])))
else:
    print("Failed to solve") """