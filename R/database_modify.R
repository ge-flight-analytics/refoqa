
utils::globalVariables(c("insert_group"))

create_coloumn_query <- function(df, schema_map){

  #This code is ported over from Rems
  #
  # Inputs:
  #    df (data.frame): A DataFrame of values to input, where the columns are the fieldIds and the entries are values to input.
  #    schema_map (list): A mapping of named dataframe columns to field ids, e.g. list('column1' = '[-hub][schema]')

  # if schema_map is not null, we want to translate column names to fields in EMS, so we need to make sure all of the dataframe
  # columns are also in schema_map, which maps df column names to schemas in EMS
  if (!is.null(schema_map)){
    for (col in colnames(df)){
      if (!(col %in% names(schema_map))){
        cat(sprintf("Column: '%s' found in df, but not in mapper.  Please only pass in columns which should be updated in the target table and for which a
                      schema mapping exists in the supplied mapper list.", col))
        stop("Not all columns in df were found in schema_map.")
      }
    }
  }

  create_columns <- list()

  i <- 1 # Begin to loop over all key:value pairs in row.
  for (i in 1:nrow(df)){
    row <- as.list(df[i,])
    curr_length <- length( create_columns ) # Get length of createColumns field
    next_entry <- curr_length + 1 # Find next entry, which is where we want to put our next row
    create_columns[[next_entry]] <- list() # Add an empty list at next_entry
    j <- 1
    for (name in names(row)){
      # Add all keys and values as {fieldId = key, value = value}
      # Use schema_map to translate dataframe column names into a schema, if schema_map is not null
      if (!is.null(schema_map)){
        create_columns[[next_entry]][[j]] <- list(fieldId = schema_map[[name]], value = row[[name]])
      } else { # if schema_map is not null, assume column names are schemas
        create_columns[[next_entry]][[j]] <- list(fieldId = name, value = row[[name]])
      }
      j <- j + 1
    }
    i <- i + 1
  }

  return( create_columns )
}

create_insert_query <- function( df, schema_map){

  column_query <- create_coloumn_query(df, schema_map)

  insert_query <- list("createColumns" = column_query)

  return(insert_query)

}

create_delete_query <- function( df, schema_map){

  column_query <- create_coloumn_query(df, schema_map)

  delete_query <- list("deleteColumns" = column_query)

  return(delete_query)

}

insert_partial_data_frame <- function( target_partition, input_df_partitioned,
                                       schema_map, data_source_id, efoqa_connection ){

  print( glue::glue( "Running insert on partition {target_partition}" ) )

  df_subset <- dplyr::filter(input_df_partitioned, insert_group == target_partition)
  df_subset <- dplyr::select(df_subset, -insert_group)

  insert_query <- create_insert_query( df_subset, schema_map )

  request_from_ems_api(conn = efoqa_connection,
                       rtype = "POST",
                       uri_keys = c("database", "create"),
                       uri_args = c(efoqa_connection$system_id, data_source_id),
                       jsondata = insert_query )

}

#' Insert Entities from Data Frame
#'
#' @param input_df An R dataframe that should be inserted into the EMS database
#' @param schema_map An R list that maps the dataframe columns to schema monikers.
#' @param data_source_id Schema moniker of database entity type to be deleted.
#' @param efoqa_connection Connection to efoqa for re-use or advanced use.
#'
#' @export
#'
insert_data_frame <- function(input_df, schema_map, data_source_id, efoqa_connection = connect_to_efoqa())
  {

    target_group_number <- round( nrow(input_df) / 500 )
    #batch the input dataframe into groups of 300 so that the insert queries are not so huge.
    input_df_partitioned <- dplyr::mutate( input_df, insert_group = dplyr::row_number() %% target_group_number )

    partition_groups <- unique(input_df_partitioned$insert_group)

    purrr::walk( partition_groups, insert_partial_data_frame,
                 input_df_partitioned, schema_map, data_source_id, efoqa_connection)


  }


#' Delete Entities from Query
#'
#' @param data_source_id Schema moniker of database entity type to be deleted.
#' @param query_list  List form of the query to get the records that should be deleted
#' @param efoqa_connection Connection to efoqa for re-use or advanced use.
#'
#' @return TRUE when completed.
#' @export
#'
delete_from_query <- function( data_source_id, query_list,
                               efoqa_connection = connect_to_efoqa() ){

  target_records <- database_query_from_list( data_source_id, query_list, efoqa_connection )

  if( class( query_list$select ) == "data.frame" ){
    schema_map <- query_list$select$fieldId
    names(schema_map) <- names(target_records)
  }else{
    schema_map <- purrr::map_chr( query_list$select, ~.$fieldId )
    names(schema_map) <- names(target_records)
  }



  delete_query <- create_delete_query( target_records, schema_map)

  query_response <- request_from_ems_api(conn = efoqa_connection,
                                         rtype = "POST",
                                         uri_keys = c("database", "delete"),
                                         uri_args = c(efoqa_connection$system_id, data_source_id),
                                         jsondata = delete_query )

  return(TRUE)
}
