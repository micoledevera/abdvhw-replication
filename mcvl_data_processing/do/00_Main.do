/*-------------------------------------------------
 Masterfile for reading MCVL and converting to .dta
-------------------------------------------------*/

clear
clear matrix
set more off
set matsize 3000

cd "..."

global do "\mcvl_data_processing\do"
global raw "\mcvl_data_processing\raw"
global dta "\mcvl_data_processing\dta"
global temp "\mcvl_data_processing\temp"
global out "\mcvl_data_processing\out"


global latest 2018

global yrlast =  2018
global yrfirst = 2005

*Read MCVL and tax data
forvalues x = 2005/$latest {
  do "$do\mcvl_reading_`x'"
}

do "$do\01_Past_info"

do "$do\02_MergeMCVL_05_12"
do "$do\02_MergeMCVL_13_latest"

do "$do\03_MonthlyVars"

do "$do\04_ReshapeData"

do "$do\05_OtherVars"

do "$do\06_01_FixIDs"
do "$do\06_02_DatosFiscales_Unemp"
do "$do\06_03_Pensions"
do "$do\06_04_Count_Days"

do "$do\07_01_Prep_Data_RemoveAllAfter2_NotClustering"
do "$do\07_02_Prep_Data_RemoveAllAfter3_NotClustering"
do "$do\07_03_Prep_Data_RemoveAllAfter2"
do "$do\07_04_Prep_Data_RemoveAllAfter2_morevars"
do "$do\07_05_Prep_Data_NoConstraint"









