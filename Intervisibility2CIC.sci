// File name: Intervisibility2CIC.sci
// Final Modified Date: 08/07/2016 
// Author: Barrou Dumont, Zacharie
// Email : zachariebd@hotmail.com
//


// visibility: (dates (day), date(seconds), indication of intervisibility, elevation, azimuth, distance satellite-station, distance satellite-station (has to be changed))
// GS_Position: position of the ground station
// GS_name: name of the ground station
// Sat_Name: name of the satellite
// GS_Body_Name : name of the ground station's planet
// File_path_Inter : name of the output file



function [] = Intervisibility2CIC(visibility,Sat_name, GS_Body_name,File_path_Inter, GS_name, GS_Position);
   
	// Header  definition
	time = getdate();
	time1 = [time(1),time(2), time(6), time(7), time(8), time(9), time(10)];

	correction_month = "";
	correction_day   = "";
	correction_hour = "";
	correction_mn = "";
	correction_sec = "";

	if time(6) <10 then
	correction_day   = '0';
	end
	if time(2) <10 then
	correction_month = '0';
	end
	if time(7) <10 then
	correction_hour = '0';
	end
	if time(8) <10 then
	correction_mn = '0';
	end
	if time(9) <10 then
	correction_sec = '0';
	end
	time1   = strcat(['CREATION_DATE = ', string(time1(1)),"-",strcat([correction_month,string(time1(2))]),"-",strcat([correction_day,string(time1(3))]),"T",strcat([correction_hour,string(time1(4))]),":",strcat([correction_mn,string(time1(5))]),":",strcat([correction_sec,string(time1(6))]),".",string(time1(7)) ]);

	// Writing to file
    fd = mopen(File_path_Inter,'wt');
    mfprintf(fd,'CIC_OEM_VERS = 3.0\n');
    mfprintf(fd,'%s\n',time1);
    mfprintf(fd,'ORIGINATOR = DOCKing System\n');
    mfprintf(fd,'\n');
    mfprintf(fd,'META_START\n');
    mfprintf(fd,'\n');
    mfprintf(fd,'OBJECT_NAME = %s\n',Sat_name);
    mfprintf(fd,'OBJECT_ID = %s\n',Sat_name);
    mfprintf(fd,'CENTER_NAME = %s\n',GS_Body_name);
    mfprintf(fd,'STATION_NAME = %s\n',GS_name);
    mfprintf(fd,'STATION_COORDINATE = %f %f %f\n',GS_Position(1),GS_Position(2),GS_Position(3));
    mfprintf(fd,'REF_FRAME = ECF\n');
    mfprintf(fd,'TIME_SYSTEM = UTC\n');
    mfprintf(fd,'\n');
    mfprintf(fd,'COLUMNS: MJD DATE,MJD SEC, INTERVISIBILITY, ELEVATION, AZIMUT, DISTANCE\n');
    mfprintf(fd,'META_STOP\n');
    mfprintf(fd,'\n');

	//Combine all data into one matrix 
        for i=1:1:size(visibility,'r')

                 mfprintf(fd,'%d %f %d %f %f %f\n',visibility(i,1),visibility(i,2),visibility(i,3),visibility(i,4),visibility(i,5),visibility(i,6));

        end
	

    mclose(fd);


endfunction
