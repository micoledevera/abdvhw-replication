// Fix the missing firm_id before merging with tax data

// Get the affiliates files from each year, get the firm_cc2 and firm_id, get unique values
forvalues year = 2005/$latest {
	use "$dta\mcvl_`year'\affiliates.dta", clear
	
	** Get the exit year
	tostring exit_date, replace
	gen exit_yr = substr(exit_date, 1, 4)
	destring exit_yr, replace
	drop if exit_yr < 2003 /*Remove firms which we dont need the firm_id to merge to tax */
	
	** Keep useful variables
	keep firm_cc firm_id
	
	duplicates drop
	
	gen year = `year'
	
	save "$temp\firm_ids_`year'.dta", replace
}


// Append and check for duplicates
use "$temp\firm_ids_2005.dta", clear

forvalues year = 2006/$latest {
	append using "$temp\firm_ids_`year'.dta"
	*erase "$temp\firm_ids_`year'.dta"
	
	** Check duplicates
	bysort firm_cc firm_id (year): gen counter = _N
	bysort firm_cc firm_id (year): gen obs_no = _n
	
	** Keep most recent firm_cc2 firm_id pair
	keep if obs_no == counter
	drop counter obs_no
}

save "$temp\firm_ids.dta", replace
*erase "$temp\firm_ids_2005.dta"

use "$temp\firm_ids.dta", clear

// Count how many have different firm_ids
bysort firm_cc: gen totalno = _N
gen negyear = -year
bysort firm_cc (negyear): gen counter = _n

// Remove not problematic cases
* If the firm_cc firm_id is unique
drop if totalno == 1

* If all the firm_ids are not zero
gen zero_id = (firm_id == 0)
bysort firm_cc: egen sum_zero = sum(zero_id)
drop if sum_zero == 0

// Give up on those totalno >= 4
drop if totalno >= 4

// Obvious fixes only applicable for totalno == 2 -- take the nonzero value
drop if totalno == 2 & zero_id == 1

// For totalno == 3, just keep the most recent
drop if totalno == 3 & zero_id == 1
drop counter
bysort firm_cc (negyear): gen counter = _n
drop if totalno == 3 & counter > 1

// Keep firm_cc and firm_id 
keep firm_cc firm_id
rename firm_id firm_id_correction

save "$temp\firm_id_correction.dta", replace























