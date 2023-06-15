quietly summarize id								// generate a unique id over both datasets
replace id = `r(max)' + id2 if id==.
drop id2
gen covid = data==1


reshape wide age main_activity datetime_year datetime_month lang_understand lang_speak lang_read lang_write pol_co pol_rc satisfaction get_ahead hospitable spendtime_co spendtime_rc isced_co_entra migr_year migr_month int_year int_month time_in_germany religiosity discrimination unemployed  workinghours expectation working durstay , i(id) j(wave)
gen time_between = int_month1 - int_month0 + 1 if int_year1== int_year0
replace time_between = (12-int_month0+1) + (int_year1 - int_year0 - 1)*12 + int_month1 if int_year1!= int_year0

replace expectation1 = expectation0 if data==1

foreach x in datetime_year0 main_activity0 datetime_year0 datetime_month0 age0 lang_understand0 lang_speak0 lang_read0 lang_write0 pol_co0 pol_rc0 satisfaction0 get_ahead0 hospitable0 spendtime_co0 spendtime_rc0 isced_co_entra0 migr_year0 migr_month0 int_year0 int_month0 time_in_germany0 main_activity1 datetime_year1 datetime_month1 age1 lang_understand1 lang_speak1 lang_read1 lang_write1 pol_co1 pol_rc1 satisfaction1 get_ahead1 hospitable1 spendtime_co1 spendtime_rc1 isced_co_entra1 migr_year1 migr_month1 int_year1 int_month1 time_in_germany1 sex reas_economic reas_education reas_family reas_political group isced_co expectation0 expectation1 covid time_between workinghours0 workinghours1 working0 working1 unemployed0 unemployed1 expectation0 expectation1{
  replace `x' =. if `x' <0
}




reshape long age main_activity datetime_year datetime_month lang_understand lang_speak lang_read lang_write pol_co pol_rc satisfaction get_ahead hospitable spendtime_co spendtime_rc isced_co_entra migr_year migr_month int_year int_month time_in_germany n_co_friends workinghours expectation unemployed, i(id) j(wave)

gen isced=isced_co
replace isced = isced_co_entra if isced_co_entra!=.
recode isced 9/10=8

reshape wide age main_activity datetime_year datetime_month lang_understand lang_speak lang_read lang_write pol_co pol_rc satisfaction get_ahead hospitable spendtime_co spendtime_rc isced_co_entra migr_year migr_month int_year int_month time_in_germany n_co_friends workinghours expectation unemployed, i(id) j(wave)



* Language:
*     SCIP	|	ENTRA		||  Harmonized 1	|  Harmonized 2		|    Harmonized 3
*---------------|-----------------------||----------------------|-----------------------|----------------------------------
*  1 not at all	|  1 not at all		||  1=0     & 1=0	|  1=1 & 1=1		| 1=1  &  1=1
*  2 not well	|  2 not well		||  2=0.33  & 2=0.2	|  2=2 & 2=2		| 2=2  &  2=2
*  3 well	|  3 so and so		||  3=0.66  & 3=0.4	|  3=3 & 4=3		| 3=3  &  3=2 | 3=3 coin flip
*  4 very well	|  4 well		||  4=1	    & 4=0.6	|  4=4 & 5=4		| 4=4  &  4=3
* 		|  5 very well		||	      5=0.8	|	 3=.		| 	  5=4
* 		|  6 native speaker lvl	||            6=1	|	 6=.		| 	  6=.
*---------------|-----------------------||----------------------|-----------------------|----------------------------------


*Zentrale Variablen
*Language
foreach x in lang_understand0 lang_speak0 lang_read0 lang_write0 lang_understand1 lang_speak1 lang_read1 lang_write1{
  gen byte rec1_`x' = `x'
  gen byte rec2_`x' = `x'
  gen rec3_`x' = `x'
  replace rec1_`x' = (rec1_`x'-1)/3 if data==0
  replace rec1_`x' = (rec1_`x'-1)/5 if data==1
  
  recode rec2_`x' 3=. 4=3 5=4 6=. if data==1
  
  recode rec3_`x' 3=2.5 4=3 5=4 6=. if data==1
  gen rng_`x' = runiform(-0.5,0.5)
  replace rng_`x' = -0.5 if rng_`x' <0
  replace rng_`x' = +0.5 if rng_`x' >=0
  replace rec3_`x' = rec3_`x' + rng_`x' if rec3_`x'==2.5
  drop rng_`x'
}

gen language_skill_v1_0 = (rec1_lang_understand0 + rec1_lang_speak0 + rec1_lang_read0 + rec1_lang_write0)/4
gen language_skill_v1_1 = (rec1_lang_understand1 + rec1_lang_speak1 + rec1_lang_read1 + rec1_lang_write1)/4

gen language_skill_v2_0 = rec2_lang_understand0 + rec2_lang_speak0 + rec2_lang_read0 + rec2_lang_write0 - 3
gen language_skill_v2_1 = rec2_lang_understand1 + rec2_lang_speak1 + rec2_lang_read1 + rec2_lang_write1 - 3

gen language_skill_v3_0 = rec3_lang_understand0 + rec3_lang_speak0 + rec3_lang_read0 + rec3_lang_write0 - 3
gen language_skill_v3_1 = rec3_lang_understand1 + rec3_lang_speak1 + rec3_lang_read1 + rec3_lang_write1 - 3

drop rec1* rec2* rec3* 
rename language_skill_v1_0 language0
rename language_skill_v1_1 language1

reshape long language age main_activity datetime_year datetime_month lang_understand lang_speak lang_read lang_write pol_co pol_rc satisfaction get_ahead hospitable spendtime_co spendtime_rc isced_co_entra migr_year migr_month int_year int_month time_in_germany n_co_friends workinghours expectation unemployed, i(id) j(wave)

*Rescale
replace spendtime_rc = (spendtime_rc-1)/5
replace pol_rc = (pol_rc-1)/3

lab drop revPOL_RC revPPRC

*relevant variables:
*id wave data
*main: language, working, spendtime, political interest
*controls: age, sex, education, time since arrival, time between panel waves, intention to stay 

recode isced 0/2=0 3/6=1 7/10=2

gen stay = expectation==1
replace stay = . if expectation==.

keep 	id wave data ///
	group language pol_rc unemployed spendtime_rc ///
	int_year int_month migr_year migr_month ///
	age sex isced time_in_germany time_between reas_economic reas_education reas_family reas_political stay

lab var stay "Expect to stay"
lab var id "Identifier"	
lab var time_in_germany "Time living in Germany"
lab var spendtime_rc "Time spent with Germans"
lab var unemployed "Unemployed"
lab var pol_rc "Interest in German politics"
lab var age "Age at W1"
lab var data "Dataset"
lab var group "Group"
lab var sex "Sex"
lab var reas_economic "Migr. Reason: Econ."
lab var reas_education "Migr. Reason: Educ." 
lab var reas_family "Migr. Reason: Fam." 
lab var reas_political "Migr. Reason: Pol." 
lab var time_between "Time between interviews"
lab var isced "Education"
lab var language "German Language Skills"
lab var unemployed "Unemployment"
lab def isced 1 "Educ: Medium (Ref: Low)" 2 "Educ: High (Ref: Low)", replace
lab val isced isced
lab var stay "Exp. to stay in Ger."


compress
