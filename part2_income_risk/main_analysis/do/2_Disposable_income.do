* CONSTRUCT DISPOSABLE INCOME
clear all
set more off
global maindir "/Users/siqiwei/Dropbox/Global_Income_Dynamics/Part2/risk_measure"
global aggind TS
capture log close 


*****************************************************************************
// import delimited using "$maindir/dta/effective_tax_rate.csv",clear
// save "$maindir/dta/effective_tax_rate.dta",replace
*****************************************************************************


foreach i in "RemoveAllAfter2" "RemoveAllAfter2_NotClustering" "RemoveAllAfter2_NotClustering_morevars" ///
  "RemoveAllAfter3_NotClustering"{
** USE DATA
use "$maindir/dta/mcvl_annual_FinalData_pt2_`i'.dta", clear // already merge with unemp and gdp
capture drop disp_inc* eff_rate*

* nominal income 
global cpi2018 = 103.664		// Set the value of the CPI in 2018. 
matrix cpimat = /*  CPI between 2005  and 2018
*/ (83.694, 86.637, 89.051,92.680,92.414, 94.077, 97.084, 99.458, 100.859, 100.707, 100.203, /*
*/  100.000,101.956,103.664)'
matrix cpimat = cpimat/${cpi2018}

* tot_inc_nom
* tot_inc_lag_nom
gen tot_inc_nom = .
gen tot_inc_lag_nom = .
forval yr = 2005/2018 {
    local cpi_index = `yr' - 2004
	local cpi_index_lag = `yr' - 2005
    replace tot_inc_nom =tot_inc*cpimat[`cpi_index',1] if year == `yr'
	replace tot_inc_lag_nom =tot_inc_lag*cpimat[`cpi_index_lag',1] if year == `yr'	
}

* build DI
merge m:1 year using "$maindir/dta/effective_tax_rate.dta"
drop _merge
gen base_7 = .
gen eff_rate = .
forval i = 1/6{  
  local j = `i' + 1   
  replace eff_rate = tau_`i' if ((tot_inc_nom < base_`j')|(missing(base_`j'))) & (eff_rate==.)
}
gen disp_inc = tot_inc_nom - eff_rate/100*tot_inc_nom

* lag
drop base* tau*
replace year = year-1
merge m:1 year using "$maindir/dta/effective_tax_rate.dta"
replace year = year + 1
drop _merge
gen base_7 = .
gen eff_rate_lag = .
forval i = 1/6{  
  local j = `i' + 1    
  replace eff_rate_lag = tau_`i' if ((tot_inc_lag_nom < base_`j')|(missing(base_`j'))) & (eff_rate_lag==.)
}
gen disp_inc_lag = tot_inc_lag_nom - eff_rate_lag/100*tot_inc_lag_nom

* real income 
forval yr = 2006/2018{
  local cpi_index = `yr' - 2004
  local cpi_index_lag = `yr' - 2005
  replace disp_inc = disp_inc/cpimat[`cpi_index',1] if year == `yr'
  replace disp_inc_lag = disp_inc_lag/cpimat[`cpi_index_lag',1] if year == `yr'
}
drop base* tau* tot_inc_nom tot_inc_lag_nom


gen log_disp_inc_lag = log(disp_inc_lag)
replace log_disp_inc_lag = 0 if missing(log_disp_inc_lag) & !missing(disp_inc_lag)


qui sum log_disp_inc_lag
replace log_disp_inc_lag = (log_disp_inc_lag - r(mean)) / r(sd)
gen log_disp_inc_lag_h2 = (log_disp_inc_lag^2 - 1) 
gen log_disp_inc_lag_h3 = (log_disp_inc_lag^3 - 3*log_disp_inc_lag) 





save "$maindir/dta/mcvl_annual_FinalData_pt2_`i'.dta",replace

}

