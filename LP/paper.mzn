int: width;
int: n;
array[1..n, 1..2] of int: dimensions;
int: m = 5;
0..1: allow_rotation =  0;

int: domain_limit = 1000000;

var int: M;
var int: height;
array[1..n] of var 0..domain_limit: xbl;
array[1..n] of var 0..domain_limit: xbr;
array[1..n] of var 0..domain_limit: ybb;
array[1..n] of var 0..domain_limit: ybt;
array[1..m] of var 0..domain_limit: xbl_bb;
array[1..m] of var 0..domain_limit: xbr_bb;
array[1..m] of var 0..domain_limit: ybb_bb;
array[1..m] of var 0..domain_limit: ybt_bb;
array[1..m, 1..2] of var 0..domain_limit: bb_dimensions;
array[1..n, 1..n] of var 0..1: r;
array[1..n, 1..n] of var 0..1: u;
array[1..n] of var 0..1: v;
array[1..n] of var 1..m: E;
array[1..n, 1..2] of var 0..domain_limit: actual_dimensions;

var int: objective_function;

constraint sum(v) <= allow_rotation; 

constraint objective_function = sum(k in 1..m)(
  bb_dimensions[k, 1] + bb_dimensions[k, 2]
) + width * height;

constraint forall(i in 1..n)(
  E[i] = 
);

% Constraints 1-4
constraint forall(k in 1..m)(
  forall(i in 1..n where E[i] = k)(
    xbl_bb[k] <= 0.5 * (xbl[i] + xbr[i]) /\
    xbr_bb[k] >= 0.5 * (xbl[i] + xbr[i]) /\
    ybb_bb[k] <= 0.5 * (ybb[i] + ybt[i]) /\
    ybt_bb[k] >= 0.5 * (ybb[i] + ybt[i])
  )
);

% Constraints 5-6
constraint forall(k in 1..m)(
  xbr_bb[k] - xbl_bb[k] = bb_dimensions[k, 1] /\
  ybb_bb[k] - ybt_bb[k] = bb_dimensions[k, 2]
);

% Constraints 7-8
constraint forall(i in 1..n)(
  xbr[i] - xbl[i] = actual_dimensions[i, 1] /\
  ybb[i] - ybt_bb[i] = actual_dimensions[i, 2]
);

% Rotation
constraint forall(i in 1..n)(
  actual_dimensions[i, 1] = v[i] * dimensions[i, 2] + (1 - v[i]) * dimensions[i, 1]
);
constraint forall(i in 1..n)(
  actual_dimensions[i, 2] = (1 - v[i]) * dimensions[i, 2] + v[i] * dimensions[i, 1]
);

% Constraint 13
constraint forall(i in 1..n)(
  forall(j in 1..n where i < j)(
    r[i, j] + r[j, i] + u[i, j] + u[j, i] <= 3
  )
);

% Constraint 14
constraint forall(i in 1..n)(
  forall(j in 1..n where i != j)(
    xbr[i] <= xbl[j] + M * r[i, j]
  )
);

% Constraint 15
constraint forall(i in 1..n)(
  forall(j in 1..n where i != j)(
    ybt[i] <= ybb[j] + M * u[i, j]
  )
);

% Constraint 16-17
constraint forall(i in 1..n)(
  forall(j in 1..n)(
    width >= xbr[i] - xbl[j] /\
    height >= ybt[i] - ybb[j]
  )
);

solve minimize objective_function;