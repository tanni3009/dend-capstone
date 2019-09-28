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
* How many students took the opportunity for a study exchange or work placement each year?
* What are the most popular countries to go to? Does this trend change over the years?
* What are the most popular institutions to go to?

The scope for the different steps will be defined as follows:
1. **Explore and Assess the Data**

    The outcome of this step should be a unified CSV file for the five years of Erasmus mobility data. As the CSV formats for the different years are not all aligned, this step is important for pre-processing the data to be able to smoothly run ETL on it later on.
    
    Moreover, the data exploration will give me an idea of which attributes can actually be used to answer the questions defined above and will serve as input for the data modelling afterwards.
    
    
1. **Define the Data Model**

    After having assessed the data, the next step is to conceptualize the data model and explaining will the resulting model will serve the above mentioned analytics use cases.
    Additionally, an outline for the data pipeline will be given.
    
1. **Run ETL to Model the Data**
    
    The defined concept will be implemented in this step to provide the analytics table in a Postgres database.
