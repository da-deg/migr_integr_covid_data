/*
Preparing SCIP dataset
*/

*Step 1: Filter to a comparable population and keep only the relevant variables
*variables:
*	CB_op		: country of birth (keep only Turks and Poles)
*	CTZSHIP_ELSE 	: no other Citizenship
*	CTZSHIP_RC	: no German citizenship
drop if CB_op!="-99 (filtered)" & CB_op!=""					// drop if born in other country
drop if CTZSHIP_ELSE != 0 & CTZSHIP_ELSE != .					// drop if different citizenship
drop if CTZSHIP_RC != 0 & CTZSHIP_RC != .					// drop if they hold the German citizenship
*drop if YB_op <0								// drop if year of birth is unknows


duplicates tag ID, gen(panel)							// gen variable "panel": 1 = two observations per ID, 0 = one observation per ID
drop if panel==0 								// drop observations that did not pariticipate in the second panel wave
drop panel									// drop the variable panel

sort ID wave
by ID: gen id = 1 if _n==1							// generate variable id which is 1 to n for observations in wave 1
replace id = sum(id)								// replace variable id as the sum of previous values for id (result: id per observations over wave)
drop ID										// drop old identifier


global varlist "id wave city EG YB_op SEX IMDATE_op  datetime EDUMAX_CO_TR_ISCED EDUMAX_CO_PL_ISCED  SIT HHSZ FMSIT POL_RC POL_CO LRCSPK LRCWR LRCRD LRCUD PPRC PPCO ACT ACT HOSP_RC WKHARD_RC DSCRFREQ MYLEAVE_RC_op SATIS_RC HM_RC WKHARD_RC HOSP_RC PPCO PPRC WHYECO WHYEDU WHYFFM WHYJFM WHYMAR WHYPOL RELDGR DSCRFREQ ACT EDUFTPT FRCO_RC_op FR1CB FR2CB FR3CB FR1BACK FR2BACK FR3BACK FRN_RC WKH_op JB_RC_op_ISEI CURRJB_RC_op_ISEI" 
keep $varlist
gen data=0


*Step 2: prepare the data for harmonization

*Reason to migrate	
gen reas_economic = WHYECO==1
gen reas_education = WHYEDU==1 
gen reas_family = WHYFFM==1 | WHYJFM==1 | WHYMAR==1
gen reas_political =WHYPOL==1


rename SIT expectation_scip
sort id wave
replace SEX=SEX[_n-1] if id==id[_n-1]
replace IMDATE_op=IMDATE_op[_n-1] if id==id[_n-1]
replace city=city[_n-1] if id==id[_n-1]
replace EDUMAX_CO_PL_ISCED=EDUMAX_CO_PL_ISCED[_n-1] if id==id[_n-1]
replace EDUMAX_CO_TR_ISCED=EDUMAX_CO_TR_ISCED[_n-1] if id==id[_n-1]
replace reas_economic =reas_economic[_n-1] if id == id[_n-1]
replace reas_education =reas_education[_n-1] if id == id[_n-1]
replace reas_family =reas_family[_n-1] if id == id[_n-1]
replace reas_political =reas_political[_n-1] if id == id[_n-1]
replace expectation_scip =expectation_scip[_n-1] if id == id[_n-1]


*Religiosity
recode RELDGR -99/-52=.
revrs RELDGR, 
rename revRELDGR religiosity
drop RELDGR 


*time of migration
rename IMDATE_op immigra_date_scip

*time of interview
gen datetime_year = substr(datetime,1,4)
gen datetime_month = substr(datetime,6,2)
destring datetime_year, replace
destring datetime_month, replace

*age
gen age = datetime_year - YB_op 

*sex
rename SEX sex // 1 male 2 female
recode sex 1=0 2=1
lab def sex 0"Male" 1"Female", replace
lab val sex sex

*group
gen group = .
replace group = 0 if EG == 5
replace group = 1 if EG == 7
lab def group 0 "Poles" 1 "Turks" 2 "Italians" 3 "Syrians", replace
lab val group group


*education: isced
gen isced_co = EDUMAX_CO_PL_ISCED if group == 0
replace isced_co = EDUMAX_CO_TR_ISCED if group == 1
lab val isced_co isced

*language: understand, speak, write, read
recode LRCUD -99/0 = .
recode LRCSPK -99/0 = .
recode LRCRD -99/0 = .
recode LRCWR -99/0 = .

revrs LRCUD, replace
rename LRCUD lang_understand

revrs LRCSPK, replace
rename LRCSPK lang_speak

revrs LRCRD, replace
rename LRCRD lang_read

revrs LRCWR, replace
rename LRCWR lang_write

*labor market
rename ACT main_activity

*political
recode POL_CO -99/0=.
recode POL_RC -99/0=.

revrs POL_CO, replace
rename POL_CO pol_co

revrs POL_RC, replace
rename POL_RC pol_rc

*identification
recode SATIS_RC -99/0=.
revrs SATIS_RC, replace
rename SATIS_RC satisfaction

recode WKHARD_RC -99/0=.
revrs WKHARD_RC, replace
rename WKHARD_RC get_ahead

recode HOSP_RC -99/0=.
revrs HOSP_RC, replace
rename HOSP_RC hospitable 

*social
recode PPCO -99/0=.
recode PPRC -99/0=.
revrs PPCO, replace
rename PPCO spendtime_co
revrs PPRC, replace
rename PPRC spendtime_rc 

*perceived discrimination
recode DSCRFREQ -99/-97 = .
revrs DSCRFREQ, replace
rename DSCRFREQ discrimination

*working
gen working = 1 if main_activity==1
replace working =0 if main_activity>1

*unemployed
gen unemployed =1 if main_activity==2
replace unemployed = 0 if main_activity==1 | (main_activity>=3 & main_activity<=8)
replace unemployed = 0 if EDUFTPT == 1

*Ankunftsdatum
gen migr_year = substr(immigra_date_scip,4,4)
destring migr_year, replace force
gen migr_month = substr(immigra_date_scip,1,2)
destring migr_month, replace

*Date of interview 
gen int_year = substr(datetime,1,4) if data==0
gen int_month = substr(datetime,6,2) if data==0
destring int_year, replace
destring int_month, replace

*time living in Germany
gen time_in_germany = int_month - migr_month + 1 if int_year== migr_year
replace time_in_germany = (12-migr_month+1) + (int_year - migr_year - 1)*12 + int_month if int_year!= migr_year
*drop immigra_date_scip datetime


gen expectation = expectation_scip if expectation_scip>0 & expectation_scip <10
drop expectation_scip 

recode wave 1=0 2=1
lab def wave 0"Wave 1" 1"Wave 2", replace
lab val wave wave

lab def data 0 "SCIP" 1 "ENTRA"
lab val data data
drop EDUFTPT 



*keep data id int_year int_month time_in_germany age sex group isced_co lang_understand lang_speak lang_read lang_write main_activity pol_co pol_rc satisfaction get_ahead hospitable spendtime_co spendtime_rc datetime_year datetime_month wave reas_economic reas_education working reas_family reas_political religiosity discrimination unemployed // isei

order 	id data wave group sex age time_in_germany isced_co 			/// fundamental variables
	int_year int_month migr_year migr_month					/// dates
	lang_understand lang_speak lang_read lang_write 			/// outcome: language
	spendtime_co spendtime_rc 						/// outcome: time spent
	main_activity unemployed 					/// outcome: labor market activity
	pol_co pol_rc 								/// outcome: political interest
	reas_economic reas_education reas_family reas_political 		/// controls: reason to migrate
	religiosity discrimination						/// optional outcomes 1/2
	satisfaction get_ahead hospitable 					/// optional outcomes 2/2
	datetime_year datetime_month int_year int_month expectation				//  background variables

keep 	id data wave group sex age time_in_germany isced_co 			/// fundamental variables
	int_year int_month migr_year migr_month						/// dates
	lang_understand lang_speak lang_read lang_write 			/// outcome: language
	spendtime_co spendtime_rc 						/// outcome: time spent
	main_activity unemployed 					/// outcome: labor market activity
	pol_co pol_rc 								/// outcome: political interest
	reas_economic reas_education reas_family reas_political 		/// controls: reason to migrate
	religiosity discrimination						/// optional outcomes 1/2
	satisfaction get_ahead hospitable 					/// optional outcomes 2/2
	datetime_year datetime_month  int_year int_month expectation			//  background variables


*reshape wide data group sex age time_in_germany isced_co lang_understand lang_speak lang_read lang_write spendtime_co spendtime_rc main_activity working unemployed pol_co pol_rc reas_economic reas_education reas_family reas_political religiosity discrimination satisfaction get_ahead hospitable datetime_year datetime_month, i(id) j(wave)

*gen time_between = time_in_germany1 - time_in_germany0
*reshape long
compress







/*
*Included in previous versions
*Working hours
rename WKH_op workinghours
lab var workinghours "Working Hours"
replace workinghours = . if ACT!=1
recode workinghours -99/-1 =.

*ISEI
gen isei = JB_RC_op_ISEI
recode isei -99/-1=.
replace isei = CURRJB_RC_op_ISEI if isei==.
recode isei -99/-1=.

gen n_co_friends=0 if FRN_RC==1
replace n_co_friends= FRCO_RC_op if n_co_friends==.
recode n_co_friends -99/-52=. 
gen add = .
replace add=1 if FR1CB==1 | FR1BACK==1
replace add=add+1 if (FR2CB==1 | FR2BACK==1) & add!=.
replace add=1 if (FR2CB==1 | FR2BACK==1) & add==.
replace add=add+1 if (FR3CB==1 | FR3BACK==1) & add!=.
replace add=1 if (FR3CB==1 | FR3BACK==1) & add==.
*replace add=. if FR1CB<0 & FR2CB < 0 & FR3CB<0 & FRCO_RC_op<0
replace n_co_friends = add if ((add!=.& add>n_co_friends) | (n_co_friends==.))
*keep n_co_friends FRCO_RC_op add FR*CB FR*BACK

*/
