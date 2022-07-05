include "globals.mzn";

int: width;
int: n;
array[1..n, 1..2] of int: dimensions;
int: max_height = sum(i in 1..n)(dimensions[i, 2]);
int: min_height = floor(sum(i in 1..n)(dimensions[i, 1] * dimensions[i, 2]) / width);
array[1..n] of int: order = sort_by([j | j in 1..n], [-dimensions[i, 1] * dimensions[i, 2] | i in 1..n]);

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
  lex_less([positions_y[order[1]], positions_x[order[1]]], [positions_y[order[2]], positions_x[order[2]]])
);	
  
% constraint symmetry_breaking_constraint(
%   sum(i in 1..n where positions_x[i] <= width div 2)(dimensions[i, 1] * dimensions[i, 2]) >= 
%   sum(i in 1..n where positions_x[i] > width div 2)(dimensions[i, 1] * dimensions[i, 2])
% );
      
% IMPLIED
% constraint all_different([positions_x[i] * 10 + positions_y[i] | i in 1..n])::domain;

% SEARCH
int: search_heuristic = 1;

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

solve :: seq_search([
    int_search(positions_y, first_fail, indomain_min),
    int_search(positions_x, first_fail, indomain_min),
    int_search([height], smallest, indomain_min)])
    minimize height;