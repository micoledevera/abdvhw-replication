// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// This code specify country-specific variables.  
// This version Jan 25, 2020
//	Halvorsen, Ozkan, Salgado
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// PLEASE DO NOT CHANGE VALUES FRM LINE 7 TO 20. IF NEEDS TO BE CHANGED, CONTACT Ozkan/Salgado

set more off
set matsize 500
set linesize 255
version 13  // This program uses Stata version 13. 

global begin_age = 25 		// Starting age
global end_age = 55			// Ending age
global base_price = 2018	// The base year nominal values are converted to real. 
global winsor=99.999999		// The values above this percentile are going to be set to this percentile. 
global noise=0.0			// Noise added to income. See line 112 in 1_Gen_Base_Sample.do


// PLEASE MAKE THE APPROPRIATE CHANGES BELOW. 

global unix=1  // Please change this to 1 if you run stata on Unix or Mac

global wide=0  // Please change this to 1 if your raw data is in wide format; 0 if long.
 
if($unix==1){
	global sep="/"
}
else{
	global sep="\"
}
// If there are missing observations for earnings between $begin_age and $end_age
// set the below global to 1. Otherwise, the code will convert all missing earnings
// observations to zero.
global miss_earn=1 

//Please change the below to the name of the actual data set
global datafile="..." 

// Define the variable names in your dataset.
global personid_var="person_id" 	// The variable name for person identity number.
global male_var="sex" 		// The variable name for gender: 1 if male, 0 o/w.
global yob_var="birth_year" 	// The variable name for year of birth.
global yod_var="death_year" 		// The variable name for year of death.
global educ_var="education" 		// The variable name for year of death.
global labor_var="wage" // The variable name for total annual labor earnings from all jobs during the year.  
global year_var="year" 		// The variable name for year if the data is in long format


scalar def educ_typ=2   /*Define the type of variable for education 1=string; 2=numerical*/

global iso = "ESP" 		// Define the 3-letters code of the country. Use ISO codes. For instance 
						// for Italy use ITA, for Spain use ESP, for Norway use NOR and so on
						
global minnumberobs = 5 // Define the minimum number of observations in a cell. If the min number of obs is not 
						// satisfied, all moments calculated with that subsample are replaced by missing.


// Define these variables for your dataset
global yrfirst = 2005 		// First year in the dataset 
global yrlast =  2018 		// Last year in the dataset

global kyear = 5
	// This controls the years for which the empirical densities will be calculated.
	// The densisity is calculated every mod(year/kyear) == 0. Set to 1 if 
	// every year is needed (If need changes, contact  Ozkan/Salgado)
	
global nquantiles = 40
	// Number of quantiles used in the statistics conditioning on permanent income
	// One additional quintile will be added at the top for a total of 41 (see Guidelines)
		
global nquantilemob = 40
	// Number of quantiles used in the rank-rank mobility measures.
	
global qpercent = 99	
	// Top percentile for which the change in top-share will be calculated. 
	// In this case 99 implies top 1%. 
	// Calculations are made using  Matthieu Gomez's paper
	
global mergecohort = 2
	// Number of cohorts to be merged to prevent too few observations in year/age cells 
	
global hetgroup = `"male age educ "male age" "male educ" "male educ age" "' 
	// Define heterogenous groups for which time series stats will be calculated 

// Price index for converting nominal values to real, e.g., the PCE for the US.  
// IMPORTANT: Please set the LOCAL CPI starting from year ${yrfirst} and ending in ${yrlast}.

global cpi2018 = 103.664		// Set the value of the CPI in 2018. 
matrix cpimat = /*  CPI between ${yrfirst}  and ${yrlast}
*/ (83.694, 86.637, 89.051,92.680,92.414, 94.077, 97.084, 99.458, 100.859, 100.707, 100.203, /*
*/  100.000,101.956,103.664)'


matrix cpimat = cpimat/${cpi2018}

global exrate2018 = 0.846 		// Set the value the exchange rate from LC to 1US$ in 2018 (e.g. 1US$ = $(exrate2018) LC)
matrix exrate = /*  Nominal average exchange rate from FRED between ${yrfirst}  and ${yrlast} (LC per dollar)
*/  (0.803,0.796,0.729,0.679,0.718,0.754,0.718,0.778,0.753,0.752, /*
*/      0.901,0.903,0.885,0.846)'




// Define years for recession bars/ These will be used to generate a variable called rece used in the plots
global receyears = "2008,2009,2011,2012,2013"

// Define the year that will be use for normalization. 
global normyear = ${yrfirst}


/*DO NOT CHANGE THIS SECTION**********************************************
THIS SECTION DEFINES THE REAL EXCHANGE CHANGE USING THE LOCAL AND US CPI
*/
global cpi2018us = 108.231		// DO NOT CHANGE. This is the US PCE  
								// Annual average from https://fred.stlouisfed.org/series/PCEPI#0
matrix cpimatus = /*  PCE between 1970  and 2018
*/ (20.951, 21.841, 22.586, 23.802, 26.280, 28.470, 30.032, 31.986, 34.211, 37.250,  /*
*/ 41.262, 44.959, 47.456, 49.475, 51.343, 53.134, 54.290, 55.964, 58.150, 60.690,  /*
*/ 63.355, 65.473, 67.218, 68.892, 70.330, 71.811, 73.346, 74.623, 75.216, 76.338, /*
*/ 78.235, 79.738, 80.789, 82.358, 84.411, 86.813, 89.174, 91.438, 94.180, 94.094,  /*
*/ 95.705, 98.130, 100.000, 101.347, 102.868, 103.126, 104.235, 106.073, 108.231 )'

matrix cpimatus = cpimatus/${cpi2018us}

forvalues yr =  $yrfirst/$yrlast{
	local ee = `yr' - ${yrfirst} + 1
	local ii = `yr' - 1970 + 1
	matrix exrate[`ee',1] = exrate[`ee',1]*(cpimatus[`ii',1]/cpimat[`ee',1])
			// Coverting nominal exchange rate to real exchange rate
}
**********************************************

global set_rmininc = 2
// Set to 1: 
// If you want to use US min wages to create the minimum income threshold. 
// If your country does not have a minimum wage, and you want to use the US specific threshold
// then set set_rmininc = 1

// Set to 2:
// If your country has a minimum wage 

// Set to 3:
// If you want to use a percentage criterion or a particular custom value, then you need to specify those rmininc values below.



if ${set_rmininc} == 1{
	
	// CREATING MINIMUM INCOME THRESHOLD USING US MINIMUM WAGE  
	matrix minwgus = /* Nominal minimum wage 1959-2018 in the US
	*/ (1.00,1.00,1.00,1.15,1.15,1.25,1.25,1.25,1.25,1.40,1.60,1.60,1.60,1.60,/*
	*/  1.60,1.60,2.00,2.10,2.10,2.30,2.65,2.90,3.10,3.35,3.35,3.35,3.35,3.35,/*
	*/  3.35,3.35,3.35,3.35,3.80,4.25,4.25,4.25,4.25,4.25,4.75,5.15,5.15,5.15,/*
	*/  5.15,5.15,5.15,5.15,5.15,5.15,5.15,5.85,6.55,7.25,7.25,7.25,7.25,7.25,/*
	*/  7.25,7.25,7.25)'

	local yinic = ${yrfirst} - 1959 + 1						
	local yend = ${yrlast} - 1959 + 1

	matrix minincus = 260*minwgus[`yinic'..`yend',1]		// Nominal min income in the US
															// This uses the factor of 260 given in the Guidelines
	matrix rmininc = J(${yrlast}-${yrfirst}+1,1,0)
	local tnum = ${yrlast}-${yrfirst}+1

	forvalues i = 1(1)`tnum'{
		local ii = `i' + ${yrfirst} - 1970
		matrix rmininc[`i',1] = minincus[`i',1]*${exrate2018}/cpimatus[`ii',1]				
						// real min income threshold in local currency 
	}
	
}
else if ${set_rmininc} == 2{
	
	// CREATING MINIMUM INCOME THRESHOLD USING COUNTRY SPECIFIC MINIMUM WAGE  
	
	matrix minwg_C = /* Nominal minimum wage 1959-2018 in YOUR COUNTRY
	*/  (513,540.9,570.6,600,624,633.3,641.4,641.4,645.3,645.3,648.6,655.2,707.7,735.9)'

	// Change 1959 to the first year in your minwg_C matrix
	local yinic = ${yrfirst} - 2005 + 1	
	local yend = ${yrlast} - 2005 + 1

	matrix mininc_C = 3*minwg_C[`yinic'..`yend',1]/2*14/12 		// Nominal min income in the US
															// This uses the factor of 260 given in the Guidelines
	matrix rmininc = J(${yrlast}-${yrfirst}+1,1,0)
	local i = 1
	local tnum = ${yrlast}-${yrfirst}+1
	forvalues pp = 1(1)`tnum'{
		matrix rmininc[`i',1] = mininc_C[`i',1]/cpimat[`i',1]					
						// real min income threshold in local currency 
		local i = `i' + 1
	}
}	
else if ${set_rmininc} == 3{
	// CREATING MINIMUM INCOME THRESHOLD USING CUSTOM VALUES 
	// (E.G., the bottom 23% of the gender, combined earnings distribution, etc.)  
	
	matrix rmininc = /* REAL MINIMUM INCOME THRESHOLD ${yrfirst}-${yrlast} in YOUR COUNTRY
	*/ (1.00,1.00,1.00,1.15,1.15,1.25,1.25,1.25,1.25,1.40,1.60,1.60,1.60,/*
	*/  1.60,1.60,2.00,2.10,2.10,2.30,2.65,2.90,3.10,3.35,3.35,3.35)'
	
}

// PLEASE DO NOT CHANGE THIS PART. IF NEEDS TO BE CHANGED, CONTACT Ozkan/Salgado


*global yrlist = ///
*	"${yrfirst} 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 ${yrlast}"
*	// Define the years for which the inequality and concetration measures are calculated

global  yrlist = ""
forvalues yr = $yrfirst(1)$yrlast{
	global yrlist = "${yrlist} `yr'"
}		
	
*global d1yrlist = ///
*	"1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012"
	// Define years for which one-year log-changes measures are calculated

global d1yrlist = ""
local tempyr = $yrlast-1
forvalues yr = $yrfirst(1)`tempyr'{
	global d1yrlist = "${d1yrlist} `yr'"
}
	
*global d5yrlist = ///
*	"1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008"
	// Define years t for which five-years log-changes between t+5 and t are calculated
	
global d5yrlist = "$yrfirst"
local tempyrb = $yrfirst+1
local tempyr = $yrlast-5
forvalues yr = `tempyrb'(1)`tempyr'{
	local tmp = ",`yr'"
	global d5yrlist = "${d5yrlist}`tmp'"
}	
	
*global perm3yrlist = /// 
*	"1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,${yrlast}"
	// Define the ending years (t) to construct permanent income between t-2 and t 
	
local tempyrb = $yrfirst+2	
global perm3yrlist = "`tempyrb'"
local tempyrb = $yrfirst+3	
local tempyre = $yrlast
forvalues yr = `tempyrb'(1)`tempyre'{
	local tmp = ",`yr'"
	global perm3yrlist = "${perm3yrlist}`tmp'"
}	

