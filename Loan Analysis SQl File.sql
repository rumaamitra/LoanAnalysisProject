select * from dbo.LoanData

--Total loan applications
select count(id) as TotalApplications from dbo.LoanData

--Month to date total applications - calculated over issue date
--Calculations done for latest year
select MONTH(issue_date) as Month, count(*) as MTD_TotalApplications from dbo.LoanData where 
YEAR(issue_date)=(select YEAR(max(issue_date)) from dbo.loanData) and MONTH(issue_date)=(select MONTH(max(issue_date)) from dbo.loanData)
group by YEAR(issue_date),MONTH(issue_date)
--A monthly threshold must have been set by the bank to evaluate performance, compare if our calculated value shows over-achievement, underperformance or as expected
--Also compare the latest MTD applications to the past MTD's from current year as well as from previous years to determine trends and seasonality effect

--MoM growth for applications for current year
with TempTable as(
select YEAR(issue_date) as Year, MONTH(issue_date) as Month,  count(*) as TotalMonthlyApplications, Lag(count(*)) over (order by MONTH(issue_date)) as PrevMonthTotAppl
from dbo.LoanData where YEAR(issue_date)= (select Year(max(issue_date)) from dbo.LoanData) group by YEAR(issue_date),MONTH(issue_date)
)
select Year, Month, TotalMonthlyApplications,   
case
when PrevMonthTotAppl is null then 0
else convert(decimal(5,2),((cast(TotalMonthlyApplications as numeric)-cast(PrevMonthTotAppl as numeric))*100/cast(PrevMonthTotAppl as numeric)))
end as MoM_Growth 
from TempTable

--Total disbursed amount year-wise
select Year(issue_date) as Year, sum(loan_amount) as TotDisbursedAmount from dbo.LoanData group by Year(issue_date) order by Year(issue_date)
--0.435 billion were disbured in loan amount by the bank in 2021

--Month to date disbursed amount for the latest month
select YEAR(issue_date) as Year, MONTH(issue_date) as Month, sum(loan_amount) as MTD_TotalAmtDisbursed from dbo.LoanData where 
YEAR(issue_date)=(select YEAR(max(issue_date)) from dbo.loanData) and MONTH(issue_date)=(select MONTH(max(issue_date)) from dbo.loanData)
group by YEAR(issue_date),MONTH(issue_date)
--Approximately 54 million were disbured in the month of December

--MoM growth for funded amount for current year
with TempTable as(
select YEAR(issue_date) as Year, MONTH(issue_date) as Month,  sum(loan_amount) as TotMonthAmtDisbursed, Lag(sum(loan_amount)) over (order by MONTH(issue_date)) 
as PrevMonthTotDisbur from dbo.LoanData where YEAR(issue_date)= (select Year(max(issue_date)) from dbo.LoanData) group by YEAR(issue_date),MONTH(issue_date)
)
select Year, Month, TotMonthAmtDisbursed,   
case
when PrevMonthTotDisbur is null then 0
else convert(decimal(5,2),((TotMonthAmtDisbursed-PrevMonthTotDisbur)*100/PrevMonthTotDisbur))
end as MoM_Growth 
from TempTable
--The growth rate for December shows significant increase when comparing the same in terms of total applications received
--In situtations like this balancing healthy cash flow could become a challenge. 
--Bank should be able to predict such demands in order to plan and stay prepared

--Total repayment amount received 
--Base for bank's profits 
select Year(issue_date) as Year, sum(total_payment) as TotRepayAmount from dbo.LoanData group by Year(issue_date) order by Year(issue_date)
--Compared to banks disbursed amount of 435757075, it's earning/profit from interest is 37.3 million for the year 2021

--Month to date repayment for the latest month
select YEAR(issue_date) as Year, MONTH(issue_date) as Month, sum(total_payment) as MTD_TotalAmtRepayed from dbo.LoanData where 
YEAR(issue_date)=(select YEAR(max(issue_date)) from dbo.loanData) and MONTH(issue_date)=(select MONTH(max(issue_date)) from dbo.loanData)
group by YEAR(issue_date),MONTH(issue_date)
--Approximately 58.1 million were received in repayment compared to 54 million disbursed. Cash balance of 4.1 million is maintained for December

--MoM growth for repayment amount for current year
with TempTable as(
select YEAR(issue_date) as Year, MONTH(issue_date) as Month,  sum(total_payment) as TotMonthAmtRepayed, Lag(sum(total_payment)) over (order by MONTH(issue_date)) 
as PrevMonthTotRepay from dbo.LoanData where YEAR(issue_date)= (select Year(max(issue_date)) from dbo.LoanData) group by YEAR(issue_date),MONTH(issue_date)
)
select Year, Month, TotMonthAmtRepayed,   
case
when PrevMonthTotRepay is null then 0
else convert(decimal(5,2),((TotMonthAmtRepayed-PrevMonthTotRepay)*100/PrevMonthTotRepay))
end as MoM_Growth 
from TempTable

--Current year average interest rate
select Year(issue_date) as Year, convert(decimal(5,2),avg(int_rate)*100) as AvgInterestRate from dbo.LoanData group by Year(issue_date) order by Year(issue_date)

--Month to date interest rate for the latest month
select YEAR(issue_date) as Year, MONTH(issue_date) as Month, convert(decimal(5,2),avg(int_rate)*100) as MTD_AvgIntRate from dbo.LoanData where 
YEAR(issue_date)=(select YEAR(max(issue_date)) from dbo.loanData) and MONTH(issue_date)=(select MONTH(max(issue_date)) from dbo.loanData)
group by YEAR(issue_date),MONTH(issue_date)
--Interest rate has gone up this month compared to the average rate of 12.05%
--Combining this with the growth rate of disbured amount in Dec, it can be deduced that high value loans have been taken by customers his month 

--Portfolio-wise number of loan applications in the month of December
select purpose, count(*) as Applications from dbo.LoanData where MONTH(issue_date)=12 group by purpose order by Applications desc

--MoM growth interest rate for current year
with TempTable as(
select YEAR(issue_date) as Year, MONTH(issue_date) as Month,  convert(decimal(5,2),avg(int_rate)) as MonthlyIntRate, Lag(avg(int_rate)) over (order by MONTH(issue_date)) 
as PrevMonthIntRate from dbo.LoanData where YEAR(issue_date)= (select Year(max(issue_date)) from dbo.LoanData) group by YEAR(issue_date),MONTH(issue_date)
)
select Year, Month, MonthlyIntRate,   
case
when PrevMonthIntRate is null then 0
else convert(decimal(5,2),((MonthlyIntRate-PrevMonthIntRate)*100/PrevMonthIntRate))
end as MoM_Growth 
from TempTable
--Interest rates started falling from June till November then began rising
--It is noted that int rates are higher in the 1st of the year and they keep growing until May
--Since interest payments are a source of earnings for the bank, it should manage the profits from the 1st half of year to subsidize 
--the cash flows during the 2nd half when rates keep falling and hence lower earnings

--Average Debt to Income ratio
select Year(issue_date) as Year, convert(decimal(5,2),avg(dti)*100) as AvgDTI from dbo.LoanData group by Year(issue_date) order by Year(issue_date)
--A good debt-to-income ratio is below 36%

--Max DTI that the bank has loaned a sum to
select convert(decimal(5,2),DTI*100) DTI, purpose, loan_amount, total_payment from dbo.LoanData where dti=(select max(dti) from dbo.LoanData)
--Bank is doing a good job at assessing and lending to those with good financial capacity to rapay, safeguarding itself 

--Category-wise average debt to income ratio
select purpose, convert(decimal(5,2),avg(dti)*100) as AvgCategoryDTI from dbo.LoanData group by purpose order by AvgCategoryDTI desc

--Month to date DTI ratio for the latest month
select YEAR(issue_date) as Year, MONTH(issue_date) as Month, convert(decimal(5,2),avg(dti*100)) as MTD_DTI from dbo.LoanData where 
YEAR(issue_date)=(select YEAR(max(issue_date)) from dbo.loanData) and MONTH(issue_date)=(select MONTH(max(issue_date)) from dbo.loanData)
group by YEAR(issue_date),MONTH(issue_date)
--This month's DTI maintained around the average

--MoM DTI fluctuation for current year
with TempTable as(
select YEAR(issue_date) as Year, MONTH(issue_date) as Month,  convert(decimal(5,2),avg(dti)) as MonthlyDTI, Lag(avg(dti)) over (order by MONTH(issue_date)) 
as PrevMonthDTI from dbo.LoanData where YEAR(issue_date)= (select Year(max(issue_date)) from dbo.LoanData) group by YEAR(issue_date),MONTH(issue_date)
)
select Year, Month, MonthlyDTI,   
case
when PrevMonthDTI is null then 0
else convert(decimal(5,2),((MonthlyDTI-PrevMonthDTI)*100/PrevMonthDTI))
end as MoM_Growth 
from TempTable

select distinct(loan_status) from dbo.LoanData
--Loan status with 'Fully paid' and 'Current' are categorized as good loan and are good for bank
--Status with 'Charged off' are those who are defaulting on their payments. These lending will hamper bank's profits

--% of good loans and bad loans
select 
((count(case when loan_status in ('Fully Paid','Current') then id end)*100)/count(*)) as GoodLoansPerc, 
((count(case when loan_status='Charged Off' then id end)*100)/count(*)) as BadLoansPerc
from dbo.LoanData

--Category-wise good loan and bad loan %
select purpose,
((count(case when loan_status in ('Fully Paid','Current') then id end)*100)/count(*)) as GoodLoansPerc, 
((count(case when loan_status='Charged Off' then id end)*100)/count(*)) as BadLoansPerc
from dbo.LoanData group by purpose
--Loans taken for starting small business have the highest rate of defaulting
--This could be due to slow growth and lower earning potential hampering revenue generation for repayment
--Bank needs to re-think their assessment strategy when lending for small business set-up

--Total amount disbursed in good loans and bad loans
select 
(sum(case when loan_status in ('Fully Paid','Current') then loan_amount end)) as GoodLoansDisbAmt, 
(sum(case when loan_status='Charged Off' then loan_amount end)) as BadLoansDisbAmt
from dbo.LoanData
--370.2 million in good loans, 65.5 million in bad one's

--Total amount repayment received in good loans and bad loans
select 
(sum(case when loan_status in ('Fully Paid','Current') then total_payment end)) as GoodLoansDisbAmt, 
(sum(case when loan_status='Charged Off' then total_payment end)) as BadLoansDisbAmt
from dbo.LoanData
--435.8 million in good loans. 37.3 million received in bad loans
--The bank earned a profit of 65.6 millions from good loans
--and lost 28.2 million + interest earnings fromthe bad loans this year

--Yearly summary of lending performance categorized by loan status
select loan_status, count(*) TotApplications, sum(loan_amount) TotAmtDisbursed, sum(total_payment) TotRepaymentRec,
round(avg(int_rate)*100,2) AvgIntRate, round(avg(dti)*100,2) AvgDTI from dbo.LoanData group by loan_status order by loan_status
--Note that the one's that defaulted on repayments have higher average interest 

--MTD Performance summary
select YEAR(issue_date) Year, MONTH(issue_date) Month, loan_status, count(*) MTD_Applications, sum(loan_amount) MTD_AmtDisbursed, 
sum(total_payment) MTD_RepaymentRec, round(avg(int_rate)*100,2) MTD_AvgIntRate, round(avg(dti)*100,2) MTD_AvgDTI from dbo.LoanData
where MONTH(issue_date)=(select MONTH(MAX(issue_date)) from dbo.LoanData) group by loan_status, YEAR(issue_date), MONTH(issue_date)
order by loan_status
--Interest rates are higher this month compared to the yerly average

--Monthly trends
select DATENAME(Month, issue_date) Month, count(*) TotApplications, sum(loan_amount) TotAmtDisbursed, sum(total_payment) TotRepaymentRec 
from dbo.LoanData group by DATENAME(Month, issue_date), MONTH(issue_date) order by MONTH(issue_date)
--The no. of applications and loan amount show a gradual increase through the year except for a small drop in Feb

--Regional lending trends
select address_state, count(*) TotApplications, sum(loan_amount) TotAmtDisbursed, sum(total_payment) TotRepaymentRec 
from dbo.LoanData group by address_state order by TotApplications desc

--Term Analysis
select term, count(*) TotApplications, sum(loan_amount) TotAmtDisbursed, sum(total_payment) TotRepaymentRec 
from dbo.LoanData group by term order by term 
--3 year is preferred term for repayment compared to 5 years

--Analysis by employee length
select emp_length, count(*) TotApplications, sum(loan_amount) TotAmtDisbursed, sum(total_payment) TotRepaymentRec 
from dbo.LoanData group by emp_length order by TotApplications desc
--Bank gives most loans to people with longer employment history - sign of financial stability

--Analysis by employee length based on grade
--Grades are risk classifications assigned based on creditworthiness. Higher grade -> Lower risk
select emp_length, grade, count(*) TotApplications, sum(loan_amount) TotAmtDisbursed, sum(total_payment) TotRepaymentRec 
from dbo.LoanData group by emp_length, grade order by TotApplications desc
--Most of the loans given to customers with employment length <=4 yrs belong to grade A/B/C
--Meaning these were low risk loans since the customer had good credit history

--Loan purpose analysis
select purpose, count(*) TotApplications, sum(loan_amount) TotAmtDisbursed, sum(total_payment) TotRepaymentRec 
from dbo.LoanData group by purpose order by TotApplications desc
--Most of the loan applictaions have been for Debt consolidation
--Bank can explore interest rate changes to increase profit earnings from the high demand lending categories

--Home ownership analysis
--It is used as an assessment for collateral availibility
select home_ownership, count(*) TotApplications, sum(loan_amount) TotAmtDisbursed, sum(total_payment) TotRepaymentRec 
from dbo.LoanData group by home_ownership order by TotApplications desc
--Number of applications have been the highest for renters, followed by mortgagers. 
--But higher amount has been disbursed in funds for those currently living in a mortgaged home

--Home ownership analysis based on interest rate
--Home owners usually get loans at lower interset rates because risk of defaulting is lower due to avalibility of collateral
select home_ownership, round(avg(int_rate)*100,2) as AvgIntRate, count(*) TotApplications, sum(loan_amount) TotAmtDisbursed, 
sum(total_payment) TotRepaymentRec from dbo.LoanData group by home_ownership order by AvgIntRate desc 
--Customers with mortagaged and full ownership home show lower interset rate compared to others