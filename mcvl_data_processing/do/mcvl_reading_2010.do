/*----------------------------
Read MCVL 2010 and save as dta
----------------------------*/

** Set year
global v_old 2010

** INDIVIDUALS
insheet using "$raw\mcvl_${v_old}\MCVL${v_old}PERSONAL_CDF.txt", clear delimiter(";")

* Rename variables
rename v1 person_id
rename v2 birth_date
rename v3 sex
rename v4 nationality
rename v5 birth_prov
rename v6 ss_reg_prov
rename v7 person_muni_latest
rename v8 death_year_month
rename v9 birth_country
rename v10 edu_code
drop v11

* Label variables
label var person_id "Individual identifier"
label var birth_date "Birth date"
label var sex "Sex: Male=1 Female=2"
label var birth_date "Birth year-month"
label var death_year_month "Month deceased"
label var birth_prov "Birth province"
label var birth_country "Birth country"
label var nationality "Nationality"
label var person_muni_latest "Municipality of residence from municipal registry"
label var ss_reg_prov "Province of social security registration"
label var edu_code "Education from municipal registry"

* There should only be one entry per id
sort person_id
duplicates drop /* drop duplicates in all variables*/
egen tagpid = tag(person_id) /*If tagpid takes value 0, it means there is more than one record for same id*/
by person_id: egen mintagpid = min(tagpid) /*Identify ids with more than one record and drop*/
drop if mintagpid == 0
drop mintagpid tagpid

* Save as dta
compress
save "$dta\mcvl_${v_old}\individuals", replace


** CONVIVIENTES
insheet	using "$raw\mcvl_${v_old}\MCVL${v_old}CONVIVIR_CDF.txt", clear delimiter(";")

* Rename variables
rename v1 person_id
rename v2 birth_date
rename v3 sex
rename v4 birth_date2
rename v5 sex2
rename v6 birth_date3
rename v7 sex3
rename v8 birth_date4
rename v9 sex4
rename v10 birth_date5
rename v11 sex5
rename v12 birth_date6
rename v13 sex6
rename v14 birth_date7
rename v15 sex7
rename v16 birth_date8
rename v17 sex8
rename v18 birth_date9
rename v19 sex9
rename v20 birth_date10
rename v21 sex10

* Label variables
label var person_id "Individual identifier"
label var birth_date "Birth date"
label var sex "Sex: Male=1 Female=2"
label var birth_date2 "Birth date of 2nd conviviendo"
label var sex2 "Sex of 2nd conviviendo"
label var birth_date3 "Birth date of 3rd conviviendo"
label var sex3 "Sex of 3rd conviviendo"
label var birth_date4 "Birth date of 4th conviviendo"
label var sex4 "Sex of 4th conviviendo"
label var birth_date5 "Birth date of 5th conviviendo"
label var sex5 "Sex of 5th conviviendo"
label var birth_date6 "Birth date of 6th conviviendo"
label var sex6 "Sex of 6th conviviendo"
label var birth_date7 "Birth date of 7th conviviendo"
label var sex7 "Sex of 7th conviviendo"
label var birth_date8 "Birth date of 8th conviviendo"
label var sex8 "Sex of 8th conviviendo"
label var birth_date9 "Birth date of 9th conviviendo"
label var sex9 "Sex of 9th conviviendo"
label var birth_date10 "Birth date of 10th conviviendo"
label var sex10 "Sex of 10th conviviendo"

* Compute family size
gen d2=(sex2=="1"|sex2=="2")
gen d3=(sex3=="1"|sex3=="2")
gen d4=(sex4=="1"|sex4=="2")
gen d5=(sex5=="1"|sex5=="2")
gen d6=(sex6=="1"|sex6=="2")
gen d7=(sex7=="1"|sex7=="2")
gen d8=(sex8=="1"|sex8=="2")
gen d9=(sex9=="1"|sex9=="2")
gen d10=(sex10!=.)
gen familysize=1+d2+d3+d4+d5+d6+d7+d8+d9+d10
label variable familysize "Number of people living together"
drop d2-d10

* There should only be one entry per id
sort person_id
duplicates drop /* drop duplicates in all variables*/
egen tagpid = tag(person_id) /*If tagpid takes value 0, it means there is more than one record for same id*/
by person_id: egen mintagpid = min(tagpid) /*Identify ids with more than one record and drop*/
drop if mintagpid == 0
drop mintagpid tagpid

* Save as dta
sort person_id birth_date sex
tostring birth_date, replace
compress
save "$dta\mcvl_${v_old}\convivir", replace


** DIVISION
insheet	using "$raw\mcvl_${v_old}\MCVL${v_old}DIVISION_CDF.txt", clear delimiter(" ")

* Rename variables
rename v1 person_id
rename v2 relacionesfile
rename v3 basesfile

* Replace values
replace basesfile=1 if basesfile==11
replace basesfile=2 if basesfile==12
replace basesfile=3 if basesfile==13
replace basesfile=4 if basesfile==14
replace basesfile=5 if basesfile==21
replace basesfile=6 if basesfile==22
replace basesfile=7 if basesfile==23
replace basesfile=8 if basesfile==24
replace basesfile=9 if basesfile==31
replace basesfile=10 if basesfile==32
replace basesfile=11 if basesfile==33
replace basesfile=12 if basesfile==34

* Label variables
label variable relacionesfile "FICHEROS DE RELACIONES LABORALES"
label variable basesfile "FICHERO DE BASES DE COTIZACION"

* There should only be one entry per id
sort person_id
duplicates drop /* drop duplicates in all variables*/
egen tagpid = tag(person_id) /*If tagpid takes value 0, it means there is more than one record for same id*/
by person_id: egen mintagpid = min(tagpid) /*Identify ids with more than one record and drop*/
drop if mintagpid == 0
drop mintagpid tagpid

* Save as dta
compress
save "$dta\mcvl_${v_old}\division", replace


** CONTRIBUTIONS
foreach i of numlist 1/12 {
	insheet	using "$raw\mcvl_${v_old}\MCVL${v_old}COTIZA`i'_CDF.txt", clear delimiter(";")
	
	* Rename variables
	rename v1 person_id        
	rename v2 firm_cc2                
	rename v3 entry_date                 
	rename v5 exit_date               
	rename v7 contribution_group                  
	rename v8 year
	rename v9 contribution_1
	rename v10 contribution_2
	rename v11 contribution_3
	rename v12 contribution_4
	rename v13 contribution_5
	rename v14 contribution_6
	rename v15 contribution_7
	rename v16 contribution_8
	rename v17 contribution_9
	rename v18 contribution_10
	rename v19 contribution_11
	rename v20 contribution_12
	rename v21 total_contribution
	rename v22 contract_type
	drop v4 v6
	
	* Label variables 
	label var person_id "Individual identifier"
	label var firm_cc2 "Firm identifier for secondary establishment"
	label var entry_date "Date of entry in this affiliation"
	label var exit_date "Date of exit in this affiliation"
	label var contribution_group "Contribution group"
	label var year "Year"
	label var contribution_1 "Pension contribution-January (nominal euros in cents)"
	label var contribution_2 "Pension contribution-February (nominal euros in cents)"
	label var contribution_3 "Pension contribution-March (nominal euros in cents)"
	label var contribution_4 "Pension contribution-April (nominal euros in cents)"
	label var contribution_5 "Pension contribution-May (nominal euros in cents)"
	label var contribution_6 "Pension contribution-June (nominal euros in cents)"
	label var contribution_7 "Pension contribution-July (nominal euros in cents)"
	label var contribution_8 "Pension contribution-August (nominal euros in cents)"
	label var contribution_9 "Pension contribution-September (nominal euros in cents)"
	label var contribution_10 "Pension contribution-October (nominal euros in cents)"
	label var contribution_11 "Pension contribution-November (nominal euros in cents)"
	label var contribution_12 "Pension contribution-December (nominal euros in cents)"
	label var total_contribution "Total contribution for the year"
	label var contract_type "Type of job contract in pension contribution file"
	
	* Save file
	sort person_id entry_date exit_date firm_cc2
	compress
	save "$dta\mcvl_${v_old}\contribution_`i'", replace
}


** CONTRIBUTIONS OF AUTONOMOS
insheet using "$raw\mcvl_${v_old}\MCVL${v_old}COTIZA13_CDF.txt", clear delimiter(";")

* Rename variables
rename v1 person_id        
rename v2 firm_cc2                
rename v3 entry_date                 
rename v5 exit_date               
rename v7 year
rename v8 contribution_aut_1
rename v9 contribution_aut_2
rename v10 contribution_aut_3
rename v11 contribution_aut_4
rename v12 contribution_aut_5
rename v13 contribution_aut_6
rename v14 contribution_aut_7
rename v15 contribution_aut_8
rename v16 contribution_aut_9
rename v17 contribution_aut_10
rename v18 contribution_aut_11
rename v19 contribution_aut_12
drop v4 v6 v20

* Label variables
label var person_id "Individual identifier"
label var firm_cc2 "Firm identifier for secondary establishment"
label var entry_date "Date of entry in this affiliation"
label var exit_date "Date of exit in this affiliation"
label var year "Year"
label var contribution_aut_1 "Pension contribution (autonomos)-January (nominal euros in cents)"
label var contribution_aut_2 "Pension contribution (autonomos)-February (nominal euros in cents)"
label var contribution_aut_3 "Pension contribution (autonomos)-March (nominal euros in cents)"
label var contribution_aut_4 "Pension contribution (autonomos)-April (nominal euros in cents)"
label var contribution_aut_5 "Pension contribution (autonomos)-May (nominal euros in cents)"
label var contribution_aut_6 "Pension contribution (autonomos)-June (nominal euros in cents)"
label var contribution_aut_7 "Pension contribution (autonomos)-July (nominal euros in cents)"
label var contribution_aut_8 "Pension contribution (autonomos)-August (nominal euros in cents)"
label var contribution_aut_9 "Pension contribution (autonomos)-September (nominal euros in cents)"
label var contribution_aut_10 "Pension contribution (autonomos)-October (nominal euros in cents)"
label var contribution_aut_11 "Pension contribution (autonomos)-November (nominal euros in cents)"
label var contribution_aut_12 "Pension contribution (autonomos)-December (nominal euros in cents)"

* Save as dta
sort person_id entry_date exit_date firm_cc2
compress
save "$dta\mcvl_${v_old}\contribution_13", replace


** AFFILIATES
foreach i of numlist 1/3 {
	insheet using "$raw\mcvl_${v_old}\MCVL${v_old}AFILIAD`i'_CDF.txt", clear delimiter(";")
	
	* Rename variables
	rename v1 person_id        
	rename v2 contribution_regime
	rename v3 contribution_group                 
	rename v4 contract_type
	rename v5 ptcoef
	rename v6 entry_date
	rename v7 exit_date
	rename v8 reason_dismissal
	rename v9 disability
	rename v10 firm_cc2
	rename v11 firm_muni
	rename v12 sector_cnae09
	rename v13 firm_workers
	rename v14 firm_age
	rename v15 job_relationship
	rename v16 firm_ett
	rename v17 firm_jur_type
	rename v18 firm_jur_status
	rename v19 firm_id
	rename v20 firm_cc
	rename v21 firm_main_prov
	rename v22 new_date_contract1
	rename v23 prev_contract1
	rename v24 prev_ptcoef1
	rename v25 new_date_contract2
	rename v26 prev_contract2
	rename v27 prev_ptcoef2
	rename v28 new_date_contribution_group
	rename v29 prev_contribution_group
	rename v30 sector_cnae93
	
	* Label variables
	label var person_id "Individual identifier"
	label var contribution_regime "Social security regime"
	label var contribution_group "Contribution group"
	label var contract_type "Type of job contract"
	label var ptcoef "Part time coefficient in 1/1000 of full-time equivalent, 0 if full-time"
	label var entry_date "Date of entry in this affiliation"
	label var exit_date "Date of exit in this affiliation"
	label var reason_dismissal "Reason for dismissal in this affiliation"
	label var disability "Type of disability according to entry in affiliation"
	label var firm_cc2 "Firm establishment identifier"
	label var firm_muni "Firm establishment municipality if population above 40000"
	label var sector_cnae09 "3-digit sector code (2009)" 
	label var sector_cnae93 "3-digit sector code (1993)"
	label var firm_workers "Number of workers in firm establsihment"
	label var firm_age "Date firm establishment registered its first worker"
	label var job_relationship "Type of job relationship"
	label var firm_ett "Firm establishment is a temporary recruitment agency (ETT)"
	label var firm_jur_type "Firm establishment juridical classification (natural vs. legal entities)"
	label var firm_jur_status "Firm establishment juridical status (NIF for legal entities)"
	label var firm_id "Firm establishment identifier for matching with tax data"
	label var firm_cc "Common firm identifier for multi-establishment firm"
	label var firm_main_prov "Province associated with common firm identifier"
	label var new_date_contract1 "Date of first type of contract revision"
	label var prev_contract1 "Type of contract until first revision"
	label var prev_ptcoef1 "Part time coefficient until first revision (see ptcoef)"
	label var new_date_contract2 "Date of second type of contract revision"
	label var prev_contract2 "Type of contract until second revision"
	label var prev_ptcoef2 "Part time coefficient until second revision (see ptcoef)"
	label var new_date_contribution_group "Date of occupational code revision"
	label var prev_contribution_group "Occupational code until first revision"
	
	* Save as dta
	sort person_id entry_date exit_date firm_cc2
	compress
	save "$dta\mcvl_${v_old}\affiliates_`i'", replace
}


** RETIREMENT BENEFITS
insheet	using "$raw\mcvl_${v_old}\MCVL${v_old}PRESTAC_CDF.txt", clear delimiter(";")

* Rename variables
rename v1 person_id
rename v2 year
rename v4 class
rename v10 regimep
rename v11 date1
rename v15 yearsp
rename v21 situation
rename v22 date2
rename v27 coef1
rename v28 retirementtype
rename v29 coef2
rename v34 annualpension
drop v3 v5-v9 v12-v14 v16-v20 v23-v26 v30-v33 v35-v36

* Label variables
label var person_id "Individual identifier"
label var year "Year"
label var class "Clase de la prestacion" 
label var regimep "Regimen de la prension"
label var date1 "Fecha de efectos economicos de la pension"
label var yearsp "Years cotizados para la jubilacion"
label var situation "Situacion de la prestacion (causa de la baja)"
label var date2 "Fecha de situacion de la prestacion"
label var coef1 "Coeficiente reductor total"
label var retirementtype "Tipe de situacion de jubilacion"
label var coef2 "Coeficiente de parcialidad"
label var annualpension "Importe anual total de la prestacion"

* Selection
keep if (class=="20"|class=="21"|class=="22"|class=="23"|class=="24"|class=="25"|class=="26"|class=="J1"|class=="J2"|class=="J3"|class=="J4"|class=="J5")  
drop if regimep==36|regimep==37

* Keep unique
bysort person_id year (date1): gen n = _n
keep if n == 1
drop n

* Save as dta
sort person_id year
compress
save "$dta\mcvl_${v_old}\pensiones", replace


** TAX DATA
insheet	using "$raw\mcvl_${v_old}\MCVL${v_old}FISCAL_CDF.txt", clear delimiter(";")

* Rename variables
rename v1 person_id
rename v2 firm_jur_status
rename v3 firm_id
rename v4 person_province
rename v5 payment_type
rename v6 payment_subtype
rename v7 payment_amount
rename v8 payment_retention
rename v9 payment_inkind
rename v10 payment_account
rename v11 payment_account_re
rename v13 birth_year
rename v14 marital_status
rename v15 disability
rename v16 contract_type
rename v17 extension
rename v18 geo_mobility
rename v19 part_deductions
rename v20 deducted_costs
rename v21 allowances
rename v22 food_annuality
rename v23 children_under3
rename v25 other_children
rename v33 children
rename v34 older_under75
rename v36 other_older
rename v44 older
drop v12 v24 v26-v32 v35 v37-v43

* Auxiliary transformation
gen payment_eur = payment_amount / 100
gen payment_retention_eur = payment_retention / 100
gen payment_inkind_eur = payment_inkind / 100

* Label variables
label var person_id "Individual identifier"
label var firm_jur_status "Firm juridical status (NIF for legal entities)"
label var firm_id "Firm identifier for matching with tax data"
label var person_province "Province of individual residence in tax data"
label var payment_type "Type of payment (salary, pension, unemployment benefit, prizes, etc.)"
label var payment_subtype "Subtype of payment classification (when applicable)"
label var payment_amount "Payment amount (nominal euros in cents)"
label var payment_eur "Payment amount (nominal euros)"
label var payment_retention "Payment retentions for taxes (nominal euros in cents)"
label var payment_retention_eur "Payment retentions for taxes (nominal euros)"
label var payment_inkind "Payment in-kind (nominal euros in cents)"
label var payment_inkind_eur "Payment in-kind (nominal euros)"
label var payment_account "Ingresos a cuenta efectuados"
label var payment_account_re "Ingresos a cuenta repercutidos"
label var birth_year "Birth year in tax data"
label var marital_status "Marital status in tax data (non-compulsory)"
label var disability "Degree of disability in tax data"
label var contract_type "Type of job contract in tax data"
label var extension "Prolongacion de la actividad laboral"
label var geo_mobility "Movilidad geografica"
label var part_deductions "Reducciones (Arts. 17.2 y 3 y 94)"
label var deducted_costs "Gastos deducibles (Art. 18.2)"
label var allowances "Pensiones compensatorias"
label var food_annuality "Anualidades por alimentos"
label var children_under3 "Descendientes <3 years"
label var other_children "Resto descendientes"
label var children "Numero total de descendientes"
label var older_under75 "Ascendientes <75 years"
label var other_older "Ascendientes >= 75 years"
label var older "Numero total de ascendientes" 

* Save as dta
sort person_id
compress
save "$dta\mcvl_${v_old}\tax", replace































