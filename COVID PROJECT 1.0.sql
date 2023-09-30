Select*
From [Portfolio Project]..['Covid Deaths]
Order by 3,4

--Select*
--From [Portfolio Project]..['Covid Vaccinations]
--Order by 3,4

--Select  Data that we we are going to be using

Select location, date, total_cases, new_cases,total_deaths,population
From [Portfolio Project]..['Covid Deaths]
Order by 1,2

--Looking at Total cases vs Total Deaths

Select location, date, total_cases, new_cases,total_deaths,(total_deaths/total_cases)
From [Portfolio Project]..['Covid Deaths]
Order by 1,2
--Shows likelihood of dying if you contract covid in you country

Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
From [Portfolio Project]..['Covid Deaths]
where location like '%States'
Order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of population got covid

Select location, date,population, total_cases,(total_deaths/population)*100 as Deathpercentage
From [Portfolio Project]..['Covid Deaths]
--where location like '%States'
Order by 1,2

--Looking at Countries with highest Infection Rate compared to population

Select location,population, MAX(total_cases) as HightestInfectionCount,MAX(total_deaths/population)*100 as percentpopulationInfected
From [Portfolio Project]..['Covid Deaths]
--where location like '%States'
Group by location,population
Order by percentpopulationInfected

Select location,population, MAX(total_cases) as HightestInfectionCount,MAX(total_deaths/population)*100 as percentpopulationInfected
From [Portfolio Project]..['Covid Deaths]
--where location like '%States'
Group by location,population
Order by percentpopulationInfected desc

--Showing the countries with highest death count  per population

Select location, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..['Covid Deaths]
--where location like '%States'
where continent is null
Group by location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['Covid Deaths]
--where location like '%States'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Showing the continent with highest death count  per population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['Covid Deaths]
--where location like '%States'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select  date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
From [Portfolio Project]..['Covid Deaths]
--where location like '%States'
where continent is not null
Order by 1,2

Select  date, SUM(new_cases) --, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From [Portfolio Project]..['Covid Deaths]
--where location like '%States'
where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) /SUM(new_cases)*100 as Deathpercentage
From [Portfolio Project]..['Covid Deaths]
--where location like '%States'
where continent is not null
--Group by date
Order by 1,2



Select*
From [Portfolio Project]..['Covid Deaths] dea
join [Portfolio Project]..['Covid Vaccinations] vac
 on dea.location=vac.location
 and dea.date = vac.date


 --Looking at total population vs vaccination


 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project]..['Covid Deaths] dea
join [Portfolio Project]..['Covid Vaccinations] vac
 on dea.location=vac.location
 and dea.date = vac.date
 where dea.continent is not null
 Order by 2,3

 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population) *100
From [Portfolio Project]..['Covid Deaths] dea
join [Portfolio Project]..['Covid Vaccinations] vac
 on dea.location=vac.location
 and dea.date = vac.date
 where dea.continent is not null
 Order by 2,3


 --USE CTE

 with PopvsVac (continent,location,Date,population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (
 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population) *100
From [Portfolio Project]..['Covid Deaths] dea
join [Portfolio Project]..['Covid Vaccinations] vac
 on dea.location=vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --Order by 2,3
 )

 Select*,(RollingPeopleVaccinated/population)*100
 from PopvsVac

 --TEMP TABLE
 DROP Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )


 Insert into #PercentPopulationVaccinated
 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population) *100
From [Portfolio Project]..['Covid Deaths] dea
join [Portfolio Project]..['Covid Vaccinations] vac
 on dea.location=vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --Order by 2,3


  Select*,(RollingPeopleVaccinated/population)*100
 from #PercentPopulationVaccinated

 --Create View to store data for later Visualizations

 Create View PercentPopulationVaccinated as

 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population) *100
From [Portfolio Project]..['Covid Deaths] dea
join [Portfolio Project]..['Covid Vaccinations] vac
 on dea.location=vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --Order by 2,3

 Select *
 from PercentPopulationVaccinated