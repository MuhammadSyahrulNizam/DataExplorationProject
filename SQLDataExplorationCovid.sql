select *
from Dataexplorationproject ..CovidDeaths
where continent is not null
order by 3,4

--select *
--from Dataexplorationproject ..CovidVaccinations
--Order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from Dataexplorationproject ..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in Indonesia
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from Dataexplorationproject ..CovidDeaths
where location = 'indonesia'
and continent is not null
order by 1,2

--Looking at total cases vs Population
--Shows what percentage of population got covid In Indonesia

select location, date,Population, total_cases, (total_cases/Population)*100 as Percentageinfectedpopulation
from Dataexplorationproject ..CovidDeaths
where location = 'indonesia'
order by 1,2

--Looking at Countries with highest Infection Rate Compared to Population

select location, Population, MAX(total_cases) as Highestinfectioncount, MAX((total_cases/Population))*100 as Percentageinfectedpopulation
from Dataexplorationproject ..CovidDeaths
group by location, Population
order by Percentageinfectedpopulation desc


--Showing Countries With Highest Death Count per population

select location,  MAX(cast(total_deaths as int)) as totaldeathcount
from Dataexplorationproject ..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc

--Lets break things down by Continent
--Showing continents with highest death count per population

select continent,  MAX(cast(total_deaths as int)) as totaldeathcount
from Dataexplorationproject ..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc


--Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from Dataexplorationproject ..CovidDeaths
where continent is not null
order by 1,2

--Looking at total population vs Vacctinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(int,Vac.new_vaccinations))OVER (partition by dea.location order by dea.location,dea.date) as peoplevaccinated
from Dataexplorationproject ..CovidDeaths dea join Dataexplorationproject ..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--Using CTE

with popvsvac (continent,location,date,population,new_vaccinations,peoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(int,Vac.new_vaccinations))OVER (partition by dea.location order by dea.location,dea.date) as peoplevaccinated
from Dataexplorationproject ..CovidDeaths dea join Dataexplorationproject ..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
)
select*,(peoplevaccinated/population)*100
from popvsvac



-- Temp Table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
peoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(int,Vac.new_vaccinations))OVER (partition by dea.location order by dea.location,dea.date) as peoplevaccinated
from Dataexplorationproject ..CovidDeaths dea join Dataexplorationproject ..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null

	select*,(peoplevaccinated/population)*100 as peoplevaccinatedpercent
from #percentpopulationvaccinated


--Creating View to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(int,Vac.new_vaccinations))OVER (partition by dea.location order by dea.location,dea.date) as peoplevaccinated
from Dataexplorationproject ..CovidDeaths dea join Dataexplorationproject ..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	
select*
from percentpopulationvaccinated