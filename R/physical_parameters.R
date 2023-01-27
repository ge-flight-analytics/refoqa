
utils::globalVariables(c("flight_id", "description", "key", "value"))

#this function will take the analytic result and flatten out the metadata returned so that everything can be put into a single dataframe
flatten_metadata <- function( analytic_result ){

  metadata <- analytic_result$metadata

  metadata_df <- purrr::map_dfr( metadata, ~ list( key = .x$key, value = as.character( .x$value ) ) )
  metadata_df$key <- janitor::make_clean_names( metadata_df$key )
  wide_metadata <- tidyr::pivot_wider( metadata_df, names_from = key )

  #remove the metadata from the analytic result
  analytic_result['metadata'] <- NULL

  #and then bind in the wide version
  results_with_metadata <- dplyr::bind_cols( analytic_result, wide_metadata)

  return(results_with_metadata)
}

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
                                   body = list(category="physical",
                                               includeMetadata="true"))

  content <- httr::content(response)

  #change results into a dataframe
  physical_parameters <- purrr::map_dfr(content$analytics, flatten_metadata )
  #skip if we don't get any parameters returned
  if(nrow(physical_parameters) == 0){
    return()
  }
  #clean up results
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

  #if there are no database returns for actual flights, return nothing
  if(nrow(all_pdcs) == 0){
    return()
  }


  #iterate through the example flight records for reach PDC and get a list of physical parameters
  all_physical_parameters <- purrr::map_dfr( all_pdcs$max_flight_record, get_physical_parameters_for_flight, efoqa_connection )

  #join back in the original pdc details
  physical_param_details <- dplyr::left_join( all_physical_parameters, all_pdcs, by=c("flight_id"="max_flight_record") )
  physical_param_details <- dplyr::select(physical_param_details, -flight_id)

  return(physical_param_details)

}
