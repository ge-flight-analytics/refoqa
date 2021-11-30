#' Get details on any EMS database schema field
#'
#' @param efoqa_connection optional existing efoqa connection for re-use or advanced use
#' @param data_source_id The schema name of the data source id that has the target field
#' @param field_id The schema name of the target field to get details on
#'
#' @return An R list with details on the target field
#' @export
#'
#' @examples
#' \dontrun{
#' get_database_field_details(
#' data_source_id = "[ems-core][entity-type][foqa-flights]",
#' field_id = "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[airframe-engine-field-set][base-field][airframe-engine]]]")
#' }
get_database_field_details <- function( efoqa_connection = connect_to_efoqa(), data_source_id, field_id){

  r <- request_from_ems_api(efoqa_connection, rtype = "GET",
                            uri_keys = c('database', 'field'),
                            uri_args = c(efoqa_connection$system_id, data_source_id, field_id))

  field_details <- httr::content(r)

  return(field_details)

}

#' Get a table of the avilable discrete states for any field
#'
#' @param efoqa_connection optional existing efoqa connection for re-use or advanced use
#' @param data_source_id Schema string for the target data source id
#' @param field_id Schema string for the target field id
#'
#' @return A table of the available discrete states for this field along with their local integer id
#' @export
#'
#' @examples
#' \dontrun{
#' get_dimension_table(
#' efoqa_connection,
#' data_source_id = "[ems-core][entity-type][foqa-flights]",
#' field_id = "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[airframe-engine-field-set][base-field][airframe]]]"
#' )
#' }
get_dimension_table <- function(efoqa_connection = connect_to_efoqa(), data_source_id, field_id){

  field_detail_list <- get_database_field_details( efoqa_connection, data_source_id, field_id)

  temp_discrete_table <- t(dplyr::as_tibble(field_detail_list$discreteValues))

  discrete_table <- dplyr::tibble( local_id = as.numeric(rownames( temp_discrete_table )),
                                   discrete_string = as.character(temp_discrete_table))
  return(discrete_table)

}


#' Get a table of airframes with local ids for this system
#'
#' @param efoqa_connection optional existing efoqa connection for re-use or advanced use
#'
#' @return A dataframe containing a list of all airframes and their local ID.
#' @export
#'
#' @examples
#' \dontrun{
#' get_airframe_id_table()
#' }
get_airframe_id_table <- function( efoqa_connection = connect_to_efoqa() ){

  airframe_discrete_table <- get_dimension_table(efoqa_connection,
                                                 data_source_id = "[ems-core][entity-type][foqa-flights]",
                                                 field_id = "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[airframe-engine-field-set][base-field][airframe]]]")

  return(airframe_discrete_table)
}

#' Get a table of airframe-engines with local ids for this system
#'
#' @param efoqa_connection optional existing efoqa connection for re-use or advanced use
#'
#' @return A dataframe containing a list of all airframe-engines and their local ID.
#' @export
#'
#' @examples
#' \dontrun{
#' get_airframe_engine_id_table()
#' }
get_airframe_engine_id_table <- function( efoqa_connection = connect_to_efoqa() ){

  airframe_engine_discrete_table <- get_dimension_table( efoqa_connection,
                                                   data_source_id = "[ems-core][entity-type][foqa-flights]",
                                                   field_id = "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[airframe-engine-field-set][base-field][airframe-engine]]]")
  return( airframe_engine_discrete_table )
}


#' Add an additional filter to any query list object that will filter for a specific string value of the target field
#'
#' @param efoqa_connection optional existing efoqa connection for re-use or advanced use
#' @param data_source_id Schema string for the target entity type (flights or events)
#' @param query_list An existing query in R list form
#' @param field_id The target field to filter on
#' @param dimension_string The target string name of the discrete to filter to
#'
#' @return The input query list with an additional added filter for the target dimension string
#' @export
#'
#' @examples
#' \dontrun{
#' filter_dimension_by_string( efoqa_connection,
#' data_source_id = "[ems-core][entity-type][foqa-flights]",
#' query_list = standard_flight_query_json,
#' field_id = "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[airframe-engine-field-set][base-field][airframe]]]",
#' dimension_string = "717-200")
#' }
filter_dimension_by_string <- function( efoqa_connection = connect_to_efoqa(), data_source_id,
                                        query_list, field_id, dimension_string){

  #figure out the local id for the target dimension string
  dimension_table <- get_dimension_table(efoqa_connection, data_source_id, field_id)
  target_dimensions <- dplyr::filter(dimension_table, discrete_string == dimension_string)
  target_local_id <- target_dimensions$local_id


  #create the list form of querying for this local id
  leaf_field <- list(type = "field", value = field_id)
  leaf_id <- list(type = "constant", value = target_local_id)
  args_list <- list(leaf_field, leaf_id)
  operator_list <- list(operator = "equal", args = args_list)
  new_filter <- list( type = "filter", value = operator_list)

  #if an existing filter exists, tack this new filter on as an 'and' with the existing filter
  if("filter" %in% names(query_list)){
    existing_filter <- list( type = "filter", value = query_list$filter )
    query_list$filter <- list(operator = "and",
                              args = list(
                                existing_filter,
                                new_filter
                              ))
  }else{
    #otherwise just add it directly
    query_list$filter <- list(operator = "and",
                              args = list(
                                new_filter
                              ))
  }

  return(query_list)
}

#' Add a filter for an airframe-engine by string name rather than ID
#'
#' @param efoqa_connection optional existing efoqa connection for re-use or advanced use
#' @param query_list The target query to add the airframe engine filter to
#' @param target_airframe_engine_string The airframe engine to filter on
#'
#' @return The original target query with an additional filter for the target airframe-engine
#' @export
#'
#' @examples
#' \dontrun{
#' filter_airframe_engine_by_string( efoqa_connection,
#' data_source_id = "[ems-core][entity-type][foqa-flights]",
#' query_list = standard_flight_query_json,
#' target_airframe_engine_string = "717-200")
#' }
filter_airframe_engine_by_string <- function( efoqa_connection = connect_to_efoqa(),
                                              query_list, target_airframe_engine_string ){

  new_query_list <- filter_dimension_by_string( efoqa_connection,
                                                data_source_id = "[ems-core][entity-type][foqa-flights]",
                                                query_list,
                                                field_id = "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[airframe-engine-field-set][base-field][airframe-engine]]]",
                                                dimension_string = target_airframe_engine_string)

  return(new_query_list)
}



