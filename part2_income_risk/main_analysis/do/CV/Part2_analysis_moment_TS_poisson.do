
* The main file 
clear all
set more off
global aggind TS_ppml
capture log close 

log using "$maindir\risk_measure\log\momentbased_${aggind}_${chosen_sex}_${inc_var}_${spl}_poisson_ppml", text replace

** import initial guess 
*insheet using "$maindir/moment/dta/IR_moment_coefs_Nshock_0.csv",clear
*gen aux = _n
*keep if aux ==1
*drop aux
*mkmat _all, matrix(ini)
*matrix list ini

** USE DATA
use "$savepath\mcvl_annual_FinalData_pt2_${spl}.dta", clear // already merge with unemp and gdp

** KEEP ONE OF THE SEXES
keep if sex == $chosen_sex
*keep if person_id <=10000
*STD age 
*sum age 
*replace age = (age-r(mean))/r(sd)
*sum age_sq
*replace age_sq = (age_sq-r(mean))/r(sd)

** GENERATE VARIABLES
* Dummies for education
qui tabulate education, generate(educ)

* Interaction of education with age and age_sq
global educ_groups = `r(r)'
forvalues g = 1/$educ_groups {
	gen age_ed_`g' = age * educ`g'
	gen agesq_ed_`g' = age_sq * educ`g'
}

* Dummies for years
*qui tabulate year, generate(year)

* Interaction of year dummies with age and age_sq
*global nyears = `r(r)'
*forvalues y = 1/$nyears {
*	gen age_yr_`y' = age * year`y'
*	gen agesq_yr_`y' = age_sq * year`y'
*}


************************************************************************************
*gen logy_t_1 = log(tot_inc_lag_orig)
*replace logy_t_1 = 0 if tot_inc_lag_orig == 0

*qui sum logy_t_1
*replace logy_t_1 = (logy_t_1 - r(mean)) / r(sd)

*replace tot_inc_lag = logy_t_1
*replace tot_inc_lag_h2 = (logy_t_1^2 - 1) 
*replace tot_inc_lag_h3 = (logy_t_1^3 - 3*logy_t_1) 

*sum tot_inc_lag_orig tot_inc_lag tot_inc_lag_h2 tot_inc_lag_h3


*global vars_level tot_inc_lag_dum  tot_inc_lag_orig
*global vars_log tot_inc_lag_dum  tot_inc_lag

************************************************************************************



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
			gdp*_lag* age_gdp*_lag*  //
			// no agesq_TS
* !!! removed age_sq * aggind 			


*matrix define ini_guess = J(1,45+108,0.0)
*forval i = 1/45{
*    matrix ini_guess[1,`i'] = ini[1,`i']
*}

									
** FIRST STAGE: CONDITIONAL MEAN BY EXPONENTIAL REGRESSION
ppmlhdfe ${inc_var} ${vars} if est_sample == 1  //,initial(ini_guess)		
* Predict conditional mean
predict cond_mean, mu

*estpost summarize ${var_sum} if est_sample == 1
*esttab using "$savepath\insample.tex", cells("mean min max") nomtitle nonumber replace

sum ${inc_var}  if year <=2017,detail
gen max_${inc_var} = r(max)
replace cond_mean = max_${inc_var} if cond_mean>=max_${inc_var}
drop max_${inc_var}

gen L = ${inc_var}*log(cond_mean) - cond_mean

matrix define coefs1 = e(b)
gen y_dev2 = (${inc_var} - cond_mean)^2
sum y_dev2,detail
** SAVE DATA
compress
save "$savepath\IR_moment_cvar_${aggind}_${chosen_sex}_${inc_var}_${spl}_poisson_ppml.dta", replace



** SECOND STAGE (absCV): ABSOLUTE DEVIATION BY EXPONENTIAL REGRESSION
* Generate residuals and variance
gen absdev = abs(${inc_var} - cond_mean)
* Estimate exponential regression
ppmlhdfe absdev ${vars} if est_sample == 1  
* Predict conditional variance
predict cond_absdev, mu

gen L_abs = absdev*log(cond_absdev) - cond_absdev

matrix define coefs2_abs = e(b)
** COMPUTE INCOME RISK MEASURE `log(sigma) - log(mu)'
gen cvar_m_abs = cond_absdev / cond_mean
** Make age groups 
gen ageg = .
replace ageg = 1 if (age >= 25 & age <= 30)
replace ageg = 2 if (age > 30 & age <= 35)
replace ageg = 3 if (age > 35 & age <= 40)
replace ageg = 4 if (age > 40 & age <= 45)
replace ageg = 5 if (age > 45 & age <= 50)
replace ageg = 6 if (age > 50 & age <= 55)
********** ANALYSIS
* Quantiles of the cvar
centile cvar_m_abs, centile(1 5 10 25 50 75 90 95 99)
* Quantiles of cvar by age and year
tab year ageg, summarize(cvar_m_abs)

/*
** SECOND STAGE (stdCV): ABSOLUTE DEVIATION BY EXPONENTIAL REGRESSION
* Generate residuals and variance
gen sqdev = (${inc_var} - cond_mean)^2

*gen sqdev_wins = sqdev
*sum sqdev, detail
*replace sqdev_wins = `r(p99)' if sqdev > `r(p99)' & !missing(sqdev_wins)
* Estimate exponential regression

ppmlhdfe sqdev ${vars} if est_sample == 1	
* Predict conditional variance
predict cond_sqdev, mu
matrix define coefs2_sq = e(b)	
** COMPUTE INCOME RISK MEASURE `log(sigma) - log(mu)'
gen cvar_m_sq = sqrt(cond_sqdev)/ cond_mean	
********** ANALYSIS
* Quantiles of the cvar
centile cvar_m_sq, centile(1 5 10 25 50 75 90 95 99)	
* Quantiles of cvar by age and year
tab year ageg, summarize(cvar_m_sq)
*/

** SAVE DATA
compress
save "$savepath\IR_moment_cvar_${aggind}_${chosen_sex}_${inc_var}_${spl}_poisson_ppml.dta", replace

// preserve
// * Save all matrices
// matrix define coefs = coefs1 \ coefs2_abs   // \ coefs2_sq
// matrix coln coefs = `e(params)'
// clear
//
// local names: colnames coefs
// di "`names'"
// local names: subinstr local names "_cons" "cons"
// di "`names'"
// mat coln coefs= `names'
//
// svmat coefs, names(col)
// outsheet using "$savepath\IR_moment_cvar_coefs_${aggind}_${chosen_sex}_${inc_var}_${spl}_poisson_ppml.csv", replace comma
// restore

* Semi-deviations
*gen semidev_u = cond(${inc_var} > cond_mean, ${inc_var} - cond_mean, 0)
*gen semidev_l = cond(${inc_var} < cond_mean, cond_mean - ${inc_var}, 0)

* Upper semi-deviation
*nl (semidev_u = exp({b0} + {xb: ${vars}})) if est_sample == 1
*predict cond_semidev_u, yhat

*matrix define coefs3 = e(b)

* Lower semi-deviation
*nl (semidev_l = exp({b0} + {xb: ${vars}})) if est_sample == 1
*predict cond_semidev_l, yhat

*matrix define coefs4 = e(b)

* Generate tail cvars
*gen cvar_u = cond_semidev_u / cond_mean
*gen cvar_l = cond_semidev_l / cond_mean

* Save
*compress
*save "$savepath\IR_moment_scvar_${aggind}_${chosen_sex}.dta", replace

* Save all matrices
*matrix define coefs = coefs1 \ coefs2 \ coefs3 \ coefs4
*matrix coln coefs = `e(params)'
*clear
*svmat coefs, names(col)
* Save
*outsheet using "$savepath\IR_moment_scvar_coefs_${aggind}_${chosen_sex}.csv", replace comma

log close







