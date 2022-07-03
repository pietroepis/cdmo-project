include "globals.mzn";

% int: width = 19;
% int: n = 14;
% array[1..n, 1..2] of int: dimensions = [| 3, 3 | 3, 4 | 3, 5 | 3, 6 | 3, 7 | 3, 8 | 3, 9 | 3, 10 | 3, 11 | 3, 13 | 3, 19 | 4, 5 | 4, 6 | 4, 8 |];

int: width;
int: n;
array[1..n, 1..2] of int: dimensions;
int: max_height = sum(i in 1..n)(dimensions[i, 2]);
int: min_height = floor(sum(i in 1..n)(dimensions[i, 1] * dimensions[i, 2]) / width);

var 1..max_height: height;
array[1..n] of var 0..(width - min([dimensions[i, 1] | i in 1..n]) + 1): positions_x;
array[1..n] of var 0..(max_height - min([dimensions[i, 2] | i in 1..n]) + 1): positions_y;

% plate size bounds (IMPLIED)
constraint height >= min_height /\ height <= max_height;

% positions & overflow bounds
constraint forall(i in 1..n)(
  positions_x[i] >= 0 /\ positions_x[i] <= width - dimensions[i, 1] /\
  positions_y[i] >= 0 /\ positions_y[i] <= height - dimensions[i, 2]
)::domain;

% no overlap
constraint cumulative([positions_y[i] | i in 1..n], [dimensions[i, 2] | i in 1..n], [dimensions[i, 1] | i in 1..n], width)::domain;
constraint cumulative([positions_x[i] | i in 1..n], [dimensions[i, 1] | i in 1..n], [dimensions[i, 2] | i in 1..n], height)::domain;
constraint diffn([positions_x[i] | i in 1..n], [positions_y[i] | i in 1..n],
  [dimensions[i, 1] | i in 1..n], [dimensions[i, 2] | i in 1..n]);

% height definition
constraint height = max([positions_y[i] + dimensions[i, 2] | i in 1..n]);




% symmetry breaking
% constraint symmetry_breaking_constraint(
%   lex_lesseq([positions_x[k] | k in 1..n], [width - positions_x[k] - dimensions[k, 1] | k in 1..n])
% );

constraint symmetry_breaking_constraint(
    lex_lesseq(positions_x, reverse(positions_x))
);
     
     
     
     
     
    
% IMPLIED
constraint all_different([positions_x[i] * 10 + positions_y[i] | i in 1..n])::domain;

% SEARCH
int: search_heuristic = 1;
int: restart_strategy = 1;

ann: search_ann_xhat =
if search_heuristic == 1 then
  int_search(positions_x, dom_w_deg, indomain_min)
elseif search_heuristic == 2 then
  int_search(positions_x, impact, indomain_min)
else
  int_search(positions_x, input_order, indomain_min)
endif;

ann: search_ann_yhat =
if search_heuristic == 1 then
  int_search(positions_y, dom_w_deg, indomain_min)
elseif search_heuristic == 2 then
  int_search(positions_y, impact, indomain_min)
else
  int_search(positions_y, input_order, indomain_min)
endif;

ann: restart_ann =
if restart_strategy == 1 then
  restart_luby(150)
elseif restart_strategy == 2 then
  restart_geometric(2, 50)
else
  restart_none
endif;

solve :: search_ann_xhat
      :: search_ann_yhat
      :: restart_ann
         minimize height;