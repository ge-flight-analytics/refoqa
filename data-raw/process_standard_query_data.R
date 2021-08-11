

standard_flight_query_json <- jsonlite::read_json("./data-raw/standard_flight_query_json.json")

global_event_discretes_json <- jsonlite::read_json("./data-raw/global_event_discretes.json")

global_event_measurements_json <- jsonlite::read_json("./data-raw/global_event_msmts.json")


#internal data
usethis::use_data(standard_flight_query_json, global_event_discretes_json, global_event_measurements_json, overwrite = TRUE, internal = TRUE)
