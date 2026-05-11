*-----------------------------第一组------------------------------------------------
*（可以）------------------------------高新技术企业--------------------------

cd "D:\AAA数据25.3.3\AAA修改\实证结果\异质性分析结果"

use "D:\AAA数据25.3.3\AAA修改\高新技术企业（人工智能专利）.dta" , clear

xtset Stkcd year


*当年是高新技术企业的取值为1，不是的取值为0
*高新技术企业
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind  if   hightech==1     ,fe
est store yzxhightech1
*非高新技术企业
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback   i.year i.ind  if   hightech==0     ,fe
est store yzxhightech2

ttable2 LnAInumber,by(hightech)
*组间差异系数-0.301***
*esttab yzxhightech1 yzxhightech2 using tableyzx51.rtf,stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)



*（可以）===================================融资约束sa（不是绝对值）==================

cd   "D:\AAA数据25.3.3\AAA修改\实证结果\异质性分析结果"
use "D:\AAA数据25.3.3\AAA修改\修改主回归4（人工智能专利）.dta" , clear

xtset Stkcd year

summ sa, detail
scalar med_sa= r(p50)
gen FC= .
replace FC = 1 if sa > med_sa
replace FC = 0 if sa <= med_sa
*sa数值越大（越接近 0）； 融资约束越弱，数值越小（越负）； 融资约束越强
*融资约束程度相对小（左边列）
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv   Dual  Growth rdpersonratio CR eduback  i.year i.ind  if   FC==1     ,fe
est store yzxfc1
*融资约束程度大
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv   Dual  Growth rdpersonratio CR eduback i.year i.ind  if   FC==0     ,fe
est store yzxfc2

ttable2 LnAInumber,by(FC)
*组间差异系数-0.085***
*esttab yzxfc1 yzxfc2 using tableyzx6.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

esttab yzxhightech1 yzxhightech2 yzxfc1 yzxfc2 using tableyzx1.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

*-----------------------------------第二组-------------------------------------------
*（可以）=====================市场垄断地位============================================

cd "D:\AAA数据25.3.3\AAA修改\实证结果\异质性分析结果"

use "D:\AAA数据25.3.3\AAA修改\市场竞争程度（人工智能专利）.dta", clear

xtset Stkcd year

summ Lerner, detail
scalar med_Lerner= r(p50)

gen Position= .
replace Position= 1 if Lerner > med_Lerner
replace Position = 0 if Lerner<= med_Lerner
*Lerner值越大，表明企业价格—成本加成空间越大， 
*企业勒纳指数大，企业在产品市场中的相对竞争地位（市场势力）越强
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind  if   Position==1     ,fe
est store yzxLerner1
*企业在产品市场中的相对竞争地位（市场势力）越弱
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback i.year i.ind  if   Position==0     ,fe
est store yzxLerner2

ttable2 LnAInumber,by(Position)
*组间差异系数-0.109***
*esttab yzxLerner1 yzxLerner2 using tableyzx09.rtf, stats(N F r2, ) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%12.3f) t


*（可以）==========================信息披露质量kv=============================

cd   "D:\AAA数据25.3.3\AAA修改\实证结果\异质性分析结果"
use "D:\AAA数据25.3.3\AAA修改\信息披露质量KV（人工智能专利）.dta" , clear

xtset Stkcd year
sum KV
summ KV, detail
scalar med_KV= r(p50)
gen infor= .
replace infor = 1 if KV > med_KV
replace infor = 0 if KV <= med_KV
*KV指数越高说明上市公司信息披露质量越低
*信息披露质量越低
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv sa  Dual  Growth rdpersonratio CR eduback  i.year i.ind  if   infor==1     ,fe
est store yzxinfor1
*信息披露质量越高
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv sa  Dual  Growth rdpersonratio CR eduback i.year i.ind  if   infor==0     ,fe
est store yzxinfor2

ttable2 LnAInumber,by(infor)
*组间差异系数0.051***
*esttab yzxinfor1 yzxinfor2 using tableyzx7.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

esttab yzxLerner1 yzxLerner2 yzxinfor1 yzxinfor2 using tableyzx2.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

*-----------------------------------第三组-------------------------------------------
*可以--------------------------------------智慧城市---------------------------------
cd "D:\AAA数据25.3.3\AAA修改\实证结果\异质性分析结果"

use "D:\AAA数据25.3.3\AAA修改\智慧城市智能建造试点（人工智能专利）.dta", clear

xtset Stkcd year

*是智慧城市的取值为1，不是的取值为0
*智慧城市
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback   i.year i.ind  if   INTcity==1     ,fe
est store yzxzhcs1
*非智慧城市
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback   i.year i.ind  if   INTcity==0     ,fe
est store yzxzhcs2

ttable2 LnAInumber,by(INTcity)
*组间差异系数 -0.042***
*esttab yzxzhcs1 yzxzhcs2 using tableyzx08.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)


*可以-------------------------------------省级经营环境指数----------------------------
cd "D:\AAA数据25.3.3\AAA修改\实证结果\异质性分析结果"

use "D:\AAA数据25.3.3\AAA修改\省级经营环境指数（人工智能专利）.dta", clear

xtset Stkcd year

*Index越大表示营商环境越好
*Env=1 为营商环境较好组，Env=0 为营商环境较差组
summ Index, detail
scalar med_Index= r(p50)

gen Env= .
replace Env= 1 if Index > med_Index
replace Env = 0 if Index<= med_Index
*营商环境好
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind  if   Env==1     ,fe
est store yzxEnv1
*营商环境差
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback i.year i.ind  if   Env==0     ,fe
est store yzxEnv2

ttable2 LnAInumber,by(Env)
*组间差异系数 -0.194***
*esttab yzxEnv1 yzxEnv2 using tableyzx013.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

esttab yzxzhcs1 yzxzhcs2 yzxEnv1 yzxEnv2 using tableyzx3.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)


