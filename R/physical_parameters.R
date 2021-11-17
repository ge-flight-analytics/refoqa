
utils::globalVariables(c("flight_id", "description"))

#' Get a list of all physical parameters for a given flight record.
#'
#' @param flight_id The numeric flight id for the flight to get physical parameters for.
#' @param efoqa_connection An optional connection for re-use or advanced multi-system use.
#'
#' @return A dataframe with details on all physical parameters (names, units, uids)
#' @export
#'
#' @examples
#' \dontrun{
#'
#' get_physical_parameters_for_flight(3135409)
#' }
get_physical_parameters_for_flight <- function(flight_id, efoqa_connection = connect_to_efoqa() ){

  #execute the query
  response <- request_from_ems_api(efoqa_connection, rtype = "GET",
                                   uri_keys = c('analytic', 'group_f'),
                                   uri_args = c(efoqa_connection$system_id, flight_id),
                                   body = list(category="physical"))

  content <- httr::content(response)

  #clean up the results.
  physical_parameters <- purrr::map_dfr(content$analytics, function(x) return(x))
  physical_parameters <- janitor::clean_names(physical_parameters)
  physical_parameters <- dplyr::mutate(physical_parameters,
                                       uid = stringr::str_match(description, "Uid: (.*)\\sName:")[,2])
  physical_parameters <- dplyr::select(physical_parameters, -description)

  #add in the flight id for down stream tracking.
  physical_parameters$flight_id <- flight_id

  return( physical_parameters )
}

#' Get a list of all physical parameters for all PDCs/LFLs on the system.
#'
#' @param efoqa_connection An optional connection for re-use or advanced multi-system use.
#'
#' @return A dataframe with details on all physical parameters (names, units, uids) for all PDCs/LFLs on the system.
#' @export
#'
#' @examples
#' \dontrun{
#'
#' get_all_physical_parameters()
#' }
get_all_physical_parameters <- function( efoqa_connection = connect_to_efoqa() ){

  #get dataframe of all pdcs on system with an example flight from each
  all_pdcs <- standard_pdc_query( efoqa_connection )

  #iterate through the example flight records for reach PDC and get a list of physical parameters
  all_physical_parameters <- purrr::map_dfr( all_pdcs$max_flight_record, get_physical_parameters_for_flight, efoqa_connection )

  #join back in the original pdc details
  physical_param_details <- dplyr::left_join( all_physical_parameters, all_pdcs, by=c("flight_id"="max_flight_record") )
  physical_param_details <- dplyr::select(physical_param_details, -flight_id)

  return(physical_param_details)

}
