

#' Query for details of a database field group
#'
#' @param field_group_id Target EMS Schema ID for the group of interest
#' @param data_source_id EMS schema ID for target entity / database
#' @param efoqa_connection Optional EMS connection to override default
#'
#' @return List of details for the field group of interest.
#' @export
#'
#' @examples
#' \dontrun{
#' odw_fields <- get_all_field_details_below_group_as_df(
#'   field_group_id = "[-hub-][field-group][[[odw-logical][entity-type][odw-flights]][[--][internal-field-group][root]]]",
#'   data_source_id = "[odw-logical][entity-type][odw-flights] )
#' }

field_groups_query <- function( field_group_id,
                                data_source_id,
                                efoqa_connection = connect_to_efoqa() ){

  r <- request_from_ems_api(efoqa_connection,
                            rtype = "GET",
                            uri_keys = c('database', 'field_group'),
                            uri_args = c(efoqa_connection$system_id, data_source_id),
                            body = list(groupId = field_group_id)
                            )

  field_group_details <- httr::content(r)

  return( field_group_details )
}


field_details_query_as_df <- function( field_id,
                                       data_source_id,
                                       efoqa_connection = connect_to_efoqa() ){

  r <- request_from_ems_api(efoqa_connection,
                            rtype = "GET",
                            uri_keys = c('database', 'field'),
                            uri_args = c(efoqa_connection$system_id, data_source_id, field_id)
  )

  field_details <- httr::content(r)

  if( !( "numberUnits" %in% names( field_details ) ) ){
    field_details$numberUnits <- NA
  }

  field_df <- tibble::tibble( id = field_details$id,
                              type = field_details$type,
                              name = field_details$name,
                              units = field_details$numberUnits )

  return( field_df )

}



#' Get All Field Details for this group and all sub-groups
#'
#' @param field_group_id Target field group EMS schema ID
#' @param data_source_id Target entity database or datasource ID
#' @param exclude_folder_ids Optional vector of field groups to exclude.  Useful to exclude processing folders.
#' @param efoqa_connection optional efoqa connection to use for this operation
#'
#' @return A dataframe with details of all fields in the target field_group_id and all sub-groups.
#' @export
#'
#' @examples
#' \dontrun{
#' odw_fields <- get_all_field_details_below_group_as_df(
#'   field_group_id = "[-hub-][field-group][[[odw-logical][entity-type][odw-flights]][[--][internal-field-group][root]]]",
#'   data_source_id = "[odw-logical][entity-type][odw-flights]",
#'   exclude_folder_ids = c( "[-hub-][field-group][[[odw-logical][entity-type][odw-flights]][[odw-logical][internal-field-group][flight-info]]]" ) )
#' }

get_all_field_details_below_group_as_df <- function( field_group_id,
                                                     data_source_id,
                                                     exclude_folder_ids = NULL,
                                                     efoqa_connection = connect_to_efoqa() ){

  #get the defails for the target fields group
  all_fields_and_groups_at_level <- field_groups_query( field_group_id,
                                                        data_source_id,
                                                        efoqa_connection )

  #get the first level sub-groups / sub-folders
  groups_at_level <- all_fields_and_groups_at_level$groups
  group_ids_at_level <- purrr::map_chr( groups_at_level, ~ .x$id )
  group_ids_at_level_not_excluded <- setdiff( group_ids_at_level, exclude_folder_ids )

  #get the leaf field ids
  fields_at_level <- all_fields_and_groups_at_level$fields
  fields_ids_at_level <- purrr::map_chr( fields_at_level, ~ .x$id )

  #recursively get all of the field details for each sub-group
  fields_below_level <- purrr::map_dfr( group_ids_at_level_not_excluded, get_all_field_details_below_group_as_df,
                                        data_source_id, efoqa_connection)

  #get the field details for all leaf fields
  field_details_at_level <- purrr::map_dfr( fields_ids_at_level, field_details_query_as_df,
                                            data_source_id,
                                            efoqa_connection)

  #combine the field details at this level and all levels below
  all_fields_details <- dplyr::bind_rows( field_details_at_level, fields_below_level )

  return( all_fields_details )

}



#' Get all ODW Logical Item fields on this system
#'
#' @param efoqa_connection optional efoqa connection
#'
#' @return a dataframe with details of the ODW logical item fields
#' @export
#'
#' @examples
#' \dontrun{
#' all_odw_logical_items <- get_odw_logical_item_fields()
#' }
#'
get_odw_logical_item_fields <- function( efoqa_connection = connect_to_efoqa() ){

  odw_fields <- get_all_field_details_below_group_as_df(
    field_group_id = "[-hub-][field-group][[[odw-logical][entity-type][odw-flights]][[--][internal-field-group][root]]]",
    data_source_id = "[odw-logical][entity-type][odw-flights]",
    exclude_folder_ids = c( "[-hub-][field-group][[[odw-logical][entity-type][odw-flights]][[odw-logical][internal-field-group][flight-info]]]" ) )

  return( odw_fields )
}


