
utils::globalVariables(c("record_type", "readable_record_type"))

clean_csv_glossary <- function(raw_glossary){
  glossary_with_clean_names <- janitor::clean_names(raw_glossary)

  #clean up the record type
  record_type_df <- tibble::tribble(
    ~record_type, ~readable_record_type,
    "T", "timepoint",
    "I", "interval",
    "M", "measurement",
    "V", "event"
  )
  glossary_with_readable_record_type <- dplyr::left_join(glossary_with_clean_names, record_type_df)

  glossary <- dplyr::mutate(glossary_with_readable_record_type,
                            record_type = ifelse(!is.na(readable_record_type), readable_record_type, record_type))
  glossary <- dplyr::select(glossary, -readable_record_type)

  return(glossary)

}


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
    glossary <- clean_csv_glossary(glossary)

  }else{
    glossary <- httr::content(r)
  }

  return(glossary)
}

#' list_all_apm_profiles
#'
#' @param efoqa_connection optional efoqa_connection list
#'
#' @return A list off all profiles on the system, including names, ids, tree locations, etc.
#' @export
#'
#' @examples
#' \dontrun{
#' all_profiles <- list_all_apm_profiles( )
#' }
list_all_apm_profiles <- function( efoqa_connection = connect_to_efoqa() ){

  cat("Querying for the list of profiles\n")

  r <- request_from_ems_api(efoqa_connection,
                            rtype = "GET",
                            uri_keys = c('profile', 'profiles'),
                            uri_args = c(efoqa_connection$system_id))

  profiles <- httr::content(r)

  return(profiles)
}
