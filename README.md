
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

## Installation

You can install the released version of refoqa from github with:

``` r
insall.packages("devtools")
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
#> Async query connection (query ID: f5f9c699-1c6c-42e0-a216-31a8a3970f4e) deleted.
#> Done.

print(head(all_flights))
#> # A tibble: 6 x 16
#>   flight_record flight_date flight_number fleet   tail_number flight_classifica~
#>   <chr>         <chr>       <chr>         <chr>   <chr>       <chr>             
#> 1 3135409       Oct 2012    0             Fleet ~ GE-704      Scheduled Flights 
#> 2 3135410       Oct 2012    0             Fleet ~ GE-704      Scheduled Flights 
#> 3 3135417       Nov 2012    0             Fleet ~ GE-704      Scheduled Flights 
#> 4 3135418       Nov 2012    0             Fleet ~ GE-704      Scheduled Flights 
#> 5 3135421       Nov 2012    0             Fleet ~ GE-704      Scheduled Flights 
#> 6 3135422       Nov 2012    0             Fleet ~ GE-704      Scheduled Flights 
#> # ... with 10 more variables: airframe <chr>, airframe_engine_type <chr>,
#> #   airframe_group <chr>, takeoff_airport_icao_code <chr>,
#> #   takeoff_airport_iata_code <chr>, takeoff_runway_id <chr>,
#> #   detected_approach <chr>, landing_airport_icao_code <chr>,
#> #   landing_airport_iata_code <chr>, landing_runway_id <chr>
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
#> Async query connection (query ID: a7afaf3d-9ea9-48f6-8993-b99fd3586766) deleted.
#> Done.
#> Sending and opening an async-query to EMS ...
#> Done.
#> === Async call: 1 === 
#> Received up to  25000 rows.
#> === Async call: 2 === 
#> Received up to  50000 rows.
#> === Async call: 3 === 
#> Received up to  56411 rows.
#> Async query connection (query ID: 09e9876c-81a3-47f3-9bfd-1ab7be7b3281) deleted.
#> Done.
#> Joining, by = c("flight_record", "event_record")

print(head(example_event_data))
#> # A tibble: 6 x 28
#>   flight_record event_record event_type       false_positive  severity  status  
#>   <chr>         <chr>        <chr>            <chr>           <chr>     <chr>   
#> 1 3135409       224779       Insufficient En~ Not a False Po~ Caution   FOQA: C~
#> 2 3135409       224780       Insufficient En~ Not a False Po~ Caution   FOQA: C~
#> 3 3135409       224782       Insufficient En~ Not a False Po~ Caution   Unknown 
#> 4 3135409       224784       Insufficient En~ Not a False Po~ Caution   Unknown 
#> 5 3135410       224790       Airspeed Exceed~ Not a False Po~ Informat~ Enginee~
#> 6 3135410       224791       FDR/EMU Marker   Not a False Po~ Informat~ FOQA: C~
#> # ... with 22 more variables: baro_altitude_at_start_of_event_ft <dbl>,
#> #   height_agl_at_start_of_event_ft <dbl>,
#> #   height_above_takeoff_best_estimate_at_start_of_event_ft <dbl>,
#> #   height_above_touchdown_best_estimate_at_start_of_event_ft <dbl>,
#> #   airspeed_calibrated_at_start_of_event_knots <dbl>,
#> #   ground_speed_at_start_of_event_knots <dbl>,
#> #   mach_number_at_start_of_event <dbl>,
#> #   pitch_attitude_captains_or_only_at_start_of_event_deg <dbl>,
#> #   angle_of_attack_best_available_at_start_of_event_deg <dbl>,
#> #   roll_attitude_captains_or_only_at_start_of_event_deg <dbl>,
#> #   vertical_speed_at_start_of_event_ft_min <dbl>,
#> #   heading_magnetic_at_start_of_event_deg <dbl>,
#> #   track_angle_at_start_of_event_deg <dbl>,
#> #   fuel_quantity_kg_at_start_of_event_kg <dbl>,
#> #   latitude_at_start_of_event_deg <dbl>,
#> #   longitude_at_start_of_event_deg <dbl>,
#> #   great_circle_distance_from_liftoff_to_start_of_event_nm <dbl>,
#> #   great_circle_distance_from_start_of_event_to_threshold_nm <dbl>,
#> #   ground_track_distance_from_liftoff_to_start_of_event_nm <dbl>,
#> #   ground_track_distance_from_start_of_event_to_threshold_nm <dbl>,
#> #   gmt_at_start_of_event_hrs <dbl>, gross_weight_kg_at_start_of_event_kg <dbl>
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
#> # A tibble: 6 x 4
#>   flight_record p35_maximum_pressu~ p35_bank_angle_magnit~ p35_pitch_attitude_m~
#>   <chr>         <chr>               <chr>                  <chr>                
#> 1 3135409       39049 ft            26.7188 degrees        14.5898 degrees      
#> 2 3135410       38035 ft            28.125 degrees         13.7109 degrees      
#> 3 3135417       38016 ft            26.3672 degrees        14.5898 degrees      
#> 4 3135418       39021 ft            31.2891 degrees        17.0508 degrees      
#> 5 3135421       38027 ft            28.4766 degrees        14.9414 degrees      
#> 6 3135422       35018 ft            24.2578 degrees        14.5898 degrees
```

### Notes

At least as of right now, the return type of each field is based on your
query. This means that in your json query,

    "format": "display" 

Will return all results as strings.

    "format": "none" 

Will return numbers.

We may change at some point.
