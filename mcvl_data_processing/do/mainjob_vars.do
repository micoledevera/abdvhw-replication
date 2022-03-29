**** Identify the main contract of the year
bysort person_id year firm_cc2 rel_contract: egen contribution_con = sum(contribution) if rel_contract == 1
bysort person_id year: egen max_contribution = max(contribution_con)

gen main_con = (max_contribution == contribution_con) if rel_contract == 1

**** Identify most recent entry of the firm in main contract
bysort person_id year firm_cc2 rel_contract (month baja): gen recent_main_contract = (_n == _N & main_con == 1)

* Keep only most recent
bysort person_id year recent_main_contract (month): replace recent_main_contract = 0 if _n != _N & recent_main_contract == 1

**** Determine whether main contract is PERMANENT
cap drop permanent
gen permanent_main = .

** Different types of permanent contracts
* Indefinido ordinario
replace permanent_main = 1 if inlist(contract_type, 1, 3, 65, 100, 139, 189, 200, 239, 289) & recent_main_contract == 1

* Fomento empleo
replace permanent_main = 1 if inlist(contract_type, 8, 9, 11, 12, 13, 20, 23, 28, 29, 30, 31, 32, 33, 35, ///
												38, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, ///
												59, 60, 61, 62, 63, 69, 70, 71, 80, 81, 86, 88, 89, 90, ///
												91, 98, 101, 102, 109, 130, 131, 141, 150, 151, 152, 153, ///
												154, 155, 156, 157, 186, 209, 230, 231, 241, 250, 251, ///
												252, 253, 254, 255, 256, 257) & recent_main_contract == 1
												
* Fijo discontinuo
replace permanent_main = 1 if inlist(contract_type, 18, 181, 182, 183, 184, 185, 300, 309, 330, 331, 350, ///
												351, 352, 353, 354, 355, 356, 357, 389) & recent_main_contract == 1
												
* Functionarios and funcionarios interinos
replace permanent_main = 1 if contract_type == 0 & inlist(job_relationship, 901, 902, 910) & recent_main_contract == 1

** Types of temporal contracts
* Duracion determinada
replace permanent_main = 0 if inlist(contract_type, 4, 5, 16, 17, 22, 24, 64, 72, 73, 74, 75, 76, 82, 83, ///
												84, 92, 93, 94, 95, 408, 410, 418, 500, 508, 510, 518) ///
												& recent_main_contract == 1

* Obra o servicio
replace permanent_main = 0 if inlist(contract_type, 14, 401, 501) & recent_main_contract == 1

* Circumstancia de produccion
replace permanent_main = 0 if inlist(contract_type, 15, 402, 502) & recent_main_contract == 1

* Formacion
replace permanent_main = 0 if inlist(contract_type, 6, 7, 26, 27, 36, 37, 39, 53, 54, 55, 56, 57, 58, 66, ///
												67, 68, 77, 78, 79, 85, 87, 96, 97, 420, 421, 430, 431, ///
												403, 452, 503, 520, 530, 531) & recent_main_contract == 1

replace permanent_main = 0 if contract_type == 0 & job_relationship == 87 & recent_main_contract == 1

* Relevo
replace permanent_main = 0 if inlist(contract_type, 10, 25, 34, 441, 540, 541) & recent_main_contract == 1

* Otros
replace permanent_main = 0 if inlist(contract_type, 450, 451, 457, 550, 551, 552, 557, 990) & recent_main_contract == 1

replace permanent_main = 0 if contract_type == 0 & job_relationship == 932 & recent_main_contract == 1

* No Consta
replace permanent_main = 0 if permanent_main == . & recent_main_contract == 1 

**** Determine whether main contract is FULL-TIME
cap drop parttime
gen fulltime_main = .

* By contract type
replace fulltime_main = 0 if inlist(contract_type, 23, 24, 25, 26, 27, 64, 65, 84, 95, 200, 209, 230, 231, ///
												239, 241, 250, 289, 500, 501, 502, 503, 508, 510, 518, ///
												520, 530, 531, 540, 541, 550, 551, 552) & recent_main_contract == 1

* By contract_type (reclassified by Cristina)
replace fulltime_main = 0 if inlist(contract_type, 3, 4, 6, 34, 38, 63, 73, 76, 81, 83, 89, 93, 98, 102, ///
												209, 251, 252, 253, 254, 255, 256, 257, 557) & recent_main_contract == 1
												
* By parttime coefficient
replace fulltime_main = 1 if ptcoef == 0 & recent_main_contract == 1
replace fulltime_main = 0 if ptcoef != 0 & ptcoef != . & recent_main_contract == 1

**** Determine whether main contract is CONTINUING TO NEXT YEAR
gen continuing_main = year(baja) > year if recent_main_contract == 1

**** Determing whether main contract is CIVIL-SERVICE JOB
gen govt_main = inlist(job_relationship, 901, 902, 910) if recent_main_contract == 1

**** Drop intermediate variables
drop contribution_con max_contribution main_con


**** NEW DEFINITION OF PUBLIC AND FUNCIONARIOS
gen public = inlist(firm_jur_status, "P", "Q", "S") if recent_main_contract == 1
gen funcionario = inlist(job_relationship, 901, 902, 932, 937) if recent_main_contract == 1












