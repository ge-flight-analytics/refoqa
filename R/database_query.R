
utils::globalVariables(c("discrete_string"))

create_data_frame_from_row <- function(row_of_data, field_names){

  null_removed_row_of_data <- purrr::map(row_of_data, function(x) ifelse(is.null(x), NA, x))
  names(null_removed_row_of_data) <- field_names
  return(tibble::as_tibble(null_removed_row_of_data))

}

ems_api_response_to_dataframe <- function(ems_api_response){

  #I would like to use the tidyr rectangle functions here, but since everything is unnamed I am doing it by hand
  field_names <- purrr::map_chr(ems_api_response$header, function(x) x$name)
  results_data_frame <- purrr::map_dfr(ems_api_response$rows, function(x) create_data_frame_from_row(x, field_names))

  cleaned_data_frame <- janitor::clean_names(results_data_frame)

  return(cleaned_data_frame)
}

# These functions are a fork of similar functions in the 'flt_query.R' source in the ge-flight-analytics Rems project.

open_async_query <- function(efoqa_connection, data_source_id, jsondata) {
  cat('Sending and opening an async-query to EMS ...\n')
  r <- request_from_ems_api(efoqa_connection, rtype = "POST",
                            uri_keys = c('database', 'open_asyncq'),
                            uri_args = c(efoqa_connection$system_id, data_source_id),
                            jsondata = jsondata)
  if (is.null(httr::content(r)$id)) {
    print(httr::headers(r))
    print(httr::content(r))
    stop("Opening Async query did not return the query Id.")
  }
  cat('Done.\n')
  return( httr::content(r) )
}

simple_database_query <- function(efoqa_connection, data_source_id, jsondata)
{

  cat("Sending a regular query to EMS ...")
  r <- request_from_ems_api(efoqa_connection, rtype = "POST",
                            uri_keys = c('database', 'query'),
                            uri_args = c(efoqa_connection$system_id, data_source_id),
                            jsondata = jsondata)
  cat("Done.\n")

  results_dataframe <- ems_api_response_to_dataframe( httr::content(r) )

  return( results_dataframe )
}

async_database_query <- function(efoqa_connection, data_source_id, jsondata, n_row = 25000)
{

  async_query <- open_async_query(efoqa_connection, data_source_id, jsondata)

  ctr <- 1
  df  <- tibble::tibble()

  while(T) {
    cat(sprintf("=== Async call: %d === \n", ctr))
    tryCatch({
      # Mini batch async call. Sometimes the issued query ID gets expired.
      # In that case, try up to three times until getting a new query ID.
      for(i in 1:3) {
        response <- request_from_ems_api(efoqa_connection, rtype = "GET",
                                         uri_keys = c('database', 'get_asyncq'),
                                         uri_args = c(efoqa_connection$system_id,
                                                      data_source_id,
                                                      async_query$id,
                                                      formatC(n_row*(ctr-1), format="d"),
                                                      formatC(n_row*ctr-1, format="d")))
        if (is.null(httr::content(response)$rows)) {
          # Reopen the query if not returning data
          async_query <- open_async_query(efoqa_connection, data_source_id, jsondata)
        } else {
          break
        }
      }
      response_content <- httr::content(response)
      response_content$header <- async_query$header
    }, error = function(e) {
      cat("Something's wrong. Returning what has been sent so far.\n")
      print(httr::headers(response))
    })
    if (length(response_content$rows) < 1) {
      break
    }
    incremental_df <- ems_api_response_to_dataframe(response_content)
    df <- rbind(df, incremental_df)
    cat(sprintf("Received up to  %d rows.\n", nrow(df)))
    if (nrow(incremental_df) < n_row) {
      break
    }
    ctr <- ctr + 1
  }
  tryCatch({
    r <- request_from_ems_api(efoqa_connection, rtype = "DELETE",
                              uri_keys = c('database', 'close_asyncq'),
                              uri_args = c(efoqa_connection$system_id, data_source_id, async_query$id))
    cat(sprintf("Async query connection (query ID: %s) deleted.\n", async_query$id))
  }, error = function(e) {
    cat(sprintf("Couldn't delete the async query (query ID: %s). Probably it was already expired.\n", async_query$id))
  })

  cat("Done.\n")
  return(df)
}



#' Execute Database Query from R List
#'
#' @param data_source_id String for EMS data source / database ID.  For example FDW Flights = "[ems-core][entity-type][foqa-flights]"
#' @param query_list  R list object containing the EMS API query to execute
#' @param efoqa_connection Optional if you want to re-use an existing connection to the API.
#'
#' @return The results of the EMS database query as a dataframe.  Note that no type conversions are performed.  Result types will depend on the 'format' flag in the query.
#' @export
#'
#' @examples
#' \dontrun{
#' database_query_from_json("[ems-core][entity-type][foqa-flights]",
#'   query_list = standard_flight_query_json)
#' }
#'
database_query_from_list <- function( data_source_id, query_list, efoqa_connection = connect_to_efoqa() ){

  #run the simple non async query only if there is a 'top n' limiter
  if( !is.null( query_list$top ) && ( query_list$top < 25000 ) ){
    query_results <- simple_database_query(efoqa_connection, data_source_id, query_list)
  }else{
    query_results <- async_database_query(efoqa_connection, data_source_id, query_list)
  }

  return(query_results)
}

#' database_query_from_json
#' @description
#' Executes an EMS database query for the supplied json query file.
#'
#' @param data_source_id String for EMS data source / database ID.  For example FDW Flights = "[ems-core][entity-type][foqa-flights]"
#' @param json_file  The path to the query you want to run in json file form.  For example "./test_query.json"
#' @param efoqa_connection Optional if you want to re-use an existing connection to the API.
#'
#' @return The results of the EMS database query as a dataframe.  Note that no type conversions are performed.  Result types will depend on the 'format' flag in the query.
#' @export
#'
#' @examples
#' \dontrun{
#' database_query_from_json("[ems-core][entity-type][foqa-flights]",
#'   json_file = "./my_query_file.json")
#' }
#'
#'
database_query_from_json <- function(data_source_id, json_file, efoqa_connection = connect_to_efoqa()){

  query_list <- jsonlite::read_json(json_file)

  query_results <- database_query_from_list( data_source_id, query_list, efoqa_connection )

  return(query_results)
}
