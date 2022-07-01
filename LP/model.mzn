include "globals.mzn";

% int: width = 19;
% int: n = 14;
% array[1..n, 1..2] of int: dimensions = [| 3, 3 | 3, 4 | 3, 5 | 3, 6 | 3, 7 | 3, 8 | 3, 9 | 3, 10 | 3, 11 | 3, 13 | 3, 19 | 4, 5 | 4, 6 | 4, 8 |];

int: width;
int: n;
array[1..n, 1..2] of int: dimensions;
int: max_height = sum(i in 1..n)(dimensions[i, 2]);
int: min_height = floor(sum(i in 1..n)(dimensions[i, 1] * dimensions[i, 2]) / width);

var int: M;
var int: height;
array[1..n, 1..2] of var int: positions;
array[1..n, 1..n, 1..4] of var 0..1: delta;
var int: objective_function;

constraint M = max_height + width;

constraint objective_function = height * width;

% plate size bounds
constraint height >= min_height;
constraint height <= max_height;

% positions bounds
constraint forall(i in 1..n)(
  positions[i, 1] >= 0
);
constraint forall(i in 1..n)(
  positions[i, 1] <= width - dimensions[i, 1]
);
constraint forall(i in 1..n)(
  positions[i, 2] >= 0
);
constraint forall(i in 1..n)(
  positions[i, 2] <= height - dimensions[i, 2]
);

% no overlap
constraint forall(i in 1..n)(
  sum(j in 1..n where positions[j, 2] <= dimensions[i, 2] /\ dimensions[i, 2] < positions[j, 2] + dimensions[j, 2])(
    dimensions[j, 1] 
  ) <= width
);

constraint forall(i in 1..n)(
  sum(j in 1..n where positions[j, 1] <= dimensions[i, 1] /\ dimensions[i, 1] < positions[j, 1] + dimensions[j, 1])(
    dimensions[j, 2]
  ) <= height
);

constraint forall(i in 1..n)(
  forall(j in 1..n where i != j)(
    positions[i, 1] + dimensions[i, 1] <= positions[j, 1] + M * delta[i, j, 1] /\
    positions[j, 1] + dimensions[j, 1] <= positions[i, 1] + M * delta[i, j, 2] /\
    positions[i, 2] + dimensions[i, 2] <= positions[j, 2] + M * delta[i, j, 3] /\
    positions[j, 2] + dimensions[j, 2] <= positions[i, 2] + M * delta[i, j, 4]
  )
);

constraint forall(i in 1..n)(
  forall(j in 1..n where i != j)(
    sum(k in 1..4)(delta[i, j, k]) <= 3
  )
);

% constraint diffn([positions[i, 1] | i in 1..n], [positions[i, 2] | i in 1..n],
%   [dimensions[i, 1] | i in 1..n], [dimensions[i, 2] | i in 1..n]);

% no overflow
constraint forall(i in 1..n)(positions[i, 1] + dimensions[i, 1] <= width);

% height definition
constraint forall(i in 1..n)(
  height >= positions[i, 2] + dimensions[i, 2]
);

solve minimize objective_function;