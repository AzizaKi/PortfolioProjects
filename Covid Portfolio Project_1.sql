--The following queries were made analyzing data about Covid-19 cases, vaccinations, and deaths from 2020 and 2021 





Select * 
From portfolioproject..coviddeaths
where continent is not null
order by 3,4

--select * 
--From portfolioproject..covidVaccination
--order by 3,4


--Select Data that we are going to be using


Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioproject..coviddeaths

-- Looking at the Total Cases VS Total Deaths
-- Shows the likelihood of dying if you contract covid in your country


Select Location, date, total_cases, total_deaths,(total_deaths/total_cases) *100 AS DeathPercentage
From portfolioproject..coviddeaths
WHERE location LIKE '%states%'
Order by 1,2


--Looking at Total Cases VS Population
--Shows what percentage of population got covid

Select Location, date, total_cases,Population, (total_cases/population) *100 AS PercentPopulationInfected
From portfolioproject..coviddeaths
--WHERE location LIKE '%states%'
Order by 1,2



--Looking at countries with highest infection rate compared to population

Select Location, Population, Max(total_cases) AS HighestInfectionCount,  Max((total_cases/population)) *100 AS PercentPopulationInfected
From portfolioproject..coviddeaths
--WHERE location LIKE '%states%'
Group by Location , Population
Order by PercentPopulationInfected Desc


-- Showing countries with the highest Death Count per Population

Select Location, Max(cast(total_deaths as bigint)) as totalDeathCount
From portfolioproject..coviddeaths
--WHERE location LIKE '%states%'
where continent is not null
Group by Location 
Order by Totaldeathcount Desc


--Lets break things down by continent 



--Showing continent with the highest death count pe

Select continent, Max(cast(total_deaths as bigint)) as totalDeathCount
From portfolioproject..coviddeaths
--WHERE location LIKE '%states%'
where continent is not null
Group by continent 
Order by Totaldeathcount Desc


-- Global numbers


Select date, SUM(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths , sum(cast(new_deaths as int))/sum(new_cases) * 100 AS 
DeathPercentage
From portfolioproject..coviddeaths
WHERE continent is not null
Group by date
Order by 1,2



--Calculate the death percentage across the world

Select SUM(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths , sum(cast(new_deaths as int))/sum(new_cases) * 100 AS 
DeathPercentage
From portfolioproject..coviddeaths
WHERE continent is not null
Order by 1,2

-- looking at total population VS vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 

from portfolioproject..covidDeaths dea
JOIN portfolioproject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2, 3

-- USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from portfolioproject..covidDeaths dea
JOIN portfolioproject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3
)
select * , (RollingPeopleVaccinated/population) *100
from PopvsVac



-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 

from portfolioproject..covidDeaths dea
JOIN portfolioproject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3

select * , (RollingPeopleVaccinated/population) *100
from #PercentPopulationVaccinated


--Creating view to store data later for visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 

from portfolioproject..covidDeaths dea
JOIN portfolioproject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3


select*
from PercentPopulationVaccinated


