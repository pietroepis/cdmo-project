include "globals.mzn";

% int: width = 19;
% int: n = 14;
% array[1..n, 1..2] of int: dimensions = [| 3, 3 | 3, 4 | 3, 5 | 3, 6 | 3, 7 | 3, 8 | 3, 9 | 3, 10 | 3, 11 | 3, 13 | 3, 19 | 4, 5 | 4, 6 | 4, 8 |];

int: width;
int: n;
array[1..n, 1..2] of int: dimensions;
int: max_height = sum(i in 1..n)(dimensions[i, 2]);
int: min_height = floor(sum(i in 1..n)(dimensions[i, 1] * dimensions[i, 2]) / width);

var int: height;
array[1..n, 1..2] of var int: positions;
array[0..(width - 1), 0..(max_height - 1)] of var (1..n+1): map;  % n+1 because of the empty cells

% plate size bounds (IMPLIED)
constraint height >= min_height /\ height <= max_height;

% positions & overflow bounds
constraint forall(i in 1..n)(
  positions[i, 1] >= 0 /\ positions[i, 1] <= width - dimensions[i, 1] /\
  positions[i, 2] >= 0 /\ positions[i, 2] <= height - dimensions[i, 2]
);

% no overlap
constraint cumulative([positions[i, 2] | i in 1..n], [dimensions[i, 2] | i in 1..n], [dimensions[i, 1] | i in 1..n], width);
constraint cumulative([positions[i, 1] | i in 1..n], [dimensions[i, 1] | i in 1..n], [dimensions[i, 2] | i in 1..n], height);
constraint diffn([positions[i, 1] | i in 1..n], [positions[i, 2] | i in 1..n],
  [dimensions[i, 1] | i in 1..n], [dimensions[i, 2] | i in 1..n]);

% height definition
constraint height = max([positions[i, 2] + dimensions[i, 2] | i in 1..n]);

% symmetry breaking
constraint symmetry_breaking_constraint(
  lex_lesseq(array1d(map), [ map[i,j] | j in 0..max_height-1, i in reverse(0..width-1)]) /\ 
  lex_lesseq(array1d(map),[ map[i,j] | j in reverse(0..max_height-1), i in 0..width-1]) /\ 
  lex_lesseq(array1d(map), [ map[i,j] | j in reverse(0..max_height-1), i in reverse(0..width-1)]));

  
% channeling
constraint forall(i in 0..(width - 1), j in 0..(max_height - 1), k in 1..n)
  (map[i, j] == k <-> (positions[k, 1] <= i /\ i < positions[k, 1] + dimensions[k, 1] /\
    positions[k, 2] <= j /\ j < positions[k, 2] + dimensions[k, 2]));
    
% IMPLIED
constraint all_different([positions[i, 1] * 10 + positions[i, 2] | i in 1..n]);

% solve minimize height;
solve :: seq_search([
  int_search([positions[i, 1] | i in 1..n], dom_w_deg, indomain_min, complete), 
  int_search([positions[i, 2] | i in 1..n], dom_w_deg, indomain_min, complete)
]) minimize height;