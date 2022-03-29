clear all
set more off

** TAKE WAGES FROM TAX DATA
foreach j of numlist 2005/2015 {
	use "$dta\mcvl_`j'\tax", clear
	
	keep person_id firm_id payment_amount payment_inkind firm_jur_status payment_type payment_subtype 
	
	collapse (sum) payment_amount payment_inkind, by(person_id firm_id firm_jur_status payment_type payment_subtype)
	gen year = `j'
	rename payment_amount wage
	rename payment_inkind inkind
	
	replace wage = (wage + inkind) / 100
	replace inkind = inkind / 100
	
	sort person_id firm_id
	save "$temp\cohorts\Fiscal`j'", replace
}

foreach j of numlist 2016/2016 {
	use "$dta\mcvl_`j'\tax", clear
	
	gen wage = payment_amount + amount_il
	rename payment_inkind inkind
	
	keep person_id firm_id wage inkind firm_jur_status payment_type payment_subtype
	
	collapse (sum) wage inkind, by(person_id firm_id firm_jur_status payment_type payment_subtype)
	gen year = `j'
	
	replace wage = (wage + inkind) / 100
	replace inkind = inkind / 100
	
	sort person_id firm_id
	save "$temp\cohorts\Fiscal`j'", replace
}

foreach j of numlist 2017/$latest {
	use "$dta\mcvl_`j'\tax", clear
	
	gen wage = payment_amount + wage_il
	replace payment_inkind = payment_inkind + inkind_il
	rename payment_inkind inkind
	
	keep person_id firm_id wage inkind firm_jur_status payment_type payment_subtype
	
	collapse (sum) wage inkind, by(person_id firm_id firm_jur_status payment_type payment_subtype)
	gen year = `j'
	
	replace wage = (wage + inkind) / 100
	replace inkind = inkind / 100
	
	sort person_id firm_id
	save "$temp\cohorts\Fiscal`j'", replace
}

** APPEND ALL TAX FILES
use "$temp\cohorts\Fiscal${latest}", clear
local last = $latest - 1
foreach j of numlist 2005/`last' {
	append using "$temp\cohorts\Fiscal`j'"
	erase "$temp\cohorts\Fiscal`j'.dta"
}
save "$temp\Fiscal${latest}full_plus", replace
erase "$temp\cohorts\Fiscal${latest}.dta"

** SEPARATE ENTRIES ASSOCIATED TO UNEMPLOYMENT
use "$temp\Fiscal${latest}full_plus", clear
keep if payment_type == "C"
collapse (sum) wage inkind, by(person_id year)
gen aux_append = 0
save "$temp\Fiscal${latest}_unemp", replace

rename wage inc_unemp
drop aux_append inkind
save "$temp\Fiscal${latest}_unemp_det", replace

use "$temp\Fiscal${latest}_unemp", clear
keep person_id year
save "$temp\Fiscal${latest}_unemp_list", replace

use "$temp\Fiscal${latest}full_plus", clear
keep if payment_type == "C"
collapse (sum) wage, by(person_id firm_id year)
rename wage inc_unemp
save "$temp\Fiscal${latest}_unemp_firm", replace

** SEPARATE ENTRIES ASSOCIATED TO "PROFESSIONAL ACTIVITIES"
use "$temp\Fiscal${latest}full_plus", clear
keep if payment_type == "G" | payment_type == "H"
drop if payment_type == "G" & (payment_subtype == 0 | payment_subtype == 2)
drop if payment_type == "H" & payment_subtype == 3
collapse (sum) wage inkind, by(person_id year)
gen aux_append = 0
save "$temp\Fiscal${latest}_prof", replace

rename wage inc_prof
drop aux_append inkind
save "$temp\Fiscal${latest}_prof_det", replace

use "$temp\Fiscal${latest}full_plus", clear
keep if payment_type == "G" | payment_type == "H"
drop if payment_type == "G" & (payment_subtype == 0 | payment_subtype == 2)
drop if payment_type == "H" & payment_subtype == 3
collapse (sum) wage, by(person_id firm_id year)
rename wage inc_prof
save "$temp\Fiscal${latest}_prof_firm", replace

** SEPARATE ENTRIES ASSOCIATED TO "PENSIONS"
use "$temp\Fiscal${latest}full_plus", clear
keep if payment_type == "B"
collapse (sum) wage inkind, by(person_id year)
save "$temp\Fiscal${latest}_pension", replace

use "$temp\Fiscal${latest}_pension", clear
keep person_id year
save "$temp\Fiscal${latest}_pension_list", replace

** SEPARATE ENTRIES ASSOCIATED TO OTHER `CLAVES' RELATED TO NORMAL PAID WORK
use "$temp\Fiscal${latest}full_plus", clear 

* Drop other categories that disappear after 2005
drop if payment_type == "B" | payment_type == "C" | payment_type == "D" | payment_type == "E" | ///
		payment_type == "G" | payment_type == "H" | payment_type == "I" | payment_type == "J" | ///
		payment_type == "K" | payment_type == "L" | payment_type == "M"

collapse (sum) wage inkind, by(person_id firm_id year)

save "$temp\Fiscal${latest}_work", replace









































