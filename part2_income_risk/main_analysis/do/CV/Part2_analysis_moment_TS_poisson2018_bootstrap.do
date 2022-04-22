
* The main file 
*clear all
set more off

									
** FIRST STAGE: CONDITIONAL MEAN BY EXPONENTIAL REGRESSION
ppmlhdfe ${inc_var} ${vars},vce(cluster person_id) //if est_sample == 1  //,initial(ini_guess)		
* Predict conditional mean
eststo modelmean
predict cond_mean, mu


		
sum ${inc_var}  if year <=2018,detail
gen max_${inc_var} = r(max)
replace cond_mean = max_${inc_var} if cond_mean>=max_${inc_var}
drop max_${inc_var}

gen L = ${inc_var}*log(cond_mean) - cond_mean


matrix define coefs1 = e(b)
gen y_dev2 = (${inc_var} - cond_mean)^2
sum y_dev2,detail
** SAVE DATA
compress

** SECOND STAGE (absCV): ABSOLUTE DEVIATION BY EXPONENTIAL REGRESSION
* Generate residuals and variance
gen absdev = abs(${inc_var} - cond_mean)
* Estimate exponential regression
ppmlhdfe absdev ${vars},vce(cluster person_id) //if est_sample == 1  


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


* Save all matrices
matrix define coefs = coefs1 \ coefs2_abs   // \ coefs2_sq
matrix coln coefs = `e(params)'
clear
//
local names: colnames coefs
di "`names'"
local names: subinstr local names "_cons" "cons"
di "`names'"
mat coln coefs= `names'
		
svmat coefs, names(col)
outsheet using "$savepath\IR_moment_cvar_coefs_${aggind}_${chosen_sex}_${inc_var}_${spl}_poisson_ppml2018_bts${bts}.csv", replace comma







