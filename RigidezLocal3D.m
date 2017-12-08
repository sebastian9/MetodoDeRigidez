function [K] = RigidezLocal3D(E, A, L, Iz, Iy, G, J)

K_1 = ( [ E*A/L 0 0 0 0 0 -E*A/L 0 0 0 0 0 ] );
K_2 = ( [ 0 12*E*Iz/L^3 0 0 0 6*E*Iz/L^2 0 -12*E*Iz/L^3 0 0 0 6*E*Iz/L^2 ] );
K_3 = ( [ 0 0 12*E*Iy/L^3 0 -6*E*Iy/L^2 0 0 0 -12*E*Iy/L^3 0 -6*E*Iy/L^2 0 ] );
K_4 = ( [ 0 0 0 G*J/L 0 0 0 0 0 -G*J/L 0 0 ] );
K_5 = ( [ 0 0 -6*E*Iy/L^2 0 4*E*Iy/L 0 0 0 6*E*Iy/L^2 0 2*E*Iy/L 0 ] );
K_6 = ( [ 0 6*E*Iz/L^2 0 0 0 4*E*Iz/L 0 -6*E*Iz/L^2 0 0 0 2*E*Iz/L ] );
K_7 = ( [ -E*A/L 0 0 0 0 0 E*A/L 0 0 0 0 0 ] );
K_8 = ( [ 0 -12*E*Iz/L^3 0 0 0 -6*E*Iz/L^2 0 12*E*Iz/L^3 0 0 0 -6*E*Iz/L^2 ] );
K_9 = ( [ 0 0 -12*E*Iy/L^3 0 6*E*Iy/L^2 0 0 0 12*E*Iy/L^3 0 6*E*Iy/L^2 0 ] );
K_10 = ( [ 0 0 0 -G*J/L 0 0 0 0 0 G*J/L 0 0 ] );
K_11 = ( [ 0 0 -6*E*Iy/L^2 0 2*E*Iy/L 0 0 0 6*E*Iy/L^2 0 4*E*Iy/L 0 ] );
K_12 = ( [ 0 6*E*Iz/L^2 0 0 0 2*E*Iz/L 0 -6*E*Iz/L^2 0 0 0 4*E*Iz/L ] );
K = [ K_1; K_2; K_3; K_4; K_5; K_6; K_7; K_8; K_9; K_10; K_11; K_12 ];

end