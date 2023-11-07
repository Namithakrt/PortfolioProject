select*
from PortfolioProject..CovidDeath

select *
from PortfolioProject..CovidDeath
order by 3,4

--select data that we are using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeath
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathRatePercent
from PortfolioProject..CovidDeath
order by 1,2

select location,date,total_cases,total_deaths,(CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathRatePercent
from PortfolioProject..CovidDeath
where location like '%states%'
 and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of populatin got covid

select location,date,total_cases,population,(CAST(total_cases as float)/population)*100 as InfectedPopulationPercent
from PortfolioProject..CovidDeath
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location,population,Max(total_cases) as HighestInfectionCount,MAX((CAST(total_deaths as int)/population))*100 as InfectedPopulationPercent
from PortfolioProject..CovidDeath
--where location like '%states%'
group by population,Location
order by InfectedPopulationPercent desc

--showing countries with highest death count per population

select location,Max(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc

--Let's break thing s down by Continent


select continent,Max(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


select location,Max(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--where location like '%states%'
where continent is null
group by Location
order by TotalDeathCount desc

--showing continents with highest death count per population 

select continent,Max(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select date,sum(new_cases) from PortfolioProject..CovidDeath
where continent is not null
group by date
order by 1,2

select date,sum(new_cases) as cases,sum(cast(new_deaths as int)) as deaths from PortfolioProject..CovidDeath
where continent is not null
group by date
order by 1,2,

select date,sum(new_cases) as cases,sum(cast(new_deaths as int)) as deaths,
case 
     when sum(new_cases) = 0 then null 
     else sum(cast(new_deaths as int))/sum(new_cases)*100 
end as DeathPercent from PortfolioProject..CovidDeath
where continent is not null
group by date
order by 1,2

select sum(new_cases) as cases,sum(cast(new_deaths as int)) as deaths,
case 
     when sum(new_cases) = 0 then null 
     else sum(cast(new_deaths as int))/sum(new_cases)*100 
end as DeathPercent 
from PortfolioProject..CovidDeath
where continent is not null
--group by date
order by 1,2


/* Covid Vaccination*/

select * from PortfolioProject..CovidVaccination


--looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location)
from PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location
AND dea.date=vac.date
where dea.continent is not null
order by 2,3

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location,dea.Date)
from PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location
AND dea.date=vac.date
where dea.continent is not null
order by 2,3

--create CTE

with PopvsVac (Continent,Location,Date,Population,New_Vaccination,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location,dea.Date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location
AND dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

--  TEMP TABLE

--drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location,dea.Date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location
AND dea.date=vac.date
--where dea.continent is not null


select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations

create view  PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location,dea.Date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location
AND dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated