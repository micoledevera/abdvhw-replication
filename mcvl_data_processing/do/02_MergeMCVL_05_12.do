clear all
set more off

* MAKE TEMP FOLDER
qui cap mkdir "$temp\cohorts"

* MERGE CONTRIBUTION FILES
foreach j of numlist 2005/2012 {
	use "$dta\mcvl_`j'\contribution_1", clear
	foreach i of numlist 2/12 {
		append using "$dta\mcvl_`j'\contribution_`i'"
	}
	save "$dta\mcvl_`j'\contribution", replace
}

* MERGE AFFILIATION FILES
foreach j of numlist 2005/2012 {
	use "$dta\mcvl_`j'\affiliates_1", clear
	foreach i of numlist 2/3 {
		append using "$dta\mcvl_`j'\affiliates_`i'"
	}
	save "$dta\mcvl_`j'\affiliates", replace
}

foreach j of numlist 2005/2012 {
	* MERGE INDIVIDUALS WITH BASES
	use "$temp\individuals_last", clear
	keep if MCVL_last == `j'
	merge 1:m person_id using "$dta\mcvl_`j'\contribution", generate(_mergeBases) keep(match)
	
	label var _mergeBases "Rtdo. de merge individuals_`j' using Bases`j'"
	compress
	save "$temp\mcvl_`j'\IndividualsBases`j'", replace
	
	* MERGE SELF-EMPLOYED CONTRIBUTIONS
	use "$temp\individuals_last", clear
	keep if MCVL_last == `j'
	merge 1:m person_id using "dta\mcvl_`j'\contribution_13", generate(_mergeBases13) keep(match)
	
	label var _mergeBases13 "Rtdo. de merge individuals_`j' using Bases`j'_13"
	compress
	save "$temp\mcvl_`j'\IndividualsBases`j'13", replace
	
	* JOIN BOTH DATASETS
	use "$temp\mcvl_`j'\IndividualsBases`j'", clear
	append using "$temp\mcvl_`j'\IndividualsBases`j'13"
	drop _mergeBases _mergeBases13
	sort person_id firm_cc2 year
	
	* SAVE AS ONE COHORT
	compress
	save "$temp\cohorts\IndividualsBases`j'All", replace
	
	* REMOVE DUPLICATES
	* Monthly bases are unique to pid-contributionyear-cc2, regardless of the number of affiliation episodes linked to that
	foreach m of numlist 1/12 {
		bysort person_id firm_cc2 year: egen inc`m'_ = max(contribution_`m')
		bysort person_id firm_cc2 year: egen incaut`m'_ = max(contribution_aut_`m')
		drop contribution_`m' contribution_aut_`m'
		rename inc`m'_ contribution_`m'
		rename incaut`m'_ contribution_aut_`m'
		label var contribution_`m' "Base de cotizacion por contingencias comunes mes `m'"
		label var contribution_aut_`m' "Base de cotizacion cuenta propia y otros mes `m'"
	}
	
	* DELETE REDUNDANT VARIABLES THAT APPEAR IN AFFILIATION FILES (SINCE 2013, THEY ARE NOT IN BASES)
	drop contract_type contribution_group entry_date exit_date
	bysort person_id firm_cc2 year: drop if _n > 1
	
	* SAVE
	save "$temp\cohorts\IndividualsBases`j'OK", replace
	
	* REMOVE INTERMEDIATE FILES
	erase "$temp\mcvl_`j'\IndividualsBases`j'.dta"
	erase "$temp\mcvl_`j'\IndividualsBases`j'13.dta"
	
	* MERGE INDIVIDUALS TO AFFILIATED
	use "$temp\individuals_last", clear
	keep if MCVL_last == `j'
	merge 1:m person_id using "$dta\mcvl_`j'\affiliates", generate(_mergeAff) keep(match)
	label var _mergeAff "Rtdo. de merge Individuals`j' using affiliates"
	
	* REMOVE DUPLICATES AND EPISODES WITH CODE 81
	/* Version 2005 of MCVL, in the affiliation table, registered a considerable amount of entry
	episodes in unconventional accounts that do not correspond to situations of entry in the labor market,
	not to assistential benefits, nor to any other entry situations that provoke the inclusion in the 
	reference population of the MCVL. The code 81 is frequently used in data cleaning. In later versions of
	the MCVL, there are 100,000 relations, corresponding to 19,000 individuals that were in versions 2004
	and 2005 with this exit code key, which exclusively referred to health benefits. We eliminate these eps: */
	drop if MCVL_last == 2005 & exit_date == 19980531 & reason_dismissal == 81
	
	bysort person_id entry_date exit_date firm_cc2: gen dupes = _n
	tab dupes
	drop if dupes > 1
	drop dupes
	
	* GET ENTRY YEAR AND EXIT YEAR
	gen entry_year = int(entry_date/10000)
	gen exit_year = int(exit_date/10000)
	
	* ENTRY AND EXIT (IN DATE FORMAT)
	tostring entry_date, replace
	gen alta = date(entry_date, "YMD")
	tostring exit_date, replace
	gen baja = date(exit_date, "YMD")
	format alta baja %tdDD.Mon.CCYY
	label var alta "Real date of entry in affilate"
	label var baja "Real date of exit in affiliate"
	
	order alta baja, after(exit_date)
	drop entry_date exit_date
	drop if alta > baja /* Eliminate episodes with negative duration */
	
	* SAVE
	sort person_id firm_cc2 entry_year exit_year alta baja
	order person_id firm_cc2 entry_year exit_year alta baja, first
	compress
	save "$temp\cohorts\IndividualsAffiliated`j'All", replace
	
	* MERGE IndividualsAffiliated WITH IndividualsBases
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
		bysort person_id alta baja firm_cc2: gen year = cond(_n==1, entry_year, entry_year[1] + _n - 1)
		label var year "Year"
		save "$temp\cohorts\IndividualsAffiliated`j'_`i'", replace
		
		* Slice up IndividualBases into smaller files
		use "$temp\cohorts\IndividualsBases`j'OK" if birth_year == `i', clear
		save "$temp\cohorts\IndividualsBases`j'_`i'", replace
		
		* Merge modified IndividualsAffiliated with modified IndividualsBases
		use "$temp\cohorts\IndividualsAffiliated`j'_`i'", clear
		merge m:1 person_id firm_cc2 year using "$temp\cohorts\IndividualsBases`j'_`i'", generate(_mergeBasesM)
		
		/* Do not erase observations that correspond with affiliation episodes (==1) without contribution bases
		especially if these episodes took place, totally or in part, before June 1980. Keep this info for
		4_ReshareData20##.do before deleting any observations */
		tab _mergeBasesM, m
		label var _mergeBasesM "MERGE IndividualsAffiliated using IndividualsBases"
		drop if _mergeBasesM == 2
		gen dummy = (year < entry_year | year > exit_year)
		tab dummy /* There should be no 1s */
		drop dummy total_contribution
		
		/* For the same pid+contribution_year+cc2, the contribution base will be the same even if several
		affiliation episodes (diff entry/exit date_ for that same combination */
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





































