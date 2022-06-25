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

filename = "ins-1.txt"
f = open("../instances/" + filename, "r")
input = f.read().splitlines()

n = int(input[1])
dimensions = [tuple(map(int, input[i + 2].split(" "))) for i in range(n)]
width = int(input[0])
max_height = sum([dim[1] for dim in dimensions])
height = [Bool(f"h_{i}") for i in range(max_height)]

# s = Solver()
s = Optimize()

map = [[[Bool(f"x_{i}_{j}_{k}") for k in range(n)] for j in range(width)] for i in range(max_height)]

# No overlapping
for i in range(max_height):
    for j in range(width):
        s.add(at_most_one(map[i][j]))

# Position the rectangles
for k in range(n):
    possible_plates = []

    for i in range(max_height - dimensions[k][0] + 1):
        for j in range(width - dimensions[k][1] + 1):
            ands = []

            for oy in range(max_height):
                for ox in range(width):
                    if i <= oy < i + dimensions[k][0] and j <= ox < j + dimensions[k][1]:
                        ands.append(map[oy][ox][k])
                    else:
                        ands.append(Not(map[oy][ox][k]))

            possible_plates.append(And(ands))
            
    s.add(at_least_one(possible_plates))

# At least one rectangle for each depth layer
for k in range(n):
    s.add(at_least_one(flatten(map[:][:][k])))

# Bind height and map
s.add(exactly_one([height[i] for i in range(max_height)]))
# s.add(And([Implies(Or(flatten(map[i])), height[i]) for i in range(max_height)]))
s.add([height[i] == And([Or(flatten(map[i]))] + [Not(Or(flatten(map[j]))) for j in range(i + 1, max_height)])
    for i in range(max_height)])

x = Int("x")
s.add(And([
    And([Implies(height[i], x == i) for i in range(len(height))]),
    And([Implies(x == i, height[i]) for i in range(len(height))])
]))

if s.check() == sat:
    # m = s.optimize()
    m = s.minimize(x)
    display_solution(m, max_height)
    print(sorted([(d, m[d]) for d in m], key = lambda x: str(x[0])))
else:
    print("Failed to solve")