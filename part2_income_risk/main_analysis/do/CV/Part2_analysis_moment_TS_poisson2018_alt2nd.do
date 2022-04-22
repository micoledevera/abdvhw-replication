
* The main file 
clear all
set more off
global aggind TS_ppml
capture log close 

log using "$maindir\log\momentbased_${aggind}_${chosen_sex}_${inc_var}_${spl}_poisson_ppml2018_alt2nd", text replace


* use 1st step result 
use "$savepath\IR_moment_cvar_${aggind}_${chosen_sex}_${inc_var}_${spl}_poisson_ppml2018.dta", replace


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
			

** SECOND STAGE (absCV): ABSOLUTE DEVIATION BY EXPONENTIAL REGRESSION
* Generate residuals and variance
gen cv = abs(${inc_var} - cond_mean)/cond_mean
* Estimate exponential regression
ppmlhdfe cv ${vars},vce(cluster person_id) 
* Predict conditional variance
capture drop cvar_m_abs
predict cvar_m_abs, mu

capture drop L_abs

matrix define coefs2_abs = e(b)
* Quantiles of the cvar
centile cvar_m_abs, centile(1 5 10 25 50 75 90 95 99)
* Quantiles of cvar by age and year
tab year ageg, summarize(cvar_m_abs)


** SAVE DATA
compress
save "$savepath\IR_moment_cvar_${aggind}_${chosen_sex}_${inc_var}_${spl}_poisson_ppml2018_alt2nd.dta", replace

log close







