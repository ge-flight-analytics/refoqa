


#' Connect to EMS and get the Auth token.
#'
#' @param efoqa_user String, eFOQA username
#' @param efoqa_password String, eFOQA password
#' @param efoqa_server_url String, eFOQA server
#' @return a Connection object.

#' @export
connect_to_efoqa <-
  function(efoqa_user = Sys.getenv("EFOQAUSER"),
           efoqa_password =  Sys.getenv("EFOQAPASSWORD"),
           efoqa_server_url = Sys.getenv("EFOQASERVER"))
  {
    # Prevent from the Peer certificate error ("Error in curl::curl_fetch_memory(url, handle = handle) :
    # Peer certificate cannot be authenticated with given CA certificates")
    httr::set_config(httr::config(ssl_verifypeer = 0))

    header <- c("Content-Type" = "application/x-www-form-urlencoded", "User-Agent" = "refoqa")
    body <- list(grant_type = "password",
                 username   = efoqa_user,
                 password   = efoqa_password)

    token_uri = paste0(efoqa_server_url, uris$sys$auth)


    response <- httr::POST(
      token_uri,
      httr::add_headers(.headers = header),
      body = body,
      encode = "form"
    )


    if (!is.null(httr::content(response)$message)) {
      print(paste("Message:", httr::content(response)$message))
    }

    if (httr::http_error(response)) {
      stop(paste("Message:", httr::content(response)$error_description))
    }


    connection <- list(
      token      = httr::content(response)$access_token,
      token_type = httr::content(response)$token_type
    )

    return(connection)
  }
