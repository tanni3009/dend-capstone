# DEND Capstone project
Capstone project for the Udacity Data Engineering Nanodegree

Author: Tanja Hösl <br/>
Date: September 2019

## Scoping the project and gathering data

During the course of this capstone project, an open dataset should be analysed.
Since the EU offers open data published by EU institutions and bodies via their **European Union Open Data Portal** (https://data.europa.eu/euodp/en/home), this data source was browsed to find a dataset suitable for this project.
The datasets were assessed following two criteria: 1 - proving an analytics use case of personal interest to the creator of this project and 2 - fulfilling the dataset criteria for this assessment of at least two different data sources in two different format and at least one million source rows.

### The source dataset - Erasmus mobility statistics
The chosen dataset provides mobility statistics about the Erasmus programme, an EU programme to support education, training, youth and sport in Europe. This programme aims to provide millions of Europeans opportunities to study, train and gain experience abroad.

The European Union Open Data Portal provides Erasmus mobility statistics datasets for various years. For the scope of this project I chose to use datasets for 5 years:
1. 2008-09: https://data.europa.eu/euodp/en/data/dataset/erasmus-mobility-statistics-2008-09
1. 2009-10: https://data.europa.eu/euodp/en/data/dataset/erasmus-facts-figures-trends-2009-2010
1. 2010-11: https://data.europa.eu/euodp/en/data/dataset/erasmus-facts-figures-trends-2010-2011
1. 2011-12: https://data.europa.eu/euodp/en/data/dataset/erasmus-facts-figures-trends-2010-2011
1. 2012-13: https://data.europa.eu/euodp/en/data/dataset/erasmus-mobility-statistics-2012-13

Altogether, these sources contain data for over 1 million study exchanges and work placements in CSV format.

As a second datasource, a list of participating institutions is available in JSON format.

### Scope of the capstone project 
The end goal of this project is to provide analytics table in a star schema, to be able to analyse Erasmus mobility behaviour during 2008 to 2012. The tables should be able to answer analytics questions including
* How many students took the opportunity for a study exchange or work placement each (academic) year?
* What are the most popular countries to go to for studying abroad?
* What are the most popular institutions to go to?
* How long do students stay abroad?

The scope for the different steps will be defined as follows:
1. **Explore and Assess the Data**

    The outcome of this step should be a unified CSV file for the five years of Erasmus mobility data. As the CSV formats for the different years are not all aligned, this step is important for pre-processing the data to be able to smoothly run ETL on it later on.
    
    Moreover, the data exploration will give me an idea of which attributes can actually be used to answer the questions defined above and will serve as input for the data modelling afterwards. A provided data catalog on the data portal will help with that.
    
    
1. **Define the Data Model**

    After having assessed the data, the next step is to conceptualize the data model and explaining will the resulting model will serve the above mentioned analytics use cases.
    Additionally, an outline for the data pipeline will be given.
    
1. **Run ETL to Model the Data**
    
    The defined concept will be implemented in this step to provide the analytics table in a Postgres database.

## Exploring and assessing the data
During this step, the raw data found in the folder ``raw_data`` was assessed and data quality issues were cleaned.

Documentation of the steps to exploring the data, identifying data quality issues and cleaning them up can be found in *01_data_cleaning.ipynb*.

The resulting dataframe for student mobility data was split into several small CSV files for two reasons:
1. to be able to upload it to GitHub (file size limit of 100MB)
1. to transform the data file by file in the ETL pipeline later on

The output of this step can be found in the ``cleaned_data`` subfolder.

## Defining the data model

### Conceptual model

The explored and assessed data will be transformed into facts and dimensions as follows.

#### FactStudentMobility
| Column name | Description | Type | Constraints |
|---|---|---|---|
| home_institution_code | code for student's home institution | TEXT | NOT NULL |
| host_institution_code | code for student's host institution | TEXT |  |
| mobility_type | type of programme | CHAR(1) | NOT NULL; one of [S, P, C] |
| student_age | student's age | SMALLINT |  |
| student_gender | student's gender | CHAR(1) | one of [F, M] |
| student_nationality | student's nationality | CHAR(2) | ISO2 country code |
| student_level | student's study level at home institution | CHAR(1) |  |
| student_years_prior | number of study years prior to period abroad | SMALLINT |  |
| student_previous_participation | indicates whether student received prior Erasmus grant | CHAR(1) |  |
| work_placement | name of organisation for work placement | TEXT |  |
| work_placement_country | country of organisation for work placement | CHAR(2) | ISO2 country code |
| length_study | length of study period in months | DECIMAL(4,2) |  |
| length_work | length of work placement in months | DECIMAL(4,2) |  |
| short_duration_reason | reason for participation less than 3 months | CHAR(1) |  |
| study_start_date | start date of study period | CHAR(7) | format: yyyy-mm |
| work_start_date | start date of placement period | CHAR(7) | format: yyyy-mm |
| combined_start_date | start date of period abroad | CHAR(7) | calculated as MIN(study_start_date, work_start_date)|
| ects_study | anticipated credits for study | SMALLINT |  |
| ects_work | anticipated credits for placement | SMALLINT |  |
| ects_total | total anticipated credits | SMALLINT | calculated as SUM(ects_study, ects_work) |
| sn_supplement | grant awarded for special needs | DECIMAL(8,2) |  |
| study_grant | grant awarded for study period | DECIMAL(8,2) |  |
| work_grant | grant awarded for work placement | DECIMAL(8,2) |  |
| total_grant | total grant awarded | DECIMAL(8,2) | calculated as SUM(sn_supplement, study_grant, work_grant) |

#### DimInstitution
| Column name | Description | Type | Constraints |
|---|---|---|---|
| institution_code | code for institution | TEXT | PK |
| application_reference_number | reference number for applications | TEXT | NOT NULL |
| organisation_name | name of institution | TEXT |  |
| country | country of institution | CHAR(2) | ISO2 country code |
| city | city of institution | TEXT |  |

#### DimDate
| Column name | Description | Type | Constraints |
|---|---|---|---|
| year_month_code | unique code for month/year | CHAR(7) | PK, format: yyyy-mm |
| month_number | number of month | SMALLINT | NOT NULL, [1-12] |
| month_name | name of month | TEXT | NOT NULL |
| year_number | number of year | SMALLINT | NOT NULL  |
| academic_year | string representing academic year | CHAR(7)  | NOT NULL, e.g. 2008-09 |

The central table in this dimensional schema is the fact table **FactStudentMobility** that contains transactional data whereby one transaction represents a student going abroad.
This table contains facts like the length of the study period, grant awarded for the time abroad or ECTS credits the students anticipated.

To be able to slice and dice the data for analytics, the host institution as well as the date for the start of the abroad period have been modelled as dimensions.
This enables us to answer questions like which countries are the most popular to go to or analyse trends over time.


### Pipelining the data into the dimensional model

#### Loading dimensions
##### DimInstitution
The data for institutions is available as a separate dataset, so this dimension can be easily filled from the provided JSON file.
This data was already cleaned in the previous step so no transformations are needed any more and the data can be directly loaded in the dimension table.

##### DimDate
The data for this dimension will be calculated. As the exact timeframe for the data to be analysed is known, this dimension table will be filled for the years 2008 to 2013.
The table will represent one month per row whereas the columns will be calculated based on the month of interest.
The academic_year field will be calculated based on the rule that the academic years starts in September and ends in August.


#### Loading the fact table
The fact table will be filled from the student data. Some columns need to be transformed to another format but most of the data has also already been cleaned in the previous step.
Some columns will be calculated based on other columns to be able to unify querying of different study exchange programme types.


## Running ETL to model the data
The above conceptualized data model was implemented on a locally installed Postgres database.
The ETL pipeline was built in an IPython notebook, utilizing Python's modules pandas and SQLAlchemy to pipe the data from files into the database.

As the dataset is not too large and does not change frequently (once a year), the pipeline was designed to be run once
This will enable analyses use cases for 5 years of data and should serve the scope of this project.


### Choice of tools and technologies
A **Postgres database** was chosen to be able to provide high query performance.
With the low amount of data provided by this project, also a local installation is sufficient and there is no need to run a distributed database on a cluster.

The code to execute the ETL pipeline was developed and run in IPython notebooks, 
as this tool allows for a highly interactive style of coding, 
let's you easily document your code in a clear format 
and also gives you the flexibility to logically structure the code.


### Data quality checks
In the IPython notebook ``04_data_quality_checks.ipynb`` two data quality checks can be found.

#### Check count of student mobility fact
This DQ check compares the number of rows in the CSV files vs the final fact table to make sure all rows could be successfully stored in the database.

#### Check integrity of host institution
The fact table has a home_institution_code that refers to the institution_dimension. This check finds out, how many home institutions are not available in the dimension table

As this data quality check fails, let me reflect on the load. 
The institutions data is loaded from a separate file and not from the student mobility data. Therefore it happened, that some institutions were not available in the compiled list although they were used in the mobility data.

What we could do to prevent this, is to build a deferred load for this dimension. By doing so, we would create a new row in the dimension table for every institution code found in the fact table although we might not have detailed data available for some codes. 
This would mean that we would need to change the NULL constraints on the dimension table and allow NULL values for all attributes.
As soon as new institutions data is available, these data could be merged with the dimension table to fill up the missing values.


### Alternative scenario
This section aims to describe the approach of this ETL pipeline under the following scenario:
* If the data was increased by 100x.
* If the pipelines were run on a daily basis by 7am.
* If the database needed to be accessed by 100+ people.

As the amount of data can not easily be processed on a single machine any more, I would implement 
the pipeline on a distributed system. The input data could be loaded to S3 buckets and then transformed
using Spark to be able to scale the computational power.

To be able to run the pipeline on a daily basis, the load needs to be implemented as a delta load to 
make sure upserts are handled correctly.
Moreover, a scheduling tool, such as Airflow, can be used to trigger the delta load every day.
Airflow itself should then of course be set up on a server.

For multi concurrence database reads, a database cluster should be implemented.
We could an Amazon Redshift cluster, scaled for 100+ people to ensure all requested analytics questions are answered within a sufficient time period.

