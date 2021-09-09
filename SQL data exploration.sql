USE PortfolioProject

--1.
--ANÁLISIS POR PAÍS
--Seleccionamos los datos a utilizar. 

SELECT location, date, new_cases, total_cases,  total_deaths, population
FROM tbl_COVID_DEATHS
ORDER BY 1,2

GO
--2.
--Observamos la tasa de mortalidad (Casos vs. Muertes)

SELECT location, date, total_cases,total_deaths, (CONVERT (decimal(10,2),(total_deaths/total_cases)*100)) AS Mortality_rt
FROM tbl_COVID_DEATHS
where continent is not null
ORDER BY 1,2

GO
--3.
--Observamos el porcentaje de población infectada por país, a lo largo del tiempo (Población vs. Casos)

SELECT location, date, total_cases, population, (CONVERT (decimal(10,2),(total_cases/population)*100)) AS infected_population
FROM tbl_COVID_DEATHS
where continent is not null
ORDER BY 1,2

GO
--4.
--Observamos el ratio de infección, y los países con la mayor cuenta. 

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count,
CONVERT(decimal(10,2), MAX(((total_cases/population)*100))) AS Percentage_Population_Infected
FROM tbl_COVID_DEATHS
where continent is not null
GROUP BY location, population
ORDER BY Percentage_Population_Infected  desc

GO
--5.
--Observamos los países que presentan la mayor cantidad de fatalidades.  

SELECT location, MAX(cast(total_deaths as int)) as Death_Count_Per_Country
From tbl_COVID_DEATHS
where continent is not null
Group by location
Order By Death_Count_Per_Country desc

GO
--6.
--ANÁLISIS POR CONTINENTE
--Observamos la cuenta de fatalidades por continente. 

// Highest death count

SELECT continent, MAX(cast(total_deaths as int)) as Death_Count_Per_Continent
From tbl_COVID_DEATHS
where continent is not null
Group by continent
Order By Death_Count_Per_Continent desc

GO

--7.
--Preparación de vistas. 

SELECT date, SUM(New_cases) AS Cases, SUM(CAST (New_Deaths as int)) AS Deaths,
CONVERT(decimal(10,2), SUM(CAST (New_Deaths as int))/SUM(new_cases)*100) AS Mortality_Rate
FROM tbl_COVID_DEATHS
where continent is not null
GROUP BY date
ORDER BY 1,2

GO

--8.
--Suma de casos, suma de fatalidades, porcentaje de fatalidades.

SELECT SUM(New_cases) AS Cases, SUM(CAST (New_Deaths as int)) AS Deaths,
CONVERT (decimal(10,2), SUM(CAST (New_Deaths as int))/SUM(new_cases)*100) AS Mortality_Rate
FROM tbl_COVID_DEATHS
where continent is not null
--GROUP BY date
ORDER BY 1,2

GO
--9.
--Población vs. vacunas (Porcentaje vacunado)
WITH Population_vs_Vaccines (continent, location, date, population, new_vaccinations, Rolling_Count_People_Vaccinated)
AS 
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(float, v.new_vaccinations)) 
OVER (partition by d.Location order by d.location, d.date) AS Rolling_Count_People_Vaccinated
FROM tbl_COVID_DEATHS AS D
JOIN tbl_COVID_VACCINATIONS AS V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent IS NOT NULL
)
SELECT *, CONVERT (decimal(10,2),(Rolling_Count_People_Vaccinated/population)*100) AS Percentage__Population_Vaccinated
FROM Population_vs_Vaccines


GO

--10.
--Creación de views


CREATE VIEW Percent_Population_Vaccinated
AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(float, v.new_vaccinations)) 
OVER (partition by d.Location order by d.location, d.date) AS Rolling_Count_People_Vaccinated
FROM tbl_COVID_DEATHS AS D
JOIN tbl_COVID_VACCINATIONS AS V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent IS NOT NULL
group by D.location


GO

--11. 
--Más vistas de valor para exportar y visualizar. 

--Casos, fatalidades y mortalidad global

CREATE VIEW Mortality_Rate_Global
AS
SELECT SUM(New_cases) AS Cases, SUM(CAST (New_Deaths as int)) AS Deaths,
CONVERT (decimal(10,2), SUM(CAST (New_Deaths as int))/SUM(new_cases)*100) AS Mortality_Rate_Global
FROM tbl_COVID_DEATHS
where continent is not null

GO

SELECT * FROM Mortality_Rate_Global

GO

--Suma de fatalidades por continente

CREATE VIEW Death_Count_Per_Continent
AS
SELECT continent, MAX(cast(total_deaths as int)) as Death_Count_Per_Continent
From tbl_COVID_DEATHS
where continent is not null
Group by continent

GO

SELECT * FROM Death_Count_Per_Continent


GO
--Porcentaje de la población infectada por país


CREATE VIEW Infected_Population_Per_Country
AS
SELECT location, population, MAX(total_cases) AS Highest_Infection_Count,
CONVERT(decimal(10,2), MAX(((total_cases/population)*100))) AS Percentage_Population_Infected
FROM tbl_COVID_DEATHS
where continent is not null
GROUP BY location, population

GO

SELECT * FROM Infected_Population_Per_Country
SELECT * FROM Percent_Population_Vaccinated
SELECT * FROM Mortality_Rate_Global
SELECT * FROM Death_Count_Per_Continent
SELECT * FROM Infected_Population_Per_Country
