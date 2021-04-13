function [Gcode] = funWriteGcode(x0,extrusion,filename)

% Purpose:
% Used to wirte the G-code for controlling the motion of 3D-printer
% to do designated pattern on surfaces
% Inputs:
% x0   -     [required] Position of the points, needs to be 3-column
%            matrix. Number of the rows equals the number of the beads 
%            and the x,y z coordinates are in the first, second and 
%            third column respectively
% extrusion -[required] Extrusion volume (ml) of each dot. It needs
%            to be a vector of the same length as the number of dots
%            or a single uniform value for all the dots.
% filename - [optioanl] Name of the gcode file, needs to be string
%            and end in '*.gcode'. It is 'Patten.gcode' by default.
%
% Output:
%
% Gcode  -   G-code lines written into the output.gcode file.
%
% Jialiang Tao, UW-Madison, 2020

nbeads=size(x0,1);%number of dots
if nargin == 2; filename='Pattern.gcode'; end
if length(extrusion)== 1; extrusion=extrusion*ones(nbeads,1);end


%% start gcode
Gcodebegin=strcat('T0 ; select extruder0\n' ...
    ,'G92 X0 Y0 Z0 E0\n '...
,'G1 E0.0001\n' ...
,'G92 E0\n' ...
,'T0\n' ...
,'M302 P1\n' ...
,'G21 ; set units to millimeters\n' ...
,'G90 ; use absolute coordinates\n' ...
,'M83 ; use relative distances for extrusion\n');% prepare motor for printing

%% g-code body

fileID = fopen(filename,'w');
x=x0(:,1);
y=x0(:,2);
z=x0(:,3);
Gbody=sprintf('; start pattern\nG1 Z2 \n');
G3=sprintf('G1 Z6 F800');
extrusion=extrusion/(1.61e-7)*0.0001;% transfer extursion volume to extrusion distance of motor 
% go through all the dots
for i=1:nbeads
    G1=sprintf('G1 X%.4f Y%.4f E0 F500',x(i),y(i));%Go to the designed position
    G2=sprintf('G1 Z%.4f E%.5f F200',z(i),extrusion(i));% Do extrusion
    G3=sprintf('G1 Z6 F800');
    Gbody=strcat(Gbody,'\n',G1,'\n',G2,'\n',G3);
end

%% end g-code

Gcodeend=strcat('G1 E-0.075 F60 ; retreat extruder\n'...
    ,'G1 Z20 F500 ; retreat head\n'...
    ,'G28 ; home the exruder\n'...
    ,'G92 X0 Y0 Z0 E0; set the current position to be(0,0,0)\n'...
    ,'M84 ;Motors off');
Gcode=strcat(Gcodebegin,Gbody,Gcodeend);
fprintf(fileID,Gcode);
