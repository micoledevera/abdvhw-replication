// GOAL: 2 panels
// 1. Panel of individuals and a reference to the latest MCVL they appear in
// 2. Panel of firms and their characteristics over time

*****************
// INDIVIDUALS //
*****************
foreach j of numlist 2005/$latest {
	* Make temp folder
	qui cap mkdir "$temp\mcvl_`j'"
	
	* Read data
	use "$dta\mcvl_`j'\individuals.dta", clear
	
	* Merge individuals with convivir by person_id
	merge 1:1 person_id using "$dta\mcvl_`j'\convivir.dta"
	drop if _merge == 2
	drop _merge
	
	* Nationality and country of birth
	destring nationality, replace ignore("N")
	replace nationality = . if nationality == 99
	label var nationality "Nationality"
	
	destring birth_country, replace ignore("N")
	replace birth_country = . if birth_country == 99
	label var birth_country "Birth country"
	replace birth_country = nationality if birth_country == .
	compress
	label define birth_country 0"España" 1"Alemania" 3"Argentina" 4"Bulgaria" 5"China" /// 
	6"Colombia" 7"Cuba" 8"Rep.Dominicana" 9"Ecuador" 10"Francia" 11"Italia" ///
	12"Marruecos" 13"Perú" 14"Polonia" 15"Portugal" 16"Reino Unido" 17"Rumania" ///
	18"Ucrania" 19"Resto UE15" 20"Resto UE25" 21"Otros Europa" 22"Otros Sud y Centroamerica" ///
	23"Otros África" 24"Otros Asia y Pacífico" 25"Norteamérica" 26"Bolivia" 27"Brasil"
	label values birth_country birth_country
	label values nationality birth_country
	
	* Education level
	gen educ = .
	replace educ = 10 if (edu_code == "10" | edu_code == "11")
	replace educ = 20 if (edu_code == "20" | edu_code == "21" | edu_code == "22")
	replace educ = 30 if (edu_code == "30" | edu_code == "31" | edu_code == "32")
	replace educ = 40 if (edu_code == "40" | edu_code == "41" | edu_code == "42")
	replace educ = 50 if (edu_code == "43" | edu_code == "44" | edu_code == "45")
	replace educ = 60 if (edu_code == "46" | edu_code == "47")
	replace educ = 70 if edu_code == "48"
	
	drop edu_code
	rename educ education
	label var education "Education from municipal registry"
	label define education 10"No sabe leer ni escribir" 20"Titulación inferior a graduado escolar" ///
	30"Graduado escolar o equivalente" 40"Bachiller o Formación Profesional 2ºgrado" ///
	50"Diplomado, Técnico u otra titulación media" 60"Licenciado o Graduado Universitario" ///
	70"Máster, Doctorado o estudios de postgrado"
	label values education education
	
	* Create some year variable we will use to get the latest MCVL person is part of
	gen year  = `j'
	label var year "Year"
	
	* Check duplicates
	duplicates drop person_id, force
	
	* Save
	compress
	save "$temp\mcvl_`j'\individuals_`j'", replace
}

* Combine all years
use "$temp\mcvl_${latest}\individuals_${latest}", clear

local z = $latest - 1
forvalues j = 2005/`z' {
	append using "$temp\mcvl_`j'\individuals_`j'"
	erase "$temp\mcvl_`j'\individuals_`j'.dta"
}

bysort person_id: egen MCVL_last = max(year)	// Last MCVL of individual
bysort person_id: egen MCVL_entry = min(year)	// First MCVL of individual

compress
save "$temp\individuals_all", replace
erase "$temp\mcvl_${latest}\individuals_${latest}.dta"

* CLEAN INCONSISTENCIES
* Remove individuals who change birthdate
gen bday = date(birth_date, "YM")
format bday %tdMon.CCYY
drop birth_date
rename bday birth_date
label var birth_date "Birth year-month"

bysort person_id: gen tag = _n
bysort person_id: egen sd_birth = sd(birth_date)
count if sd_birth != 0 & sd_birth != . & tag == 1 // Number of individuals to drop
drop if sd_birth != 0 & sd_birth != .
drop sd_birth

* Remove missing birthday
bysort person_id (birth_date): replace birth_date = birth_date[1] // This replaces all missings to number, if available
count if birth_date == . & tag == 1 // Number of individuals to drop
drop if birth_date == .
drop tag

* RECTANGULARIZATION
fillin person_id year

rename MCVL_last aux
bys person_id (year): egen MCVL_last = max(aux) // To get MCVL_last because of fillin
drop aux

rename MCVL_entry aux
bys person_id (year): egen MCVL_entry = max(aux)
drop aux

drop if year > MCVL_last
drop if year < MCVL_entry

// To correct for the missings that fillin made:
ds person_id year MCVL_last MCVL_entry _fillin, not
foreach var of varlist `r(varlist)' {
	// For the created rows, copy the most recent year information
	bys person_id (year): replace `var' = `var'[_n-1] if _fillin == 1
}

* CONSISTENCY OF SEX, BIRTH_PROV, SS_REG_PROV, BIRTH_COUNTRY, AND DEATH_YEAR_MONTH
* For following variables, a zero is like missing
foreach var of varlist sex birth_prov ss_reg_prov {
	gen negyear = -year
	replace negyear = . if `var' == . | `var' == 0
	bysort person_id (negyear):  replace `var' = `var'[1]
	drop negyear
}

foreach var of varlist birth_country death_year_month {
	gen negyear = -year
	replace negyear = . if `var' == .
	bysort person_id (negyear): replace `var' = `var'[1]
	drop negyear
}

* REMOVE STRANGE OBSERVATIONS BASED ON GENDER (sex==0)
* Variable for gender, male = 1 and female = 0
drop if sex != 1 & sex != 2 // Drop strange observations
replace sex = 0 if sex == 2 // Define sex such that male == 1
label var sex "Sex: Male=1 Female=0"

* CREATE ROWS BETWEEN 16 YEARS OLD AND UNTIL WE OBSERVE THEM IN THE DATA
* (Why do this?)
sort person_id year

gen birth_year = year(birth_date)
label var birth_year "Cohort year"
order birth_year birth_date, after(person_id)

gen d16 = birth_year + 16 // Year when person turns 16

// Count how many years between 16 and mcvl_entry. If negative, will not make more rows
gen expan_numA = MCVL_entry - d16 + 1 if year == MCVL_entry & year != MCVL_last

// Create 4 years of information after last observation
gen expan_numB = min($latest - MCVL_last + 1, 4 + 1) if year == MCVL_last & year != MCVL_entry

// For people only observed once
gen expan_numC = MCVL_entry - d16 + min($latest - MCVL_last + 1, 4 + 1) if year == MCVL_entry & year == MCVL_last

expand expan_numA, gen(duplicateA)
expand expan_numB, gen(duplicateB)
expand expan_numC, gen(duplicateC)

* CREATE YEAR VARIABLE FOR DUPLICATES
replace duplicateA = -duplicateA // Put duplicates at beginning and original at end
sort person_id year duplicateA
by person_id: replace year = cond(_n == 1, min(d16, MCVL_entry), min(d16, MCVL_entry) + _n - 1) if duplicateA == -1

sort person_id year duplicateB
by person_id: replace year = year[_n-1] + 1 if duplicateB == 1

replace duplicateC = -duplicateC
sort person_id year duplicateC
by person_id: replace year = cond(_n == 1, min(d16, MCVL_entry), min(d16, MCVL_entry) + _n - 1)

drop d16

* SAVE AS DTA
sort person_id year
order person_id year birth_year MCVL_last MCVL_entry _fillin, first
save "$temp\individuals_full", replace


* CREATE LIST OF INDIVIDUALS AND WHEN THEY WERE LAST OBSERVED
keep if year == MCVL_last
keep person_id MCVL_last birth_year birth_date
save "$temp\individuals_last", replace


**************
// EMPRESAS //
**************
foreach i of numlist 2005/$latest {
	// Specify how many affilates files
	if `i' <= 2012 {
		local num 3
	} 
	else {
		local num 4
	}
	
	// Merge all affliates files
	use "$dta\mcvl_`i'\affiliates_1", clear
	foreach a of numlist 2/`num' {
		append using "$dta\mcvl_`i'\affiliates_`a'"
	}
	
	// Drop variables we do not need
	drop person_id contribution_regime contribution_group contract_type ptcoef ///
		entry_date exit_date reason_dismissal disability job_relationship firm_id ///
		firm_cc new_date_contract1 prev_contract1 prev_ptcoef1 ///
		new_date_contract2 prev_contract2 prev_ptcoef2 new_date_contribution_group ///
		prev_contribution_group
		
	// Clean firm_jur_type and firm_jur_status
	destring firm_jur_type, replace force
	replace firm_jur_type = 0 if firm_jur_type == .
	replace firm_jur_status = "" if firm_jur_status != "A" ///
	& firm_jur_status != "B" ///
	& firm_jur_status != "C" ///
	& firm_jur_status != "D" ///
	& firm_jur_status != "E" ///
	& firm_jur_status != "F" ///
	& firm_jur_status != "G" ///
	& firm_jur_status != "H" ///
	& firm_jur_status != "J" ///
	& firm_jur_status != "N" ///
	& firm_jur_status != "P" ///
	& firm_jur_status != "Q" ///
	& firm_jur_status != "R" ///
	& firm_jur_status != "S" ///
	& firm_jur_status != "U" ///
	& firm_jur_status != "V" ///
	& firm_jur_status != "W" 
	
	
	// Remove duplicates
	* Rule: get most recent
	gen altayear = floor(firm_age / 10000)
	gsort firm_cc2 -altayear
	egen tagid = tag(firm_cc2)
	keep if tagid == 1
	drop tagid
	
	// Create year variable
	gen year = `i'
	
	// Save
	compress
	save "$temp\mcvl_`i'\firms_`i'", replace
}

* COMBINE ALL FIRM DATA
use "$temp\mcvl_${latest}\firms_${latest}", clear

local z = ${latest} - 1
foreach i of numlist 2005/`z' {
	append using "$temp\mcvl_`i'\firms_`i'"
	erase "$temp\mcvl_`i'\firms_`i'.dta"
}

save "$temp\firms_all_ORIGINAL", replace
erase "$temp\mcvl_${latest}\firms_${latest}.dta"

* CORRECT SOME MISSING VARIABLES
* ETT is only present after 2006
gen negyear = -year
sort firm_cc2 negyear
bysort firm_cc2 (negyear): replace firm_ett = firm_ett[_n-1] if year == 2005 & _n > 1

* Correct firm entry into mcvl
replace firm_age = . if firm_age == 0
by firm_cc2: replace firm_age = firm_age[_n-1] if firm_age == . & firm_age[_n-1] != . & _n > 1

* Correct CNAE-09 (only available after 2009. Fill with closest data)
by firm_cc2: replace sector_cnae09 = sector_cnae09[_n-1] if sector_cnae09 == . & sector_cnae09[_n-1] != .

* Correct CNAE-93 (not available for MCVL2009, take the previous/next year)
by firm_cc2: replace sector_cnae93 = sector_cnae93[_n-1] if year == 2009
bysort firm_cc2 year: replace sector_cnae93 = sector_cnae93[_n-1] if year == 2009 & missing(sector_cnae93)
drop negyear

* RECTANGULARIZE THE PANEL AND FILL IN INFORMATION IF THERE ARE GAPS
* Create variable that says first/last MCVL with information
by firm_cc2: egen ini_year = min(year)
by firm_cc2: egen end_year = max(year)

* Fill in gaps
qui fillin firm_cc2 year
sort firm_cc2 year

* Fill in ini_year and end_year which is missing because of fillin
rename ini_year ini_year_tmp
by firm_cc2: egen ini_year = max(ini_year_tmp)
label var ini_year "Initial MCVL year we observe CC2"
drop ini_year_tmp

rename end_year end_year_tmp
by firm_cc2: egen end_year = max(end_year_tmp)
label var end_year "Last MCVL year we observe CC2"
drop end_year_tmp

* Clean which years we need
drop if year < ini_year
drop if year > end_year

* Fill up cells in between ini_year and end_year
sort firm_cc2 year
foreach var of varlist sector_cnae93 firm_jur_status sector_cnae09 firm_workers ///
firm_age firm_ett firm_jur_type firm_main_prov {
	by firm_cc2: replace `var' = `var'[_n-1] if _fillin == 1
}

* Expand the panel to cover from the first edicion of MCVL until year of first affiliation of a worker
* In some cases, there is a change in firm_age so take the earliest
sort firm_cc2 firm_age
by firm_cc2: egen highyear_cc2 = min(int(firm_age/10000))
/* NOTE: there are cases when firm appears even when theoretically it hasnt been registered.
That is, the first worker is observed after the firm appears. We prioritize ini_year of highyear_cc2 */

/* Information on CC goes back until 1940 (chosen) or back until it is first observed, whichever is closer.
If highyear_cc2 is missing, we will be conservative and assume it has been around since 1940.
When there is a case that highyear_cc2 is after ini_year, expan_num is negative and no duplicates will be made */
sort firm_cc2 year
gen expan_num = ini_year - cond(missing(highyear_cc2), 1940, max(1940, highyear_cc2)) + 1 if year == ini_year
expand expan_num, gen(duplicate)

* Place duplicates above non-duplicates and create variable that goes from year of creation to last year it appears
replace duplicate = -duplicate
bysort firm_cc2 (year duplicate): replace year = cond(_n==1, max(1940, highyear_cc2), max(1940, highyear_cc2)+_n-1) if duplicate == -1

* SAVE FILE
compress
sort firm_cc2 year
save "$temp\firms_all", replace
















