clear all
set more off

* MERGE CONTRIBUTION FILES
foreach j of numlist 2013/$latest {
	use "$dta\mcvl_`j'\contribution_1", clear
	foreach i of numlist 2/12 {
		append using "$dta\mcvl_`j'\contribution_`i'"
	}
	save "$dta\mcvl_`j'\contribution", replace
}

* MERGE AFFILIATION FILES
foreach j of numlist 2013/$latest {
	use "$dta\mcvl_`j'\affiliates_1", clear
	foreach i of numlist 2/4 {
		append using "$dta\mcvl_`j'\affiliates_`i'"
	}
	save "$dta\mcvl_`j'\affiliates", replace
}

foreach j of numlist 2013/$latest {
	* MERGE INDIVIDUALS WITH BASES
	use "$temp\individuals_last", clear
	keep if MCVL_last == `j'
	merge 1:m person_id using "$dta\mcvl_`j'\contribution", generate(_mergeBases) keep(match)
	label var _mergeBases "Rtdo. de merge Individuals`j' using Bases`j'"
	compress
	save "$temp\mcvl_`j'\IndividualsBases`j'", replace
	
	* MERGE SELF-EMPLOYED CONTRIBUTIONS
	use "$temp\individuals_last", clear
	keep if MCVL_last == `j'
	merge 1:m person_id using "$dta\mcvl_`j'\contribution_13", generate(_mergeBases13) keep(match)
	label var _mergeBases13 "Rtdo. de merge Individuals`j' using Bases`j'13"
	compress
	save "$temp\mcvl_`j'\IndividualsBases`j'13", replace
	
	* JOIN BOTH DATASETS
	use "$temp\mcvl_`j'\IndividualsBases`j'", clear
	append using "$temp\mcvl_`j'\IndividualsBases`j'13"
	drop _mergeBases _mergeBases13
	sort person_id firm_cc2 year
	
	* SAVE
	compress
	save "$temp\cohorts\IndividualsBases`j'All", replace
	
	* REMOVE INTERMEDIATE FILES
	erase "$temp\mcvl_`j'\IndividualsBases`j'.dta"
	erase "$temp\mcvl_`j'\IndividualsBases`j'13.dta"
	
	* MERGE INDIVIDUALS WITH AFFILIATED
	use "$temp\individuals_last", clear
	keep if MCVL_last == `j'
	merge 1:m person_id using "$dta\mcvl_`j'\affiliates", generate(_mergeAff) keep(match)
	label var _mergeAff "Rtdo. de merge Individuals`j' using affiliates"
	
	* REMOVE DUPLICATES
	bysort person_id entry_date exit_date firm_cc2: gen dupes = _n
	tab dupes
	drop if dupes > 1
	drop dupes
	
	* ENTRY YEAR AND EXIT YEAR
	gen entry_year = int(entry_date/10000)
	gen exit_year = int(exit_date/10000)
	
	* ENTRY AND EXIT (IN DATE FORMAT)
	tostring entry_date, replace
	gen alta = date(entry_date, "YMD")
	tostring exit_date, replace
	gen baja = date(exit_date, "YMD")
	format alta baja %tdDD.Mon.CCYY
	label var alta "Real date of entry in affilate"
	label var baja "Real date of exit in affilate"
	
	order alta baja, after(exit_date)
	drop entry_date exit_date
	drop if alta > baja /* Eliminate episodes of negative duration */
	
	* SAVE
	sort person_id firm_cc2 entry_year exit_year alta baja
	order person_id firm_cc2 entry_year exit_year alta baja, first
	compress
	save "$temp\cohorts\IndividualsAffiliated`j'All", replace
	
	* MERGE IndividualsAffiliate with Individualsases
	local end = `j' - 16
	local start = `j' - 99
	
	foreach i of numlist `start'/`end' {
		use "$temp\cohorts\IndividualsAffiliated`j'All" if birth_year == `i', clear
		
		* Change the shape of IndividualsAffiliated such that it fits with IndividualsBases
		* make (repeated) observations of each affiliation episode as years between entry and exit
		gen expan_num = (exit_year - entry_year) + 1
		expand expan_num, gen(duplicate)
		sort person_id alta baja firm_cc2
		drop expan_num duplicate
		
		* Create variable for contribution year to merge with contributions file
		bysort person_id alta baja firm_cc2: gen year = cond(_n == 1, entry_year, entry_year[1] + _n - 1)
		label var year "Year"
		save "$temp\cohorts\IndividualsAffiliated`j'_`i'", replace
		
		* Slice the file "IndividualsBases" into smaller files
		use "$temp\cohorts\IndividualsBases`j'All" if birth_year == `i', clear
		save "$temp\cohorts\IndividualsBases`j'_`i'", replace
		
		* Merge modified IndividualsAffiliated and IndividualsBases
		use "$temp\cohorts\IndividualsAffiliated`j'_`i'", clear
		merge m:1 person_id firm_cc2 year using "$temp\cohorts\IndividualsBases`j'_`i'", generate(_mergeBasesM)
		
		/* Do not erase observations that correspond with affiliation episodes (==1) without contribution bases
		especially if these episodes took place, totally or in part, before June 1980. Keep this info for
		4_ReshapeData20##.do before deleting any observations */
		tab _mergeBasesM, m
		label var _mergeBasesM "MERGE IndividualsAffiliated using IndividualsBases"
		drop if _mergeBasesM == 2
		gen dummy = (year < entry_year | year > exit_year)
		tab dummy /* There should be no 1s */
		drop dummy total_contribution
		
		/* For the same pid+contribution_year+cc2, the contribution base will be the same even if several
		affiliation episodes (diff entry/exit date) for that same combination */
		order person_id firm_cc2 year alta baja, first
		sort person_id year alta baja firm_cc2
		drop entry_year exit_year
		
		compress
		save "$temp\cohorts\IndividualsBasesM`j'_`i'", replace
		erase "$temp\cohorts\IndividualsAffiliated`j'_`i'.dta"
		erase "$temp\cohorts\IndividualsBases`j'_`i'.dta"
	}
	
	* Erase extra files
	erase "$temp\cohorts\IndividualsAffiliated`j'All.dta"
	erase "$temp\cohorts\IndividualsBases`j'All.dta"
}








































