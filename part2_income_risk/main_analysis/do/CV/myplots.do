/*
	This code plots the time series of the moments geneated for the QE project
	First version, March,03,2019
    Last edition,  Dec, 08, 2020
	
	This code might need to be updated to accomodate the particular characteristics of 
	the data in each country. If you have problems, contact Ozkan/Salgado on Slack
*/

*DEFINE PLOTING FUNCTIONS
capture program drop  tspltAREALimPA2 tsplt2sc  tspltAREALimPA



program tspltAREALimPA2

	graph set window fontface "${fontface}"
*Define which variables are plotted
	local varilist = "`1'"

*Defime the time variable
	local timevar = "`2'"

*Define limits of x-axis
	local xmin = `3'
	local xmax = `4'
	local xdis = `5'

*Define labels
	local lab1 = "`6'"
	local lab2 = "`7'"
	local lab3 = "`8'"
	local lab4 = "`9'"
	local lab5 = "`10'"
	local lab6 = "`11'"
	local lab7 = "`12'"
	local lab8 = "`13'"
	local lab9 = "`14'"
	

	local cols = "`15'"
	local posi = "`16'"

*Define Title, Subtitle, and axis labels 
	local xtitle = "`17'"
	local ytitle = "`18'"
	local title = "`19'"
	local subtitle = "`20'"

*Define name and output file 
	local namefile = "`21'"	

*Define limits of y-axis
	local ymin = "`22'"
	local ymax = "`23'"
	local ydis = "`24'"
		if "`ymin'" == ""{
			local ylbls = ""
		}
		else{
			local ylbls = "`22'(`24')`23'"
		}
	
*Define whether the legend is active or no 
	if "`25'" == ""{
		local lgactive = "on"
	}
	else{
		local lgactive = "off"
	}
	
*Define the color scheme 
local colors = "`26'"
	
	local cframe = ""
	foreach co of local colors{
		local cframe = "`cframe'"+" "+"`co'"
		local mcframe = "`mcframe'"+" "+"`co'*0.25"
	}	
	
*Define msymbols 
	local labsym = "`27'"
	
*Define whether we need a yline 
	local ylinex = ""
	if "`28'" == "yes"{
		*local ylinex = "yline(0,lpattern(dash) lcolor(black) axis(2) extend )"
		local moxdmd = `xmin' - 1
		local ylinex = "(pcarrowi   0 `moxdmd'  0 `xmax', color(black) lpattern(dash) yaxis(2) msize(vtiny) msymbol(none))"
	}
	

*Some global defined 

	local xtitlesize = "${xtitlesize}" 			// Size of xtitle font
	local ytitlesize = "${ytitlesize}" 			// Size of ytitle font	
	local xlabsize = "${xlabsize}"
	local ylabsize = "${ylabsize}"	
	local titlesize = "${titlesize}"			// Size of title font
	local subtitlesize = "${subtitlesize}"		// Size of subtiotle font
	local formatfile = "${formatfile}"			// format of saved file 
	local folderfile = "${folderfile}"			// folder where the plot is saved
	local marksize = "${marksize}"				// Marker size 
	local legesize = "${legesize}"				// Marker size 


*Calculating plot limits
	local it = 1
	foreach vv of local varilist{
		if `it' == 1{
			
			qui: sum `vv'
			local upt = r(min)
			local ipt = r(max)
	
			local opt1 = "`upt'"
			local opt2 = "`ipt'"
			local it = 0
		}
		else{
			qui: sum `vv'
			local upt = r(min)
			local ipt = r(max)
			
			local opt1 = "`opt1',`upt'"
			local opt2 = "`opt2',`ipt'"
			local it = 2
		}
	
	}
	
	if `it' == 0 {
		local rmin = `upt'
		local rmax = `ipt'
	}
	else{
		local rmin = min(`opt1')
		local rmax = max(`opt2')
	}
	
				
	
	local ymin1 : di %4.2f  round(`rmin'*(0.9),0.1)
	local ymax1 : di %4.2f round(`rmax'*(1+0.1),0.1)
	local ydis1 = (`ymax1' - `ymin1')/5
	
	
	
*Plot
	if "`28'" == "yes"{
		*With dashed line*
		tw  `ylinex' (connected `varilist'  `timevar' if `timevar' >= `xmin' & `timevar' <= `xmax',  				 /// Plot
		lwidth(medthick)  lcolor(`r(p)')  ///			Line color
		lpattern(solid longdash dash dash_dot solid longdash dash dash_dot solid longdash dash dash_dot)  ///			Line pattern
		msymbol(`labsym')		/// Marker
		msize("`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" )		/// Marker size
		mfcolor("`r(p)'*0.25")  ///	Fill color
		mlcolor(`r(p)')  ///			Marker  line color
		yaxis(2)   ytitle(`ytitle', axis(2) size(`ytitlesize')) ylabel(`ylbls', labsize(`ylabsize') grid axis(2))) ///
		,  /// yaxis optins
		xtitle("") xtitle(`xtitle',size(`xtitlesize')) xlabel(`xmin'(`xdis')`xmax',grid labsize(`xlabsize')) ///		xaxis options
		legend(`lgactive' size(`legesize') col(`cols') symxsize(7.0) ring(1) position(`posi') ///
		order(3 "`lab1'" 4 "`lab2'" 5 "`lab3'" 6 "`lab4'" 7 "`lab5'" 8 "`lab6'" 9 "`lab7'" 10 "`lab8'" 11 "`lab9'") ///
		region(color(none) lcolor(white))) graphregion(color(white)) /// Legend options 
		graphregion(color(white)  ) ///				Graph region define
		plotregion(lcolor(black))  ///				Plot regione define
		title(`title', color(black) size(`titlesize')) subtitle(`subtitle', color(black) size(`subtitlesize'))  // Title and subtitle
		cap noisily: graph export "`folderfile'/`namefile'.`formatfile'", replace 
	}
	else{
		colorpalette9 cblind, select(7 8 9 3 2 1 6 4 3 )	
		*Without dashed line*
		tw  (connected `varilist'  `timevar' if `timevar' >= `xmin' & `timevar' <= `xmax',  				 /// Plot
		lwidth(medthick)  lcolor(`r(p)')  ///			Line color
		lpattern(solid longdash dash dash_dot solid longdash dash dash_dot solid longdash dash dash_dot)  ///			Line pattern
		msymbol(`labsym')		/// Marker
		msize("`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" )		/// Marker size
		mfcolor(`r(p)')  ///	Fill color
		mlcolor(`r(p)')  ///			Marker  line color
		yaxis(2)   ytitle(`ytitle', axis(2) size(`ytitlesize')) ylabel(`ylbls', labsize(`ylabsize') grid axis(2))) ///
		,  /// yaxis optins
		xtitle("") xtitle(`xtitle',size(`xtitlesize')) xlabel(`xmin'(`xdis')`xmax',grid labsize(`xlabsize')) ///		xaxis options
		legend(`lgactive' size(`legesize') col(`cols') symxsize(7.0) ring(0) position(`posi') ///
		order(1 "`lab1'" 2 "`lab2'" 3 "`lab3'" 4 "`lab4'" 5 "`lab5'" 6 "`lab6'" 7 "`lab7'" 8 "`lab8'" 9 "`lab9'") ///
		region(color(none) lcolor(white))) graphregion(color(white)) /// Legend options 
		graphregion(color(white)  ) ///				Graph region define
		plotregion(lcolor(black))  ///				Plot regione define
		title(`title', color(black) size(`titlesize')) subtitle(`subtitle', color(black) size(`subtitlesize'))  // Title and subtitle
		cap noisily: graph export "`folderfile'/`namefile'.`formatfile'", replace 
		
	}

end






program tsplt2sc

graph set window fontface "${fontface}"

 
*Define which variables are plotted
local varilist1 = "`1'"
local varilist2 = "`2'"

*Defime the time variable
local timevar = "`3'"

/*Define limits of y-axis 1
local ymin1 = `4'
local ymax1 = `5'
local ydis1 = `6'

*Define limits of y-axis 2
local ymin2 = `7'
local ymax2 = `8'
local ydis2 = `9'
*/

*Define limits of x-axis
local xmin = `4'
local xmax = `5'
local xdis = `6'

*Define labels
local lab1 = "`7'"
local lab2 = "`8'"

*Define Title, Subtitle, and axis labels 
local xtitle = "`9'"
local ytitle1 = "`10'"
local ytitle2 = "`11'"
local title = "`12'"
local subtitle = "`13'"

*Define name and output file 
local namefile = "`14'"

*Some global defined 
local xtitlesize = "${xtitlesize}" 			// Size of xtitle font
local ytitlesize = "${ytitlesize}" 			// Size of ytitle font
local titlesize = "${titlesize}"			// Size of title font
local subtitlesize = "${subtitlesize}"		// Size of subtiotle font
local formatfile = "${formatfile}"			// format of saved file 
local folderfile = "${folderfile}"			// folder where the plot is saved
local marksize = "${marksize}"				// Marker size 


*Calculating plot limits
qui: sum `varilist1'
	
	local aux1 = r(rmin) 
	if `aux1' < 0 {
		local mfact = 1.1
	}
	else {
		local mfact = 0.9
	}
	
	local ymin1: di %4.2f round(r(min)*`mfact',0.1)
	local ymax1: di %4.2f round(r(max)*(1+0.1),0.1)
	local ydis1 = (`ymax1' - `ymin1')/5
	
qui: sum `varilist2'
	local aux1 = r(min) 
	if `aux1' < 0 {
		local mfact = 1.1
	}
	else {
		local mfact = 0.9
	}
	local ymin2: di %4.2f round(r(min)*`mfact',0.01)
	local ymax2: di %4.2f round(r(max)*(1+0.1),0.01)
	local ydis2 = (`ymax2' - `ymin2')/5



*Plot
colorpalette9 cblind, select(7 8 9 3 2 1 6 4 3 )	
tw  (bar rece year if `timevar' >= `xmin' & `timevar' <= `xmax', ylabel(,nogrid axis(1)) c(1) color(gray*0.5)) ///
    (connected `varilist1'  `timevar', 				 /// Plot
	lwidth(medthick) lcolor("`r(p1)'")  ///			Line color
	lpattern(solid )  ///			Line pattern
	msymbol(T )		/// Marker
	msize("`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" )		/// Marker size
	mfcolor("`r(p1)'")  ///	Fill color
	mlcolor("`r(p1)'")  ///			Marker  line color
	yaxis(1)  ytitle("`ytitle1'", axis(1) size(`ytitlesize')) ylabel(0(5)20,axis(1)) yscale(r(0 20))) ///
	///
	(connected `varilist2'  `timevar', 				 /// Plot
	lcolor("`r(p2)'")  ///			Line color
	lpattern(longdash dash solid longdash dash solid longdash dash solid)  ///			Line pattern
	msymbol(O T D O T D O T D)		/// Marker
	msize("`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" )		/// Marker size
	mfcolor("`r(p2)'" )  ///	Fill color
	mlcolor("`r(p2)'" )  ///			Marker  line color
	yaxis(2)  ytitle("`ytitle2'", axis(2) size(`ytitlesize'))  yscale(r(0 0.2)) ylabel(0(0.1)0.5,axis(2))  ) ///
	///
	,xtitle("") xtitle(`xtitle',size(`xtitlesize')) xlabel(`xmin'(`xdis')`xmax',grid) ///		xaxis options
	legend(col(1) symxsize(7.0) ring(0) position(11) ///
	order(2 "`lab1'" 3 "`lab2'") ///
	region(color(none))) graphregion(color(white)) /// Legend options 
	graphregion(color(white)  ) ///				Graph region define
	plotregion(lcolor(black))  ///				Plot regione define
	title(`title', color(black) size(`titlesize')) subtitle(`subtitle', color(black) size(`subtitlesize'))  // Title and subtitle
	cap noisily: graph export "`folderfile'/`namefile'.`formatfile'", replace 
	
	
end




program tspltAREALimPA

	graph set window fontface "${fontface}"
*Define which variables are plotted
	local varilist = "`1'"

*Defime the time variable
	local timevar = "`2'"

*Define limits of x-axis
	local xmin = `3'
	local xmax = `4'
	local xdis = `5'

*Define labels
	local lab1 = "`6'"
	local lab2 = "`7'"
	local lab3 = "`8'"
	local lab4 = "`9'"
	local lab5 = "`10'"
	local lab6 = "`11'"
	local lab7 = "`12'"
	local lab8 = "`13'"
	local lab9 = "`14'"
	

	local cols = "`15'"
	local posi = "`16'"

*Define Title, Subtitle, and axis labels 
	local xtitle = "`17'"
	local ytitle = "`18'"
	local title = "`19'"
	local subtitle = "`20'"

*Define name and output file 
	local namefile = "`21'"	

*Define limits of y-axis
	local ymin = "`22'"
	local ymax = "`23'"
	local ydis = "`24'"
		if "`ymin'" == ""{
			local ylbls = ""
		}
		else{
			local ylbls = "`22'(`24')`23'"
		}
	
*Define whether the legend is active or no 
	if "`25'" == ""{
		local lgactive = "on"
	}
	else{
		local lgactive = "off"
	}
	
*Define the color scheme 
local colors = "`26'"
	
	local cframe = ""
	foreach co of local colors{
		local cframe = "`cframe'"+" "+"`co'"
		local mcframe = "`mcframe'"+" "+"`co'*0.25"
	}	
	
*Define msymbols 
	local labsym = "`27'"
	
*Define whether we need a yline 
	local ylinex = ""
	if "`28'" == "yes"{
		*local ylinex = "yline(0,lpattern(dash) lcolor(black) axis(2) extend )"
		local moxdmd = `xmin' - 1
		local ylinex = "(pcarrowi   0 `moxdmd'  0 `xmax', color(black) lpattern(dash) yaxis(2) msize(vtiny) msymbol(none))"
	}
	

*Some global defined 

	local xtitlesize = "${xtitlesize}" 			// Size of xtitle font
	local ytitlesize = "${ytitlesize}" 			// Size of ytitle font	
	local xlabsize = "${xlabsize}"
	local ylabsize = "${ylabsize}"	
	local titlesize = "${titlesize}"			// Size of title font
	local subtitlesize = "${subtitlesize}"		// Size of subtiotle font
	local formatfile = "${formatfile}"			// format of saved file 
	local folderfile = "${folderfile}"			// folder where the plot is saved
	local marksize = "${marksize}"				// Marker size 
	local legesize = "${legesize}"				// Marker size 


*Calculating plot limits
	local it = 1
	foreach vv of local varilist{
		if `it' == 1{
			
			qui: sum `vv'
			local upt = r(min)
			local ipt = r(max)
	
			local opt1 = "`upt'"
			local opt2 = "`ipt'"
			local it = 0
		}
		else{
			qui: sum `vv'
			local upt = r(min)
			local ipt = r(max)
			
			local opt1 = "`opt1',`upt'"
			local opt2 = "`opt2',`ipt'"
			local it = 2
		}
	
	}
	
	if `it' == 0 {
		local rmin = `upt'
		local rmax = `ipt'
	}
	else{
		local rmin = min(`opt1')
		local rmax = max(`opt2')
	}
	
				
	
	local ymin1 : di %4.2f  round(`rmin'*(0.9),0.1)
	local ymax1 : di %4.2f round(`rmax'*(1+0.1),0.1)
	local ydis1 = (`ymax1' - `ymin1')/5
	
		
*Plot
	if "`28'" == "yes"{
		*With dashed line*
		tw   (bar rece year if `timevar' >= `xmin' & `timevar' <= `xmax', ylabel(,nogrid axis(1)) c(l) color(gray*0.5) yscale(off)) ///
		`ylinex' (connected `varilist'  `timevar' if `timevar' >= `xmin' & `timevar' <= `xmax',  				 /// Plot
		lwidth(medthick)  lcolor(`cframe')  ///			Line color
		lpattern(solid longdash dash dash_dot solid longdash dash dash_dot solid longdash dash dash_dot)  ///			Line pattern
		msymbol(`labsym')		/// Marker
		msize("`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" )		/// Marker size
		mfcolor(`mcframe')  ///	Fill color
		mlcolor(`cframe')  ///			Marker  line color
		yaxis(2)  yscale(alt axis(2)) ytitle(`ytitle', axis(2) size(`ytitlesize')) ylabel(`ylbls', labsize(`ylabsize') grid axis(2))) ///
		,  /// yaxis optins
		xtitle("") xtitle(`xtitle',size(`xtitlesize')) xlabel(`xmin'(`xdis')`xmax',grid labsize(`xlabsize')) ///		xaxis options
		legend(`lgactive' size(`legesize') col(`cols') symxsize(7.0) ring(0) position(`posi') ///
		order(3 "`lab1'" 4 "`lab2'" 5 "`lab3'" 6 "`lab4'" 7 "`lab5'" 8 "`lab6'" 9 "`lab7'" 10 "`lab8'" 11 "`lab9'") ///
		region(color(none) lcolor(white))) graphregion(color(white)) /// Legend options 
		graphregion(color(white)  ) ///				Graph region define
		plotregion(lcolor(black))  ///				Plot regione define
		title(`title', color(black) size(`titlesize')) subtitle(`subtitle', color(black) size(`subtitlesize'))  // Title and subtitle
		cap noisily: graph export "`folderfile'/`namefile'.`formatfile'", replace 
	}
	else{
		colorpalette9 cblind, select(7 8 9 3 2 1 6 4 3 )
		*Without dashed line*
		tw   (bar rece year if `timevar' >= `xmin' & `timevar' <= `xmax', ylabel(,nogrid axis(1)) c(l) color(gray*0.5) yscale(off)) ///
		     (connected `varilist'  `timevar' if `timevar' >= `xmin' & `timevar' <= `xmax',  				 /// Plot
		lwidth(medthick)  lcolor(`r(p)')  ///			Line color
		lpattern(solid longdash dash dash_dot solid longdash dash dash_dot solid longdash dash dash_dot)  ///			Line pattern
		msymbol(`labsym')		/// Marker
		msize("`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" "`marksize'" )		/// Marker size
		mfcolor(`r(p)')  ///	Fill color
		mlcolor(`r(p)')  ///			Marker  line color
		yaxis(2)  yscale(alt axis(2)) ytitle(`ytitle', axis(2) size(`ytitlesize')) ylabel(`ylbls', labsize(`ylabsize') grid axis(2))) ///
		,  /// yaxis optins
		xtitle("") xtitle(`xtitle',size(`xtitlesize')) xlabel(`xmin'(`xdis')`xmax',grid labsize(`xlabsize')) ///		xaxis options
		legend(`lgactive' size(`legesize') col(`cols') symxsize(7.0) ring(0) position(`posi') ///
		order(2 "`lab1'" 3 "`lab2'" 4 "`lab3'" 5 "`lab4'" 6 "`lab5'" 7 "`lab6'" 8 "`lab7'" 9 "`lab8'" 10 "`lab9'") ///
		region(color(none) lcolor(white))) graphregion(color(white)) /// Legend options 
		graphregion(color(white)  ) ///				Graph region define
		plotregion(lcolor(black))  ///				Plot regione define
		title(`title', color(black) size(`titlesize')) subtitle(`subtitle', color(black) size(`subtitlesize'))  // Title and subtitle
		cap noisily: graph export "`folderfile'/`namefile'.`formatfile'", replace 
		
	}

end


