include "globals.mzn";

int: width;
int: n;
array[1..n, 1..2] of int: dimensions;

var int: height;
array[1..n, 1..2] of var int: positions;

% plate size bounds
constraint height > 0 /\ height <= sum(i in 1..n)(dimensions[i, 2]);

% positions bounds
constraint forall(i in 1..n)(
  positions[i, 1] >= 0 /\ positions[i, 1] < width /\
  positions[i, 2] >= 0 /\ positions[i, 2] < height
);

% no overlap
constraint forall(i in 1..n)(
  forall(j in 1..(i - 1))(
    positions[i, 1] >= positions[j, 1] + dimensions[j, 1] \/
    positions[i, 2] >= positions[j, 2] + dimensions[j, 2]
  )
);

% no overflow
constraint forall(i in 1..n)(positions[i, 1] + dimensions[i, 1] <= width);

% height definition
constraint height = max([positions[i, 2] + dimensions[i, 2] | i in 1..n]);

solve minimize height;