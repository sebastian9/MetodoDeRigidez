function [T,TF] = MatrizDeTransformacion3D(lambda,eta)
cl = cos(lambda);
cn = cos(eta);
sl = sin(lambda);
sn = sin(eta);

T_0 = [ 0 0 0 0 0 0 ];
T_1 = [ cn*cl -cn*sl -sn 0 0 0 ];
T_2 = [ sl cl 0 0 0 0 ];
T_3 = [ sn*cl -sn*sl cn 0 0 0 ];
T_4 = [ 0 0 0 cn*cl -cn*sl -sn ];
T_5 = [ 0 0 0 sl cl 0 ];
T_6 = [ 0 0 0 sn*cl -sn*sl cn ];

T = [ T_1 T_0; T_2 T_0; T_3 T_0; T_4 T_0; T_5 T_0; T_6 T_0; T_0 T_1; T_0 T_2; T_0 T_3; T_0 T_4; T_0 T_5; T_0 T_6 ];

end