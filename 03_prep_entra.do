/*
Preparing ENTRA dataset
*/

gen data=1

keep if countryres==1 | countryres==.d						// keep only those who live in Germany

*COVID_Befragungsdaten raus
drop if wave==2									// drop the observations of the Covid (interim) survey
recode wave 3=2									// recode wave 2 as value 2
lab def wave 1 "W1" 2 "W2", replace
lab val wave wave

*encode co, gen(group)

sort lfid wave
replace cb=cb[_n-1] if wave==2 & lfid==lfid[_n-1]

drop if cb!=1 & cb!=.
*drop if group==1 | group==3
tab group
recode group 2=0 4=1 1=2 
*replace group = 0 if group==2
*replace group = 1 if group==4
lab def group 0 "Poles" 1 "Turks" 2 "Italians" 3 "Syrians", replace
lab val group group
tab group


global varlist2 "data lfid wave sex age sit group datetime_int edumaxtr_ISCED edumaxpl_ISCED polintrco polintrger fmsit lgerud lgerspk lgerrd lgerwr ppco ppger actco actellse hospger wkhardger treatmnt imdatearrm imdatearry imdatearrd imdatearr imgerm imgery imgerd satis whyim1 whyim2 whyim3 whyim4 whyim5 whyim6 whyim7 reldgr treatmntself wk actellse frnco frn1fam frn2fam frn3fam frn1cb frn2cb frn3cb frn wkh wkhw2 wk_ISEI durstay"
keep ${varlist2}




gen reas_economic = whyim1==1
gen reas_education = whyim2==1 
gen reas_family = whyim3==1 | whyim4==1 | whyim5==1
gen reas_political =whyim7==1

duplicates tag lfid, gen(panel)
drop if panel==0
drop panel
sort lfid




rename sex sex
rename age age
rename sit expectation_entra
rename datetime_int datetime
revrs polintrco, replace 
rename polintrco pol_co
revrs polintrger, replace
rename polintrger pol_rc

rename fmsit martital

rename wkh workinghours
sort wave lfid
lab var workinghours "Working Hours"
replace workinghours  = wkhw2 if workinghours==.
replace workinghours =. if wk!=1
recode workinghours -99/-1 =. .a/.f=.


gen isei = wk_ISEI
*replace isei = gx2_ISEI if isei==.

revrs reldgr
drop reldgr
rename revreldgr religiosity

revrs lgerud, replace
rename lgerud lang_understand
revrs lgerspk, replace
rename lgerspk lang_speak
revrs lgerrd, replace
rename lgerrd lang_read
revrs lgerwr, replace
rename lgerwr lang_write

revrs ppco, replace
revrs ppger, replace
rename ppco spendtime_co
rename ppger spendtime_rc 

rename actellse main_activity
replace main_activity = 0 if wk==1

revrs hospger, replace
rename hospger hospitable
revrs wkhardger, replace
rename wkhardger get_ahead

gen isced_co_entra = edumaxtr_ISCED if group==1
replace isced_co_entra = edumaxpl_ISCED if group==0

revrs satis, replace
rename satis satisfaction 

revrs treatmntself, replace
rename treatmntself discrimination
*replace datetime = datetime_int if wave==2
gen datetime_year = substr(datetime,1,4)
*replace datetime_year = substr(datetime,1,4) if wave==2
gen datetime_month = substr(datetime,6,2)
*replace datetime_month = substr(datetime_int,6,2) if wave==2
destring datetime_month, replace
destring datetime_year, replace

sort lfid wave
replace group = group[_n-1] if lfid == lfid[_n-1]
replace sex = sex[_n-1] if lfid == lfid[_n-1]
replace imdatearr =imdatearr[_n-1] if lfid == lfid[_n-1]
replace imdatearry = imdatearry[_n-1] if lfid == lfid[_n-1]
replace imgery = imgery[_n-1] if lfid == lfid[_n-1]
replace imdatearrm = imdatearrm[_n-1] if lfid == lfid[_n-1]
replace imgerm = imgerm[_n-1] if lfid == lfid[_n-1]
replace isced_co_entra = isced_co_entra[_n-1] if lfid == lfid[_n-1]
lab val isced_co_entra edumaxpl_ISCED
replace reas_economic =reas_economic[_n-1] if lfid == lfid[_n-1]
replace reas_education =reas_education[_n-1] if lfid == lfid[_n-1]
replace reas_family =reas_family[_n-1] if lfid == lfid[_n-1]
replace reas_political =reas_political[_n-1] if lfid == lfid[_n-1]
*replace expectation_entra =expectation_entra[_n-1] if id2 == id2[_n-1]

gen arrival_date_year_entra = imdatearry if imdatearr==1
replace arrival_date_year_entra = imgery if imdatearr==0

gen arrival_date_month_entra = imdatearrm if imdatearr==1
replace arrival_date_month_entra = imgerm if imdatearr==0

gen working = 1 if main_activity==0
replace working = 0  if main_activity<=9 & main_activity>0

gen unemployed = 1 if main_activity==1 | main_activity==2
replace unemployed = 0 if wk==1 | (main_activity>=3 & main_activity<=9)
drop wk 


drop if group>=2

sort lfid
by lfid: gen id2 = 1 if _n==1
replace id2 = sum(id2)
replace id2 = . if missing(lfid)

drop lfid
sort id2 wave


keep data id datetime age sex group isced_co_entra lang_understand lang_speak lang_read lang_write main_activity pol_co pol_rc satisfaction get_ahead hospitable spendtime_co spendtime_rc datetime_year datetime_month arrival_date_month_entra arrival_date_year_entra wave expectation_entra reas_economic working reas_education reas_family reas_political religiosity discrimination unemployed workinghours durstay //isei


*Harmonisieren Ankunftsdatum
gen migr_month = arrival_date_month_entra if data==1
gen migr_year = arrival_date_year_entra  if data==1
drop arrival_date_year_entra arrival_date_month_entra

gen int_year = datetime_year if data==1
gen int_month = datetime_month if data==1


gen time_in_germany = int_month - migr_month + 1 if int_year== migr_year
replace time_in_germany = (12-migr_month+1) + (int_year - migr_year - 1)*12 + int_month if int_year!= migr_year
drop datetime
*replace time_in_germany=.  if data==2					// check whether it makes a difference
*replace time_in_germany=durstay if data==2
*drop durstay

rename expectation_entra expectation

recode wave 1=0 2=1
lab def wave 0"Wave 1" 1"Wave 2", replace
lab val wave wave


compress

fre migr_month migr_year int_year int_month


/*
*number of friends in RC from CO
gen n_co_friends = 0 if frn==0
replace n_co_friends = frnco if frnco<=.
gen add=.
replace add = 1 if frn1fam==1 | frn1cb==1
replace add = add + 1 if (frn2fam==1 | frn2cb==1) & add!=.
replace add = 1 if (frn2fam==1 | frn2cb==1) & add==.
replace add = add + 1 if (frn3fam==1 | frn3cb==1) & add!=.
replace add = 1 if (frn3fam==1 | frn3cb==1) & add==.
replace n_co_friends = add if n_co_friends>=.
*replace n_co_friends =. if frnco==.a | frnco==.b | frnco==.r 
replace n_co_friends=0 if n_co_friends ==. & frn<.
*keep n_co_friends frnco add ppco1* ppco0* wave frn
*keep if n_co_friends ==.
drop add
*/
