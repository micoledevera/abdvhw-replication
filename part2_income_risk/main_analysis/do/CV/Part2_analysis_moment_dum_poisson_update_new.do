
* The main file 
clear all
set more off
global aggind TS_ppml
capture log close 

log using "$maindir\log\momentbased_dum_${cname}_${chosen_sex}_${inc_var}_poisson_ppml_update2016", text replace

** USE DATA
use "$savepath\mcvl_annual_FinalData_pt2_RemoveAllAfter2.dta", clear // already merge with unemp and gdp

** KEEP ONE OF THE SEXES
keep if sex == $chosen_sex
** Merge with clusters
merge m:1 person_id using "${maindir}\dta\\${cfile_mean}.dta"
di "${cfile_mean}"
drop if _merge == 2

drop _merge



* Generate cluster and age/age_sq interaction
qui tab cluster, gen(clust)

forvalues c = 1/$n_clust {
	gen age_clust_`c' = age * clust`c'
	gen agesq_clust_`c' = age_sq * clust`c'
}

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
order person_id year ${inc_var} ${inc_var}_lag age age_sq clust* days_lag1 oow_inc_lag ///
			fullyear_lag1 fullyear_lag12 fullyear_lag123 year* permanent_main_prev ///
			fulltime_main_prev age_clust_* agesq_clust_* ///
			age_daysl agesq_daysl age_oowl agesq_oowl age_fullyear1 agesq_fullyear1 ///
			age_fullyear12 agesq_fullyear12 age_fullyear123 agesq_fullyear123 age_pmt agesq_pmt ///
			age_prt agesq_prt ///   *age_yr_* agesq_yr_*
			age_inclag* agesq_inclag* age_incdum agesq_incdum ///
			unemployment*_lag* age*unemployment*_lag* ///
			gdp*_lag* age*gdp*_lag*
			

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
			gdp*_lag* age_gdp*_lag* ///
			clust2-clust${n_clust} age_clust_2-age_clust_${n_clust} agesq_clust_2-agesq_clust_${n_clust} //
			
			 
									
** FIRST STAGE: CONDITIONAL MEAN BY EXPONENTIAL REGRESSION
local ctiter = 0
local lk_t_1  = 1
local dlk = 10
while (`dlk' >=0.00000001) & (`ctiter'<50){
 
 
ppmlhdfe ${inc_var} ${vars} if est_sample_clust == 1 
* Predict conditional mean

forval clt = 1/$n_clust{
forval cltnum = 1/$n_clust{
replace clust`cltnum' = (`clt'==`cltnum')
}
forvalues c = 1/$n_clust {
	replace age_clust_`c' = age * clust`c'
	replace agesq_clust_`c' = age_sq * clust`c'
}
capture drop cond_mean`clt'
predict cond_mean`clt', mu

sum ${inc_var} if year <=2016,detail
gen max_${inc_var} = r(max)
replace cond_mean`clt' = max_${inc_var} if cond_mean`clt'>=max_${inc_var} & !missing(cond_mean`clt')
drop max_${inc_var}

}

sort person_id
forval clt = 1/$n_clust{
capture drop plk`clt' mean_plk`clt'
gen plk`clt' = tot_inc*log(cond_mean`clt') - cond_mean`clt' //- lnfactorial(tot_inc)
bysort person_id est_sample_clust: egen mean_plk`clt' = mean(plk`clt') 
}

capture drop maxplk maxplk_temp
egen maxplk_temp = rowmax(mean_plk*) if est_sample_clust == 1
by person_id: egen maxplk = mean(maxplk_temp)

replace cluster = .
forval clt = 1/$n_clust{
replace cluster = `clt' if mean_plk`clt' == maxplk
}

drop clust1-clust$n_clust
* Generate cluster and age/age_sq interaction
qui tab cluster, gen(clust)

forvalues c = 1/$n_clust {
	replace age_clust_`c' = age * clust`c'
	replace agesq_clust_`c' = age_sq * clust`c'
}
qui: sum maxplk if est_sample_clust == 1
local lk_t = r(mean)
local dlk = (`lk_t' - `lk_t_1')/`lk_t_1'
local lk_t_1 = `lk_t'
local ctiter = `ctiter' + 1

di "lk_t_1"
di "`lk_t_1'"
 
di "dlk"
di "`dlk'"
 
di "ctiter" 
di "`ctiter'"
}



gen new_cluster_mean = cluster
replace new_cluster_mean = . if est_sample_clust !=1
drop cluster
bysort person_id: egen cluster = mean(new_cluster_mean)
capture drop clust1-clust$n_clust
qui tab cluster, gen(clust)
forvalues c = 1/$n_clust {
	replace age_clust_`c' = age * clust`c'
	replace agesq_clust_`c' = age_sq * clust`c'
}


*********************************************************************************************************************

ppmlhdfe ${inc_var} ${vars} if est_sample_clust == 1 
predict cond_mean if est_sample_clust != 0 , mu

*********************************************************************************************************************
sum ${inc_var} if year <=2016,detail
gen max_${inc_var} = r(max)
replace cond_mean = max_${inc_var} if cond_mean>=max_${inc_var} & !missing(cond_mean)
drop max_${inc_var}


matrix define coefs1 = e(b)
gen y_dev2 = (${inc_var} - cond_mean)^2
sum y_dev2,detail
** SAVE DATA
compress
save "$savepath\IR_moment_cvar_dum_${cname}_${chosen_sex}_${inc_var}_poisson_ppml_update2016.dta", replace



** SECOND STAGE (absCV): ABSOLUTE DEVIATION BY EXPONENTIAL REGRESSION
* Generate residuals and variance

*use "$savepath\IR_moment_cvar_dum_${cname}_${chosen_sex}_${inc_var}_poisson_ppml_update2016.dta", clear

rename cond_mean cond_mean_cluster
capture drop _merge
merge 1:1 person_id year using "${maindir}\dta\IR_moment_cvar_TS_ppml_1_tot_inc_RemoveAllAfter2_poisson_ppml2016.dta",keepusing(cond_mean)
drop if _merge == 2
drop _merge

rename cond_mean cond_mean_TS
rename cond_mean_cluster cond_mean
gen absdev = abs(${inc_var} - cond_mean_TS)


drop cluster
merge m:1 person_id using "${maindir}\dta\\${cfile_absdev}.dta"

di "${cfile_absdev}"
drop if _merge == 2
*!!!!!!!!!!!!!!!!!
*drop if _merge == 1
drop _merge

capture drop clust1-clust$n_clust
qui tab cluster, gen(clust)
forvalues c = 1/$n_clust {
	replace age_clust_`c' = age * clust`c'
	replace agesq_clust_`c' = age_sq * clust`c'
}


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
			gdp*_lag* age_gdp*_lag* ///
			clust2-clust${n_clust} age_clust_2-age_clust_${n_clust} agesq_clust_2-agesq_clust_${n_clust} //
			
	

local ctiter = 0
local lk_t_1  = 1
local dlk = 100
while (`dlk' >=0.00000001) & (`ctiter'<50){

ppmlhdfe absdev ${vars} if est_sample_clust == 1 
* Predict conditional mean

forval clt = 1/$n_clust{
forval cltnum = 1/$n_clust{
replace clust`cltnum' = (`clt'==`cltnum')
}
forvalues c = 1/$n_clust {
	replace age_clust_`c' = age * clust`c'
	replace agesq_clust_`c' = age_sq * clust`c'
}
capture drop cond_absdev`clt'
predict cond_absdev`clt', mu
}

sort person_id
forval clt = 1/$n_clust{
capture drop plk`clt' mean_plk`clt'
gen plk`clt' = absdev*log(cond_absdev`clt') - cond_absdev`clt' //- lnfactorial(tot_inc)
bysort person_id est_sample_clust: egen mean_plk`clt' = mean(plk`clt')
}


capture drop maxplk maxplk_temp
egen maxplk_temp = rowmax(mean_plk*) if est_sample_clust == 1
by person_id: egen maxplk = mean(maxplk_temp)

replace cluster = .
forval clt = 1/$n_clust{
replace cluster = `clt' if mean_plk`clt' == maxplk
}

drop clust1-clust$n_clust
* Generate cluster and age/age_sq interaction
qui tab cluster, gen(clust)

forvalues c = 1/$n_clust {
	replace age_clust_`c' = age * clust`c'
	replace agesq_clust_`c' = age_sq * clust`c'
}

qui: sum maxplk if est_sample_clust == 1 
local lk_t = r(mean)
local dlk = (`lk_t' - `lk_t_1')/`lk_t_1'
local lk_t_1 = `lk_t'
local ctiter = `ctiter' + 1

di "lk_t_1"
di "`lk_t_1'"
 
di "dlk"
di "`dlk'"

di "ctiter" 
di "`ctiter'"
}



gen new_cluster_abs = cluster
replace new_cluster_abs = . if est_sample_clust !=1
drop cluster
by person_id: egen cluster = mean(new_cluster_abs)
capture drop clust1-clust$n_clust
qui tab cluster, gen(clust)
forvalues c = 1/$n_clust {
	replace age_clust_`c' = age * clust`c'
	replace agesq_clust_`c' = age_sq * clust`c'
}


***********************************************************************
* Estimate exponential regression
ppmlhdfe absdev ${vars} if est_sample_clust == 1
predict cond_absdev if est_sample_clust != 0 , mu


***********************************************************************
*predict cond_absdev, mu
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


** SAVE DATA
compress
save "$savepath\IR_moment_cvar_dum_${cname}_${chosen_sex}_${inc_var}_poisson_ppml_update2016.dta", replace


log close







