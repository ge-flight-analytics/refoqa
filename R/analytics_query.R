
#' Search for Analytic IDs
#'
#' @param text_to_search Character string to search for in the list of 'analytics'
#' @param efoqa_connection Optional connection list object for re-use and customization
#'
#' @return list containing all analytics found with the search text
#' @export
#'
#' @examples
#' \dontrun{
#' search_for_analytic("Maximum Operating Altitude")
#' }
#'
search_for_analytic <- function(text_to_search, efoqa_connection = connect_to_efoqa() ){

  response <- request_from_ems_api(efoqa_connection, rtype = "GET",
                                   uri_keys = c('analytic', 'search'),
                                   uri_args = c(efoqa_connection$system_id),
                                   body = list(text = text_to_search) )

  content <- httr::content(response)

  return(content)
}

get_analytic_details <- function(analytic_id, flight_id, efoqa_connection){

  analytic_description_query <- list(id = analytic_id)

  response <- request_from_ems_api(efoqa_connection, rtype = "POST",
                                   uri_keys = c('analytic', 'search_f'),
                                   uri_args = c(efoqa_connection$system_id, flight_id),
                                   jsondata = analytic_description_query)

  content <- httr::content(response)

  return(content)
}

get_analytic_metadata <- function(analytic_id, flight_id, efoqa_connection){

  analytic_description_query <- list(id = analytic_id)

  response <- request_from_ems_api(efoqa_connection, rtype = "POST",
                                   uri_keys = c('analytic', 'metadata'),
                                   uri_args = c(efoqa_connection$system_id, flight_id),
                                   jsondata = analytic_description_query)

  content <- httr::content(response)

  return(content)
}

get_analytic_types <- function(analytic_id, flight_id, efoqa_connection){

  metadata <- get_analytic_metadata(analytic_id, flight_id, efoqa_connection)

  metadata_values <- metadata$values

  keys <- purrr::map_chr(metadata_values, function(x) x$key )

  analytic_type_entries <- metadata_values[keys == "DataType"]
  analytic_types <- purrr::map_chr( analytic_type_entries, function( x ) x$value )

  return(analytic_types)
}

get_analytic_name <- function(analytic_id, flight_id, efoqa_connection){

  details <- get_analytic_details(analytic_id, flight_id, efoqa_connection)

  return(details$name)

}

add_result_type <- function(analytic_result, analytic_type){
  analytic_result$type <- analytic_type
  return(analytic_result)
}

remove_nas_and_convert_type <- function( raw_values_list ){

  output_type <- raw_values_list$type

  if(output_type == "String"){
    processed_values <- purrr::map_chr( raw_values_list$values, function( x ) ifelse( is.null( x ), NA, x ) )
  }else{
    processed_values <- purrr::map_dbl( raw_values_list$values, function( x ) ifelse( is.null( x ), NA, x ) )
  }

  return(processed_values)
}


convert_analytics_query_to_dataframe <- function( analytics_content_list, flight_id, efoqa_connection ){

  analytics_results <- analytics_content_list$results

  analytics_ids <- purrr::map_chr( analytics_results, function(x) x$analyticId )
  analytics_names <- purrr::map_chr( analytics_ids, get_analytic_name, flight_id, efoqa_connection )

  analytic_types <- purrr::map_chr( analytics_ids, get_analytic_types, flight_id, efoqa_connection )

  #add in the type into the results data structure
  analytics_results_with_type <- purrr::map2(analytics_results, analytic_types, add_result_type  )

  all_values <- purrr::map( analytics_results_with_type, remove_nas_and_convert_type )

  names(all_values) <- analytics_names

  values_df <- tibble::as_tibble(all_values)
  values_df$offset <- unlist(analytics_content_list$offsets)

  values_df <- janitor::clean_names(values_df)

  values_df

  return(values_df)
}

#' Query the FDW Parameters / Constants / 'Analytics' with an R list defining the query.
#' This form of the query expects you to pass in the json query in the form of an R list.
#'
#' @param flight_id The numeric flight record id to target
#' @param query_list list format of the query to perform.  See API documentation for details.
#' @param efoqa_connection An optional efoqa connection list object for re-use or customization.
#'
#' @return A list object with the results of the analytics query.
#' @export
#'
#' @examples
#' \dontrun{
#' query_list_example <- list(
#'    select = list( list( analyticID = analytic_id_1), list( analyticID = analytic_id_2 ) )
#'    )
#'
#' analytics_query(3135409, query_list_example)
#' }
analytics_query <- function( flight_id, query_list, efoqa_connection = connect_to_efoqa() ){

  response <- request_from_ems_api(efoqa_connection, rtype = "POST",
                       uri_keys = c('analytic', 'query'),
                       uri_args = c(efoqa_connection$system_id, flight_id),
                       jsondata = query_list)

  content <- httr::content(response)

  content_df <- convert_analytics_query_to_dataframe( content, flight_id, efoqa_connection )

  return(content_df)
}


#' Query the FDW Parameters / Constants / 'Analytics'
#'
#' @param flight_id The numeric flight record id to target
#' @param query_json_file A reference to a json file describing the query to perform.  See API documentation for details.
#' @param efoqa_connection An optional efoqa connection list object for re-use or customization.
#'
#' @return A list object with the results of the analytics query.
#' @export
#'
#' @examples
#' \dontrun{
#' analytics_query_from_json(3135409, query_json_file = "./my_query_file.json")
#' }
#'

analytics_query_from_json <- function(flight_id, query_json_file, efoqa_connection = connect_to_efoqa() ){

  json_data <- jsonlite::read_json(query_json_file)

  analytics_results <- analytics_query(flight_id, json_data, efoqa_connection)

  return(analytics_results)
}
