# Phenotype Phebruary Day 3 – Atrial Fibrillation
# Author: Martin Lavallee
# Date: 2/10/2022

# Forum Link: https://forums.ohdsi.org/t/phenotype-phebruary-day-3-atrial-fibrillation/15791

# Notes: 

# Patrick Ryan developed two Afib cohorts 
#1) Is a simple afib cohort based on Wharton et al. 


# Wharton et al cohort -----------------------------------

# lookup afib icd9cm code 427.31, the only thing given by Wharton et al
afibConcept <- getConceptCodeDetails(conceptCode = '427.31', vocabulary = "ICD9CM", connectionDetails = connectionDetails,
                                     vocabularyDatabaseSchema = vocabularyDatabaseSchema, mapToStandard = TRUE)

#map this to all descendants of afib 
afibCSE <- createConceptSetExpression(conceptSet = afibConcept,
                                      Name = "AFib",
                                      includeDescendants = TRUE)

afibQuery <- createConditionOccurrence(conceptSetExpression = afibCSE, # use afib CSE
                                       attributeList = list(
                                         #create an occurrence start date attribute
                                         createOccurrenceStartDateAttribute(Op = "bt", Value = "2013-01-01", Extent = "2018-03-31")
                                       ))

afibPrimaryCriteria <- createPrimaryCriteria(Name = "Wharton Afib Diagnosis: An AFib Diagnosis between 1/1/13 and 3/31/18",
                                             ComponentList = list(
                                               afibQuery
                                             ),
                                             ObservationWindow = createObservationWindow(PriorDays = 0L, PostDays = 0L),
                                             Limit = "First")

#thats it so lets make the cohort definition
whartonAfibCohort <- createCohortDefinition(Name = "Wharton et al Afib Cohort", 
                                            PrimaryCriteria = afibPrimaryCriteria)
#compile the cohort defintion so that we get the json
whartonAfibCohortJson <- compileCohortDefinition(CohortDefinition = whartonAfibCohort)

#write the wharton Afib Cohort to json folder
readr::write_file(whartonAfibCohortJson, file = "results/day3/json/whartonAfibCohort.json")  


# Subramanya et al Afib ------------------------------


