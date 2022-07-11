include "globals.mzn";

int: width;
int: n;
array[1..n] of int: w;
array[1..n] of int: h;
int: max_height = sum(h);
int: min_height = floor(sum(i in 1..n)(w[i] * h[i]) / width);

var min_height..max_height: height;
array[1..n] of var 0..(width - min(w) + 1): positions_x;
array[1..n] of var 0..(max_height - min(h) + 1): positions_y;

% positions & overflow bounds
constraint forall(i in 1..n)(positions_x[i] <= width - w[i] /\ positions_y[i] <= height - h[i]);

% no overlap
constraint cumulative(positions_y, h, w, width)::domain;
constraint cumulative(positions_x, w, h, height)::domain;
constraint diffn(positions_x, positions_y, w, h)::domain;

% height definition
constraint height = max([positions_y[i] + h[i] | i in 1..n]);

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
			w[i] == w[j]
		) -> positions_y[i] <= positions_y[j]
	)
);
constraint symmetry_breaking_constraint(
	forall (i,j in 1..n where i < j)(
		(
			positions_y[i] == positions_y[j] /\ 
    	h[i] == h[j]
		) -> positions_x[i] <= positions_x[j]
	)
);

% three blocks symmetry
constraint symmetry_breaking_constraint(
	forall (i,j,k in 1..n where i > j /\ j > k)(
		(
			positions_x[i] == positions_x[j] /\ 
			w[i] == w[j] /\ 
			positions_y[i] == positions_y[k] /\ 
			h[i] + h[j] == h[k]
		) -> positions_x[k] <= positions_x[i]
	)
);
constraint symmetry_breaking_constraint(
	forall (i,j,k in 1..n where i > j /\ j > k)(
    (
    	positions_y[i] == positions_y[j] /\ 
    	h[i] == h[j] /\ 
    	positions_x[i] == positions_x[k] /\ 
    	w[i] + w[j] == w[k]
    ) -> positions_y[k] <= positions_y[i] 
	)
);

% SEARCH
solve :: seq_search([
    int_search(positions_y, first_fail, indomain_min),
    int_search(positions_x, first_fail, indomain_min),
    int_search([height], smallest, indomain_min)])
    minimize height;