include "globals.mzn";

int: width;
int: n;
array[1..n, 1..2] of int: dimensions;
int: max_height = sum(i in 1..n)(dimensions[i, 2]);
int: min_height = floor(sum(i in 1..n)(dimensions[i, 1] * dimensions[i, 2]) / width);
int: M = max_height + width;
int: max_dim = max(dimensions);
int: min_dim = min(dimensions);

var int: height;
array[1..n, 1..2] of var int: positions;
array[1..n, 1..n, 1..4] of var 0..1: delta;
array[1..n] of var bool: rotated;
array[1..n, 1..2] of var min_dim..max_dim: actual_dimensions;
var int: objective_function;

constraint objective_function = height * width;

% plate size bounds
constraint height >= min_height;
constraint height <= max_height;

% positions bounds
constraint forall(i in 1..n)(
  positions[i, 1] >= 0
);
constraint forall(i in 1..n)(
  positions[i, 1] <= width - actual_dimensions[i, 1]
);
constraint forall(i in 1..n)(
  positions[i, 2] >= 0
);
constraint forall(i in 1..n)(
  positions[i, 2] <= height - actual_dimensions[i, 2]
);

% no overlap
constraint forall(i in 1..height)(
  sum(j in 1..n where positions[j, 2] <= i /\ i < positions[j, 2] + actual_dimensions[j, 2])(
    actual_dimensions[j, 1] 
  ) <= width
);

constraint forall(i in 1..width)(
  sum(j in 1..n where positions[j, 1] <= i /\ i < positions[j, 1] + actual_dimensions[j, 1])(
    actual_dimensions[j, 2]
  ) <= height
);

constraint forall(i in 1..n)(
  forall(j in 1..n where i != j)(
    positions[i, 1] + actual_dimensions[i, 1] <= positions[j, 1] + M * delta[i, j, 1] /\
    positions[j, 1] + actual_dimensions[j, 1] <= positions[i, 1] + M * delta[i, j, 2] /\
    positions[i, 2] + actual_dimensions[i, 2] <= positions[j, 2] + M * delta[i, j, 3] /\
    positions[j, 2] + actual_dimensions[j, 2] <= positions[i, 2] + M * delta[i, j, 4]
  )
);

constraint forall(i in 1..n)(
  forall(j in 1..n where i != j)(
    sum(k in 1..4)(delta[i, j, k]) <= 3
  )
);

% rotation
constraint forall(i in 1..n)(
  actual_dimensions[i, 1] = rotated[i] * dimensions[i, 2] + (1 - rotated[i]) * dimensions[i, 1]
);
constraint forall(i in 1..n)(
  actual_dimensions[i, 2] = (1 - rotated[i]) * dimensions[i, 2] + rotated[i] * dimensions[i, 1]
);

% no overflow
constraint forall(i in 1..n)(positions[i, 1] + actual_dimensions[i, 1] <= width);

% height definition
constraint forall(i in 1..n)(
  height >= positions[i, 2] + actual_dimensions[i, 2]
);

solve minimize objective_function;