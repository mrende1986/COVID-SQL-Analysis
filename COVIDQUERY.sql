SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..['CovidDeaths$']
wHERE continent is not NULL
order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..['CovidDeaths$']
where location like '%states%'
order by 1,2;

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as deathpercentage
FROM [Portfolio Project]..['CovidDeaths$']
order by 1,2;


-- Total Cases vs Total Deaths in the USA
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as deathpercentage
FROM [Portfolio Project]..['CovidDeaths$']
where location like '%states%'
order by 1,2;


-- Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases / population)*100 as deathpercentage
FROM [Portfolio Project]..['CovidDeaths$']
-- where location like '%states%'
order by 1,2;


-- Locations with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) as highestcasenumber, MAX((total_cases / population))*100 as percentofpopulationinfected
FROM [Portfolio Project]..['CovidDeaths$']
-- where location like '%states%'
GROUP BY location, population
order by 4 desc;


-- Countries with the highest death count
SELECT location, MAX(cast(total_deaths as int)) as totaldeathcount
FROM [Portfolio Project]..['CovidDeaths$']
Where continent is not null
GROUP BY location
order by totaldeathcount desc;


-- Death count by Continent
SELECT continent, MAX(cast(total_deaths as int)) as totaldeathcount
FROM [Portfolio Project]..['CovidDeaths$']
Where continent is not null
GROUP BY continent
order by totaldeathcount desc;


-- Percent of COVID patients who died from the disease worldwide (by day)
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Portfolio Project]..['CovidDeaths$']
where continent is not null
group by date
order by 1,2

-- Percent of COVID patients who died from the disease worldwide (total)
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Portfolio Project]..['CovidDeaths$']
where continent is not null
-- group by date
order by 1,2


-- Looking at vaccination table
select *
from [Portfolio Project]..['CovidVaccinations$']


-- Join Deaths and Vaccinations
Select *
from [Portfolio Project]..['CovidDeaths$'] dea
JOIN [Portfolio Project]..['CovidVaccinations$'] vac
    on dea.[location] = vac.[location]
    and dea.[date] = vac.[date]

-- Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from [Portfolio Project]..['CovidDeaths$'] dea
JOIN [Portfolio Project]..['CovidVaccinations$'] vac
    on dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
where dea.continent is not null and dea.[location] like '%States%'
order by 2,3


-- CTE --
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from [Portfolio Project]..['CovidDeaths$'] dea
JOIN [Portfolio Project]..['CovidVaccinations$'] vac
    on dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
where dea.continent is not null and dea.[location] like '%States%'
)

select *, (RollingPeopleVaccinated/population)*100 as percent_vaccinated
from PopvsVac



-- The last query counted both doeses of vacinations. 
-- This query uses People Fully Vaccinated to get a better estimate of the population vaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated, (vac.people_fully_vaccinated/dea.population)*100 as peoplefullyvaccinated
from [Portfolio Project]..['CovidDeaths$'] dea
JOIN [Portfolio Project]..['CovidVaccinations$'] vac
    on dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
where dea.continent is not null and dea.[location] like '%States%'
order by dea.date