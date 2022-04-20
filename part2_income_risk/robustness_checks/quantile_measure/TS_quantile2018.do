
* The main file 
clear all
set more off
capture log close 

global maindir "...\part2_income_risk\main_analysis"
global data "...\part2_income_risk\main_analysis\dta"
global savepath "...\part2_income_risk\main_analysis\dta"

* Parameters
global aggind TS_quantile
global chosen_sex 1
global inc_var tot_inc
global spl RemoveAllAfter2_NotClustering

log using "$maindir\log\quantilebased_${aggind}_${chosen_sex}_${inc_var}_${spl}", text replace

** USE DATA
use "$data\mcvl_annual_FinalData_pt2_${spl}.dta", clear // already merged with unemp and gdp

** KEEP ONE OF THE SEXES
keep if sex == $chosen_sex

** GENERATE VARIABLES
***!!!!! Keep tot_inc > 0 only and take logs
keep if ${inc_var} > 0
gen log_${inc_var} = log(${inc_var})

* Dummies for education
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

local vl gdp unemployment gdppr unemploymentpr 

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
			// no agesq_TS
* !!! removed age_sq * aggind 			


** P10 regression
qreg log_${inc_var} ${vars}, quantile(0.1)
predict p10
						
** SAVE DATA
compress
save "$savepath\IR_moment_cvar_${aggind}_${chosen_sex}_${inc_var}_${spl}_quantile2018.dta", replace

** P50 regression
qreg log_${inc_var} ${vars}, quantile(0.5)
predict p50
						
** SAVE DATA
compress
save "$savepath\IR_moment_cvar_${aggind}_${chosen_sex}_${inc_var}_${spl}_quantile2018.dta", replace

** P90 regression
qreg log_${inc_var} ${vars}, quantile(0.9)
predict p90
						
** SAVE DATA
compress
save "$savepath\IR_moment_cvar_${aggind}_${chosen_sex}_${inc_var}_${spl}_quantile2018.dta", replace

** P90-P10
gen ${inc_var}_disp = p90 - p10

** Kelley skewness
gen ${inc_var}_skew = (p90 - 2*p50 + p10) / (p90 - p10)

** SAVE DATA
compress
save "$savepath\IR_moment_cvar_${aggind}_${chosen_sex}_${inc_var}_${spl}_quantile2018.dta", replace

log close







