include "globals.mzn";

int: width = 8;
int: n = 4;
array[1..n, 1..2] of int: dimensions = [|3, 3|3, 5|5, 3|5, 5|];

int: max_height = sum(i in 1..n)(dimensions[i, 2]);
% int: width;
% int: n;
% array[1..n, 1..2] of int: dimensions;

var int: height;
array[1..n, 1..2] of var int: positions;
array[1..width, 1..max_height] of var 0..1: corners_map;

% plate size bounds
constraint height > 0 /\ height <= sum(i in 1..n)(dimensions[i, 2]) /\ height = 8;

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
constraint lex_lesseq(array1d(corners_map), [ corners_map[i,j] | i in reverse(1..width), j in 1..max_height ]) /\
  lex_lesseq(array1d(corners_map), [ corners_map[i,j] | i in 1..width, j in reverse(1..max_height) ]) /\
  lex_lesseq(array1d(corners_map), [ corners_map[i,j] | i in reverse(1..width), j in reverse(1..max_height) ]);
  
% channeling
constraint forall(i in 1..width)(
  forall(j in 1..max_height)(
    corners_map[i, j] = 1 <-> exists(k in 1..n)(positions[k, 1] = i - 1 /\ positions[k, 2] = j - 1) 
  )
);

solve satisfy;