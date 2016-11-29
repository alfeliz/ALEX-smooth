#! /usr/bin/octave -q
#La línea de arriba señala que es un script que se le pasará a este programa. Recuerda que el archivo tiene que ser ejecutable. 
#La opción -q es para evitar el mensajillo de saludo al principio.
## Copyright (C) 2016 Gonzalo Rodríguez Prieto <gonzalo.rprieto@uclm.es>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.
###########################################################################################
#
#
#  OCTAVE SCRIPT TO OBTAIN THE SMOOTH A DATA VECTOR IN A FAST WAY
#    Made by Gonzalo Rodríguez Prieto
#              Version 0.0
#
#
#########################################################
#
#   It uses the function:
#	 	 display_rounded_matrix
#  It must be in the same directory.
#
###########################################################################################



#Charge the smooth package:
pkg load data-smoothing %To smooth data correctly

pkg load io %Input Output package

tic; #Control total computing time.

#Empty memory from user created variables:
clear;

###
# Parameters:
###
mm = 1e3; %meters
us = 1e6; %seconds


###########################################################################################
#### READ THE FILE AND SMOOTH IT
###########################################################################################



###
# Reading the data file (only 2 rows, see line 81):
###

arg_list = argv (); %Aquí está el comando que se usó, arg_list{1} y todo lo que le pongas detrás.

printf("Argumentos: \n");
for i = 1:nargin %nargin es el número de argumentos, incluidos el comando de entrada.
  printf (" %s", arg_list{i});
endfor
printf ("\n");

#String with the file name:
%filename = "500µm-15kV-All.txt"; %Testing purposes.
filename = arg_list{1}

[file, msg] = fopen(filename, "r");
if (file == -1) 
   error ("ALEX-smooth script: Unable to open file name: %s, %s",filename, msg); 
endif;

data = csv2cell(filename); %rading a CSV file like a boss...

# data(1,:) has all the headers of the CSV file.
# data(2:end,:) has all the columns (4 are expected in this file)

#Transforming the data in numbers:
t = cell2mat(data(2:end,1)); #Time vector (in µs)
r = cell2mat(data(2:end,2));  #Radius vector (in mm) (IT DOES NOT WORK WITH EMPTY ELEMENTS IN THE ARRAY!!!!)
t = sort(t); #Ordering the vectors correctly
r = sort(r);



###
# Smoothing the data:
###
if(length(t)==length(r))
	trad = linspace(t(1),t(end),round(abs(t(end)-t(1))/0.010))'; %Equispaciated vector with 10 ns. Necessary for smoothing
	dev = std(r); %Standard deviation. Best for not over smoothing.
	#Radial data smoothing:
	%r_smooth = regdatasmooth(t,r, "xhat", trad, "stdev", dev, "relative" ); % "xhat": points for x values; "stdev": value of admited standard deviation;
	r_smooth = regdatasmooth(t,r, "xhat", trad, "lambda", 0.007 ); % "xhat": points for x values; "lambda": value starting lambda value.
else
	error("Vectors radial and time are not of the same length")
endif;
 

###
# Cheking graphs:
###
#Smoothing and experimental data:
 graphics_toolkit ("gnuplot"); %To save LATEX symbols properly.
figure("visible","off");
plot(t,r,"*k",trad,r_smooth,"-g"); %Show the radial shadow border expansion, smoothing.
title(filename,"interpreter","tex"); %Graph title: Filename of data.
xlabel('t(\mus)',"interpreter","tex");%Graph labels
ylabel("r(mm)");
legend('Exp. data', 'Smoothing');
graphname = horzcat(filename(1:index(filename,".","first")),"rad_smooth.jpg"); %Graph filename
print(graphname); %Save a file with the graph
close; %Close the graph window


graphics_toolkit ("fltk"); %To come back to normal.



###
# Saving the results:
###



#Saving r smoothed data:
#Output file name:
name = horzcat(filename(1:index(filename,".","first")),"-smooth.dat"); %Adding the right sufix to the shot name chosen from the filename variable.
output = fopen(name,"w"); %Opening the file.
#First line ((Veusz system, acepted as garbage line by QtiPlot):
fdisp(output,"descriptor `t(µs)`  `r_shadow(mm)`");
redond = [4 4];
rad2 = [trad, r_smooth]; %Puting the vectors in columns.
display_rounded_matrix(rad2, redond, output); 
fclose(output); %Closing the file.


###
# Total processing time
###

timing = toc; 

disp("Script ALEX-smooth execution time:")
disp(timing)
disp(" seconds")  


#That's...that's all folks!!!
