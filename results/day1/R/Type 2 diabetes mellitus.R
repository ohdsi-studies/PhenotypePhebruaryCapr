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


# We can reuse the parts of each prior cohort in the next one.

# Frist set up a connection to a CDM database
# devtools::install_github("OHDSI/Capr")
library(Capr)
library(DatabaseConnector)
connectionDetails <- createConnectionDetails("postgresql", user = "postgres", password = "", server = "localhost/covid")
connection <- connect(connectionDetails)

# verify connection works 
stopifnot(nrow(dbGetQuery(connection, "select * from cdm5.concept limit 1")) == 1) 

vocabularyDatabaseSchema <- "cdm5"



##################################################################################################################################
## Cohort 1: [PhenotypePhebruary][T2DM] Persons with new type 2 diabetes mellitus at first diagnosis -----------------------------

## Concept set ------

nm0 <- "Type 2 diabetes mellitus (diabetes mellitus excluding T1DM and secondary)"
cid0 <- c(443238, 201820, 442793, 40484648, 20125, 435216, 201254, 195771, 4058243, 761051)
conceptMapping0 <- list(
  list(includeDescendants = TRUE, isExcluded = FALSE, includeMapped = FALSE),
  list(includeDescendants = TRUE, isExcluded = FALSE, includeMapped = FALSE),
  list(includeDescendants = TRUE, isExcluded = FALSE, includeMapped = FALSE),
  list(includeDescendants = TRUE, isExcluded = TRUE, includeMapped = FALSE),
  list(includeDescendants = TRUE, isExcluded = TRUE, includeMapped = FALSE),
  list(includeDescendants = TRUE, isExcluded = TRUE, includeMapped = FALSE),
  list(includeDescendants = TRUE, isExcluded = TRUE, includeMapped = FALSE),
  list(includeDescendants = TRUE, isExcluded = TRUE, includeMapped = FALSE),
  list(includeDescendants = TRUE, isExcluded = TRUE, includeMapped = FALSE),
  list(includeDescendants = TRUE, isExcluded = TRUE, includeMapped = FALSE))


conceptSet0 <- getConceptIdDetails(conceptIds = cid0,
                                   connection = connection,
                                   vocabularyDatabaseSchema = vocabularyDatabaseSchema,
                                   mapToStandard = FALSE) %>%
  createConceptSetExpressionCustom(Name = nm0, conceptMapping = conceptMapping0)

## Initial Event -----

# People having any of the following:
#   a condition occurrence of Type 2 diabetes mellitus (diabetes mellitus excluding T1DM and secondary)
#  with continuous observation of at least 0 days prior and 0 days after event index date, and limit initial events to: earliest event per person.

queryPC1 <- createConditionOccurrence(conceptSetExpression = conceptSet0)

PrimaryCriteria <- createPrimaryCriteria(Name = "cohortPrimaryCriteria",
                                         ComponentList = list(queryPC1),
                                         ObservationWindow = createObservationWindow(PriorDays = 0L,PostDays = 0L),
                                         Limit = "First")


AdditionalCriteria <- createAdditionalCriteria(Name = "cohortAdditionalCriteria", Contents = NULL, Limit = "First")


# Inclusion Rules -----

# Inclusion Criteria #1: has 365d prior observation
# Having all of the following criteria:
#   at least 1 occurrences of: an observation period
# where event starts between All days Before and 365 days Before index start date and event ends between 0 days After and All days After index start date
# Limit qualifying cohort to: earliest event per person.

timelineInclusionRule1_1 <- createTimeline(
  StartWindow = createWindow(EventStarts = TRUE, StartDays = "All", StartCoeff = "Before", EndDays = 365L, EndCoeff = "Before"),
  EndWindow = createWindow(EventStarts = FALSE, StartDays = 0L, StartCoeff = "After", EndDays = "All", EndCoeff = "After"))

countInclusionRule1_1 <- createCount(Query = createObservationPeriod(), Logic = "at_least", Count = 1L, Timeline = timelineInclusionRule1_1)

InclusionRule1 <- createGroup(Name = "has 365d prior observation",
                              type = "ALL",
                              criteriaList = list(countInclusionRule1_1))

InclusionRules <- createInclusionRules(Name = "cohortInclusionRules",
                                       Contents = list(InclusionRule1), Limit = "First")

# Cohort Collapse Strategy -----
#   Collapse cohort by era with a gap size of 0 days
## Create the cohort definition -----

# No end date strategy selected. By default, the cohort end date will be the end of the observation period that contains the index event.

cohortT2DM_1 <- createCohortDefinition(Name = "[PhenotypePhebruary][T2DM] Persons with new type 2 diabetes mellitus at first diagnosis",
                                       cdmVersionRange = ">=5.0.0",
                                       PrimaryCriteria = PrimaryCriteria1,
                                       AdditionalCriteria = AdditionalCriteria,
                                       InclusionRules = InclusionRules,
                                       EndStrategy = NULL,
                                       CensoringCriteria = NULL,
                                       CohortEra = createCohortEra(0L))




##################################################################################################################################
## Cohort 2: [PhenotypePhebruary][T2DM] Persons with new type 2 diabetes and no prior T1DM or secondary diabetes -----------------

# Full text of cohort definition #2
# Initial Event 
# People having any of the following:
#   a condition occurrence of Type 2 diabetes mellitus (diabetes mellitus excluding T1DM and secondary)3
# with continuous observation of at least 0 days prior and 0 days after event index date, and limit initial events to: earliest event per person.
#
# Inclusion Rules
# Inclusion Criteria #(1): has 365d prior observation
# Having all of the following criteria:
#   at least 1 occurrences of: an observation period
# where event starts between All days Before and 365 days Before index start date and event ends between 0 days After and All days After index start date
# Inclusion Criteria #(2): no Type 1 diabetes mellitus diagnosis on or prior to T2DM
# Having all of the following criteria:
#   exactly 0 occurrences of: a condition occurrence of Type 1 diabetes mellitus
# where event starts between All days Before and 0 days After index start date
# Inclusion Criteria #(3): no secondary diabetes diagnosis on or prior to T2DM
# Having all of the following criteria:
#   exactly 0 occurrences of: a condition occurrence of Secondary diabetes mellitus1
# where event starts between All days Before and 0 days After index start date
# Limit qualifying cohort to: earliest event per person.
# End Date Strategy
# No end date strategy selected. By default, the cohort end date will be the end of the observation period that contains the index event.
# Cohort Collapse Strategy:
#   Collapse cohort by era with a gap size of 0 days


# This definition is very similar to the previous one. We simply need to add two additional inclusion criteria.

# Inclusion Criteria #(2): no Type 1 diabetes mellitus diagnosis on or prior to T2DM
# Having all of the following criteria:
#   exactly 0 occurrences of: a condition occurrence of Type 1 diabetes mellitus2
# where event starts between All days Before and 0 days After index start date

conceptSet1 <- getConceptIdDetails(conceptIds = c(435216L, 201254L, 40484648L),
                                   connection = connection,
                                   vocabularyDatabaseSchema = vocabularyDatabaseSchema,
                                   mapToStandard = FALSE) %>%
  createConceptSetExpressionCustom(Name = "Type 1 diabetes mellitus")

queryInclusionRule2_1 <- createConditionOccurrence(conceptSetExpression = conceptSet1)

timelineInclusionRule2_1 <- createTimeline(StartWindow = createWindow(EventStarts = TRUE, StartDays = "All", StartCoeff = "Before", EndDays = 0L, EndCoeff = "After"),
                                           EndWindow = NULL,
                                           IgnoreObservationPeriod = TRUE)

countInclusionRule2_1 <- createCount(Query = queryInclusionRule2_1, Logic = "exactly", Count = 0L, Timeline = timelineInclusionRule2_1)

InclusionRule2 <- createGroup(Name = "no Type 1 diabetes mellitus diagnosis on or prior to T2DM",
                              type = "ALL",
                              criteriaList = list(countInclusionRule2_1))


# Inclusion Criteria #(3): no secondary diabetes diagnosis on or prior to T2DM
# Having all of the following criteria:
#   exactly 0 occurrences of: a condition occurrence of Secondary diabetes mellitus1
# where event starts between All days Before and 0 days After index start date

conceptSet2 <- getConceptIdDetails(conceptIds = 195771L,
                                   connection = connection,
                                   vocabularyDatabaseSchema = vocabularyDatabaseSchema,
                                   mapToStandard = FALSE) %>%
  createConceptSetExpressionCustom(Name = "Secondary diabetes mellitus")


queryInclusionRule3_1 <- createConditionOccurrence(conceptSetExpression = conceptSet2, attributeList = NULL)

timelineInclusionRule3_1 <- createTimeline(StartWindow = createWindow(StartDays = "All", StartCoeff = "Before", EndDays = 0L, EndCoeff = "After", EventStarts = TRUE, IndexStart = TRUE),
                                           EndWindow = NULL,
                                           IgnoreObservationPeriod = TRUE)

countInclusionRule3_1 <- createCount(Query = queryInclusionRule3_1,
                                     Logic = "exactly",
                                     Count = 0L,
                                     isDistinct = FALSE,
                                     Timeline = timelineInclusionRule3_1)

InclusionRule3 <- createGroup(Name = "no secondary diabetes diagnosis on or prior to T2DM",
                              type = "ALL",
                              count = NULL,
                              criteriaList = list(countInclusionRule3_1),
                              demographicCriteriaList = NULL,
                              Groups = NULL)

InclusionRules <- createInclusionRules(Name = "cohortInclusionRules",
                                        Contents = list(InclusionRule1, InclusionRule2, InclusionRule3),
                                        Limit = "First")

cohortT2DM_2 <- createCohortDefinition(Name = "[PhenotypePhebruary][T2DM] Persons with new type 2 diabetes and no prior T1DM or secondary diabetes",
                                       cdmVersionRange = ">=5.0.0",
                                       PrimaryCriteria = PrimaryCriteria,
                                       AdditionalCriteria = AdditionalCriteria,
                                       InclusionRules = InclusionRules,
                                       EndStrategy = NULL,
                                       CensoringCriteria = NULL,
                                       CohortEra = createCohortEra(0L))




##################################################################################################################################
## Cohort 3: [PhenotypePhebruary][T2DM] Persons with new type 2 diabetes mellitus at first dx rx or lab --------------------------

# For the third definition we need to define two new concept sets, 
# three new additional primary criteria, and one new inclusion criteria

# Create additional concept sets
conceptSet3 <- getConceptIdDetails(conceptIds = c(37059902L, 4184637L), 
                                   connection = connection, 
                                   vocabularyDatabaseSchema = vocabularyDatabaseSchema, 
                                   mapToStandard = FALSE) %>% 
  createConceptSetExpressionCustom(Name = "Hemoglobin A1c (HbA1c) measurements")

conceptSet4 <- getConceptIdDetails(conceptIds = 21600744L, 
                                   connection = connection, 
                                   vocabularyDatabaseSchema = vocabularyDatabaseSchema, 
                                   mapToStandard = FALSE) %>% 
  createConceptSetExpressionCustom(Name = "Drugs for diabetes except insulin")

# Create three new Primary criteria
queryPC2 <- createDrugExposure(conceptSetExpression = conceptSet4, attributeList = NULL)

attPC3_1 <- createValueAsNumberAttribute(Op = "bt", Value = 6.5, Extent = 30L)

attPC3_2 <- createUnitAttribute(conceptIds = 8554L, 
                                connection = connection, 
                                vocabularyDatabaseSchema = vocabularyDatabaseSchema, 
                                mapToStandard = FALSE)

queryPC3 <- createMeasurement(conceptSetExpression = conceptSet3, attributeList = list(attPC3_1, attPC3_2))

attPC4_1 <- createValueAsNumberAttribute(Op = "bt", Value = 48L, Extent = 99L)

attPC4_2 <- createUnitAttribute(conceptIds = 9579L, 
                                connection = connection, 
                                vocabularyDatabaseSchema = vocabularyDatabaseSchema, 
                                mapToStandard = FALSE)

queryPC4 <- createMeasurement(conceptSetExpression = conceptSet3, 
                              attributeList = list(attPC4_1, attPC4_2))

PrimaryCriteria <- createPrimaryCriteria(Name = "cohortPrimaryCriteria", 
                                         ComponentList = list(queryPC1, queryPC2, queryPC3, queryPC4), 
                                         ObservationWindow = createObservationWindow(PriorDays = 0L, PostDays = 0L), 
                                         Limit = "First")

# Create new inclusion criterion - "has at least one diagnosis of T2DM on or within 365d of index date"
queryInclusionRule4_1 <- createConditionOccurrence(conceptSetExpression = conceptSet0, 
                                                   attributeList = NULL)

timelineInclusionRule4_1 <- createTimeline(StartWindow = createWindow(StartDays = 0L, StartCoeff = "Before", EndDays = 365L, EndCoeff = "After", EventStarts = TRUE, IndexStart = TRUE), 
                                           EndWindow = NULL, 
                                           IgnoreObservationPeriod = FALSE)

countInclusionRule4_1 <- createCount(Query = queryInclusionRule4_1, 
                                     Logic = "at_least", Count = 1L, isDistinct = FALSE, Timeline = timelineInclusionRule4_1)

InclusionRule4 <- createGroup(Name = "has at least one diagnosis of T2DM on or within 365d of index date", 
                              criteriaList = list(countInclusionRule4_1))

# combine all inclusion rules
InclusionRules <- createInclusionRules(Name = "cohortInclusionRules", 
                                       Contents = list(InclusionRule1, InclusionRule2, InclusionRule3, InclusionRule4), 
                                       Limit = "First")

cohortT2DM_3 <- createCohortDefinition(Name = "CohortDefinition", 
                                       cdmVersionRange = ">=5.0.0", 
                                       PrimaryCriteria = PrimaryCriteria, 
                                       AdditionalCriteria = AdditionalCriteria, 
                                       InclusionRules = InclusionRules, 
                                       EndStrategy = NULL, 
                                       CensoringCriteria = NULL, 
                                       CohortEra = createCohortEra(0L))








