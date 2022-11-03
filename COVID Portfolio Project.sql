/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select  *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select  *
From PortfolioProject..CovidVaccinations
order by 3,4

-- Select Data

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population

Select location, max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Break down by continent
-- Showing continents with the highest death count per population

Select continent, max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global break down

Select location, max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
	and location not like '%income%'
group by location
order by TotalDeathCount desc

Select sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Economic breakdown

Select location, max(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
	and location like '%income%'
group by location
order by TotalDeathCount desc


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- -- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
