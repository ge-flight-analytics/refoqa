
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
standard_flight_query()

``` r
library(refoqa)
library(tidyverse)
#> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
#> ✔ dplyr     1.1.4     ✔ readr     2.1.5
#> ✔ forcats   1.0.0     ✔ stringr   1.5.1
#> ✔ ggplot2   3.5.1     ✔ tibble    3.2.1
#> ✔ lubridate 1.9.3     ✔ tidyr     1.3.1
#> ✔ purrr     1.0.2     
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

all_flights <- standard_flight_query()
#> Sending and opening an async-query to EMS ...
#> Done.
#> === Async call: 1 === 
#> Received up to  25000 rows.
#> === Async call: 2 === 
#> Received up to  45145 rows.
#> character(0)
#> Async query connection (query ID: 8e16a67e-46fb-4961-9196-880d908dee12) deleted.
#> Done.

print(head(all_flights))
#> # A tibble: 6 × 15
#>   flight_record flight_date flight_number fleet    tail_number airframe
#>   <chr>         <chr>       <chr>         <chr>    <chr>       <chr>   
#> 1 3135409       Oct 2012    0             Fleet 14 GE-704      747-400 
#> 2 3135410       Oct 2012    0             Fleet 14 GE-704      747-400 
#> 3 3135417       Nov 2012    0             Fleet 14 GE-704      747-400 
#> 4 3135418       Nov 2012    0             Fleet 14 GE-704      747-400 
#> 5 3135421       Nov 2012    0             Fleet 14 GE-704      747-400 
#> 6 3135422       Nov 2012    0             Fleet 14 GE-704      747-400 
#> # ℹ 9 more variables: airframe_engine_type <chr>, airframe_group <chr>,
#> #   takeoff_airport_icao_code <chr>, takeoff_airport_iata_code <chr>,
#> #   takeoff_runway_id <chr>, detected_approach <chr>,
#> #   landing_airport_icao_code <chr>, landing_airport_iata_code <chr>,
#> #   landing_runway_id <chr>
```

## Specifying the ‘Data Source Id’ (aka entity or database)

The ‘data_source_id’ will need to be specified when you want to query
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
#> Received up to  58347 rows.
#> character(0)
#> Async query connection (query ID: a7a0e54e-fcd1-4269-a165-f145d2618b9c) deleted.
#> Done.
#> Sending and opening an async-query to EMS ...
#> Done.
#> === Async call: 1 === 
#> Received up to  25000 rows.
#> === Async call: 2 === 
#> Received up to  50000 rows.
#> === Async call: 3 === 
#> Received up to  58347 rows.
#> character(0)
#> Async query connection (query ID: 1b8e2425-7159-4214-9899-a31482f9ca27) deleted.
#> Done.
#> Joining with `by = join_by(flight_record, event_record)`

print(head(example_event_data))
#> # A tibble: 6 × 28
#>   flight_record event_record event_type           false_positive severity status
#>   <chr>         <chr>        <chr>                <chr>          <chr>    <chr> 
#> 1 4740995       187266       Master Warning       Not a False P… Caution  Unkno…
#> 2 4263140       197871       TCAS Traffic Adviso… Not a False P… Informa… Unkno…
#> 3 5670598       224802       Unstable Approach (… Not a False P… Caution  Unkno…
#> 4 5670603       224803       High-Energy Descent  Not a False P… Informa… Unkno…
#> 5 5670603       224804       Unstable Approach (… Not a False P… Caution  FOQA:…
#> 6 5670603       224805       Insufficient Engine… Not a False P… Informa… Unkno…
#> # ℹ 22 more variables: baro_altitude_at_start_of_event_ft <dbl>,
#> #   height_agl_at_start_of_event_ft <dbl>,
#> #   height_above_takeoff_best_estimate_at_start_of_event_ft <dbl>,
#> #   height_above_touchdown_best_estimate_at_start_of_event_ft <dbl>,
#> #   airspeed_calibrated_at_start_of_event_knots <dbl>,
#> #   ground_speed_at_start_of_event_knots <dbl>,
#> #   mach_number_at_start_of_event <dbl>, …
```

## A Full Custom Query

Now let’s do a full custom query. Run through the full ‘Data Source’ app
selecting the data source and fields. In the end you will get a json
query in the ‘JSON Editor’ tab.

<figure>
<img src="images/example_json_query.PNG" alt="JSON Query Example" />
<figcaption aria-hidden="true">JSON Query Example</figcaption>
</figure>

Copy + Paste this json query to create a new json file in your R
project. Then pass it to ‘database_query_from_json’ along with the data
source id and it will get executed.

``` r
custom_query_results <- database_query_from_json(data_source_id = "[ems-core][entity-type][foqa-flights]",
                                                 json_file = example_query_file)
#> Sending a regular query to EMS ...Done.
print(head(custom_query_results))
#> # A tibble: 6 × 6
#>   flight_record fleet    airframe p35_maximum_pressure_…¹ p35_bank_angle_magni…²
#>   <chr>         <chr>    <chr>    <chr>                   <chr>                 
#> 1 3193189       Fleet 03 A320-200 36072 ft                24.2576 degrees       
#> 2 3203702       Fleet 03 A320-200 34048 ft                25.3123 degrees       
#> 3 3208826       Fleet 03 A320-200 38036 ft                26.0154 degrees       
#> 4 3208827       Fleet 03 A320-200 35064 ft                27.7732 degrees       
#> 5 3211863       Fleet 03 A320-200 34052 ft                25.3123 degrees       
#> 6 3211868       Fleet 03 A320-200 35044 ft                28.4764 degrees       
#> # ℹ abbreviated names: ¹​p35_maximum_pressure_altitude_ft,
#> #   ²​p35_bank_angle_magnitude_maximum_while_airborne_degrees
#> # ℹ 1 more variable: p35_pitch_attitude_maximum_while_airborne_degrees <chr>
```

### Notes

#### Field Formats

The return type of each field is based on your query. This means that in
your json query,

    "format": "display" 

Will return all the result as a strings.

    "format": "none" 

Will return numbers.

You can set this globally at the base of your json for all fields or
overwrite the value for any given field within the ‘select’ definition.

    {
      "select": [
        {
          "fieldId": "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[ems-core][base-field][flight.uid]]]",
          "aggregate": "none",
          "format": "none"
        }
      ],
      "format": "display"
    }

#### ‘Top 10’

By default the Data Sources App will include a line limiting the results
to just the first 10 records:

      "top": 10

Delete this line to get all results.

#### Alias for Fields

You can set an alias for any database field within the select statement.
This lets you shorten the returned name for something very specific
‘best available baro corrected altitude 1 at start of event’ to
something very short and convenient ‘altitude’

    {
      "select": [
        {
          "fieldId": "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[ems-core][base-field][flight.uid]]]",
          "aggregate": "none",
          "alias": "flight_record
        }
      ]
    }

## Full Flight Data ‘Analytics’ Queries

This is super rough right now and may change, but you can query the
‘analytics’ API endpoint. See the documentation in the EMS Online REST
API Explorer for details on the json form of the query.

``` r

example_parameter_results <- analytics_query_from_json(flight_id = 3135409, query_json_file = example_analytics_query_file )

ggplot(data = example_parameter_results, aes(x = offset, y = pressure_altitude_ft)) +
  geom_line()
#> Warning: Removed 3 rows containing missing values or values outside the scale range
#> (`geom_line()`).
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

You can run an analytics query on multiple flight records with:

``` r
query_as_r_list <- jsonlite::read_json(example_analytics_query_file)
multiple_results <- analytics_query_multiflight(flight_ids=c(3135409, 3135410), query_list = query_as_r_list)

multiple_results %>%
  dplyr::group_by(flight_id) %>%
  dplyr::summarise(max_alt = max(pressure_altitude_ft, na.rm = TRUE))
#> # A tibble: 2 × 2
#>   flight_id max_alt
#>       <dbl>   <dbl>
#> 1   3135409   39049
#> 2   3135410   38035
```

You can optionally specify start and end times too if you have them. You
will have to pipe in the offsets from the database queries above. For
example I have a stored query here that gets the timepoint Top of
Descent to Touchdown for 10 flights. Note: The format = ‘none’ option is
useful in these timepoint queries

``` r
flight_dataframe <-  database_query_from_json(data_source_id = "[ems-core][entity-type][foqa-flights]",
                                              json_file = example_timepoint_query_file)
#> Sending a regular query to EMS ...Done.
print(head(flight_dataframe))
#> # A tibble: 6 × 3
#>   flight_record top_of_descent touchdown
#>           <int>          <dbl>     <dbl>
#> 1       3135409          23086    24420 
#> 2       3135410          27852    29719 
#> 3       3135417          10522    13967.
#> 4       3135418           8337     9556.
#> 5       3135421          15320    17084 
#> 6       3135422          11650    13351.
```

And then we can do our same query but pass in these timepoints as the
start and end.

``` r
query_as_r_list <- jsonlite::read_json(example_analytics_query_file)
tod_to_touchdown <- analytics_query_multiflight(flight_ids=flight_dataframe$flight_record,
                                                query_list = query_as_r_list,
                                                start_offsets = flight_dataframe$top_of_descent,
                                                end_offsets = flight_dataframe$touchdown)

ggplot(data = tod_to_touchdown, aes(x = ground_track_distance_to_touchdown_nm, y = pressure_altitude_ft, color=as.factor(flight_id))) +
  geom_point()
#> Warning: Removed 6 rows containing missing values or values outside the scale range
#> (`geom_point()`).
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

And an option to do this without specifying a flight record if you want
to ( refoqa will select a random flight for you). Mostly useful for
system maintenance type uses, but it is here if you want it.

``` r
example_parameter_results <- analytics_query_with_unspecified_flight( query_list = query_as_r_list )
#> Sending a regular query to EMS ...Done.

ggplot(data = example_parameter_results, aes(x = offset, y = pressure_altitude_ft)) +
  geom_line()
#> Warning: Removed 3 rows containing missing values or values outside the scale range
#> (`geom_line()`).
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

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
#> 
#> [[1]]$metadata
#> NULL
#> 
#> [[1]]$path
#> [[1]]$path[[1]]
#> [1] "RG.Root.FlightData"
#> 
#> [[1]]$path[[2]]
#> [1] "RG.FlightConstants.Hierarchical"
#> 
#> [[1]]$path[[3]]
#> [1] "RG.FlightConstants.Hierarchical.Flight Dynamics"
#> 
#> [[1]]$path[[4]]
#> [1] "RG.FlightConstants.Hierarchical.Flight Dynamics.Speed"
#> 
#> 
#> [[1]]$displayPath
#> [[1]]$displayPath[[1]]
#> [1] "Flight Data"
#> 
#> [[1]]$displayPath[[2]]
#> [1] "Fleet Constants"
#> 
#> [[1]]$displayPath[[3]]
#> [1] "Flight Dynamics"
#> 
#> [[1]]$displayPath[[4]]
#> [1] "Speed"
```

## Helpers for Discretes or Dimensions

The ‘data sources’ app and json query are not great for handling
discretes or dimensions. Here are a few helper functions to help out.

### Get Possible Dimension/Discrete States

One way to work around this is to get the EMS ids for the possible
discretes. Then you can type these in by hand into your json query.
There are some build in id_table queries to get these lists.

``` r

airframe_id_table <- get_airframe_id_table()
print( head( airframe_id_table ) )
#> # A tibble: 6 × 2
#>   local_id discrete_string
#>      <dbl> <chr>          
#> 1       83 717-200        
#> 2      185 727-200        
#> 3      167 737 (BBJ)      
#> 4      169 737 (BBJ2)     
#> 5      159 737 (BBJ3)     
#> 6      151 737 MAX 10

airframe_engine_id_table <- get_airframe_engine_id_table()
print( head( airframe_engine_id_table ) )
#> # A tibble: 6 × 2
#>   local_id discrete_string   
#>      <dbl> <chr>             
#> 1      124 717-200 BR715     
#> 2      243 727-200 JT8D      
#> 3      212 737 (BBJ) CFM56-7 
#> 4      224 737 (BBJ2) CFM56-7
#> 5      222 737 (BBJ3) CFM56-7
#> 6      210 737 MAX 10 LEAP-1B
```

Or you can get a table of possible discrete states for any field you
want.

``` r
fleet_table <- get_dimension_table(data_source_id = "[ems-core][entity-type][foqa-flights]",
                                   field_id = "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[ems-core][base-field][flight.fleet]]]")
print(head(fleet_table))
#> # A tibble: 6 × 2
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
#> # A tibble: 6 × 6
#>   flight_record fleet    airframe p35_maximum_pressure_…¹ p35_bank_angle_magni…²
#>   <chr>         <chr>    <chr>    <chr>                   <chr>                 
#> 1 3193189       Fleet 03 A320-200 36072 ft                24.2576 degrees       
#> 2 3203702       Fleet 03 A320-200 34048 ft                25.3123 degrees       
#> 3 3208826       Fleet 03 A320-200 38036 ft                26.0154 degrees       
#> 4 3208827       Fleet 03 A320-200 35064 ft                27.7732 degrees       
#> 5 3211863       Fleet 03 A320-200 34052 ft                25.3123 degrees       
#> 6 3211868       Fleet 03 A320-200 35044 ft                28.4764 degrees       
#> # ℹ abbreviated names: ¹​p35_maximum_pressure_altitude_ft,
#> #   ²​p35_bank_angle_magnitude_maximum_while_airborne_degrees
#> # ℹ 1 more variable: p35_pitch_attitude_maximum_while_airborne_degrees <chr>
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
#> # A tibble: 6 × 6
#>   flight_record fleet    airframe p35_maximum_pressure_…¹ p35_bank_angle_magni…²
#>   <chr>         <chr>    <chr>    <chr>                   <chr>                 
#> 1 3137698       Fleet 19 737-800  35968 ft                30.4102 degrees       
#> 2 3137733       Fleet 19 737-800  30018 ft                29.8828 degrees       
#> 3 3137877       Fleet 19 737-800  37015 ft                31.1133 degrees       
#> 4 3137878       Fleet 19 737-800  33970 ft                25.6641 degrees       
#> 5 3137881       Fleet 19 737-800  36018 ft                33.9258 degrees       
#> 6 3137884       Fleet 19 737-800  37013 ft                25.6641 degrees       
#> # ℹ abbreviated names: ¹​p35_maximum_pressure_altitude_ft,
#> #   ²​p35_bank_angle_magnitude_maximum_while_airborne_degrees
#> # ℹ 1 more variable: p35_pitch_attitude_maximum_while_airborne_degrees <chr>
```

## Other Potentially Useful Functions

### List APM Profiles

You can get a list of all available profiles on the system with the
list_all_apm_profiles() function:

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
#> Joining with `by = join_by(record_type)`

example_glossary <- select(example_glossary, name, record_type, item_id, logical_id)
print(head(example_glossary))
#> # A tibble: 6 × 4
#>   name                                            record_type item_id logical_id
#>   <chr>                                           <chr>       <chr>   <chr>     
#> 1 Beginning of File                               timepoint   0       383DAB63-…
#> 2 End of File                                     timepoint   1       FA806D6C-…
#> 3 Begin Airborne Interval                         timepoint   2       25D29FB0-…
#> 4 First Known Phase of Flight                     timepoint   3       AD668953-…
#> 5 Last Valid Data                                 timepoint   4       3522561F-…
#> 6 Rest of File is more than 80% sync errors and … timepoint   5       36507F42-…
```

You can also get a list of the events in a profile

``` r

example_events_df <- apm_events_glossary( profile_id = example_profile_id )
#> Querying for the profile glossary
#> Done.

print( head( example_events_df ) )
#> # A tibble: 6 × 3
#>      id name                                                 comments           
#>   <int> <chr>                                                <chr>              
#> 1     0 Low-Level Windshear                                  "This event indica…
#> 2     1 Risk of Ground Collision due to Low-Level Wind Shear "This event indica…
#> 3     2 EGT Limit Exceedance (Left Outboard Engine)          "This event indica…
#> 4     3 EGT Limit Exceedance (Left Inboard Engine)           "This event indica…
#> 5     4 EGT Limit Exceedance (Center Engine)                 "This event indica…
#> 6     5 EGT Limit Exceedance (Right Inboard Engine)          "This event indica…
```

### More Built In Queries

A built-in query for a summary of the airframe-engine types on the
system

``` r

airframe_summary <- standard_airframe_query()
#> Sending a regular query to EMS ...Done.

print( head( airframe_summary ) )
#> # A tibble: 6 × 5
#>   max_flight_record max_flight_date airframe_engine_type    count_flight_record
#>   <chr>             <chr>           <chr>                                 <int>
#> 1 5670603           Mar 2015        CRJ100/200 CF34-1/3                     373
#> 2 5439176           Dec 2015        767-400ER CF6-80                       4764
#> 3 5498858           Dec 2015        737-800 CFM56-7                       10276
#> 4 5499576           Dec 2015        757-200 PW2000                         7726
#> 5 5575245           Dec 2015        777-200ER Trent 800                    1069
#> 6 5427509           Dec 2015        777-200LR GE90-110/115B                1631
#> # ℹ 1 more variable: airframe <chr>
```

A built-in query for a summary of the fleets on the system

``` r

fleet_summary <- standard_fleet_query()
#> Sending a regular query to EMS ...Done.

print( head( fleet_summary ) )
#> # A tibble: 6 × 4
#>   max_flight_record fleet    count_flights max_flight_month
#>   <chr>             <chr>            <int> <chr>           
#> 1 5439176           Fleet 23          4764 Dec 2015        
#> 2 5265936           Fleet 29            12 Nov 2015        
#> 3 4830154           Fleet 15           593 Apr 2015        
#> 4 5417487           Fleet 03           790 Dec 2015        
#> 5 5427509           Fleet 26          1631 Dec 2015        
#> 6 5499576           Fleet 21          1775 Dec 2015
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
#> # A tibble: 6 × 3
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
#> # A tibble: 6 × 2
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
#> # A tibble: 6 × 3
#>   name                        description                              item_type
#>   <chr>                       <chr>                                    <chr>    
#> 1 FWC- Rud Trav Lim           ""                                       logical_…
#> 2 GMT (hrs)                   "Greenwich Mean Time (i.e. the time at … logical_…
#> 3 Subframe Identifier         ""                                       logical_…
#> 4 Sync Error (error if > 0.5) "A synchronization error (a disruption … logical_…
#> 5 APU Command On (1=On)       "The flight-deck switch for activating … logical_…
#> 6 APU EGT (deg C)             "Exhaust Gas Temperature (EGT) of the A… logical_…
```
