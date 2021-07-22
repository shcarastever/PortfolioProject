Select *
from model..covidvacc$_xlnm#_FilterDatabase
order by 3,4


select *
from model..covidvacc$_xlnm#_FilterDatabase
where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from coivddeath$
order by 1,2

--Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from coivddeath$
where location like'%states%'
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population go covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentpopulationInfected
from coivddeath$
where location like'%states%'
order by 1,2

-- Looking at counties with highest infection rate compared to population

select location, population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentpopulationInfected
from coivddeath$
--where location like'%states%'
Group by location, population
order by PercentpopulationInfected desc

--Braking it down by continent

select location, Max(cast(Total_deaths as int)) as Totaldeathcount
from coivddeath$
--where location like'%states%'
where continent is null
Group by location
order by totaldeathcount desc




-- showing conuntries with highest death count per population

select location, Max(cast(Total_deaths as int)) as Totaldeathcount
from coivddeath$
--where location like'%states%'
where continent is not null
Group by location
order by totaldeathcount desc


--Global Numbers


select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from coivddeath$
--where location like'%states%'
where continent is not null
--Group by date
order by 1,2


--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated, 
from coivddeath$ dea
join covidvacc$_xlnm#_FilterDatabase vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (continent, Location, Date, Population, new_vaccintaions, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coivddeath$ dea
join covidvacc$_xlnm#_FilterDatabase vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table

Drop table if exists #PrecentPopulationVaccinated
Create Table #PrecentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PrecentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coivddeath$ dea
join covidvacc$_xlnm#_FilterDatabase vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PrecentPopulationVaccinated


--Creating View to store data for later visualizations

Create View percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coivddeath$ dea
join covidvacc$_xlnm#_FilterDatabase vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

