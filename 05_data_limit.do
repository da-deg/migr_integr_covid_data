*DECISIONS!
*Pruning: 
drop reas_economic reas_education reas_family reas_political
reshape wide time_in_germany spendtime_rc unemployed pol_rc age language int_year int_month, i(id) j(wave)

foreach x in time_between id data time_in_germany0 time_in_germany1{
 drop if `x'==.
}


*Age: respondents could not be older than 3 years in the second wave
gen a = age1-age0
drop if a<0
drop if a>=3
drop a
replace age1=age0

*Age: SCIP sample differed (18-60) compared to ENTRA (18-40)
*Respondents should not be older than 45 at the first interview
tab age0 data
drop if age0 > 45

*time between: 
tab time_between data
drop if time_between >26

*time in Germany at first interview:
tab time_in_germany0 data 
drop if time_in_germany0 >35


sort data id
gen id2=_n
drop id
rename id2 id


*Keep observatiosn with complete information!
foreach x in spendtime_rc unemployed pol_rc language {
  drop if `x'0 >10000
  drop if `x'1 >10000
}


reshape long time_in_germany spendtime_rc unemployed pol_rc age language int_year int_month, i(id) j(wave)

foreach x in id wave age time_in_germany data group sex time_between isced stay{
  drop if `x'>10000
}

foreach x in language pol_rc spendtime_rc unemployed{
  replace `x'=. if `x'>10000
}
replace time_between = time_between -1 // correction
compress
