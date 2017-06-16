#!/bin/bash
# File name: Intervisibility_gen.sh
# Final Modified Date: 08/07/2016 
# 
# Author: Barrou Dumont, Zacharie
# Email : zachariebd@hotmail.com 
#



#INTERVISIBILITY DEPEND ON THE EASYTRAJECTORY RESULTS 

#===Load information from "Check_result.tmp" file===
Check_result=Module/Tmp/Check_result.tmp
Exit_flag=`tac $Check_result | grep -m 1 '^ *Exit *=' | awk -F '"' '{printf $2}'`
if [ "$Exit_flag" == "True" ]; then
	exit 0
fi

Date=`tac $Check_result | grep -m 1 '^ *Date *=' | awk -F '"' '{printf $2}'`
Scenario_file=`tac $Check_result | grep -m 1 '^ *Scenario_name *=' | awk -F '"' '{printf $2}'`
Scenario_location=`tac $Check_result | grep -m 1 '^ *Scenario_location *=' | awk -F '"' '{printf $2}'`
Configuration_file=`tac $Check_result | grep -m 1 '^ *Configuration_name *=' | awk -F '"' '{printf $2}'`
Configuration_location=`tac $Check_result | grep -m 1 '^ *Configuration_location *=' | awk -F '"' '{printf $2}'`
Error_flag=`tac $Check_result | grep -m 1 '^ *Error_flag *=' | awk -F '"' '{printf $2}'`
Dock_main_location=`pwd`

#===Check the need of this module===  
INTERVISIBILITY=`grep 'INTERVISIBILITY' $Check_result | awk -F '"' '{printf $2}'`        
if [ "$INTERVISIBILITY" == "True" ]; then     
	echo ""
	echo "===Intervisibility module===" | tee -a "$Dock_main_location/Output/Log/DEBUG_Log/Log-$Date.log"
else
	exit
fi



#===Load parameters from Scenario file=== THE REALTRAJ OPTION WILL HAVE TO BE ADDED
Keep_temp_file=`tac $Scenario_file | grep -m 1 '^ *Keep_temp_file *=' | awk -F '"' '{printf $2}'`
Satellite_Sat_name=`tac $Configuration_file | grep -m 1 '^ *Satellite_name *=' | awk -F '"' '{printf $2}'`
Satellite_Body_name=`tac $Configuration_file | grep -m 1 '^ *Satellite_parentpath *=' | awk -F '"' '{printf $2}' | awk -F / '{print $2}'`


Easy_traj_type=`tac $Scenario_file | grep -m 1 '^ *Easy_traj_type *=' | awk -F '"' '{printf $2}'`
Easy_traj_sma=`tac $Scenario_file | grep -m 1 '^ *Easy_traj_sma *=' | awk -F '"' '{printf $2}'`
Easy_traj_ecc=`tac $Scenario_file | grep -m 1 '^ *Easy_traj_ecc *=' | awk -F '"' '{printf $2}'`
Easy_traj_inc=`tac $Scenario_file | grep -m 1 '^ *Easy_traj_inc *=' | awk -F '"' '{printf $2}'`
Easy_traj_pom=`tac $Scenario_file | grep -m 1 '^ *Easy_traj_pom *=' | awk -F '"' '{printf $2}'`
Easy_traj_gom=`tac $Scenario_file | grep -m 1 '^ *Easy_traj_gom *=' | awk -F '"' '{printf $2}'`
Easy_traj_anm=`tac $Scenario_file | grep -m 1 '^ *Easy_traj_anm *=' | awk -F '"' '{printf $2}'`







#===Check if the specific directory is existing or not, if not, use the default "Output/Intervisibility" and folder===		
cd $Configuration_location
Intervisibility_output_location=`tac $Configuration_file | grep -m 1 '^ *Intervisibility_output_location *=' | awk -F '"' '{printf $2}'`
if [ ! -d "$Intervisibility_output_location" ]; then
	Intervisibility_output_location="$Dock_main_location/Output/Intervisibility"
	echo "Use the default output folder which is \"Output/Intervisibility/\""
elif [ "$Intervisibility_output_location" == "." ]; then
	Intervisibility_output_location=$Configuration_location
else
	# Force the path to be a standard format of absolute path 	
	Intervisibility_output_location=`cd $Intervisibility_output_location;pwd`
fi

Easy_traj_output_location=`tac $Configuration_file | grep -m 1 '^ *Easy_traj_output_location *=' | awk -F '"' '{printf $2}'`
if [ ! -d "$Easy_traj_output_location" ]; then
	Easy_traj_output_location="$Dock_main_location/Output/Easy_traj"
	echo "Use the default output folder which is \"Output/Easy_traj/\""
elif [ "$Easy_traj_output_location" == "." ]; then
	Easy_traj_output_location=$Configuration_location
else
	# Force the path to be a standard format of absolute path 	
	Easy_traj_output_location=`cd $Easy_traj_output_location;pwd`
fi

cd $Dock_main_location




#---Check the Sat name---
if [ "$Satellite_Sat_name" = "" ]; then
	Satellite_Sat_name="Undefined"
fi
if [ "$Satellite_Body_name" = "" ]; then
	Satellite_Body_name="Undefined"
fi

#---Send a title into Log file---
{ echo "===Intervisibility===" ; } >> $Dock_main_location/Output/Log/DEBUG_Log/Log-$Date.log






#===Creating new Scilab file for each stations===


cd Module/Intervisibility/

Current_location=`pwd`	



GroundStations_number=`tac $Scenario_file | grep -m 1 '^ *GroundStations_number *=' | awk -F '"' '{printf $2}'`
echo "GroundStations_number = $GroundStations_number"

for i in $(seq 1 $GroundStations_number)   # for each station
do

#for each station we read their parameters in the strings (for station 2 we select the second parameter of each string using " awk -v fd=$i '{printf $fd}' ")
 GroundStation_name=`tac $Scenario_file | grep -m 1 '^ *GroundStations_names *=' | awk -F '"' '{printf $2}'| awk -v fd=$i '{printf $fd}'`
 GroundStation_bodie=`tac $Scenario_file | grep -m 1 '^ *GroundStations_bodies *=' | awk -F '"' '{printf $2}'| awk -v fd=$i '{printf $fd}'`
 GroundStation_elevation=`tac $Scenario_file | grep -m 1 '^ *GroundStations_elevations *=' | awk -F '"' '{printf $2}'| awk -v fd=$i '{printf $fd}'`
 GroundStation_longitude=`tac $Scenario_file | grep -m 1 '^ *GroundStations_longitudes *=' | awk -F '"' '{printf $2}'| awk -v fd=$i '{printf $fd}'`
 GroundStation_latitude=`tac $Scenario_file | grep -m 1 '^ *GroundStations_latitudes *=' | awk -F '"' '{printf $2}'| awk -v fd=$i '{printf $fd}'`
 GroundStation_altitude=`tac $Scenario_file | grep -m 1 '^ *GroundStations_altitudes *=' | awk -F '"' '{printf $2}'| awk -v fd=$i '{printf $fd}'`


echo ""
echo "Creating new Scilab .sce file for intervisibility......"

# a temporary scilab file is created to initialise the necessary variables and tables and call the Intervisibility_gen function  
cat > $Current_location/Intervisibility-tmp-$GroundStation_name-$Date.sce <<EOF
clear
clc
cd $Current_location
// Mean orbital elements, frame = ECI(EME2000)
sma = $Easy_traj_sma * 1000; // semi major axis (unit m)
ecc = $Easy_traj_ecc; // eccentricity 
inc = $Easy_traj_inc * %pi/180; // inclination
pom = $Easy_traj_pom * %pi/180; // Argument of perigee
gom = $Easy_traj_gom * %pi/180; // RAAN (Longitude of the ascending node)
anm = $Easy_traj_anm * %pi/180; // Mean anomaly

// Orbit type: Keplerian or Circular
type_oe = "$Easy_traj_type";

//Trajectory Data
//We read the trajectory data directy from the output of easyquat
Mat = fscanfMat("$Dock_main_location/Output/Easy_traj/Easy-traj-$Date.txt");

Dates(:,1) = Mat(:,1);
Dates(:,2) = Mat(:,2);
Sat_positions(:,1) = Mat(:,3);
Sat_positions(:,2) = Mat(:,4);
Sat_positions(:,3) = Mat(:,5);

// Ground Station
GS_name = "$GroundStation_name";
Body_name = "$GroundStation_bodie";
elev_min = $GroundStation_elevation * %pi/180;
GS_Position(1)=$GroundStation_longitude * %pi/180;
GS_Position(2)=$GroundStation_latitude * %pi/180;
GS_Position(3)=$GroundStation_altitude;
//GS_Position column vector

// CIC output setting
Sat_name = '$Satellite_Sat_name';
Body_name = '$Satellite_Body_name';
File_path = '$Intervisibility_output_location/Intervisibility-$GroundStation_name-$Date.txt';

//Call the Intervisibility2CIC function
exec('Intervisibility_gen.sci');

Intervisibility_gen(Dates, Sat_positions, sma, ecc, inc, pom, gom, anm, type_oe,GS_Position,elev_min,GS_name, Sat_name, Body_name, File_path);

//Intervisibility_gen(Dates, Sat_positions,GS_Position,elev_min,GS_name, Sat_name, Body_name, File_path);

exit();
EOF

echo "New .sce file has been created."
echo "File name: Intervisibility-tmp-$GroundStation_name-$Date.sce"
echo "" 		
echo "Executing the Scilab......"

#---Execute Scilab---
scilab-adv-cli  -f Intervisibility-tmp-$GroundStation_name-$Date.sce -nb >> $Dock_main_location/Output/Log/DEBUG_Log/Log-$Date.log

if [ $Keep_temp_file == "False" ]; then  #we erase the temporary file if this is the chosen option
	rm -f Intervisibility-tmp-$GroundStation_name-$Date.sce
fi

echo "New Intervisibility CIC file was created."
echo "File name is: Intervisibility-$GroundStation_name-$Date.txt"

#---Put the Intervisibility file name into "Check_result.tmp"
{ echo "New_Intervisibility_$GroundStation_name = \"$Intervisibility_output_location/Intervisibility-$GroundStation_name-$Date.txt\" by \"INTERVISIBILITY\"" ; } >> $Dock_main_location/Module/Tmp/Check_result.tmp

done











