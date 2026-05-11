*===================================合并数据===================================

* 1. 加载数据
use "D:\AAA数据25.3.3\AAA修改\修改主回归4（人工智能专利）.dta"  ,clear
* 2. 以 stkcd 和 year 为键，与数据1进行 1:1 合并
*merge m:1  year using "D:\AAA数据25.3.3\AAA修改\人工智能采纳程度（已剔除金融STPT已缩尾）.dta"
merge 1:1 Stkcd year using "D:\AAA数据25.3.3\AAA修改\上市公司企业资源配置效率(Richardson模型 )2024-2005年\结果数据（缩尾、剔除STPT与金融业）.dta"
*merge m:1 CITYCODE using "D:\AAA数据25.3.3\A这次一定要显著\主回归\工具变量2\地级市是否为通商口岸的虚拟变量.dta"

* 3. （可选）检查 _merge 变量，如果不需要保留可删除
keep if _merge == 3

drop _merge

* 4. 保存补充后的数据，覆盖原数据2文件
save "D:\AAA数据25.3.3\AAA修改\上市公司企业资源配置效率（人工智能专利）.dta", replace

*===================================描述性统计===================================

*cd   "D:\AAA数据25.3.3\A这次一定要显著\主回归"
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\修改主回归4（人工智能专利）.dta" , clear

drop if Dual ==.
drop if LnAI ==.



*总的描述性统计
sum EDF DDKMV LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio    CR eduback 
logout, save(主要变量描述性统计) word replace dec(3):   ///
            tabstat EDF DDKMV LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio    CR eduback , ///
			stats(N mean sd min p25 median p75 max) c(s) 

*对DD
tabstat EDF DDKMV lnx1 Size Lev EM ROA  NetProfitGrowth  Rec CashFlow BM Board  Balance1 staffnumber pe  Inv  fc  Dual  Growth , stats(N mean sd min p25 median p75 max) c(s) f(%12.3f)

*对EDF
tabstat EDF lnx1 Size Lev EM ROA  NetProfitGrowth  Rec CashFlow BM Board  Balance1 staffnumber pe  Inv  fc  Dual  Growth , stats(N mean sd min p25 median p75 max) c(s) f(%12.3f)


*===================================主回归=======================================

cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\修改主回归4（人工智能专利）.dta" , clear

xtset Stkcd year


*gen AInumber=RInvig+RUmig+RInvjg+RDesjg
*gen LnAInumber=ln(AInumber+1)


*对EDF(AI专利)
xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe

est store zhg1

*对DDKMV(AI专利)
xtreg DDKMV LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe

est store zhg2

esttab zhg1 zhg2 using tablezhg1.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

xtreg EDF3 LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe
esttab , stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)
 
*===================================稳健性检验=======================================
*-----------------------------------熵平衡--------------------------------------------
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\修改主回归4（人工智能专利）.dta" , clear

xtset Stkcd year

*1.构造虚拟变量treat//连续变量要构建treat
summ LnAInumber , detail
scalar med_LnAInumber  = r(p50)

gen treat = .
replace treat = 1 if LnAInumber  > med_LnAInumber
replace treat = 0 if LnAInumber  <= med_LnAInumber


*2.熵平衡检验（负的两星）
*计算权重

ebalance treat Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback ,target(3) keep(熵匹配) replace

*3.加权后回归
reghdfe EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback [pweight=_webal], a(Stkcd year ind) cl(ind)

est store shph1

esttab shph1 using tableshph1.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)




*------------------------------------------安慰剂检验--------------------------------
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\修改主回归4（人工智能专利）.dta" , clear

xtset Stkcd year

xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe
esttab, stats(N F r2, ) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%12.6f) t

*回归系数 -0.010  
*t值      -5.504

cap erase "simulation.dta"

permute LnAInumber beta =_b[LnAInumber] se=_se[LnAInumber] df=e(df_r),reps(500) rseed(123) saving("simulation.dta"):xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe

use "simulation.dta",clear
gen t_value = beta / se
gen p_value = 2*ttail(df,abs(beta/se))


twoway ///
    (kdensity beta, yaxis(1)) ///
    (scatter p_value beta, msymbol(smcircle_hollow) mcolor(black) yaxis(2)), ///
    title("安慰剂检验") ///
    xlabel(-0.02(0.005)0.02) ///
    xtitle("虚假估计系数") ///
    ytitle("估计密度", axis(1)) ///
    ytitle("虚假P值", axis(2) angle(0)) ///
    ylabel(0(100)500, axis(1)) ///
    ylabel(0(1)10, axis(2)) ///
    yscale(range(0 500) axis(1)) ///
    yscale(range(0 10) axis(2)) ///
    xline(-0.010, lwidth(vthin) lp(shortdash)) ///
    yline(0.1, lwidth(vthin) lp(dash) axis(2)) ///
    legend(label(1 "估计密度") label(2 "P值")) ///
    plotregion(style(none)) ///
    graphregion(color(white))


*-------------------------------------替换解释变量------------------------------------
*===================================文本=======================================

cd   "D:\AAA数据25.3.3\AAA修改"
use "D:\AAA数据25.3.3\AAA修改\MertonDD（文本）.dta", clear
drop if Dual == .

xtset Stkcd year
*对EDF(AI总投资)
xtreg EDF lnx1  Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe

est store tihuan1



*===================================人工智能投资======================================

cd   "D:\AAA数据25.3.3\AAA修改"
use "D:\AAA数据25.3.3\AAA修改\修改主回归2（人工智能投资）.dta", clear
drop if Dual == .

xtset Stkcd year
*对EDF(AI总投资)
xtreg EDF AIInvest  Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe
esttab , stats(N F r2, ) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%12.3f) t

est store tihuan2


*---------------------------------人工智能技术创新------------------------------------
cd   "D:\AAA数据25.3.3\AAA修改"
use "D:\AAA数据25.3.3\AAA修改\修改主回归3（人工智能技术创新）.dta", clear
drop if Dual == .

xtset Stkcd year
*对EDF(人工智能技术创新)
xtreg EDF innovation  Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe
esttab , stats(N F r2, ) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%12.3f) t


est store tihuan3


*------------------------------------人工智能采纳-------------------------------------
cd   "D:\AAA数据25.3.3\AAA修改"
use "D:\AAA数据25.3.3\AAA修改\修改主回归1（人工智能采纳）.dta", clear
drop if Dual == .

xtset Stkcd year
*对EDF(人工智能采纳)
xtreg EDF AIadopt  Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe
esttab , stats(N F r2, ) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%12.3f) t

est store tihuan4


esttab tihuan1 tihuan2 tihuan3 tihuan4 using tabletihuanx.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)


*-------------------------------------替换被解释变量----------------------------------
*-----------------------------------Zscore--------------------------------------------
cd   "D:\AAA数据25.3.3\AAA修改"
use "D:\AAA数据25.3.3\AAA修改\替换zs（人工智能专利）.dta", clear
drop if Dual == .

xtset Stkcd year
*对EDF(人工智能技术创新)
xtreg Zscore LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe
est store tihuany1



*-----------------------------------------RLPM--------------------------------------
cd   "D:\AAA数据25.3.3\AAA修改"
use "D:\AAA数据25.3.3\AAA修改\RLPM合并（人工智能专利）.dta", clear
drop if Dual == .

xtset Stkcd year
*对EDF(人工智能技术创新)
xtreg DownsideRisk LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe
est store tihuany2

esttab tihuany1 tihuany2 using tabletihuany.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

*-----------------------------事后违约概率---------------------------------------
cd "D:\AAA数据25.3.3\AAA修改"
use "D:\AAA数据25.3.3\AAA修改\新增多种Violate口径（人工智能专利）.dta", clear

xtset Stkcd year

probit Violate_f LnAInumber Size ROA CashFlow Board Balance1 staffnumber pe Inv sa Dual Growth rdpersonratio CR eduback i.year i.ind , vce(cluster Stkcd)
est store tihuany7

esttab tihuany7 using tabletihuany7.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

*------------------------------------------------------------------------------
cd "D:\AAA数据25.3.3\AAA修改"
use "D:\AAA数据25.3.3\AAA修改\新增多种Violate口径（人工智能专利）.dta", clear

xtset Stkcd year

probit Violate_f LnAInumber Size ROA CashFlow Board Balance1 staffnumber pe Inv sa Dual Growth rdpersonratio CR eduback i.year i.ind , vce(cluster Stkcd)
est store tihuany8

esttab tihuany8 using tabletihuany8.rtf, ///
    stats(N chi2 p ll, fmt(0 3 3 3) labels("N" "Wald chi2" "Prob>chi2" "Log pseudolikelihood")) ///
    nogaps star(* 0.10 ** 0.05 *** 0.01) ///
    b(%9.3f) z(%9.3f) replace
*===================================高阶固定效应============================

*高阶固定效应（行业*年份）

cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\修改主回归4（人工智能专利）.dta" , clear

xtset Stkcd year

xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback   i.year##i.ind ,fe

est store gjgdxyindyear

esttab gjgdxyindyear  using tableindyear.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

*高阶固定效应（省份*年份）

cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\修改主回归4（人工智能专利）.dta" , clear

xtset Stkcd year

xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback   i.year##i.PROVINCECODE ,fe

est store gjgdxyPROyear

esttab gjgdxyPROyear  using tablePROyear.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)


*======================================排除其他政策影响===========================

cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\排除沪港深通（人工智能专利）.dta" , clear

xtset Stkcd year

*沪深港通
xtreg EDF LnAInumber hsgtDID Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe

est store pchsgt1


*------------------------------
*宽带中国
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\宽带中国示范城市（人工智能专利）.dta", clear

xtset Stkcd year
xtreg EDF LnAInumber kdzg Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe

est store pckdzg1

esttab pchsgt1 pckdzg1 using tablepcqtzc1.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

*---------------------------------
*智慧城市
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\智慧城市智能建造试点（人工智能专利）.dta", clear

xtset Stkcd year
xtreg EDF LnAInumber INTcity Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe

est store zhcs1

*---------------------------------
*货币政策
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\排除货币政策（人工智能专利）.dta", clear

xtset Stkcd year
xtreg EDF LnAInumber MPLEV Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe

est store hbzc1

esttab zhcs1 hbzc1 using tablepcqtzc2.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

*-----------------------------------稳健性考虑新冠疫情----------------------------
cd "D:\AAA数据25.3.3\AAA修改\实证结果"

use "D:\AAA数据25.3.3\AAA修改\修改主回归4（人工智能专利）.dta"  , clear

xtset Stkcd year

gen covid = inrange(year, 2020, 2022)   // 2020–2022 为疫情期，可根据样本情况微调
label var covid "COVID-19 pandemic period"


* 只保留非疫情年份做回归（排除特殊事件）
preserve
    keep if covid == 0    // 即 2008–2019 和 2023；根据你样本年份调整
    xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  ///
          i.ind i.year, fe
    est store nob_covid
restore

* 把结果导出
esttab nob_covid using table_robust_covid.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

	  
	  
*====================================工具变量检验（滞后一期）===================
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\修改主回归4（人工智能专利）.dta" , clear

xtset Stkcd year

*======================
* 1. 构造滞后一期的 LnAInumber 作为工具变量
*======================
* 按公司-年份排序
sort Stkcd year

* 生成滞后一期变量
by Stkcd: gen L1_LnAInumber = l.LnAInumber
label var L1_LnAInumber "Lagged AI (t-1)"

* 如果需要，可以把没有滞后一期的首年样本删掉
drop if missing(L1_LnAInumber)


xtreg LnAInumber L1_LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.ind i.year ,fe
est store gjbl1

esttab gjbl1 using tablegjbl1.rtf,  stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

*======================
* 2. 工具变量回归（2SLS）
*    被解释变量：EDF
*    内生变量：LnAInumber
*    工具变量：L1_LnAInumber
*======================
	  
ivreg2 EDF Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback   (LnAInumber=L1_LnAInumber) i.ind i.year i.Stkcd ,first
est store gjbl2
esttab gjbl2 using tablegjbl2.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)


*=============================heckman两阶段=======================================
*行---------------------------------知识产权示范城市----------------------------------
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\heckman知识产权（人工智能专利）.dta", clear

xtset Stkcd year

*xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe

probit AI zscq Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.ind i.year 
est store ms21
predict d,xb
gen IMR1=normalden(d)/normal(d)

sum d IMR1

xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  IMR1 i.ind i.year if AI==1 ,fe
est store ms31
esttab ms21 ms31 using tableheckmanZSCQ_2.rtf, stat( N  F r2) star( * 0.1 ** 0.05 *** 0.01) nogaps b(%6.3f) t



*--------------------------------------高管技术背景-----------------------------------
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\heckman高管信息技术背景（人工智能专利）.dta", clear

xtset Stkcd year

*xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind ,fe

probit AI ITmanager Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.ind i.year 
est store ms21
predict d,xb
gen IMR1=normalden(d)/normal(d)

sum d IMR1

xtreg EDF LnAInumber Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  IMR1 i.ind i.year if AI==1 ,fe
est store ms31
esttab ms21 ms31 using tableheckmanITMANAGER_2.rtf, stat( N  F r2) star( * 0.1 ** 0.05 *** 0.01) nogaps b(%6.3f) t



*======================================机制检验================================
*-----------------------------------知识整合能力1（知识多元化）-----------------------
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\知识整合机制1_知识多元化（人工智能专利）.dta", clear

xtset Stkcd year


* 生成交互项
gen LnAInumber_knowledge =LnAInumber * knowledge
*回归


xtreg EDF  LnAInumber_knowledge LnAInumber knowledge  Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind  ,fe

est store jzknowledge1

*---------------------------知识整合能力2（知识宽度）---------------------------------
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\知识整合机制2_企业知识宽度（人工智能专利）.dta", clear

xtset Stkcd year

 
* 生成交互项
gen LnAInumber_width1=LnAInumber * width1
*回归


xtreg EDF  LnAInumber_width1 LnAInumber width1  Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind  ,fe

est store jzknowledge2



esttab jzknowledge1 jzknowledge2 using tablejzKNOWLDEGE1.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)



*---------------------------------------组织韧性1-------------------------------------
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\韧性机制_组织韧性指标1（人工智能专利）.dta", clear


xtset Stkcd year


* 生成交互项
gen LnAInumber_Res1 =LnAInumber * Res1
*回归

xtreg EDF  LnAInumber_Res1 LnAInumber Res1 Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind  ,fe

est store jzResilience1

*---------------------------------------组织韧性2-------------------------------------
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\韧性机制_组织韧性指标2（人工智能专利）.dta", clear

xtset Stkcd year


* 生成交互项
gen LnAInumber_Res2 =LnAInumber * Res2
*回归

xtreg EDF  LnAInumber_Res2 LnAInumber Res2 Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind  ,fe

est store jzResilience2


*---------------------------------------组织韧性3-------------------------------------
cd   "D:\AAA数据25.3.3\AAA修改\实证结果"
use "D:\AAA数据25.3.3\AAA修改\韧性机制_标准化后的组织韧性指标3（人工智能专利）.dta", clear

xtset Stkcd year

* 生成交互项
gen LnAInumber_z_Res3 =LnAInumber * z_Res3

*回归

xtreg EDF  LnAInumber_z_Res3 LnAInumber z_Res3 Size  ROA  CashFlow Board  Balance1 staffnumber pe  Inv  sa   Dual  Growth rdpersonratio CR eduback  i.year i.ind  ,fe

est store jzResilience3

*原代码（除了3都可以用）
*esttab jzResilience1 jzResilience2 jzResilience3 using tablejzRES1.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

esttab jzResilience3 using tablejzRES1标准化后.rtf, stats(N F r2, fmt(0 3 3)) nogaps star(* 0.10 ** 0.05 *** 0.01) b(%9.3f) t(%9.3f)

