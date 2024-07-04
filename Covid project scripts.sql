select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


Change the columns type to perform some maths operations
alter table PortfolioProject..CovidDeaths
alter column total_cases FLOAT

alter table PortfolioProject..CovidDeaths
alter column total_deaths FLOAT

alter table PortfolioProject..CovidDeaths
alter column new_cases float

--Shows the percentage of deaths from all cases in Tunisia
select location,date,total_cases,total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where total_cases<>0 and location like'%tunisia%'
order by 1,2

--Shows the percentage of deaths from all cases in Tunisia
select location,date,total_cases,total_deaths, population, (total_cases/population)*100 as CasesRatio 
from PortfolioProject..CovidDeaths
order by 1,2

--Shows countries with the highest cases ratio
select location, population, MAX(total_cases) as MaxCases, MAX((total_cases/population)*100) as HighestCasesRatio
from PortfolioProject..CovidDeaths
group by location, population
order by 4 desc
 
-- Shows the countries with the highest death count
select location, max(total_deaths) as DeathCount
from PortfolioProject..CovidDeaths
group by location
order by DeathCount desc

--Group by continent
select continent, max(total_deaths) as DeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by DeathCount desc

--Show continent with highest death count per population
select continent, max(total_deaths/ population)*100 as DeathCountPop
from PortfolioProject..CovidDeaths
group by continent

--Global stats
select date, sum(new_cases) as DailyCases,sum(cast(new_deaths as float)) as TotalDailyDeaths, (sum(cast(new_deaths as float))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where new_cases<>0
group by date
order by date 


--Now let's move to the Vaccination dataset
with PopVsVacc (Continent, Location, Date,  New_vaccinations, Population,CumulativeVaccins)
as
(
select dea.continent, dea.location,dea.date,  vacc.new_vaccinations, dea.population,
sum(convert(float, new_vaccinations)) over (partition by dea.location order by dea.location,dea.date )
as CumulativeVaccins
from PortfolioProject..CovidVaccination vacc
join PortfolioProject..CovidDeaths dea
    on dea.date=vacc.date 
    and dea.location= vacc.location
--order by location, date 
)
select *, (CumulativeVaccins/Population)*100 as VaccinPercentage
from PopVsVacc

--Create temp table

CREATE TABLE #PercPeopleVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
New_vaccinations float,
Population float,
CumulativeVaccins float
)


insert into #PercPeopleVaccinated
select dea.continent, dea.location,dea.date,  vacc.new_vaccinations, dea.population,
sum(convert(float, new_vaccinations)) over (partition by dea.location order by dea.location,dea.date )
as CumulativeVaccins
from PortfolioProject..CovidVaccination vacc
join PortfolioProject..CovidDeaths dea
    on dea.date=vacc.date 
    and dea.location= vacc.location

select *, (CumulativeVaccins/Population)*100 as VaccinPercentage
from #PercPeopleVaccinated
where Population<>0





-- Drop the view if it already exists
IF OBJECT_ID('PercentagePeopleVaccinated', 'V') IS NOT NULL
    DROP VIEW PercentagePeopleVaccinated;
GO

--CREATE VIEW to store data for later visualization
CREATE VIEW PercentagePeopleVaccinated AS 
SELECT 
    dea.continent, 
    dea.location, 
    dea.date,  
    vacc.new_vaccinations, 
    dea.population,
    SUM(CONVERT(FLOAT, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccins
FROM 
    PortfolioProject..CovidVaccination vacc
JOIN 
    PortfolioProject..CovidDeaths dea
    ON dea.date = vacc.date 
    AND dea.location = vacc.location;
GO


--Check the existance of the view
SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'PercentagePeopleVaccinated';

SELECT * FROM PercentagePeopleVaccinated;
