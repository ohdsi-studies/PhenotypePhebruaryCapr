# CaprPhenotypePheburary


For Phenotype Pheburary, we are testing out programmatic cohort creation using Capr. This project will be used to debug Capr, assess areas of improvement and provide examples of how to use Capr for cohort creation. To participate in the project please install [`Capr`](https://github.com/OHDSI/Capr), make sure you have access to an OMOP CDM (connecting to vocabulary, clinical and results tables), and that you can write cohorts to a results schema on your backend db. We hope through this project we can address issues with `Capr`, improve analysis pipelines in OHDSI, and that you have fun coding and building cohorts!


# Contributing Project

### Database Connection
Please configure your R session with the `codeToRun.R` file to setup your database connection and database parameters. The code to run is a template and should not be changed. 

### Phenotype Assignment
So as to not overlap phenotypes, please sign out the cohort definitions that you are working on in the `PhenotypePheburaryAssignmentSheet.csv` file. While this is the official list to track the code for main branch of the project, you can work on any assigned phenotype; just save to your own development branch. 

### Code Structure

At the top of each Capr .R script file please create a header section describing the cohort, attributing any prior work, and providing basic information of the development (author, date, title, etc.). See example below. After the header skip straight to the Capr code and omit any package loading and database connection. It is assumed that this is loaded in the `codeToRun.R` before this file. 

```
# Phenotype Phebruary Day 1 – Type 2 diabetes mellitus
# Author: Adam Black
# Date: 2/9/2022

# ATLAS Link: https://forums.ohdsi.org/t/phenotype-phebruary-day-1-type-2-diabetes-mellitus/15764
# Notes: 

# Patrick Ryan developed three Type 2 diabetes definitions for day 1

# The frist is a simple definition.
# People entering at the first condition occurrence of Type 2 diabetes mellitus (diabetes mellitus excluding T1DM and secondary) with at least 365 days of prior continuous observation

# The second definition adds two additional inclusion criteria.
# 1) no prior type 1 diabetes mellitus and 2) no secondary diabetes mellitus

# The third definition adds three additional possible entry events and one inclusion criteria.
# People enter cohort 3 on a T2DM diagnosis or a diabetes drug exposure (excluding insulin), or an HbA1c measurement (using two possible units)

```

Please comment your code communicating the steps you took to build the cohort. If you are using `Capr::writeCaprCall` you do not need to comment, it will automatically render the R code. Use of R markdown is also highly encouraged!

### Saving Work 
When working on a phenotype create a new folder in results labeled dayX where X is the day in February. In this folder create an R folder containing the Capr code used to create a cohort and a json folder to save json file outputs of the cohorts. If you created any custom functions for your R script please save them in a separate clearly labeled file. Any .txt files created using `Capr::writeCaprCall` should be saved to a folder labelled output. 

### Capr Issues 
If you encounter any bugs with Capr, please post an issue first to this repository so that it can be reviewed. After review, the bug may be escalated to an issue in the Capr repository if it is thought to be an issue with the package. Please dont post issues directly to Capr, so that they can be reviewed and discussed first. 


# Organization

This repository is not an R package so it follows a non-standard organizational structure. Please use the Rproj when collaborating but be sure to no upload .Rhistory to any branch in the repository, it should be set in the .gitignore. The organization of the project is subject to change as the project progresses.  The primary folders in this repository are: 

- **results**: this contains the code for each day in Phenotype Pheburary labeled day 1 through day 28.    
  -*R*: contains Capr R code used to create cohort definitions   
  -*json*: contains the json files used to identify the cohort definitions   
  -*output*: contains the txt file outputs from the function `Capr::writeCaprCall`, if it is used   
- **extras**: contains additional files pretaining to the project   
  - `codeToRun.R` template file used to configure your session for the Phenotype Pheburary project   
  - `PhenotypePheburaryAssignmentSheet.csv` file to track and assign phenotypes to developers.   


# Questions

If you have any questions feel free to reach out to either Martin Lavallee (lavalleema@vcu.edu), post an issue in the repository or post on the forum thread for [Capr Phenotype Pheburary](https://forums.ohdsi.org/t/phenotype-phebruary-capr-style). 


