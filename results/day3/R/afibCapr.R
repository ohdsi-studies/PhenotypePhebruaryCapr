# Phenotype Phebruary Day 3 – Atrial Fibrillation
# Author: Martin Lavallee
# Date: 2/10/2022

# Forum Link: https://forums.ohdsi.org/t/phenotype-phebruary-day-3-atrial-fibrillation/15791

#load inst files
source("results/day3/inst/R/afibFunctions.R")

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

#Need to add attrial flutter to concept set expression
aFlutterConcept <- getConceptCodeDetails(conceptCode = '427.32', vocabulary = "ICD9CM", connectionDetails = connectionDetails,
                                     vocabularyDatabaseSchema = vocabularyDatabaseSchema, mapToStandard = TRUE)

afibCSESubramanya <- addConceptToCSE(afibCSE, addition = aFlutterConcept, includeDescendants = TRUE)

#create inpatient concept set expression
inpatientCSE <- getConceptIdDetails(conceptIds = c(9201, 262), connectionDetails = connectionDetails, 
                                  vocabularyDatabaseSchema = vocabularyDatabaseSchema) %>%
  createConceptSetExpression(Name = "Inpatient Visit", includeDescendants = TRUE)

#create outpatient concept set expression
outpatientCSE <- getConceptIdDetails(conceptIds = c(9202, 9203), connectionDetails = connectionDetails, 
                                 vocabularyDatabaseSchema = vocabularyDatabaseSchema) %>%
  createConceptSetExpression(Name = "Outpatient or ER Visit", includeDescendants = TRUE)


#Based on Patrick Ryan interpretation to generalize the phenotype
#Subramanya et al target: 
# - one Afib diag occurring in a hospital admission OR
# - two Afib diag occuring in an outpat or ER visit separated by 7d to 365d

#start by setting the hospitalization
#an inpatient visit occurring any time before and ending after initial afib
inpatientQuery <- createVisitOccurrence(conceptSetExpression = inpatientCSE)
inpatientCount <- createCount(Query = inpatientQuery,
                              Logic = "at_least",
                              Count = 1,
                              Timeline = createTimeline(StartWindow = createWindow(StartDays = "All",
                                                                                   StartCoeff = "Before",
                                                                                   EndDays = 0,
                                                                                   EndCoeff = "After"),
                                                        EndWindow = createWindow(StartDays = 0, 
                                                                                 StartCoeff = "Before",
                                                                                 EndDays = "All",
                                                                                 EndCoeff = "After",
                                                                                 EventStarts = FALSE)))


#next create the 2 outpat visits separated by 7d to 365d
#to make the 2 outpat visits we need to do some nesting
#want an outpat visit with a nesting criteria that an Afib diag occurred from an outpat visit
#So we need to create a Group where it contains all of
#outpat visit correlated with a second afib diag that is correlated with another outpat visit

#lets draw a picture
png(file = "results/day3/output/AfibOutpatFigure.png", width = 600, height = 400)
drawAfibOutpatFig()
dev.off()

#with this plot in mind lets first create an outpatient query

secondOutpatientQuery <- createVisitOccurrence(conceptSetExpression = outpatientCSE)
secondOutpatientCount <- createCount(Query = secondOutpatientQuery ,
                               Logic = "at_least",
                               Count = 1,
                               Timeline = createTimeline(StartWindow = createWindow(StartDays = "All",
                                                                                    StartCoeff = "Before",
                                                                                    EndDays = 0,
                                                                                    EndCoeff = "After"),
                                                         EndWindow = createWindow(StartDays = 0, 
                                                                                  StartCoeff = "Before",
                                                                                  EndDays = "All",
                                                                                  EndCoeff = "After",
                                                                                  EventStarts = FALSE)))
secondOutpatientGroup <- createGroup(Name = "Outpatient group",
                               type = "ALL",
                               criteriaList = list(secondOutpatientCount))


#create a nesting of afib with outpatient (this is the subsequent visit)
subseqAfibOutpatQuery <- createConditionOccurrence(conceptSetExpression = afibCSESubramanya,
                                                   attributeList = list(
                                                     createCorrelatedCriteriaAttribute(Group = secondOutpatientGroup)
                                                   ))
subseqAfibOutpatCount <- createCount(Query = subseqAfibOutpatQuery,
                                     Logic = "at_least", Count = 1,
                                     Timeline = createTimeline(StartWindow = createWindow(StartDays = 7,
                                                                                          StartCoeff = "After",
                                                                                          EndDays = 365,
                                                                                          EndCoeff = "After")))
subseqAfibOutpatGroup <- createGroup(Name = "Subsequent Afib Diag on Outpatient visit 7-365 days after 1st",
                                     type = "ALL",
                                     criteriaList = list(subseqAfibOutpatCount))

#now nest this with the first outpatient visit for afib

bothOutpatientQuery <- createVisitOccurrence(conceptSetExpression = outpatientCSE,
                                              attributeList = list(
                                                createCorrelatedCriteriaAttribute(
                                                  Group = subseqAfibOutpatGroup
                                                )
                                              ))

bothOutpatientCount <- createCount(Query = bothOutpatientQuery,
                                    Logic = "at_least", 
                                    Count = 1,
                                    Timeline = createTimeline(StartWindow = createWindow(StartDays = "All",
                                                                                         StartCoeff = "Before",
                                                                                         EndDays = 0,
                                                                                         EndCoeff = "After"),
                                                              EndWindow = createWindow(StartDays = 0, 
                                                                                       StartCoeff = "Before",
                                                                                       EndDays = "All",
                                                                                       EndCoeff = "After",
                                                                                       EventStarts = FALSE)))
#turn into group so that it can be part of a correlated criteria
bothOutpatientGroup <- createGroup(Name = "2 Outpatient Visits for Afib within 7 to 365 days apart",
                                   type = "ALL",
                                   criteriaList = list(bothOutpatientCount))


#Created the inpatient visit group and 2 outpatient visit groups that are correlated with the afib occurrence
#Now create the correlated criteria of both

nestedCritVisitTypes <- createGroup(Name = "Correlated Visit Types to Afib (1 IP or 2 OP)",
                                    type = "ANY",
                                    criteriaList = list(inpatientCount),
                                    Groups = list(bothOutpatientGroup))
  

#Finally create the primary criteria of an afib occurrence
afibQuerySubramanya <- createConditionOccurrence(conceptSetExpression = afibCSESubramanya,
                                                 attributeList = list(
                                                   #add the start data attribute
                                                   createOccurrenceStartDateAttribute(Op = "bt", 
                                                                                      Value = "2007-01-01",
                                                                                      Extent = "2015-10-01"),
                                                   #add the visit type correlated attribute
                                                   createCorrelatedCriteriaAttribute(nestedCritVisitTypes)
                                                 ))

afibPrimaryCriteriaSubramanya <- createPrimaryCriteria(Name = "Subramanya Afib Diagnosis",
                                             ComponentList = list(
                                               afibQuerySubramanya
                                             ),
                                             ObservationWindow = createObservationWindow(PriorDays = 0L, PostDays = 0L),
                                             Limit = "First")

#thats it so lets make the cohort definition
subramanyaAfibCohort <- createCohortDefinition(Name = "Subramanya et al Afib Cohort", 
                                            PrimaryCriteria = afibPrimaryCriteriaSubramanya)
#compile the cohort defintion so that we get the json
subramanyaAfibCohortJson <- compileCohortDefinition(CohortDefinition = subramanyaAfibCohort)

#write the subramanya Afib Cohort to json folder
readr::write_file(subramanyaAfibCohortJson, file = "results/day3/json/subramanyaAfibCohort.json")  


