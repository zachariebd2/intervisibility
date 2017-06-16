
Intervisibility_gen.sh: reads from a text file the orbital parameters of a satellite and the parameters of multiple ground station. For each ground station it produces a temporary scilab file (with the parameters written in it) which will call Intervisibility_gen.sci

Intervisibility_gen.sci : calculate the intervisibility data between a satellite and a space station. Sends the result to Intervisibility2CIC.sci

Intervisibility2CIC.sci: prepare the intervisibility data into the CIC format so it can be read by VTS (visualisation tool for space missions)