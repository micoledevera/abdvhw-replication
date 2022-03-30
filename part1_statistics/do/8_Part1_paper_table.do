clear all
set more off
// You should change the below directory. 
global maindir ="...\part1_statistics"

// Do not make change from here on. Contact Ozkan/Salgado if changes are needed. 
do "$maindir/do/0_Initialize.do"

// Create folder for output and log-file
global outfolder=c(current_date)
global outfolder="$outfolder Extra_Tables"
capture noisily mkdir "$maindir${sep}out${sep}$outfolder"
capture log close
capture noisily log using "$maindir${sep}log${sep}$outfolder.log", replace

// Cd to the output file, create the program for moments, and load base sample.
cd "$maindir${sep}out${sep}$outfolder"
do "$maindir${sep}do${sep}myprogs.do"		

timer clear 1
timer on 1


foreach spl in "CS" "LX" "H"{

foreach curr in "usd" "euro"{
// Loop over the years
if "`spl'" == "CS" {
	local fsrtyr = $yrfirst
	local lastyr = $yrlast
}
else if "`spl'" == "LX" {
	local fsrtyr = $yrfirst
	local lastyr = $yrlast - 5		// So 5 year changes are present in the sample
}
else if "`spl'" == "H" {
	local fsrtyr = $yrfirst + 3		// So perm   income is present in the sample
	local lastyr = $yrlast - 5		// So 5 year change is present in the sample
}

forvalues yr = `fsrtyr'/`lastyr'{
*foreach yr of numlist $yrlist{	
	disp("Working in year `yr' for Sample `spl'")
	if "`spl'" == "CS" {
		use  male yob educ labor`yr' using ///
			"$maindir${sep}dta${sep}master_sample.dta" if labor`yr'~=. , clear  	
	}
	else if "`spl'" == "LX" {
		use  male yob educ labor`yr' researn1F`yr' researn5F`yr' using ///
			"$maindir${sep}dta${sep}master_sample.dta" if labor`yr'~=. , clear  	
	}
	else if "`spl'" == "H" {
		local yrp = `yr'-1
		use  male yob educ labor`yr' researn1F`yr' researn5F`yr' permearn`yrp' using ///
			"$maindir${sep}dta${sep}master_sample.dta" if labor`yr'~=. , clear  	
	}
	
	// Create year
	gen year=`yr'
	
	// Create age (This applies to all samples)
	gen age = `yr'-yob+1
	qui: drop if age<${begin_age} | age>${end_age}
	
	// Select CS sample (Individual has earnings above min treshold)
	if "`spl'" == "CS"{
		qui: keep if labor`yr'>=rmininc[`yr'-${yrfirst}+1,1] & labor`yr'!=. 
	}
	
	// Select LX sample (Individual has 1 and 5 yr residual earnings change)
	if "`spl'" == "LX"{
		qui: keep if researn1F`yr'!=. & researn5F`yr'!= . 
	}
	
	// Select H sample (Individual has permanent income measure)
	if "`spl'" == "H"{
		qui: keep if researn1F`yr'!=. & researn5F`yr'!= . 
		qui: keep if permearn`yrp' != . 
	}
	
	// Transform to US dollars
	local er_index = `yr'-${yrfirst}+1
	if "`curr'" == "usd"{
		qui: replace labor`yr' = labor`yr'/${exrate2018}
	}
	// Calculate cross sectional moments for year `yr'
	rename labor`yr' labor 	

	bymysum "labor" "L_" "_`yr'" "year"
	bymysum "labor" "L_" "_male`yr'" "year male"
	
	bymyPCT "labor" "L_" "_`yr'" "year"
	bymyPCT "labor" "L_" "_male`yr'" "year male"
		
	collapse (count) numobs = labor (sum) sum_labor = labor, by(year male educ age)
	order year male educ age numobs sum_labor
	qui: save "numobs`yr'.dta", replace
	
} // END of loop over years

* Collects number of observations data across years (for what did we need this?)
clear
*local fsrtyr = 2005
*local lastyr = 2018
*local spl = "CS"
forvalues yr = `fsrtyr'/`lastyr'{
	append using "numobs`yr'.dta"
	erase "numobs`yr'.dta"	
}



sort year male
by year: gen temp = sum(numobs)
by year: egen obs = max(temp)
drop temp
gen prop = numobs/obs

* Obs.
preserve 
collapse (mean) Obs = obs, by(year)
save year_obs.dta,replace
restore

* Women Share
preserve 
collapse (sum) fem_prop = prop, by(year male)
keep if male == 0
drop male

save year_femprop.dta, replace 
restore 

*Age Shares
preserve
gen ageid = 1 if age>=25 & age<=35
replace ageid = 2 if age>=36 & age<=45
replace ageid = 3 if age>=46 & age<=55
collapse (sum) age_prop = prop, by(year ageid)
reshape wide age_pro,i(year) j(ageid)
save year_ageprop.dta, replace 
restore

*edu shares
preserve
collapse (sum) edu_prop = prop, by(year educ)
reshape wide edu_prop,i(year) j(educ)
save year_educprop.dta, replace 
restore 


*mean income 
preserve
collapse (sum) male_numobs = numobs ///
               male_sumlabor = sum_labor, by(year male)
gen mean_labor = male_sumlabor/male_numobs
keep year male mean_labor
reshape wide mean_labor,i(year) j(male)
save year_meanlabor.dta, replace 
restore

use year_obs,clear
merge 1:1 year using "year_meanlabor.dta"
drop _merge
merge 1:1 year using "year_femprop.dta"
drop _merge
merge 1:1 year using "year_ageprop.dta"
drop _merge
merge 1:1 year using "year_educprop.dta"
drop _merge


replace Obs = Obs/1000000
label var Obs "Obs. (Mill)"
format Obs %10.2f

label var mean_labor0 "Mean Income Women"
label var mean_labor1 "Mean Income Men"
format mean_labor0 mean_labor1 %10.0f

label var fem_prop "Women % Share"
label var age_prop1 "Age Shares % [25,35]"
label var age_prop2 "Age Shares % [36,45]"
label var age_prop3 "Age Shares % [46,55]"
label var edu_prop1 "Education Shares % <= Primary"
label var edu_prop2 "Education Shares % Lower secondary"
label var edu_prop3 "Education Shares % Upper secondary"
label var edu_prop4 "Education Shares % >=College"

replace fem_prop = fem_prop*100
replace age_prop1 = age_prop1*100
replace age_prop2 = age_prop2*100
replace age_prop3 = age_prop3*100
replace edu_prop1 = edu_prop1*100
replace edu_prop2 = edu_prop2*100
replace edu_prop3 = edu_prop3*100
replace edu_prop4 = edu_prop4*100
format *prop*  %10.1f

mkmat Obs mean_labor1 mean_labor0 fem_prop age_prop1 age_prop2 ///
   age_prop3 edu_prop1 edu_prop2 edu_prop3 edu_prop4, mat(table1)
   
   
matrix colnames table1 =  "Obs (Mill)" "Mean Inc Men" "Mean Inc Women" ///
   "Women Share" "[25,35]" "[36,45]" "[46,55]" ///
	"Primary"	"Lower secondary" ///
	"Upper secondary" "College"

if "`spl'" == "CS"{
matrix rownames table1 = "2005" "2006" "2007" "2008" "2009" ///
								"2010" "2011" "2012" "2013" ///
								"2014" "2015" "2016" "2017" ///
								"2018" 
}								
if "`spl'" == "LX"{
matrix rownames table1 = "2005" "2006" "2007" "2008" "2009" ///
								"2010" "2011" "2012" "2013" 								
}
if "`spl'" == "H"{
matrix rownames table1 = "2008" "2009" ///
								"2010" "2011" "2012" "2013"
}
esttab matrix(table1, fmt(3 0 0 1 1 1 1 1 1 1 1)) ///
	using "part1_table1_`spl'_`curr'.tex", ///
	noobs nonumber no nomtitles align(`=colsof(table1)*"c"') replace								
								

								
* percentile 
use "PC_L_labor_`fsrtyr'",clear
local yp1 = `fsrtyr' + 1
forval yr = `yp1'(1)`lastyr'{
    append using "PC_L_Labor_`yr'.dta"
}
keep year p1labor p5labor p10labor p25labor p50labor p75labor p90labor p95labor p99labor p99_5labor

mkmat p1labor p5labor p10labor p25labor p50labor p75labor p90labor p95labor p99labor p99_5labor, ///
    mat(table2)
      
matrix colnames table2 = "P1" "P5" "P10" "P25" "P50" ///
								"P75" "P90" "P95" "P99" "P99.5"

if "`spl'" == "CS"{
matrix rownames table2 = "2005" "2006" "2007" "2008" "2009" ///
								"2010" "2011" "2012" "2013" ///
								"2014" "2015" "2016" "2017" ///
								"2018" 
}								
if "`spl'" == "LX"{
matrix rownames table2 = "2005" "2006" "2007" "2008" "2009" ///
								"2010" "2011" "2012" "2013" 								
}
if "`spl'" == "H"{
matrix rownames table2 = "2008" "2009" ///
								"2010" "2011" "2012" "2013"
}
								
esttab matrix(table2, fmt(0)) ///
	using "part1_table2_`spl'_`curr'.tex", ///
	noobs nonumber no nomtitles align(`=colsof(table2)*"c"') replace								
								
}
	
}	
************************************************************************************************	
* percentage below threshold 
use personid male yob labor* logearn2* using "$maindir${sep}dta${sep}master_sample.dta" ,clear	
forval yr = 2005(1)2018{
	preserve
    keep personid male yob labor`yr' logearn`yr'
	gen age = `yr'-yob+1														
	gen ind = 1 if age >= $begin_age & age<= $end_age & !missing(labor`yr') 								
	replace ind = 0 if ind == 1 & !missing(logearn`yr')
	keep ind male 
	keep if !missing(ind)					
	gen year = `yr'
	order year male ind								
	collapse (mean) lt_thre = ind ///
	         (count) obs = ind, by(year male) 								
	reshape wide lt_thre obs,i(year) j(male)
	save lt_thres`yr'.dta, replace
	restore
}
								
use lt_thres2005.dta,clear		
forval yr = 2006(1)2018{
    append using lt_thres`yr'.dta
}
sort year
order year obs1 lt_thre1 obs0 lt_thre0 

mkmat obs1 lt_thre1 obs0 lt_thre0, mat(table3)
      
matrix colnames table3 = "Male Obs" "Proportion" "Female Obs" "Proportion" 								
matrix rownames table3 = "2005" "2006" "2007" "2008" "2009" ///
								"2010" "2011" "2012" "2013" ///
								"2014" "2015" "2016" "2017" ///
								"2018" 
								
esttab matrix(table3, fmt(0 3 0 3)) ///
	using "part1_table3.tex", ///
	noobs nonumber no nomtitles align(`=colsof(table3)*"c"') replace								
								
forval yr = 2005(1)2018{
    rm lt_thres`yr'.dta
}

						
								
