include "globals.mzn";

int: width;
int: n;
array[1..n, 1..2] of int: dimensions;
int: max_height = sum(i in 1..n)(dimensions[i, 2]);
int: min_height = floor(sum(i in 1..n)(dimensions[i, 1] * dimensions[i, 2]) / width);
array[1..n] of int: order = sort_by([j | j in 1..n], [-dimensions[i, 1] * dimensions[i, 2] | i in 1..n]);

var min_height..max_height: height;
array[1..n] of var 0..(width - min([dimensions[i, 1] | i in 1..n]) + 1): positions_x;
array[1..n] of var 0..(max_height - min([dimensions[i, 2] | i in 1..n]) + 1): positions_y;

% positions & overflow bounds
constraint forall(i in 1..n)(
  positions_x[i] <= width - dimensions[i, 1] /\ positions_y[i] <= height - dimensions[i, 2]
)::domain;

% no overlap
constraint cumulative([positions_y[i] | i in 1..n], [dimensions[i, 2] | i in 1..n], [dimensions[i, 1] | i in 1..n], width)::domain;
constraint cumulative([positions_x[i] | i in 1..n], [dimensions[i, 1] | i in 1..n], [dimensions[i, 2] | i in 1..n], height)::domain;
constraint diffn([positions_x[i] | i in 1..n], [positions_y[i] | i in 1..n],
  [dimensions[i, 1] | i in 1..n], [dimensions[i, 2] | i in 1..n])::domain;

% height definition
constraint height = max([positions_y[i] + dimensions[i, 2] | i in 1..n]);

% symmetry breaking
constraint symmetry_breaking_constraint(
  lex_less([positions_y[order[1]], positions_x[order[1]]], [positions_y[order[2]], positions_x[order[2]]])
);	
  
% % rows and columns symmetry
% constraint symmetry_breaking_constraint(
%     forall (i,j in 1..n where i < j) ((positions_x[order[i]] == positions_x[order[j]] /\ dimensions[order[i], 1] == dimensions[order[j], 1]) -> positions_y[order[i]] <= positions_y[order[j]] ));
% constraint symmetry_breaking_constraint(
%     forall (i,j in 1..n where i < j) ((positions_y[order[i]] == positions_y[order[j]] /\ dimensions[order[i], 2] == dimensions[order[j], 2]) -> positions_x[order[i]] <= positions_x[order[j]] ));

% % three blocks symmetry
% constraint symmetry_breaking_constraint(
%     forall (i,j,k in 1..n where i > j /\ j > k)
%         ((positions_x[order[i]] == positions_x[order[j]] /\ dimensions[order[i], 1] == dimensions[order[j], 1] /\ positions_y[order[i]] == positions_y[order[k]] /\ dimensions[order[i], 2] + dimensions[order[j], 2] == dimensions[order[k], 2]) -> positions_x[order[k]] <= positions_x[order[i]] ));
% constraint symmetry_breaking_constraint(
%     forall (i,j,k in 1..n where i > j /\ j > k)
%         ((positions_y[order[i]] == positions_y[order[j]] /\ dimensions[order[i], 2] == dimensions[order[j], 2] /\ positions_x[order[i]] == positions_x[order[k]] /\ dimensions[order[i], 1] + dimensions[order[j], 1] == dimensions[order[k], 1]) -> positions_y[order[k]] <= positions_y[order[i]] ));
      
% IMPLIED
% constraint all_different([positions_x[i] * 10 + positions_y[order[i]] | i in 1..n])::domain;

% SEARCH
solve :: seq_search([
    int_search(positions_y, dom_w_deg, indomain_min),
    int_search(positions_x, dom_w_deg, indomain_min),
    int_search([height], smallest, indomain_min)])
    % ::restart_geometric(2, 50)
    minimize height;