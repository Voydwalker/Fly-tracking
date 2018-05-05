%%After camera stereo calibration use the calculated camera matrices,
%rotation matrix and translation vector to calculate the Fundamental
%matrix.
%%
function ret = computeF(K1, K2, R, t) %Input: left-, right cam, rotation, translation
  A = K1 * R' * t;
  C = [0 -A(3) A(2); A(3) 0 -A(1); -A(2) A(1) 0];
  ret = (inv(K2))' * R * K1' * C;
end