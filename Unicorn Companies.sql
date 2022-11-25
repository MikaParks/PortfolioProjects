
--Look at the top 3 industries for 2019-2021

With top_industries AS(
	Select industry
	      , COUNT(*) as industry_num
	From PortfolioProject..Unicorn_Companies
	where datepart(YYYY, [date joined]) in ('2019', '2020', '2021')
	group by Industry
	order by industry_num desc
	Offset 0 rows fetch first 3 rows only
	),

yearly_rankings AS(
select COUNT(*) AS num_unicorns
		, industry
		, datepart(YYYY, [date joined]) as [year]
		, AVG(cast(valuation_billions as int)) as average_valuation
from PortfolioProject..Unicorn_Companies
group by Industry, datepart(YYYY, [date joined])
	)

Select Industry
	 , [year]
	 , num_unicorns
	 , avg(average_valuation) as average_valuation_billions
From yearly_rankings
where [year] in ('2019', '2020', '2021')
	and industry in (select industry
					from top_industries)
group by industry, num_unicorns, [year], average_valuation
order by industry, [year] desc

Select *
From PortfolioProject..Unicorn_Companies

----------------------------------------------------------------------------------------------------------------

--Create new Valuation column without $ and B

Select
PARSENAME(replace(replace(Valuation, '$',''),'B',''),1) as Valuation_billions
From PortfolioProject..Unicorn_Companies

Alter Table PortfolioProject..Unicorn_Companies
Add Valuation_billions Nvarchar(20);

Update PortfolioProject..Unicorn_Companies
set Valuation_billions = PARSENAME(replace(replace(Valuation, '$',''),'B',''),1)


