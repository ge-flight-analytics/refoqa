

standard_flight_query_json <- jsonlite::read_json("./data-raw/standard_flight_query_json.json")

global_event_discretes_json <- jsonlite::read_json("./data-raw/global_event_discretes.json")

global_event_measurements_json <- jsonlite::read_json("./data-raw/global_event_msmts.json")

standard_airframe_query_json <- jsonlite::read_json("./data-raw/standard_airframe_query.json")

single_sample_flight_query_json <- jsonlite::read_json("./data-raw/single_sample_flight_query.json")

#internal data
usethis::use_data(
  standard_flight_query_json,
  global_event_discretes_json,
  global_event_measurements_json,
  standard_airframe_query_json,
  single_sample_flight_query_json,
  overwrite = TRUE,
  internal = TRUE)
