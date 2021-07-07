

#' APM Profile Glossary
#'
#' @param profile_id guid string for the profile
#' @param efoqa_connection optional efoqa_connection list
#' @param glossary_format optional format (csv or json)
#'
#' @return Glossary object representing the APM profile (format 'csv' returns a dataframe, 'json' returns a list)
#' @export
#'
#' @examples
#' \dontrun{
#' apm_profile_glossary( profile_id = "a7483c44-9db9-4a44-9eb5-f67681ee52b0")
#' apm_profile_glossary( profile_id = "a7483c44-9db9-4a44-9eb5-f67681ee52b0", glossary_format = "csv" )
#' }
#'
apm_profile_glossary <- function( profile_id , efoqa_connection = connect_to_efoqa(), glossary_format = "json" ){

  cat("Querying for the profile glossary\n")

  r <- request_from_ems_api(efoqa_connection,
                            rtype = "GET",
                            uri_keys = c('profile', 'glossary'),
                            uri_args = c(efoqa_connection$system_id, profile_id),
                            body = list(format = glossary_format))
  cat("Done.\n")

  if(glossary_format == "csv"){
    glossary <- httr::content(r, skip = 2, col_names = TRUE, col_types = "ccccccccccccccc")
    glossary <- janitor::clean_names(glossary)
  }else{
    glossary <- httr::content(r)
  }

  return(glossary)
}
