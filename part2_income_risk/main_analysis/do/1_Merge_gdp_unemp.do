* original file name: Part2_analysis_moment_unemp_gdp*.do


* The main file 
clear all
set more off


global maindir ".../part2_income_risk/main_analysis"
global data ".../mcvl_data_processing/out"
capture log close 
log using "${maindir}/log/Merge_gdp_unemp", text replace



foreach i in "RemoveAllAfter2" "RemoveAllAfter2_NotClustering" "RemoveAllAfter2_NotClustering_morevars" ///
  "RemoveAllAfter3_NotClustering"{
** USE DATA
use "$data/mcvl_annual_FinalData_pt2_`i'.dta", clear

** Merge the data to include COUNTRY LEVEL aggregate shock 
merge m:1 year using "${maindir}/dta/National.dta"
drop _merge

** Merge the data to include PROVINCIAL LEVEL aggregate shock 
gen saveprovince = province
replace province = prov_prev
replace year = year - 1

merge m:1 province year using "${maindir}/dta/Province.dta"
drop if _merge == 2
drop _merge

replace year = year + 1
drop province
rename saveprovince province
** var: gdppr (t-1), gdppr_lag1 (t-2), gdppr_lag2 (t-3) because we match to prov_prev
local vl gdppr unemploymentpr 

foreach x of loc vl{
rename `x'_lag2 `x'_lag3
rename `x'_lag1 `x'_lag2
rename `x' `x'_lag1
}



tsset person_id year
by person_id: egen all0_f = max(tot_inc)
by person_id: egen all0_l = max(tot_inc_lag)
drop if all0_f ==0 & all0_l==0


save "$maindir/dta/mcvl_annual_FinalData_pt2_`i'.dta", replace

}
