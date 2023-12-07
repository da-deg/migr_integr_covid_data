*DECISIONS!
*Pruning: 
*drop reas_economic reas_education reas_family reas_political

reshape wide time_in_germany spendtime_rc unemployed pol_rc age language int_year int_month migr_year migr_month stay integr_course language_course, i(id) j(wave)

*If they particpated before wave 1 in a course, they still have participated in wave 2
replace integr_course1=1 if integr_course0==1 & panel!=0
replace language_course1=1 if language_course0==1 & panel!=0
drop if reas_economic ==.
drop if reas_education  ==.
drop if reas_family  ==.
drop if reas_political  ==.


replace panel =1 if data==1

foreach x in time_between id data time_in_germany0 time_in_germany1 integr_course0 language_course0 integr_course1 language_course1{
 drop if `x'==.  & panel!=0
}


*Age: respondents could not be older than 3 years in the second wave
gen a = age1-age0
drop if a<0   & panel!=0
drop if a>=3 & panel!=0
drop a
replace age1=age0


*Age: SCIP sample differed (18-60) compared to ENTRA (18-40)
*Respondents should not be older than 45 at the first interview
tab age0 data
drop if age0 > 45  

*time between: 
tab time_between data
drop if time_between >26 & panel!=0

*time in Germany at first interview:
tab time_in_germany0 data 
drop if time_in_germany0 >35


sort data id
gen id2=_n
drop id
rename id2 id


*Keep observations with complete information!
foreach x in spendtime_rc unemployed pol_rc language {
  drop if `x'0 >10000 & panel!=0
  drop if `x'1 >10000 & panel!=0
}

replace time_in_germany1=. if panel==0
drop if integr_course0 ==.
drop if language_course0 ==.
reshape long time_in_germany spendtime_rc unemployed pol_rc age language int_year int_month integr_course language_course,  i(id) j(wave)



foreach x in id wave age time_in_germany data group sex time_between isced stay0 stay1{
  drop if `x'>10000 & panel!=0
}

foreach x in language pol_rc spendtime_rc unemployed{
  replace `x'=. if `x'>10000 & panel!=0
}
replace time_between = time_between -1 // correction
compress


sort data id panel
drop time_between stay1 int_year int_month migr_year1 migr_month1
foreach x in migr_year0 migr_month0 stay0 age time_in_germany spendtime_rc unemployed pol_rc language data group sex isced{
  replace `x' = `x'[_n-1] if wave==1 & panel==0
  drop if `x' > 1000000
}
drop migr_year0 migr_month0

rename stay0 stay
lab var stay "Expect to stay in Ger."

gen lang_int_course = language_course
replace lang_int_course = 1 if integr_course==1
drop language_course integr_course

lab var lang_int_course "Integr. or lang. course"
