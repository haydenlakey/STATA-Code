//Hayden Lakey and Ethan Arendse 
//ECO3021S Project

clear all 
set more off
cap log close
version 18

log using "Projectlogfile.log", replace
use "\\technet.wf.uct.ac.za\profiledata$\LKYHAY001\Documents\Project\lmdsa-2019-v1.1 (2).dta"
 
// Variables to use age, female, race binary, education, grant income, household income, rural binary, province

rename Q43INDUSTRY Industry
rename Q17EDUCATION eduyrs 
rename Q15POPULATION Race 
rename sector2 Sector
rename Q18FIELD Field
rename Q42OCCUPATION Job
rename Q16MARITALSTATUS MaritalSta
rename Q14AGE Age
rename indus InsGroups

//The following code is just tabulations of variables that hold importance in this project analysis
tab Province //NB
tab Industry //NB
tab Q13GENDER //Male or female NB
tab eduyrs //highest level of education  NB
tab Age //Ages  NB
tab Race //Races NB
tab Sector  //Including agriculture //NB
tab Field
tab Job 
tab Hrswrk
tab MaritalSta
tab Status
tab Metro_code
tab InsGroups
tab rural_urban
tab female
//add another education variable and location variable for sub question
tab Race
numlabel, add 
//Generating variables 
gen monthly_earnings=.
replace monthly_earnings = Q54a_monthly
replace monthly_earnings = Q57a_monthly if monthly_earnings==.
sum monthly_earnings
gen log_monthly_earnings=log(monthly_earnings)

//replace age = . if age < 15 | age > 64

gen employed = .
replace employed=1 if Status==1 & (age>=15 & age<=64)
replace employed=0 if Status!=1 & (age>=15 & age<=64)
tab Age

gen wkAge = Age if Age >= 15 & Age <=64
tab wkAge

gen female=.
replace female=1 if Q13GENDER==2
replace female=0 if Q13GENDER==1
label define female_lbl 0 "Male" 1 "Female"
label values female female_lbl

gen noschooling=(eduyrs==0)
gen primary=(eduyrs>=1&eduyrs<=7)
gen inc_sec=(eduyrs>=8&eduyrs<=11)
gen comp_sec=(eduyrs==12)
gen tertiary=(eduyrs>12&eduyrs!=.)

gen educyrs = .
replace educyrs = 0 if noschooling==1         //Tut 4 
replace educyrs = 1 if primary==1
replace educyrs = 2 if inc_sec==1
replace educyrs = 3 if comp_sec==1
replace educyrs = 4 if tertiary==1
label define educyrs3_lbl 0 "No Schooling" 1 "Primary" 2 "Inc_Sec" 3 "Com_Sec" 4 "Tertiary"
label values educyrs educyrs3_lbl
sum educyrs
tab educyrs

gen rural_urban=.
replace rural_urban = 1 if Metro_code == 2
replace rural_urban =1 if Metro_code == 4
replace rural_urban =1 if Metro_code == 5
replace rural_urban =1 if Metro_code == 8
replace rural_urban =1 if Metro_code == 10
replace rural_urban =1 if Metro_code == 13
replace rural_urban =1 if Metro_code == 14
replace rural_urban =1 if Metro_code == 15
replace rural_urban = 0 if Metro_code == 1
replace rural_urban = 0 if Metro_code == 3
replace rural_urban = 0 if Metro_code == 6
replace rural_urban = 0 if Metro_code == 7
replace rural_urban = 0 if Metro_code == 9
replace rural_urban = 0 if Metro_code == 11
replace rural_urban = 0 if Metro_code == 12
replace rural_urban = 0 if Metro_code == 16
replace rural_urban = 0 if Metro_code == 17
label define rural_urban_lbl 0 "Rural" 1 "Urban"
label values rural_urban rural_urban_lbl

gen fields = .
replace fields = 1 if Field == 20 | Field == 10|Field==22|Field==25
replace fields = 2 if Field==6|Field==15|Field==16|Field==17|Field==26
replace fields = 3 if Field==2|Field==8|Field==29|Field==30|Field==31|Field==36
replace fields = 4 if Field==4|Field==5|Field==24|Field==27|Field==28
replace fields = 5 if Field==3|Field==11|Field==12|Field==18
replace fields = 6 if Field==7|Field==19|Field==37
replace	fields = 7 if Field==1|Field==32
replace fields = 8 if Field==9|Field==13|Field==14|Field==21|Field==23|Field==33|Field==34|Field==35|Field==38
label define fields_lbl 1 "Social Sciences" 2 "Sciences" 3 "Engineering" 4 "Business" 5 "Arts" 6 "Education" 7 "Agriculture" 8 "Other"
label values fields fields_lbl

gen Female_Earnings = log_monthly_earnings if female==1

gen Male_Earnings = log_monthly_earnings if female==0

//Using sum to get means etc. of variables
sum Province
sum Industry
sum female
sum eduyrs
sum age
sum Race
sum Sector
sum Field
sum Job
sum MaritalSta
sum Status
sum InsGroups
sum employed

//Regression Section
ssc install outreg2

regress monthly_earnings female wkAge i.Province i.Race i.Sector i.InsGroups i.MaritalSta rural_urban i.educyrs Hrswrk

regress monthly_earnings female wkAge i.Province i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==0

regress monthly_earnings female wkAge i.Province i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==1

regress monthly_earnings female wkAge i.Province i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==2

regress monthly_earnings female wkAge i.Province i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==3

regress monthly_earnings female wkAge i.Province i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==4
//Using asdoc to export
asdoc reg monthly_earnings female wkAge i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk i.educyrs, replace title(Regression Results) 
asdoc reg monthly_earnings female wkAge i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==0, append //model(No Schooling)
asdoc reg monthly_earnings female wkAge i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==1, append //model(Primary)
asdoc reg monthly_earnings female wkAge i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==2, append //model(Inc_Sec)
asdoc reg monthly_earnings female wkAge i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==3, append //model(Com_Sec)
asdoc reg monthly_earnings female wkAge i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==4, append //model(Tert	iary)

//Using outreg2 to export 
reg log_monthly_earnings female wkAge i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk i.educyrs 
outreg2 using "Regression_Fresults.doc", word replace title(Regression Results) ctitle(All)
reg log_monthly_earnings female wkAge i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==0 //model(No Schooling)
outreg2 using "Regression_Fresults.doc", word append ctitle(No Schooling)
reg log_monthly_earnings female wkAge i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==1 //model(Primary)
outreg2 using "Regression_Fresults.doc", word append ctitle(Primary)
reg log_monthly_earnings female wkAge i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==2 //model(Inc_Sec)
outreg2 using "Regression_Fresults.doc", word append ctitle(Inc_Sec)
reg log_monthly_earnings female wkAge i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==3 //model(Com_Sec)
outreg2 using "Regression_Fresults.doc", word append ctitle(Com_Sec)
reg log_monthly_earnings female wkAge i.Race i.Sector i.InsGroups i.MaritalSta rural_urban Hrswrk if educyrs==4 //model(Tertiary)
outreg2 using "Regression_Fresults.doc", word append ctitle(Tertiary)

vif
outreg2 using "regression1Test.doc", word

sum monthly_earnings if Q13GENDER == 1
sum monthly_earnings if Q13GENDER == 2

 // Descriptive statitcs table using Asdoc
ssc install asdoc, replace
help asdoc

asdoc tabstat monthly_earnings wkAge Q13GENDER rural_urban Race_1 Hrswrk employed, stat(mean) replace title(Table 1: Descriptive Statistics)

asdoc sum monthly_earnings wkAge female rural_urban Race_1 Hrswrk, detail replace title (Table 1: Descriptive Statistic) save ("Dstatfinal.doc")

asdoc tabstat monthly_earnings wkAge Q13GENDER rural_urban Race_1 Hrswrk employed, stat(mean) by(educyrs) rows(educyrs) append 


//Graphing Section 
histogram Hrswrk, by(Q13GENDER) title("Distribution of Hours Worked by Gender")
graph export "Histogram1.jpg", as(jpg) replace
//graph bar log_monthly_earnings, over(female)
graph bar log_monthly_earnings, over(Q13GENDER) title("Bar Graph of Log(monthly earnings) Males vs Females")
graph export "Bargraphmalevsfemale.jpg", as(jpg) replace

//Graph 3
histogram log_monthly_earnings, title("Histogram of log(Monthly Earnings)") name(graph1, replace) //These 2 count as 1 graph, must be shown side by side 
histogram monthly_earnings, title("Histogram of Monthly Earnings") name(graph2, replace)
graph combine graph2 graph1, col(2)
graph export "Histcombine.jpg", as(jpg) replace

graph bar (count), over(educyrs, label(angle(45))) by(Q13GENDER) title("Males vs Females Education Levels")
graph export "Baredugen2.jpg", as(jpg) replace
graph bar (count), over(educyrs) over(Q13GENDER) stack
//Graph 4 
graph bar log_monthly_earnings, over(educyrs) title("Log(Monthly Earnings) at Different Education Levels")
graph export "Bargraph2.jpg", as(jpg) replace

//Graph 5 (Graph of average income by rural vs urban area)
graph bar log_monthly_earnings, over(rural_urban)
graph export "Bargraph3.jpg", as(jpg) replace

//Graph 6 
graph bar log_monthly_earnings, by(educyrs)
graph bar Hrswrk, by(educyrs)
graph bar monthly_earnings, over(Q13GENDER) over(fields, gap(10)) xsize(150)
graph bar Female_Earnings Male_Earnings, over(educyrs) title("Males vs Females Earnings at Different Education Levels")
graph export "Bargraph4.jpg", as(jpg) replace

graph box log_monthly_earnings, over(Q13GENDER) title("Males vs Females Log(Monthly Earnings)") //use
graph export "Boxgraph1.jpg", as(jpg) replace

graph box log_monthly_earnings, over(educyrs) over(Q13GENDER)

//subquestion graphs
graph bar log_monthly_earnings, over(rural_urban) over(educyrs)
graph export "Bargraph5.jpg", as(jpg) replace

graph box log_monthly_earnings, over(rural_urban)

numlabel, add 