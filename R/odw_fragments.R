
#' Retrieve an ODW Fragment from the EFOQA System
#'
#' @param efoqa_connection A connection object to the EFOQA system. Defaults to the result of `connect_to_efoqa()`.
#' @param fragment_id The numeric ID of the fragment to retrieve.
#' @param fragment_format A string specifying the format of the fragment. Options are `"file"` (default) or `"raw"`
#'
#' @return The requested ODW fragment, as a text string.
#' @export
#'
#' @examples
#' \dontrun{
#' # Retrieve a fragment in file format
#' fragment <- get_odw_fragment(fragment_id = "12345")
#'
#' # Retrieve a fragment in raw format
#' fragment <- get_odw_fragment(fragment_id = "12345", fragment_format = "raw")
#' }
get_odw_fragment <- function( efoqa_connection = connect_to_efoqa(), fragment_id, fragment_format = "file" ){

  if( fragment_format == "file"){
    r <- request_from_ems_api(efoqa_connection, rtype = "GET",
                              uri_keys = c('odw_fragments', 'file'),
                              uri_args = c(efoqa_connection$system_id, fragment_id ) )
  }else if( fragment_format == "raw" ){
    r <- request_from_ems_api(efoqa_connection, rtype = "GET",
                              uri_keys = c('odw_fragments', 'raw'),
                              uri_args = c(efoqa_connection$system_id, fragment_id ) )
  }else{
    stop( "That format is not implemented.")
  }

  raw_content <- httr::content(r, as = "raw")
  text_content <- rawToChar(raw_content)

  return( text_content )
}
