** DEAL WITH PENSION FILES
clear

* Append all pensiones files
drop _all
forvalues y = $yrfirst/$yrlast { 
	append using "$dta\mcvl_`y'\pensiones.dta"
}

* Keep most recent pensiones file
bysort person_id year (date1): keep if _n == _N

* Get retirement year
gen retirementyear = trunc(date1 / 100)

* Remove jubliaciones/incapacidades parciales
drop if class == "25" | class == "J3"

keep person_id retirementyear class
duplicates drop
collapse (min) retirementyear, by(person_id)

sort person_id
compress
save "$temp\all_pensiones.dta", replace





















