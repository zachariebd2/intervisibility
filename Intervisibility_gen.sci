// File name: Intervisibility_gen.sci
// Final Modified Date: 08/07/2016 
// Author: Barrou Dumont, Zacharie
// Email : zachariebd@hotmail.com



// this function calculate when there is intervisibility between a satellite and a ground station
// the result is sent to Intervisibility2CIC.sci 


// Dates: dates (days,seconds) in the MJD format for each satellite position
// Sat_Positions : satellite positions (x,y,z) (EME2000) in km
// sma, ecc, inc, pom, gom, anm : orbital parameters
// type_oe: type of orbit
// GS_Position: position of the ground station
// elev_min : minimum elevation at which intervisibility is possible for the ground station
// GS_name: name of the ground station
// Sat_Name: name of the satellite
// GS_Body_Name : name of the ground station's planet
// File_path_Inter : name of the output file


function [] = Intervisibility_gen(Dates, Sat_Positions, sma, ecc, inc, pom, gom, anm, type_oe,GS_Position,elev_min,GS_name, Sat_Name, GS_Body_Name, File_path_Inter)

    // preparation of orbital parameters
    if type_oe == "Keplerian" then
        moe = [sma; ecc; inc; pom; gom; anm]; 
        orbit = "kep";
        model = "lydlp";
    else
        ecc_x = ecc*cos(pom);
        ecc_y = ecc*sin(pom);
        pso   = pom + anm;
        moe = [sma; ecc_x; ecc_y; inc; gom; pso];
        orbit = "cir";
        model = "central";
    end

    // Creation of a CJD format date for the CL_fr_convert function
    MJD = Dates(:,1) + Dates(:,2)/86400.0;
    MJD = MJD';
    CJD = CL_dat_convert("mjd","cjd",MJD);


    // Conversion of satellite position from 'EME2000' to 'Earth Center Fixed'
    Sat_Positions = Sat_Positions*1000;
    Sat_Positions = Sat_Positions';
    Sat_Positions_ECF = CL_fr_convert("EME2000","ECF",CJD,Sat_Positions);


    // calculation of azimut,elevation,distance for each positions
    [azim,elev,dist] = CL_gm_stationPointing(GS_Position,Sat_Positions_ECF);


    //calculation of intervisibility flags
    for i = 1:1:size(MJD,'c')
        if  elev(i) >= elev_min then  
            flag(i) = 1; //intervisibility at Dates(i)  
        else
            flag(i) = 0; //no intervisibility at Dates(i)
        end
    end


    
    //calculation of intervisibility entering and exiting times


    visibility = [0,0,0,0,0,0,0]; //this matrix will contain all the intervisibility information
    prec = 0.01;   //precision for the minimum interval calculation
    t0 = CJD(1);
    for i = 1:1:(size(MJD,'c')-1)

        if flag(i) < flag(i+1) then   //for entering times //if we go from 0 to 1

           Interval = CJD(i+1) - CJD(i);
           CJD1 = CJD(i);
           CJD2 = CJD(i+1);
           while Interval * 86400.0 > prec  
                 CJD12 = CJD1 + Interval/2;   //we create a middle point between CJD1 and CJD2
                 oe = CL_ex_propagate(model, orbit, t0, moe, CJD12, "o"); 
                 if type_oe == "Keplerian" then
                    [pos_eci, vel_eci] = CL_oe_kep2car(oe);  
                 else
                    [pos_eci, vel_eci] = CL_oe_cir2car(oe);
                 end   
                 pos_ecf = CL_fr_convert("EME2000","ECF",CJD12,pos_eci);
                 [azim12,elev12,dist12] = CL_gm_stationPointing(GS_Position,pos_ecf);  //we calculate the elevation of the middle point
                 if  elev12 >= elev_min then   //if intervisibility at CJD12
                     CJD2 = CJD12;
                 else
                     CJD1 = CJD12;
                 end
                 //the middle point becomes the new CJD1 or CJD2, thus reducing the interval
                 Interval = CJD2 - CJD1;  //we reduce the interval until the precision is obtained
           end
           MJD12 = CL_dat_convert("cjd","mjd",CJD12);  
           Sec12 = modulo(MJD12,1.0) * 86400.0;
           Day12 = MJD12 - modulo(MJD12,1.0); //we separate MJD12 into a MJD date (day) and a MJD time (sec)
           visibility($+1,:) = [Dates(i,1),Dates(i,2), flag(i) , elev(i),azim(i),dist(i),dist(i)]; //TODO: replace the second dist(i) by atmospheric attenuation
           visibility($+1,:) = [Day12,Sec12, 1 , elev12,azim12,dist12,dist12];

        elseif flag(i) > flag(i+1) then  //for exiting times //if we go from 1 to 0
           Interval = CJD(i+1) - CJD(i);
           CJD1 = CJD(i);
           CJD2 = CJD(i+1);
           while Interval * 86400.0 > prec  
                 CJD12 = CJD1 + Interval/2;
                 oe = CL_ex_propagate(model, orbit, t0, moe, CJD12, "o"); 
                 if type_oe == "Keplerian" then
                    [pos_eci, vel_eci] = CL_oe_kep2car(oe);  
                 else
                    [pos_eci, vel_eci] = CL_oe_cir2car(oe);
                 end   
                 pos_ecf = CL_fr_convert("EME2000","ECF",CJD12,pos_eci);
                 [azim12,elev12,dist12] = CL_gm_stationPointing(GS_Position,pos_ecf);
                 if  elev12 >= elev_min then   //if intervisibility at CJD12
                     CJD1 = CJD12;
                 else
                     CJD2 = CJD12;
                 end
                 Interval = CJD2 - CJD1;  //we reduce the interval until the precision is obtained
           end
           MJD12 = CL_dat_convert("cjd","mjd",CJD12);  
           Sec12 = modulo(MJD12,1.0) * 86400.0;
           Day12 = MJD12 - modulo(MJD12,1.0);
           visibility($+1,:) = [Dates(i,1),Dates(i,2), flag(i) , elev(i),azim(i),dist(i),dist(i)];
           visibility($+1,:) = [Day12,Sec12, 1 , elev12,azim12,dist12,dist12];

        else

           visibility($+1,:) = [Dates(i,1),Dates(i,2), flag(i) , elev(i),azim(i),dist(i),dist(i)];

        end



    end


    visibility(1,:) = [];  //we erase the first empty line 

    visibility(:,4) = visibility(:,4) * 180 / %pi;  //value in degree
    visibility(:,5) = visibility(:,5) * 180 / %pi;  //value in degree
    visibility(:,6) = visibility(:,6)/1000.0;       //value in kilometers
    // Call the Intervisibility2CIC function
    exec('Intervisibility2CIC.sci')

    // Generate CIC position file output
    Intervisibility2CIC(visibility,Sat_Name, GS_Body_Name, File_path_Inter, GS_name, GS_Position);


    printf("Success!\n");
endfunction
