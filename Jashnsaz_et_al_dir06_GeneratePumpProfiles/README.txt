The MATLAB code get_pump_profiles.m is used to generate the pump profiles. 

1. For a desired profile, in get_pump_profiles.m, specify characteristics of the desired profile and the experimental flow setup (lines 6-15) and run it. Refer to the output t2.png figure in the subdirectory t2_25min_0.4M for an example. 
Running the code will generate a directory with the name of the desired profile. e.g., t2_25min_0.4M,

2. Copy and paste PumpProfilesGen_41phases.xlsx into the generated directory (or alternatively, PumpProfilesGen_251phases.xlsx depending if 40 or 250 phases are used in get_pump_profiles.m). The number is the number of phases that the pump operates in to generate the desired profile. See Figure S1 in Ref. Thiemicke/Jashnsaz (2019) Scientific Report. 

3. Wishing the generated directory, the CSV file containing "loadFile" in its name (e.g., rounded_TimeLapse_t2_25min_0.4M_loadFile.csv) contains the necessary data for the profile. 
Copy and paste the 1st column (pump rate, uL/min) and the 2nd column (dispensing volume, uL) from this CSV into F and H columns in PumpProfilesGen_41phases.xlsx, respectively.  Ctrl+ S to save the sheet. 

4. Switch to the second sheet in PumpProfilesGen_41phases.xlsx. Follow the steps below to generate a .PPL files that will be  uploaded to the syringe pump. 

5. File > Save as > specify File format as Tab Delimited Text (.txt), choose a name with extension .PPL (PUMPNAME.PPL) (up to 8 characters), and save. Hit "OK" and "Yes" in the alerts. Then close the entire PumpProfilesGen_41phases.xlsx file with ought saving. This step will generate PUMPNAME.PPL that will be used to be loaded to the the pumps. 



