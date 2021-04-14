function [Gcode] = funWriteGcode(x0,extrusionVol,filename)
%FUNCTION funWriteGcode(x0,extrusionVol,filename)
% to output a G-code script to control motions of 3D-printer to paint a 
% designated pattern on the sample surface
% -------------------------------------------------------------
% Inputs:
%
%   x0         [required] A 3-column matrix to store the dot coordinates. 
%                         The row number equals the number of the beads, 
%                         and the x,y z coordinates are stored in the first,  
%                         second and third column, respectively
%   extrusion  [required] Extrusion volume (unit: mL) of the ink to print 
%                         each dot. It needs to be a single scalar or a  
%                         vector of the same length as the number of dots
%   filename   [optioanl] Name of the written G-code file, needs to be a string
%                         ended with 'gcode'. It is called 'Patten.gcode' by default.
%
% -------------------------------------------------------------
% Output:
%
%   Gcode       G-code lines are written into an output "*.gcode" file.
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
% ==============================================================

nbeads = size(x0,1); % number of dots
if nargin == 2; filename='Pattern.gcode'; end
if length(extrusionVol)== 1; extrusionVol=extrusionVol*ones(nbeads,1);end


%% G-code start part

% prepare motor for printing
Gcodebegin=strcat('T0 ; select extruder0\n' ...
                 ,'G92 X0 Y0 Z0 E0\n '...
                 ,'G1 E0.0001\n' ...
                 ,'G92 E0\n' ...
                 ,'T0\n' ...
                 ,'M302 P1\n' ...
                 ,'G21 ; set units to millimeters\n' ...
                 ,'G90 ; use absolute coordinates\n' ...
                 ,'M83 ; use relative distances for extrusion\n');  


%% G-code main body part

fileID = fopen(filename,'w');
x= x0(:,1);
y= x0(:,2);
z= x0(:,3);
Gbody=sprintf('; start pattern\nG1 Z2 \n');
G3=sprintf('G1 Z6 F800');
extrusionVol=extrusionVol/(1.61e-7)*0.0001; % transfer the extrusion volume to extrusion distance of motor 

% We complete the body part of the G code by printing all the dots.
for i=1:nbeads
    G1=sprintf('G1 X%.4f Y%.4f E0 F500',x(i),y(i)); % go to the designed position
    G2=sprintf('G1 Z%.4f E%.5f F200',z(i),extrusionVol(i)); % extrude a certain volume of ink
    G3=sprintf('G1 Z6 F800');
    Gbody=strcat(Gbody,'\n',G1,'\n',G2,'\n',G3);
end


%% G-code end part

Gcodeend=strcat('G1 E-0.075 F60 ; retreat extruder\n'...
    ,'G1 Z20 F500 ; retreat head\n'...
    ,'G28 ; home the exruder\n'...
    ,'G92 X0 Y0 Z0 E0; set the current position to be(0,0,0)\n'...
    ,'M84 ;Motors off');

Gcode=strcat(Gcodebegin,Gbody,Gcodeend);
fprintf(fileID,Gcode);



