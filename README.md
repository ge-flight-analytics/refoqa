
<!-- README.md is generated from README.Rmd. Please edit that file -->

# refoqa

<!-- badges: start -->
<!-- badges: end -->

refoqa is a tidyverse friendly R wrapper around the EMS/eFOQA API.

The primary expected workflow for this wrapper is to use the ‘Data
Sources’ Demo App / Developer Tool in EMS Online to navigate the EMS
Tree and find all of the fields you want to use.  
![Data Sources App Example](images/data_source_picker_example.PNG)

Then you will use the query json that tool generates to get exactly the
fields you wnat to query.

‘re’foqa because it is a bit of a ’re’-write of the other EMS package
(rems)

The benefits of this package over Rems are:  
1. The functions (like ‘filter’ or ‘select’ in Rems) will not clash with
dplyr verbs.  
2. Credential management is easier.  
3. Works with the ‘Data Sources’ App for interactive and precise field
selection.

## Installation

You can install the released version of refoqa from github with:

``` r
install.packages("devtools")
devtools::install_github("https://github.com/ge-flight-analytics/refoqa.git")
```

## Setup

refoqa expects you to store your EMS/eFOQA credentials and preferred
server inside if your .Renviron file. This means you don’t have to ever
pass your credentials to refoqa by hand! Set it and forget it. Plus this
is considered best practice in R so that your credentials stay out of
your script, history and git.

In Rstudio run:

``` r
usethis::edit_r_environ()
```

Add in these three lines and replace the example data with your efoqa
user, password and server

    # Example .Renviron file
    EFOQAUSER=example.user
    EFOQAPASSWORD=EXAMPLEPASSWORD
    EFOQASERVER=https://d2mo-api.us.efoqa.com/api

Restart your R session, and you can test for success by doing:

``` r
Sys.getenv("EFOQASERVER")
```

## Some Quick Results

refoqa has a couple of pre-built queries to get you started. To get some
general information about the flights on your system try using
standard\_flight\_query()

``` r
library(refoqa)

all_flights <- standard_flight_query()
#> Sending and opening an async-query to EMS ...
#> Done.
#> === Async call: 1 === 
#> Received up to  25000 rows.
#> === Async call: 2 === 
#> Received up to  45145 rows.
#> Async query connection (query ID: 750b191a-ff63-4295-86cb-34e8dc76004d) deleted.
#> Done.

print(head(all_flights))
#> # A tibble: 6 x 15
#>   flight_record flight_date flight_number fleet    tail_number airframe
#>   <chr>         <chr>       <chr>         <chr>    <chr>       <chr>   
#> 1 3135409       Oct 2012    0             Fleet 14 GE-704      747-400 
#> 2 3135410       Oct 2012    0             Fleet 14 GE-704      747-400 
#> 3 3135417       Nov 2012    0             Fleet 14 GE-704      747-400 
#> 4 3135418       Nov 2012    0             Fleet 14 GE-704      747-400 
#> 5 3135421       Nov 2012    0             Fleet 14 GE-704      747-400 
#> 6 3135422       Nov 2012    0             Fleet 14 GE-704      747-400 
#> # ... with 9 more variables: airframe_engine_type <chr>, airframe_group <chr>,
#> #   takeoff_airport_icao_code <chr>, takeoff_airport_iata_code <chr>,
#> #   takeoff_runway_id <chr>, detected_approach <chr>,
#> #   landing_airport_icao_code <chr>, landing_airport_iata_code <chr>,
#> #   landing_runway_id <chr>
```

## Specifying the ‘Data Source Id’ (aka entity or database)

The ‘data\_source\_id’ will need to be specified when you want to query
for something other than FDW Flights (for example flight safety events).
This is what controls what the ‘rows’ of your query are (flights,
events, downloads, etc.)

Let’s do an events query now. In the ‘data source’ app in EMS online,
copy the appropriate ‘Data Source id’ ![Data Sources Id
Example](images/data_source_id_events_example.PNG)

``` r
example_event_data <- standard_event_query(
  event_data_source_id = "[ems-apm][entity-type][events:profile-a7483c449db94a449eb5f67681ee52b0]")
#> Sending and opening an async-query to EMS ...
#> Done.
#> === Async call: 1 === 
#> Received up to  25000 rows.
#> === Async call: 2 === 
#> Received up to  50000 rows.
#> === Async call: 3 === 
#> Received up to  56411 rows.
#> Async query connection (query ID: 10a07475-6b3e-49d1-80f2-5b66b5ed1b9d) deleted.
#> Done.
#> Sending and opening an async-query to EMS ...
#> Done.
#> === Async call: 1 === 
#> Received up to  25000 rows.
#> === Async call: 2 === 
#> Received up to  50000 rows.
#> === Async call: 3 === 
#> Received up to  56411 rows.
#> Async query connection (query ID: aa9a7964-5ede-47d6-bd76-0eb56c12aac9) deleted.
#> Done.
#> Joining, by = c("flight_record", "event_record")

print(head(example_event_data))
#> # A tibble: 6 x 28
#>   flight_record event_record event_type        false_positive  severity  status 
#>   <chr>         <chr>        <chr>             <chr>           <chr>     <chr>  
#> 1 3135409       224779       Insufficient Eng~ Not a False Po~ Caution   FOQA: ~
#> 2 3135409       224780       Insufficient Eng~ Not a False Po~ Caution   FOQA: ~
#> 3 3135409       224782       Insufficient Eng~ Not a False Po~ Caution   Downgr~
#> 4 3135409       224784       Insufficient Eng~ Not a False Po~ Caution   Unknown
#> 5 3135410       224790       Airspeed Exceeds~ Not a False Po~ Informat~ Unknown
#> 6 3135410       224791       FDR/EMU Marker    Not a False Po~ Informat~ FOQA: ~
#> # ... with 22 more variables: baro_altitude_at_start_of_event_ft <dbl>,
#> #   height_agl_at_start_of_event_ft <dbl>,
#> #   height_above_takeoff_best_estimate_at_start_of_event_ft <dbl>,
#> #   height_above_touchdown_best_estimate_at_start_of_event_ft <dbl>,
#> #   airspeed_calibrated_at_start_of_event_knots <dbl>,
#> #   ground_speed_at_start_of_event_knots <dbl>,
#> #   mach_number_at_start_of_event <dbl>, ...
```

## A Full Custom Query

Now let’s do a full custom query. Run through the full ‘Data Source’ app
selecting the data source and fields. In the end you will get a json
query in the ‘JSON Editor’ tab.

![JSON Query Example](images/example_json_query.PNG)

Copy + Paste this json query to create a new json file in your R
project. Then pass it to ‘database\_query\_from\_json’ along with the
data source id and it will get executed.

``` r
custom_query_results <- database_query_from_json(data_source_id = "[ems-core][entity-type][foqa-flights]",
                                                 json_file = example_query_file)
#> Sending a regular query to EMS ...Done.
print(head(custom_query_results))
#> # A tibble: 6 x 6
#>   flight_record fleet    airframe p35_maximum_pressur~ p35_bank_angle_magnitude~
#>   <chr>         <chr>    <chr>    <chr>                <chr>                    
#> 1 3193189       Fleet 03 A320-200 36072 ft             24.2576 degrees          
#> 2 3203702       Fleet 03 A320-200 34048 ft             25.3123 degrees          
#> 3 3208826       Fleet 03 A320-200 38036 ft             26.0154 degrees          
#> 4 3208827       Fleet 03 A320-200 35064 ft             27.7732 degrees          
#> 5 3211863       Fleet 03 A320-200 34052 ft             25.3123 degrees          
#> 6 3211868       Fleet 03 A320-200 35044 ft             28.4764 degrees          
#> # ... with 1 more variable:
#> #   p35_pitch_attitude_maximum_while_airborne_degrees <chr>
```

### Notes

#### Field Formats

At least as of right now, the return type of each field is based on your
query. This means that in your json query,

    "format": "display" 

Will return all results as strings.

    "format": "none" 

Will return numbers.

We may change at some point.

#### ‘Top 10’

By default the Data Sources App will include a line limiting the results
to just the first 10 records:

      "top": 10

Delete this line to get all results.

## Full Flight Data ‘Analytics’ Queries

This is super rough right now and may change, but you can query the
‘analytics’ API endpoint. See the documentation in the EMS Online REST
API Explorer for details on the json form of the query.

``` r
example_parameter_results <- analytics_query_from_json(flight_id = 3135409, query_json_file = example_analytics_query_file )

ggplot(data = example_parameter_results, aes(x = offset, y = pressure_altitude_ft)) +
  geom_line()
#> Warning: Removed 2 row(s) containing missing values (geom_path).
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

There are options to do this directly from an R list (rather than json),
and an option to do this without specifying a flight record if you want
to ( refoqa will select a random flight for youu). These are mostly
useful for system maintenance type uses, but it is here if you want it.

``` r
query_as_r_list <- jsonlite::read_json(example_analytics_query_file)

example_parameter_results <- analytics_query_with_unspecified_flight( query_list = query_as_r_list )
#> Sending a regular query to EMS ...Done.

ggplot(data = example_parameter_results, aes(x = offset, y = pressure_altitude_ft)) +
  geom_line()
#> Warning: Removed 2 row(s) containing missing values (geom_path).
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

### Search Analytic Ids

``` r
search_for_analytic( "Slat Operating Speed Maximum" )
#> [[1]]
#> [[1]]$id
#> [1] "H4sIAAAAAAAEAG2QQQvCMAyF74L/Yey+tk5BGHMg6GEwL8rAa+2qC3TdbDvrz7c6qg7N4RF4+chL0j3XrbjRk+B5xaWBM3AV3BshdQKrsDamSzC21iI7R6264JiQGT7uigOreUMjkNpQyXg4MG9Cv2yNKmooa6VRlBnPLzBZ4nUFqFQ0zKaTIEiHFFzlVeZbjbaNLtoLMCpS/DUwAg4dZy4z27g9ASQSxCo0qnd58P/BUsK1d7dmZKg4emq0eArx4uuz9wefTrw5/l32ACiTbuVSAQAA"
#> 
#> [[1]]$name
#> [1] "Slat Operating Speed Maximum (knots)"
#> 
#> [[1]]$description
#> [1] "Maximum indicated airspeed permitted with the slats extended as specified in the airplane flight manual."
#> 
#> [[1]]$units
#> [1] "knots"
```

## Helpers for Discretes or Dimensions

The ‘data sources’ app and json query are not great for handling
discretes or dimensions. Here are a few helper functions to help out.

### Get Possible Dimension/Discrete States

One way to work around this is to get the EMS ids for the possible
discretes. Then you can type these in by hand into your json query.
There are some build in id\_table queries to get these lists.

``` r
airframe_id_table <- get_airframe_id_table()
print( head( airframe_id_table ) )
#> # A tibble: 6 x 2
#>   local_id discrete_string
#>      <dbl> <chr>          
#> 1      190 172S           
#> 2       83 717-200        
#> 3      185 727-200        
#> 4      167 737 (BBJ)      
#> 5      169 737 (BBJ2)     
#> 6      159 737 (BBJ3)

airframe_engine_id_table <- get_airframe_engine_id_table()
print( head( airframe_engine_id_table ) )
#> # A tibble: 6 x 2
#>   local_id discrete_string   
#>      <dbl> <chr>             
#> 1      245 172S IO-360       
#> 2      124 717-200 BR715     
#> 3      243 727-200 JT8D      
#> 4      212 737 (BBJ) CFM56-7 
#> 5      224 737 (BBJ2) CFM56-7
#> 6      222 737 (BBJ3) CFM56-7
```

Or you can get a table of possible discrete states for any field you
want.

``` r
fleet_table <- get_dimension_table(data_source_id = "[ems-core][entity-type][foqa-flights]",
                                   field_id = "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[ems-core][base-field][flight.fleet]]]")
print(head(fleet_table))
#> # A tibble: 6 x 2
#>   local_id discrete_string
#>      <dbl> <chr>          
#> 1        3 Fleet 03       
#> 2        4 Fleet 04       
#> 3        5 Fleet 05       
#> 4        6 Fleet 06       
#> 5        7 Fleet 07       
#> 6        8 Fleet 08
```

### Append Dimension/Discrete Filter by String

There is a helper to tack on a filter for a specific string version of a
particular field to an input query.

``` r
example_query_list <- jsonlite::read_json(example_query_file)

flight_query_for_fleet_03 <- filter_dimension_by_string(
  data_source_id = "[ems-core][entity-type][foqa-flights]",
  query_list = example_query_list,
  field_id = "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[ems-core][base-field][flight.fleet]]]",
  dimension_string = "Fleet 03")

fleet_03_flights <- database_query_from_list( data_source_id = "[ems-core][entity-type][foqa-flights]",
                                              query_list = flight_query_for_fleet_03)
#> Sending a regular query to EMS ...Done.
print(head(fleet_03_flights))
#> # A tibble: 6 x 6
#>   flight_record fleet    airframe p35_maximum_pressur~ p35_bank_angle_magnitude~
#>   <chr>         <chr>    <chr>    <chr>                <chr>                    
#> 1 3193189       Fleet 03 A320-200 36072 ft             24.2576 degrees          
#> 2 3203702       Fleet 03 A320-200 34048 ft             25.3123 degrees          
#> 3 3208826       Fleet 03 A320-200 38036 ft             26.0154 degrees          
#> 4 3208827       Fleet 03 A320-200 35064 ft             27.7732 degrees          
#> 5 3211863       Fleet 03 A320-200 34052 ft             25.3123 degrees          
#> 6 3211868       Fleet 03 A320-200 35044 ft             28.4764 degrees          
#> # ... with 1 more variable:
#> #   p35_pitch_attitude_maximum_while_airborne_degrees <chr>
```

And some helpers for specific dimensions

``` r
flight_query_for_737 <- filter_airframe_engine_by_string(
  query_list = example_query_list,
  target_airframe_engine_string = "737-800 CFM56-7")

flights_737 <- database_query_from_list( data_source_id = "[ems-core][entity-type][foqa-flights]",
                                              query_list = flight_query_for_737)
#> Sending a regular query to EMS ...Done.
print(head(flights_737))
#> # A tibble: 6 x 6
#>   flight_record fleet    airframe p35_maximum_pressur~ p35_bank_angle_magnitude~
#>   <chr>         <chr>    <chr>    <chr>                <chr>                    
#> 1 3137698       Fleet 19 737-800  35968 ft             30.4102 degrees          
#> 2 3137733       Fleet 19 737-800  30018 ft             29.8828 degrees          
#> 3 3137877       Fleet 19 737-800  37015 ft             31.1133 degrees          
#> 4 3137878       Fleet 19 737-800  33970 ft             25.6641 degrees          
#> 5 3137881       Fleet 19 737-800  36018 ft             33.9258 degrees          
#> 6 3137884       Fleet 19 737-800  37013 ft             25.6641 degrees          
#> # ... with 1 more variable:
#> #   p35_pitch_attitude_maximum_while_airborne_degrees <chr>
```

## Other Potentially Useful Functions

### List APM Profiles

You can get a list of all available profiles on the system with the
list\_all\_apm\_profiles() function:

``` r
all_profiles <- list_all_apm_profiles()
#> Querying for the list of profiles

print( all_profiles[[1]]$name )
#> [1] "Approach Detection Prereqs"
example_profile_id <- all_profiles[[1]]$id
print( example_profile_id )
#> [1] "2becd333-b132-4880-ad2c-aa28f30e2cd9"
```

### APM Profile Glossary

You can get a glossary of an APM profile in either json/list or
csv/dataframe form

``` r
example_glossary <- apm_profile_glossary( profile_id = example_profile_id, glossary_format = "csv" )
#> Querying for the profile glossary
#> Done.
#> No encoding supplied: defaulting to UTF-8.
#> Joining, by = "record_type"

example_glossary <- select(example_glossary, name, record_type, item_id, logical_id)
print(head(example_glossary))
#> # A tibble: 6 x 4
#>   name                                record_type item_id logical_id            
#>   <chr>                               <chr>       <chr>   <chr>                 
#> 1 Beginning of File                   timepoint   0       383DAB63-BFF3-4B15-8F~
#> 2 End of File                         timepoint   1       FA806D6C-DFA4-474D-B8~
#> 3 Begin Airborne Interval             timepoint   2       25D29FB0-3150-472B-98~
#> 4 First Known Phase of Flight         timepoint   3       AD668953-0184-49F9-8A~
#> 5 Last Valid Data                     timepoint   4       3522561F-4087-4585-86~
#> 6 Rest of File is more than 80% sync~ timepoint   5       36507F42-F9FB-4EF3-BE~
```

You can also get a list of the events in a profile

``` r
example_events_df <- apm_events_glossary( profile_id = example_profile_id )
#> Querying for the profile glossary
#> Done.

print( head( example_events_df ) )
#> # A tibble: 6 x 3
#>      id name                                                 comments           
#>   <int> <chr>                                                <chr>              
#> 1     0 Low-Level Windshear                                  "This event indica~
#> 2     1 Risk of Ground Collision due to Low-Level Wind Shear "This event indica~
#> 3     2 EGT Limit Exceedance (Left Outboard Engine)          "This event indica~
#> 4     3 EGT Limit Exceedance (Left Inboard Engine)           "This event indica~
#> 5     4 EGT Limit Exceedance (Center Engine)                 "This event indica~
#> 6     5 EGT Limit Exceedance (Right Inboard Engine)          "This event indica~
```

### More Built In Queries

A built-in query for a summary of the airframe-engine types on the
system

``` r
airframe_summary <- standard_airframe_query()
#> Sending a regular query to EMS ...Done.

print( head( airframe_summary ) )
#> # A tibble: 6 x 5
#>   max_flight_record max_flight_date airframe_engine_t~ count_flight_re~ airframe
#>   <chr>             <chr>           <chr>                         <int> <chr>   
#> 1 5670603           Mar 2015        CRJ100/200 CF34-1~              373 CRJ100/~
#> 2 5439176           Dec 2015        767-400ER CF6-80               4764 767-400~
#> 3 5498858           Dec 2015        737-800 CFM56-7               10276 737-800 
#> 4 5499576           Dec 2015        757-200 PW2000                 7726 757-200 
#> 5 5575245           Dec 2015        777-200ER Trent 8~             1069 777-200~
#> 6 5427509           Dec 2015        777-200LR GE90-11~             1631 777-200~
```

### Misc

Get details on any EMS schema field

``` r
field_details <- get_database_field_details(
  data_source_id = "[ems-core][entity-type][foqa-flights]",
  field_id = "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[airframe-engine-field-set][base-field][airframe-engine]]]")
print(names(field_details))
#> [1] "discreteValues" "id"             "type"           "name"          
#> [5] "path"
```

Get a dataframe of all physical parameters for a particular flight
record

``` r
physical_parameters_for_flight <- get_physical_parameters_for_flight(3135409)

print( head( select( physical_parameters_for_flight, name, units, uid) ) )
#> # A tibble: 6 x 3
#>   name                   units uid     
#>   <chr>                  <chr> <chr>   
#> 1 A/P ALT HOLD MODE OPER ""    APALTHLD
#> 2 A/P ALTITUDE MODE OPER ""    APALTMD 
#> 3 A/P CAUTION            ""    APCAUT  
#> 4 A/P CMD C ENGA         ""    APCMDCEN
#> 5 A/P CMD L ENGA         ""    APCMDLEN
#> 6 A/P CMD R ENGA         ""    APCMDREN
```

Get a dataframe of all physical parameters for all PDCs/LFLs on the
system

``` r
all_physical_parameters <- get_all_physical_parameters()
#> Sending a regular query to EMS ...Done.

print( head( select( all_physical_parameters, name, flight_physical_data_configuration_id ) ) )
#> # A tibble: 6 x 2
#>   name                 flight_physical_data_configuration_id
#>   <chr>                <chr>                                
#> 1 A/C NUMBER           Fleet 23                             
#> 2 A/C TYPE             Fleet 23                             
#> 3 A/P CAUTION C FCC    Fleet 23                             
#> 4 A/P CAUTION L FCC    Fleet 23                             
#> 5 A/P CAUTION R FCC    Fleet 23                             
#> 6 A/P CMD C ENGA C FCC Fleet 23
```

Get a dataframe of all logical items (parameters and constants) on the
system

``` r
all_logical_items <- get_logical_FDW_item_list()

print( head( select( all_logical_items, name, description, item_type ) ) )
#> # A tibble: 6 x 3
#>   name                        description                           item_type   
#>   <chr>                       <chr>                                 <chr>       
#> 1 FWC- Rud Trav Lim           ""                                    logical_par~
#> 2 GMT (hrs)                   "Greenwich Mean Time (i.e. the time ~ logical_par~
#> 3 Subframe Identifier         ""                                    logical_par~
#> 4 Sync Error (error if > 0.5) "A synchronization error (a disrupti~ logical_par~
#> 5 APU Command On (1=On)       "The flight-deck switch for activati~ logical_par~
#> 6 APU EGT (deg C)             "Exhaust Gas Temperature (EGT) of th~ logical_par~
```
