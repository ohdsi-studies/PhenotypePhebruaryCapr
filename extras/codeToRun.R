#codeToRun


#Participants should run this could at the start of their analysis 

#All necessary R libraries have been installed into the renv. Please
#post an issue if missing any R packages.

## load libraries
library(Capr) #used to build cohort definitions
library(DatabaseConnector) # used to access the db with OMOP data
library(SqlRender) #used to conver standardized sql to implementable sql suitable to your db connection
library(tidyverse) #data manipulation tools
library(CohortGenerator) #tool to generate cohorts on results schema
library(CohortDiagnostics) #tool to analyze cohorts
library(CirceR) # tool to convert json of cohort definition into sql 

# create connection details

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = '<dbms>', #dbms you are using (i.e. postgresql, sql server)
  server = '<server>', #the name of the server with OMOP data
  user = '<user>', #your user credential to access db
  password = '<password>', #your password credential to acces db
  port = '<port>'#,unquote for more options #the db port postgresql uses 5432 for example
  
  #other options for createConnectionDetails see documentation
  #extraSettings,
  #oracleDriver,
  #connectionString,
  #pathToDriver
)

#set schemas for writing and populating

#set vocabulary database schema
vocabularyDatabaseSchema <- "<vocabularyDatabaseSchema>" #schema that holds vocabulary tables
cdmDatabaseSchema <- "<cdmDatabaseSchema>" #schema that holds cdm, used for query results 
cohortDatabaseSchema <- "<cohortDatabaseSchema>" #schmea that has results, where you write out cohort results



