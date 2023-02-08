
remove_metadata <- function( analytic_result ){

  analytic_result['metadata'] <- NULL

  return(analytic_result)
}


gather_logical_items_recursively <- function( group_id, efoqa_connection, target_category ){

  #execute the query
  response <- request_from_ems_api(efoqa_connection, rtype = "GET",
                                   uri_keys = c('analytic', 'group'),
                                   uri_args = c(efoqa_connection$system_id),
                                   body = list(analyticGroupId = group_id,
                                               category = target_category))

  content <- httr::content(response)

  #process the returned analytics first
  analytics <- content$analytics
  #change results into a dataframe
  logical_parameters <- purrr::map_dfr(analytics, remove_metadata )
  #add in the group id to the dataframe of results
  if(nrow(logical_parameters) > 0){
    logical_parameters$group_id <- group_id
  }

  #then process the sub-groups
  groups <- content$groups
  group_ids <- purrr::map_chr(groups, function(group) as.character( group$id ) )
  sub_logical_parameters <- purrr::map_dfr(group_ids, gather_logical_items_recursively, efoqa_connection, target_category)

  all_logical_parameters <- dplyr::bind_rows(logical_parameters, sub_logical_parameters)

  return(all_logical_parameters)
}


#' Get a list of all FDW logical items ( parameters and constants ) on the system
#'
#' @param efoqa_connection An optional connection for re-use or advanced multi-system use.
#'
#' @return A dataframe with details on all logical items (names, units, uids)
#' @export
#'
#' @examples
#' \dontrun{
#'
#' get_logical_FDW_item_list()
#' }
get_logical_FDW_item_list <- function(efoqa_connection = connect_to_efoqa() ){

  logical_parameters <- gather_logical_items_recursively( group_id = "",
                                                          efoqa_connection,
                                                          target_category = "logical")
  #skip if we don't get any parameters returned
  if(nrow(logical_parameters) == 0){
    return()
  }
  #clean up names
  logical_parameters <- janitor::clean_names(logical_parameters)

  logical_parameters$item_type <- "logical_parameters"


  logical_constants <- gather_logical_items_recursively( group_id = "RG.FlightConstants.Hierarchical",
                                                         efoqa_connection,
                                                         target_category = "full")

  logical_constants$item_type <- "logical_constants"

  logical_items <- dplyr::bind_rows(logical_parameters, logical_constants)

  return( logical_items )
}

