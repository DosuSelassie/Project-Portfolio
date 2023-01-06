--Exploratory Data Analysis on Covid Data
--Death rate across countries in Africa only
select location,SUM(total_cases) as Overall_cases_toll,
SUM(cast(total_deaths as int)) as Overall_death_toll,
(SUM(cast(total_deaths as int))/SUM(total_cases))* 100 as Death_Rate 
from [portfolio project]..CovidDeath$
where continent is not null and continent ='Africa'
Group by location
order by Death_Rate DESC

--infection rate as per population across countries in Africa only
select location,population,
MAX(total_cases) as Cases_toll,
(MAX(total_cases)/population) as Infection_rate 
from [portfolio project]..CovidDeath$
where continent is not null and continent ='Africa'
Group by location,population
order by infection_rate DESC


--death rate as per population across Africa only
select location,population,
MAX(cast(total_deaths as int)) as Death_toll,
(MAX(cast(total_deaths as int))/population)* 100 as Death_rate 
from [portfolio project]..CovidDeath$
where continent is not null and continent ='Africa'
Group by location,population
order by Death_rate DESC

--infection cases cases by continents
select continent,
SUM(total_cases) as  Cases_toll
from [portfolio project]..CovidDeath$
where continent is not null
Group by continent
order by Cases_toll DESC


--Death tolls by continents
select continent,
SUM(cast(total_deaths as float)) as  Death_toll
from [portfolio project]..CovidDeath$
where continent is not null
Group by continent
order by Death_toll DESC

--Global numbers
select SUM(new_cases) as Total_cases,
SUM(convert(float,new_deaths)) as Total_deaths,
(SUM(convert(float,new_deaths))/SUM(new_cases))*100 as Death_rate
from [portfolio project]..CovidDeath$
where continent is not null
order by 1,2


--vaccinations in Africa
select cd.continent,cd.date,cd.location,
cd.population,cv.new_vaccinations,
SUM(CONVERT(float,cv.new_vaccinations)) OVER 
(Partition by cd.location Order by cd.location,cd.date) as RollingVac
from [portfolio project]..CovidDeath$ as cd
join [portfolio project]..CovidVaccination$ as cv
 on cd.location = cv.location
 and cd.date = cv.date
 where cd.continent is not null and cd.continent = 'Africa'
 order by 3,2

 --Vaccination Rate in Africa
 --CTE
 With Pop_vs_Vac(Continent,Date,Location,Population,New_Vaccinations,RollingVac)
 as
(
select cd.continent,cd.date,cd.location,
cd.population,cv.new_vaccinations,
SUM(CONVERT(float,cv.new_vaccinations)) OVER 
(Partition by cd.location Order by cd.location,cd.date) as RollingVac
from [portfolio project]..CovidDeath$ as cd
join [portfolio project]..CovidVaccination$ as cv
 on cd.location = cv.location
 and cd.date = cv.date
 where cd.continent is not null and cd.continent = 'Africa'
 --order by 3,2
 )
select *,(RollingVac/Population) * 100 as Vac_Rate
from Pop_vs_Vac
order by Vac_Rate desc

--Creating views for visualization
Create View Infection_rate as
select location,population,
MAX(total_cases) as Cases_toll,
(MAX(total_cases)/population) as Infection_rate 
from [portfolio project]..CovidDeath$
where continent is not null and continent ='Africa'
Group by location,population
--order by infection_rate DESC




