clear 
global mmdir "C:\Users\s-wei-29\Dropbox\Global_Income_Dynamics\Part2\main_analysis\do"
global maindir "C:\Users\s-wei-29\Dropbox\Global_Income_Dynamics\Part2"
global savepath "C:\Users\s-wei-29\Dropbox\Global_Income_Dynamics\Part2\main_analysis\dta"

*Select income measure
* tot_inc: total pre-tax income
* disp_inc: disposable income
global inc_var  tot_inc 
*Select gender 
* chosen_sex = 1 if male, 0 if female
global chosen_sex = 1 


** BASELINE
* Poisson regression 
* TS
// foreach i in  "RemoveAllAfter2_NotClustering" { //"RemoveAllAfter3_NotClustering"
// global spl = "`i'"   
// * Main Specification: TS 2018
// do "${mmdir}/CV/Part2_analysis_moment_TS_poisson2018.do" 
// * alternative 2nd step
// do "${mmdir}/CV/Part2_analysis_moment_TS_poisson2018_alt2nd.do" 
// 
//
// 
//  * TS 2017
// do "${mmdir}/CV/Part2_analysis_moment_TS_poisson.do" 
// * Income only 2017
// do "${mmdir}/CV/Part2_analysis_moment_inconly_poisson.do" 
// * Income + workdays 2017
// do "${mmdir}/CV/Part2_analysis_moment_inc_wkdays_poisson.do" 
// * Income + workdays + age 2017
// do "${mmdir}/CV/Part2_analysis_moment_inc_wkdays_age_poisson.do" 
//
//
// * time varying coeff
// //do "${mmdir}/CV/Part2_analysis_moment_TS_poisson2018_timevary.do" 
// * using wage instead of tot_inc
// //do "${mmdir}/CV/Part2_analysis_moment_TS_poisson2018_wage.do" 
// }




** CLUSTER

* MODEL SELECTION
// forval i = 2(2)6{
// global n_clust = `i'
// global cname "k${n_clust}_inc_poisson_until2016"
// global cfile_mean "clustering_${cname}"
// global cname_absdev "k${n_clust}_absdev_poisson_until2016"
// global cfile_absdev "clustering_${cname_absdev}"
// do "${mmdir}/CV/Part2_analysis_moment_dum_poisson_update_new.do"
// }

* USING ALL
global n_clust = 4
global cname "k${n_clust}_inc_poisson_until2018"
global cfile_mean "clustering_${cname}"
global cname_absdev "k${n_clust}_absdev_poisson_until2018"
global cfile_absdev "clustering_${cname_absdev}"
do "${mmdir}/CV/Part2_analysis_moment_dum_poisson_update_new2018.do"


