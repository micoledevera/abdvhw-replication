clear 
set more off
*global mmdir "/Users/siqiwei/Dropbox/Global_Income_Dynamics/Part2/main_analysis/do"
*global maindir "/Users/siqiwei/Dropbox/Global_Income_Dynamics/Part2"
*global savepath "/Users/siqiwei/Dropbox/Global_Income_Dynamics/Part2/main_analysis/dta"
global mmdir "C:\Users\s-wei-29\Dropbox\Global_Income_Dynamics\Part2\main_analysis\do"
global maindir "C:\Users\s-wei-29\Dropbox\Global_Income_Dynamics\Part2"
global savepath "C:\Users\s-wei-29\Dropbox\Global_Income_Dynamics\Part2\main_analysis\dta"

global aggind TS_ppml



*Select income measure
* tot_inc: total pre-tax income
* disp_inc: disposable income
global inc_var  tot_inc 
*Select gender 
* chosen_sex = 1 if male, 0 if female
global chosen_sex = 1 
global spl = "RemoveAllAfter2_NotClustering"
capture log close 
log using "$maindir\risk_measure\log\bootstrap_${aggind}_${chosen_sex}_${inc_var}_${spl}_poisson_ppml2018", text replace

** BOOTSTRAP -- BASELINE
use "$savepath\mcvl_annual_FinalData_pt2_${spl}.dta", clear // already merge with unemp and gdp
keep if sex == $chosen_sex
qui tabulate education, generate(educ)

* Interaction of education with age and age_sq
global educ_groups = `r(r)'
forvalues g = 1/$educ_groups {
	gen age_ed_`g' = age * educ`g'
	gen agesq_ed_`g' = age_sq * educ`g'
}



* Other interactions
gen age_inclag = age * log_${inc_var}_lag
gen agesq_inclag = age_sq * log_${inc_var}_lag

gen age_inclag2 = age * log_${inc_var}_lag_h2
gen agesq_inclag2 = age_sq * log_${inc_var}_lag_h2

gen age_inclag3 = age * log_${inc_var}_lag_h3
gen agesq_inclag3 = age_sq * log_${inc_var}_lag_h3

gen age_incdum = age * tot_inc_lag_dum
gen agesq_incdum = age_sq * tot_inc_lag_dum

gen age_daysl = age * days_lag1
gen agesq_daysl = age_sq * days_lag1

gen age_oowl = age * log_oow_inc_lag
gen agesq_oowl = age_sq * log_oow_inc_lag

gen age_oowl_dum = age * oow_inc_lag_dum
gen agesq_oowl_dum = age_sq * oow_inc_lag_dum

gen age_fullyear1 = age * fullyear_lag1
gen agesq_fullyear1 = age_sq * fullyear_lag1

gen age_fullyear12 = age * fullyear_lag12
gen agesq_fullyear12 = age_sq * fullyear_lag12

gen age_fullyear123 = age * fullyear_lag123
gen agesq_fullyear123 = age_sq * fullyear_lag123

gen age_pmt = age * permanent_main_prev
gen agesq_pmt = age_sq * permanent_main_prev

gen age_prt = age * fulltime_main_prev
gen agesq_prt = age_sq * fulltime_main_prev

local vl gdp unemployment  ///
   gdppr unemploymentpr 

foreach x of loc vl{
gen age_`x'_lag1 = age*`x'_lag1
gen age_`x'_lag2 = age*`x'_lag2
gen age_`x'_lag3 = age*`x'_lag3

gen agesq_`x'_lag1 = age_sq*`x'_lag1
gen agesq_`x'_lag2 = age_sq*`x'_lag2
gen agesq_`x'_lag3 = age_sq*`x'_lag3

}


compress

** DEFINE MACRO OF VARIABLES
order person_id year ${inc_var} ${inc_var}_lag age age_sq educ* days_lag1 oow_inc_lag ///
			fullyear_lag1 fullyear_lag12 fullyear_lag123 year* permanent_main_prev ///
			fulltime_main_prev age_ed_* agesq_ed_* ///
			age_daysl agesq_daysl age_oowl agesq_oowl age_fullyear1 agesq_fullyear1 ///
			age_fullyear12 agesq_fullyear12 age_fullyear123 agesq_fullyear123 age_pmt agesq_pmt ///
			age_prt agesq_prt ///   *age_yr_* agesq_yr_*
			age_inclag* agesq_inclag* age_incdum agesq_incdum ///
			unemployment*_lag* age_unemployment*_lag* ///
			gdp*_lag* age_gdp*_lag*
			// no agesq_TS

** with agg indicator		
global vars log_${inc_var}_lag log_${inc_var}_lag_h2 log_${inc_var}_lag_h3 tot_inc_lag_dum age age_sq /// 
			educ2-educ${educ_groups} days_lag1 oow_inc_lag_dum log_oow_inc_lag fullyear_lag1 fullyear_lag12 fullyear_lag123 ///
			permanent_main_prev fulltime_main_prev ///  ** year2-year${nyears}
			age_ed_2-age_ed_${educ_groups} agesq_ed_2-agesq_ed_${educ_groups} ///
			age_daysl agesq_daysl age_oowl agesq_oowl age_oowl_dum agesq_oowl_dum age_fullyear1 agesq_fullyear1 ///
			age_fullyear12 agesq_fullyear12 age_fullyear123 agesq_fullyear123 age_pmt agesq_pmt ///
			age_prt agesq_prt /// ** age_yr_2-age_yr_${nyears} agesq_yr_2-agesq_yr_${nyears}
			age_inclag agesq_inclag age_inclag2 agesq_inclag2 age_inclag3 agesq_inclag3 /// 
			age_incdum agesq_incdum unemployment*_lag* age_unemployment*_lag* ///
			gdp*_lag* age_gdp*_lag* // 
* Poisson regression 

* TS
forval bt = 1(1)100{ 
    preserve  
    global bts = "`bt'"    
	*keep if person_id < 10000
    bsample,cluster(person_id) id(temp)
	replace person_id = temp
    * Main Specification: TS 2018
    do "${mmdir}/CV/Part2_analysis_moment_TS_poisson2018_bootstrap.do" 
	restore 
}




***Insheet the first file
insheet using "${savepath}/IR_moment_cvar_coefs_TS_ppml_1_tot_inc_RemoveAllAfter2_NotClustering_poisson_ppml2018_bts1.csv", clear //add other options as needed
egen x = seq()
keep if x == 2
drop x
tempfile tempcoef //declare the temporary file
sa `tempcoef' //save the temporary file
forval ii = 2(1)100{
insheet using "${savepath}/IR_moment_cvar_coefs_TS_ppml_1_tot_inc_RemoveAllAfter2_NotClustering_poisson_ppml2018_bts`ii'.csv", clear //import the second file
egen x = seq()
keep if x == 2
drop x
append using `tempcoef' //append (both now .dta)
tempfile tempcoef //declare the temporary file
sa `tempcoef' //save the temporary file
}

sum

log close 
