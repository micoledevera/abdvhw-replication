// COUNTING DAYS

clear

local end = $latest - 16
local start = $latest - 99

foreach i of numlist `start'/`end' {
	* Erase temporary files
	capture erase "$temp\temp1.dta"
	capture erase "$temp\temp2.dta"
	capture erase "$temp\temp3.dta"
	capture erase "$temp\days_multiple.dta"
	capture erase "$temp\days_temp.dta"
	capture erase "$temp\intersect_temp.dta"
	
	* Import data
	use "$temp\cohorts\mcvl${latest}_YearMonth_`i'", clear
	
	* Keep variables we need
	keep person_id year month alta baja death_year_month firm_cc2 ///
			contribution_regime job_relationship MCVL_entry MCVL_last
			
	* Make things consistent
	bysort person_id: egen entry_aux = mean(MCVL_entry)
	drop MCVL_entry
	rename entry_aux MCVL_entry
	
	bysort person_id: egen last_aux = mean(MCVL_last)
	drop MCVL_last
	rename last_aux MCVL_last
			
	* Get entry into the muestra (SS)
	gen aux1 = year if !missing(firm_cc2)
	bysort person_id: egen min_year = min(aux1)
	drop firm_cc2 aux1
	
	gen aux = cond(MCVL_entry <= min_year, MCVL_entry, min_year) // minimum of min_year and MCVL_entry 
	drop MCVL_entry min_year
	rename aux MCVL_entry
			
	* Drop years we do not need
	drop if year < MCVL_entry
	drop if year > MCVL_last
	
	* Get year of death
	gen death_year = int(death_year_month / 100)
	
	replace death_year = . if death_year == 0
	
	bysort person_id: egen death_aux = mean(death_year)
	drop death_year
	rename death_aux death_year
	
	drop MCVL_last death_year_month
	
	* Keep MCVL_entry to merge again later
	preserve
	
	keep person_id MCVL_entry
	duplicates drop
	
	save "$temp\entry_temp.dta", replace
	
	restore
	
	drop MCVL_entry
	
	* Keep observations before death year
	drop if year > death_year
	drop death_year
			
	* identify relevant contracts
	gen rel_contract = 0
	replace rel_contract = 1 if ((contribution_regime >= 111 & contribution_regime <= 137) | ///
								(contribution_regime >= 140 & contribution_regime <= 180) | ///
								(contribution_regime >= 611 & contribution_regime <= 650) | ///
								(contribution_regime >= 811 & contribution_regime <= 823) | ///
								(contribution_regime >= 840 & contribution_regime <= 850) | ///
								(contribution_regime >= 911 & contribution_regime <= 950)) & ///
								(job_relationship < 751 | job_relationship > 756)
								
	keep if rel_contract == 1
	
	drop rel_contract contribution_regime job_relationship
	
	* Count if multiple relevant contracts in the month
	bysort person_id year month: gen multiple_con = (_N > 1)
	
	** COUNT DAYS WORKED
	* Months that was worked in full
	gen days = mdy(month + 1, 1, year) - mdy(month, 1, year) if ((year > year(alta) & year < year(baja)) | ///
					(year == year(alta) & year == year(baja) & month < month(baja) & month > month(alta)) | ///
					(year == year(alta) & year < year(baja) & month > month(alta)) | ///
					(year == year(baja) & year > year(alta) & month < month(baja))) & month != 12
	
	replace days = mdy(month - 11, 1, year + 1) - mdy(month, 1, year) if ((year > year(alta) & year < year(baja)) | ///
					(year == year(alta) & year == year(baja) & month < month(baja) & month > month(alta)) | ///
					(year == year(alta) & year < year(baja) & month > month(alta)) | ///
					(year == year(baja) & year > year(alta) & month < month(baja))) & month == 12
					
	* Started in the month
	replace days = cond(month(alta) != 12, ///
						mdy(month(alta) + 1, 1, year(alta)) - 1 - alta + 1, ///
						mdy(month(alta) - 11, 1, year(alta) + 1) - 1 - alta + 1) ///
						if year == year(alta) & month == month(alta)
	
	* Ended in the month
	replace days = day(baja) if year == year(baja) & month == month(baja)
	
	* Started and ended in the same month
	replace days = day(baja) - day(alta) + 1 if year == year(alta) & month == month(alta) & ///
												year == year(baja) & month == month(baja)
						
	** Save a temporary file with the months without multiple contracts (TEMP 1)
	preserve
	
	keep if multiple_con == 0
	
	keep person_id year month days
	
	compress
	save "$temp\temp1", replace
	
	restore
	
	* Drop multiple_con == 0 and work with months with multiple contracts
	drop if multiple_con == 0
	
	* CHECK: N_OBS > 0
	qui count
	if `r(N)' == 0 {
		* Save temp1
		use "$temp\temp1", clear
		save "$temp\annual_cohort`i'_days", replace
		
		continue
	}
	
	* If one of the contracts already spans entire month, just make days = max_days(month) (TEMP 2)
	gen negdays = -days
	bysort person_id year month (negdays): gen contract_id = _n
	bysort person_id year month (negdays): egen max_days = max(days)
	
	gen max_month = mdy(month + 1, 1, year) - mdy(month, 1, year) if month != 12
	replace max_month = mdy(month - 11, 1, year + 1) - mdy(month, 1, year) if month == 12
	
	preserve
	
	keep if contract_id == 1 & max_days == max_month
	
	keep person_id year month days
	
	compress
	save "$temp\temp2", replace
	
	restore
	
	* Deal with others
	drop if max_days == max_month
	
	* CHECK: N_OBS > 0
	qui count
	if `r(N)' == 0 {
		* Save temp1 and temp2
		use "$temp\temp1", clear
		append using "$temp\temp2"
		save "$temp\annual_cohort`i'_days", replace
		
		continue
	}
	
	drop negdays contract_id max_days max_month
	
	bysort person_id year month (alta): gen contract_id = _n
	
	save "$temp\days_multiple", replace
	
	* Create a temporary using
	preserve
	
	keep person_id year month alta baja contract_id
	rename alta alta_temp
	rename baja baja_temp
	rename contract_id contract_id_temp
	
	save "$temp\days_temp", replace
	
	restore
	
	* Do joinby to get all pairwise combinations
	joinby person_id year month using "$temp\days_temp"
	drop if contract_id == contract_id_temp 	/* remove same contracts */
	
	* Check intersection
	gen intersect = alta_temp <= baja if alta <= alta_temp
	replace intersect = alta <= baja_temp if alta > alta_temp
	
	* Sum by contract if they intersect
	collapse (sum) intersect, by(person_id year month contract_id)
	
	save "$temp\intersect_temp", replace
	
	* Merge with original
	use "$temp\days_multiple", clear
	merge 1:1 person_id year month contract_id using "$temp\intersect_temp"
	
	* If contracts do not intersect, then just add days (TEMP 3)
	bysort person_id year month: egen sum_int = sum(intersect)
	
	preserve
	
	keep if sum_int == 0
	
	capture collapse (sum) days, by(person_id year month)
	
	capture compress
	capture save "$temp\temp3", replace
	
	restore
	
	* Remaining: intersection contracts
	drop if sum_int == 0
	drop contract_id _merge sum_int intersect
	
	* CHECK: N_OBS > 0
	qui count
	if `r(N)' == 0 {
		* Save temp1 and temp2
		use "$temp\temp1", clear
		append using "$temp\temp2"
		append using "$temp\temp3"
		save "$temp\annual_cohort`i'_days", replace
		
		continue
	}
	
	bysort person_id year month (alta): gen contract_id = _n
	
	save "$temp\days_multiple", replace
	
	* Create a temporary using
	preserve
	
	keep person_id year month alta baja contract_id
	rename alta alta_temp
	rename baja baja_temp
	rename contract_id contract_id_temp
	
	save "$temp\days_temp", replace
	
	restore
	
	* Do joinby to get all pairwise combinations
	joinby person_id year month using "$temp\days_temp"
	drop if contract_id == contract_id_temp 	/* remove same contracts */
	drop if contract_id_temp < contract_id		/* half the number of pairs */
	
	* Check intersection
	gen intersect = (alta_temp <= baja & alta <= alta_temp)
	
	** COUNT DAYS IN INTERSECTION
	* No intersection
	gen days_int = 0 if intersect == 0
	
	* If intersect == 1 make auxiliary contract
	gen alta_aux = alta_temp if intersect == 1
	gen baja_aux = cond(baja < baja_temp, baja, baja_temp)  if intersect == 1
	format alta_aux baja_aux %tdDD.Mon.CCYY
	
	* Whole month is overlap
	replace days_int = mdy(month + 1, 1, year) - mdy(month, 1, year) ///
				if 	((year > year(alta_aux) & year < year(baja_aux)) | ///
					(year == year(alta_aux) & year == year(baja_aux) & month < month(baja_aux) & month > month(alta_aux)) | ///
					(year == year(alta_aux) & year < year(baja_aux) & month > month(alta_aux)) | ///
					(year == year(baja_aux) & year > year(alta_aux) & month < month(baja_aux))) & ///
					month != 12
					
	replace days_int = mdy(month - 11, 1, year + 1) - mdy(month, 1, year) ///
				if 	((year > year(alta_aux) & year < year(baja_aux)) | ///
					(year == year(alta_aux) & year == year(baja_aux) & month < month(baja_aux) & month > month(alta_aux)) | ///
					(year == year(alta_aux) & year < year(baja_aux) & month > month(alta_aux)) | ///
					(year == year(baja_aux) & year > year(alta_aux) & month < month(baja_aux))) & ///
					month == 12
					
	* Started in the month
	replace days_int = cond(month(alta_aux) != 12, ///
						mdy(month(alta_aux) + 1, 1, year(alta_aux)) - 1 - alta_aux + 1, ///
						mdy(month(alta_aux) - 11, 1, year(alta_aux) + 1) - 1 - alta_aux + 1) ///
						if year == year(alta_aux) & month == month(alta_aux)
						
	* Ended in the month
	replace days_int = day(baja_aux) if year == year(baja_aux) & month == month(baja_aux)
	
	* Started and ended in the same month
	replace days_int = day(baja_aux) - day(alta_aux) + 1 if year == year(alta_aux) & month == month(alta_aux) & ///
												year == year(baja_aux) & month == month(baja_aux)
												
	** Get the number which we will subtract from sum(days)
	collapse (max) days_int, by(person_id year month contract_id_temp)
	
	collapse (sum) days_int, by(person_id year month)
	
	save "$temp\intersect_temp", replace
	
	** COMBINE WITH THE ONES WITH MULTIPLE CONTRACTS
	use "$temp\days_multiple", clear
	
	collapse (sum) days, by(person_id year month)
	
	merge 1:1 person_id year month using "$temp\intersect_temp"
	
	* Subtract the days intersected
	replace days = days - days_int
	drop days_int
	
	* Append other files
	append using "$temp\temp1"
	append using "$temp\temp2"
	append using "$temp\temp3"
	
	* Merge to get MCVL_entry
	qui drop _merge
	merge m:1 person_id using "$temp\entry_temp.dta", keep(master match)
	drop _merge
	
	* Save
	sort person_id year month
	compress
	save "$temp\annual_cohort`i'_days", replace
}

** APPEND ALL FILES
local last = $yrlast - 16
local end = `last' - 1
local start = $yrlast - 99

use "$temp\annual_cohort`last'_days", clear
foreach j of numlist `start'/`end' {
	capture append using "$temp\annual_cohort`j'_days"
	erase "$temp\annual_cohort`j'_days.dta"
}
save "$temp\mcvl_annual_panel_days_aux", replace
erase "$temp\annual_cohort`last'_days.dta"

** MAKE PANEL ANNUAL
collapse (sum) days (mean) MCVL_entry, by(person_id year)
compress

save "$temp\mcvl_annual_panel_days_aux", replace

** FILLIN
fillin person_id year

replace days = 0 if _fillin == 1

drop _fillin

bysort person_id: egen first_MCVL = mean(MCVL_entry)

drop if year < first_MCVL
drop MCVL_entry first_MCVL

** GET DAYS WORKED LAGGED
xtset person_id year

gen days_lag1 = l.days
gen days_lag2 = l2.days
gen days_lag3 = l3.days

* Save
compress
save "$temp\mcvl_annual_panel_days", replace





















