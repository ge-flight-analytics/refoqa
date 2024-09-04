


utils::globalVariables(c("flight_record", "event_record"))

#' standard_flight_query
#' @description
#' Executes a query for FDW flights returning some of the most commonly used fields.
#'
#' @param efoqa_connection optionally supply an existing connection to the EMS API for re-use.
#'
#' @return A dataframe containing one row per FDW flight with valid data
#'   and columns with some of the most commonly needed fields.
#' @export
#'
#' @examples
#' \dontrun{
#' standard_flight_query()
#' }
standard_flight_query <-
  function(efoqa_connection = connect_to_efoqa()) {
    #standard_flight_query_json is generated with the data-raw process
    standard_flight_query_results <-
      async_database_query(efoqa_connection,
                           data_source_id = "[ems-core][entity-type][foqa-flights]",
                           standard_flight_query_json)

    return(standard_flight_query_results)
  }

#' Standard All Events Query
#' @description
#' Executs a query for all events in the target profile and returns the standard global event fields.
#' This function defaults to running on the library flight safety events profile, but can be modified to use other profiles by changing the data_source_id
#'
#' @param event_data_source_id String representing the datasource ID for events in an EMS profile.
#' @param efoqa_connection Connection list for re-use.
#'
#' @return A dataframe with the standard event fields
#' @export
#'
#' @examples
#' \dontrun{
#' standard_event_query()
#' ds_id = "[ems-apm][entity-type][events:profile-87d17d3479804596a231d1d875c85e1f]"
#' standard_event_query( ds_id )
#' }
standard_event_query <-
  function(event_data_source_id = "[ems-apm][entity-type][events:profile-a7483c449db94a449eb5f67681ee52b0]",
           efoqa_connection = connect_to_efoqa()) {

    event_discrete_results <-  async_database_query(efoqa_connection,
                                                    data_source_id = event_data_source_id,
                                                    global_event_discretes_json)

    names(event_discrete_results) <-
      stringr::str_remove(names(event_discrete_results), "p[0-9]+\\_")


    #if we know this is library flight safety events we can use the global measurements too.
    if (event_data_source_id == "[ems-apm][entity-type][events:profile-a7483c449db94a449eb5f67681ee52b0]") {
      event_measurements_results <-
        async_database_query(efoqa_connection,
                             data_source_id = event_data_source_id,
                             global_event_measurements_json)
      #clean up results for join
      names(event_measurements_results) <-
        stringr::str_remove(names(event_measurements_results), "p[0-9]+\\_")
      event_measurements_results <-
        dplyr::mutate(
          event_measurements_results,
          flight_record = as.character(flight_record),
          event_record = as.character(event_record)
        )

      all_results <-
        dplyr::left_join(event_discrete_results, event_measurements_results)

      return(all_results)

    } else{
      return(event_discrete_results)
    }

  }


#' Standard Airframe Query
#'
#' @param efoqa_connection Optional connection string for re-used or advanced configuration
#'
#' @return A dataframe with one entry per airframe-engine on the system giving the number of flights, and most recent dates and flight records
#' @export
#'
standard_airframe_query <- function( efoqa_connection = connect_to_efoqa() ){


  airframe_query_results <- simple_database_query(efoqa_connection,
                                                  data_source_id = "[ems-core][entity-type][foqa-flights]",
                                                  jsondata = standard_airframe_query_json)

  return(airframe_query_results)
}


single_sample_flight_query <- function( efoqa_connection = connect_to_efoqa() ){

  single_sample_flight_query_results <- simple_database_query(efoqa_connection,
                                                              data_source_id = "[ems-core][entity-type][foqa-flights]",
                                                              jsondata = single_sample_flight_query_json)

  return(single_sample_flight_query_results)
}


standard_pdc_query <- function( efoqa_connection = connect_to_efoqa() ){

  pdc_query_results <- simple_database_query(efoqa_connection,
                                             data_source_id = "[ems-core][entity-type][foqa-flights]",
                                             jsondata = pdc_query_json)

  return(pdc_query_results)
}

#' Standard Fleet Query
#'
#' @param efoqa_connection Optional connection string for re-used or advanced configuration
#'
#' @return A dataframe with one entry per fleet on the system giving the number of flights, and most recent dates and flight records
#' @export
#'

standard_fleet_query <- function( efoqa_connection = connect_to_efoqa() ){

  fleet_query_results <- simple_database_query(efoqa_connection,
                                             data_source_id = "[ems-core][entity-type][foqa-flights]",
                                             jsondata = fleet_query_json)

  return(fleet_query_results)
}


