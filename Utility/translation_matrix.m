x_b_i = [-0.11 -0.18 -0.71 0 0 0];
x_b_l = [0.035 0.002 -1.23 -179.93 -0.23 0.50];
x_l_c = [0.041862 -0.001905 -0.000212 160.868615 89.914152 160.619894];
x_l_c2 = [0.011238 -0.040367 -0.000393 -160.239278 89.812338 127.472911];
dof2mat(x_b_l)
H_i_c = dof2mat(x_b_i)\dof2mat(x_b_l)*dof2mat(x_l_c);
H_i_c = H_i_c * [0 1 0 0;-1 0 0 0; 0 0 1 0; 0 0 0 1]
H_c_c2 = dof2mat(x_l_c)\dof2mat(x_l_c2);
H_c_c2 = [0 1 0 0;-1 0 0 0; 0 0 1 0; 0 0 0 1] \ H_c_c2 * [0 1 0 0;-1 0 0 0; 0 0 1 0; 0 0 0 1]
H_i_c2 = H_i_c * H_c_c2
function H = dof2mat(x)
    sr = sin(pi/180.0 * x(4));
    cr = cos(pi/180.0 * x(4));

    sp = sin(pi/180.0 * x(5));
    cp = cos(pi/180.0 * x(5));

    sh = sin(pi/180.0 * x(6));
    ch = cos(pi/180.0 * x(6));

    H = zeros(4);

    H(1, 1) = ch*cp;
    H(1, 2) = -sh*cr + ch*sp*sr;
    H(1, 3) = sh*sr + ch*sp*cr;
    H(2, 1) = sh*cp;
    H(2, 2) = ch*cr + sh*sp*sr;
    H(2, 3) = -ch*sr + sh*sp*cr;
    H(3, 1) = -sp;
    H(3, 2) = cp*sr;
    H(3, 3) = cp*cr;

    H(1, 4) = x(1);
    H(2, 4) = x(2);
    H(3, 4) = x(3);

    H(4, 4) = 1;
end