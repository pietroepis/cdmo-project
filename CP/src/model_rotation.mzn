include "globals.mzn";

int: width;
int: n;
array[1..n] of int: w;
array[1..n] of int: h;
int: max_height = sum(h);
int: min_height = floor(sum(i in 1..n)(w[i] * h[i]) / width);
int: max_dim = max([max(w), max(h)]);
int: min_dim = min([min(w), min(h)]);

var min_height..max_height: height;
array[1..n] of var 0..(width - min(w) + 1): positions_x;
array[1..n] of var 0..(max_height - min(h) + 1): positions_y;
array[1..n] of var min_dim..max_dim: actual_w;
array[1..n] of var min_dim..max_dim: actual_h;
array[1..n] of var bool: rotated;

% positions & overflow bounds
constraint forall(i in 1..n)(positions_x[i] <= width - actual_w[i] /\ positions_y[i] <= height - actual_h[i]);

% no overlap
constraint cumulative(positions_y, actual_h, actual_w, width)::domain;
constraint cumulative(positions_x, actual_w, actual_h, height)::domain;
constraint diffn(positions_x, positions_y, actual_w, actual_h)::domain;

% height definition
constraint height = max([positions_y[i] + actual_h[i] | i in 1..n]);

% symmetry breaking
constraint symmetry_breaking_constraint(
  lex_less(
  	[positions_y[1], positions_x[1]], 
  	[positions_y[2], positions_x[2]]
  )
);	
  
% rows and columns symmetry
constraint symmetry_breaking_constraint(
	forall (i,j in 1..n where i < j)(
		(
			positions_x[i] == positions_x[j] /\ 
			actual_w[i] == actual_w[j]
		) -> positions_y[i] <= positions_y[j]
	)
);
constraint symmetry_breaking_constraint(
	forall (i,j in 1..n where i < j)(
		(
			positions_y[i] == positions_y[j] /\ 
    	actual_h[i] == actual_h[j]
		) -> positions_x[i] <= positions_x[j]
	)
);

% three blocks symmetry
constraint symmetry_breaking_constraint(
	forall (i,j,k in 1..n where i > j /\ j > k)(
		(
			positions_x[i] == positions_x[j] /\ 
			actual_w[i] == actual_w[j] /\ 
			positions_y[i] == positions_y[k] /\ 
			actual_h[i] + actual_h[j] == actual_h[k]
		) -> positions_x[k] <= positions_x[i]
	)
);
constraint symmetry_breaking_constraint(
	forall (i,j,k in 1..n where i > j /\ j > k)(
    (
    	positions_y[i] == positions_y[j] /\ 
    	actual_h[i] == actual_h[j] /\ 
    	positions_x[i] == positions_x[k] /\ 
    	actual_w[i] + actual_w[j] == actual_w[k]
    ) -> positions_y[k] <= positions_y[i] 
	)
);

% rotation
constraint forall(i in 1..n)(
  actual_w[i] = (if rotated[i] then h[i] else w[i] endif)
);
constraint forall(i in 1..n)(
  actual_h[i] = (if rotated[i] then w[i] else h[i] endif)
);
constraint forall(i in 1..n where w[i] = h[i])(rotated[i] = false);

% SEARCH
solve :: seq_search([
    int_search(positions_y, first_fail, indomain_min),
    int_search(positions_x, first_fail, indomain_min),
    int_search([height], smallest, indomain_min)])
    :: restart_geometric(2, 50)
    minimize height;