include "globals.mzn";

% int: width = 8;
% int: n = 4;
% array[1..n, 1..2] of int: dimensions = [|3, 3|3, 5|5, 3|5, 5|];
int: width;
int: max_height = sum(i in 1..n)(dimensions[i, 2]);
int: n;
array[1..n, 1..2] of int: dimensions;

var int: height;
array[1..width, 1..max_height] of var 0..1: corners_map;

constraint lex_lesseq(array1d(corners_map), [ corners_map[i,j] | i in reverse(1..width), j in 1..max_height ]) /\
  lex_lesseq(array1d(corners_map), [ corners_map[i,j] | i in 1..width, j in reverse(1..max_height) ]) /\
  lex_lesseq(array1d(corners_map), [ corners_map[i,j] | i in reverse(1..width), j in reverse(1..max_height) ]);
  
solve satisfy;