include "globals.mzn";

%int: width;
%int: n_circuits;
%array[1..n_circuits, 1..2] of int: dimensions;

var int: height;
%array[1..n_circuits, 1..2] of var int: positions;

%constraint height > 0 /\ height <= sum(i in 1..n_circuits)(dimensions[i, 2]);

constraint height > 0 /\ height < 5;

solve minimize height;