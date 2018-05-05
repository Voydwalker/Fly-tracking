
					Fly-tracking

This work was done with MATLAB and the Image Processing Toolbox under university license.
The files are part of my bachelor's thesis project aimed at tracking Drosophila Melanogaster in an arena.


In order to perform tracking with the current version please follow the following steps.
1.Camera stereo calibration with the Caltech Matlab calibration Toolbox.

2.Calculate the camera matrces and use computeF.m to get the Fundamental matrix.

3.Use Dpre_proc.m to get a background, subtract it, rectify video with undistort.m and get the detections.

4.Find the stereo correspondences and triangulate coordinates with Dcorr_triag.m.

5.Determine the tracks with Dster_cor.m

Note: certain parameters are hard-coded and are derived from the test data.