include "globals.mzn";

% int: width = 19;
% int: n = 14;
% array[1..n, 1..2] of int: dimensions = [| 3, 3 | 3, 4 | 3, 5 | 3, 6 | 3, 7 | 3, 8 | 3, 9 | 3, 10 | 3, 11 | 3, 13 | 3, 19 | 4, 5 | 4, 6 | 4, 8 |];

int: width;
int: n;
array[1..n, 1..2] of int: dimensions;
int: max_height = sum(i in 1..n)(dimensions[i, 2]);

var int: height;
array[1..n, 1..2] of var int: positions;
array[0..(width - 1), 0..(max_height - 1)] of var (1..n + 1): map;  % n+1 because of the empty cells

% plate size bounds (MOLTO IMPLIED)
constraint height > 0 /\ height <= max_height;

% positions bounds
constraint forall(i in 1..n)(
  positions[i, 1] >= 0 /\ positions[i, 1] < width /\
  positions[i, 2] >= 0 /\ positions[i, 2] < height
);

% no overlap
% constraint forall(i in 1..n)(
%   forall(j in 1..(i - 1))(
%     positions[i, 1] >= positions[j, 1] + dimensions[j, 1] \/
%     positions[i, 2] >= positions[j, 2] + dimensions[j, 2]
%   )
% );
constraint cumulative([positions[i, 2] | i in 1..n], [dimensions[i, 2] | i in 1..n], [dimensions[i, 1] | i in 1..n], width);
constraint cumulative([positions[i, 1] | i in 1..n], [dimensions[i, 1] | i in 1..n], [dimensions[i, 2] | i in 1..n], height);

% no overflow
constraint forall(i in 1..n)(positions[i, 1] + dimensions[i, 1] <= width);

% height definition
constraint height = max([positions[i, 2] + dimensions[i, 2] | i in 1..n]);

% symmetry breaking
% constraint lex_lesseq(array1d(corners_map), [ corners_map[i,j] | i in reverse(1..width), j in 1..max_height ]) /\
%   lex_lesseq(array1d(corners_map), [ corners_map[i,j] | i in 1..width, j in reverse(1..max_height) ]) /\
%   lex_lesseq(array1d(corners_map), [ corners_map[i,j] | i in reverse(1..width), j in reverse(1..max_height) ]);
% constraint lex_lesseq(array1d(positions), [ positions[i,j] | i in reverse(1..n), j in 1..2 ]) /\
%   lex_lesseq(array1d(positions), [ positions[i,j] | i in 1..n, j in reverse(1..2) ]) /\
%   lex_lesseq(array1d(positions), [ positions[i,j] | i in reverse(1..n), j in reverse(1..2) ]);
constraint symmetry_breaking_constraint(
  lex_lesseq(array1d(map), [ map[i,j] | j in 0..max_height-1, i in reverse(0..width-1)]) /\ 
  lex_lesseq(array1d(map),[ map[i,j] | j in reverse(0..max_height-1), i in 0..width-1]) /\ 
  lex_lesseq(array1d(map), [ map[i,j] | j in reverse(0..max_height-1), i in reverse(0..width-1)]));
  
% channeling
% constraint forall(i in 1..width)(
%   forall(j in 1..max_height)(
%     corners_map[i, j] = 1 <-> exists(k in 1..n)(positions[k, 1] = i - 1 /\ positions[k, 2] = j - 1) 
%   )
% );
constraint forall(i in 0..(width - 1), j in 0..(max_height - 1), k in 1..n)
  (map[i, j] == k <-> (positions[k, 1] <= i /\ i < positions[k, 1] + dimensions[k, 1] /\
    positions[k, 2] <= j /\ j < positions[k, 2] + dimensions[k, 2]));
    
% STRA IMPLIED
constraint all_different([positions[i, 1] * 10 + positions[i, 2] | i in 1..n]);

solve minimize height;