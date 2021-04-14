% Main file for generating G-code scripts as input to control motions of a 
% 3D printer to print DIC speckle pattern.
%
% ----------------------------------------------------------------
% Author: Jialiang Tao, University of Wisconsin-Madison (jtao22@wisc.edu)
% Edited by: Jin Yang (jyang526@wisc.edu)
% Date: 09-15-2020, 04-13-2021
%
% ----------------------------------------------------------------
% References
% [1] J Yang*, JT Tao*, C Franck. Smart Digital Image Correlation Patterns
%     via 3D Printing, Experimental Mechanics, 2021. (*: Equal contributions)
% [2] M Patel, SE Leggett, AK Landauer, IY Wong, and C Franck. Rapid, 
%     topology-based particle trackingfor high-resolution measurements of 
%     large complex 3D motion fields.Scientific Reports, 8:5581, 2018.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

%% Initialize parameters

% Total number of speckle dots
nDots = 500;

% DIC print pattern ROI size (mm)
ROISize = [12.7, 12.7];

% Resolution of camera: pixels of a single image
pxSize = [1024 1024];

% Generate a set of dots following a random Poisson distribution
spacing = 15; showIter = 0;
[x0] = poissonDisc(pxSize,spacing,nDots,showIter); % Coordinates of pattern dots

% Transform the units of each pattern dot's position from "pixel" to "mm"
transRatio = ROISize./pxSize;

x0_pw = x0*diag(transRatio); % x0 in physical world with unit "mm"
 
% Z-motions are set to be zeros for flat, planar sample top surface
x0_pw(:,3) = 0;

% Output G-code script file name
fileName = 'Pattern.gcode';

% Set uniform extrusion volume % could be non-uniform values
extrusionVol = 1.61e-7; % Unit: mL


%% Generate G-code file

Gcode = funWriteGcode(x0_pw,extrusionVol,fileName);



