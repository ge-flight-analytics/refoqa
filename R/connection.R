
# connect_to_efoqa is a fork of the 'connect' function in the ge-flight-analytics Rems project.
# request_from_ems_api is a fork of the 'request' class in the ge-flight-analytics Rems project.

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

    header <- c("Content-Type" = "application/x-www-form-urlencoded",
                "User-Agent" = user_agent)
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
      stop(paste("Error:", httr::content(response)$error_description))
    }


    #hardcoding the system_id to 1 for now, I think all systems are standardized to 1 at this point
    connection <- list(
      uri_root = efoqa_server_url,
      token = httr::content(response)$access_token,
      token_type = httr::content(response)$token_type,
      system_id = 1
    )

    return(connection)
  }

request_from_ems_api <-
  function(conn, rtype = "GET", uri_keys = NULL, uri_args = NULL,
           headers = NULL, body = NULL, jsondata = NULL,
           verbose = F)
  {
    # Default encoding is "application/x-www-form-urlencoded"
    encoding <- "form"

    if (is.null(headers)) {
      headers <- c(Authorization = paste(conn$token_type, conn$token),
                   'Accept-Encoding' = 'gzip',
                   'User-Agent' = user_agent)
    }

    if (!is.null(uri_keys)) {
      uri <- paste0(conn$uri_root,
                   uris[[uri_keys[1]]][[uri_keys[2]]])
    }

    if (!is.null(uri_args)) {
      # percent encode the args
      uri_args <- sapply(uri_args, function(x) if (is.na(suppressWarnings(as.numeric(x)))) utils::URLencode(x, reserved = T) else x)
      uri      <- do.call(sprintf, as.list(c(uri, uri_args)))
    }

    if (!is.null(jsondata)) {
      body <- jsondata
      encoding <- "json"
    }

    if (rtype=="GET") {
      tryCatch({
        response <- httr::GET(uri, query = body, httr::add_headers(.headers = headers), encode = encoding)
      }, error = function(err) {
        print(err)
        cat(sprintf("Http status code %s: %s", httr::status_code(response), httr::content(response)))
        cat("Trying to Reconnect EMS...")
        conn = connect_to_efoqa()
        response <- httr::GET(uri, query = body, httr::add_headers(.headers = headers), encode = encoding)
      })
    } else if (rtype=="POST") {
      tryCatch({
        response <- httr::POST(uri, body = body, httr::add_headers(.headers = headers), encode = encoding)
      }, error = function(err) {
        print(err)
        cat(sprintf("Http status code %s: %s", httr::status_code(response), httr::content(response)))
        cat("Trying to Reconnect EMS...\n")
        conn = connect_to_efoqa()
        response <- httr::POST(uri, body = body, httr::add_headers(.headers = headers), encode = encoding)
      })
    } else if (rtype=="DELETE") {
      tryCatch({
        response <- httr::DELETE(uri, body = body, httr::add_headers(.headers = headers), encode = encoding)
      }, error = function(err) {
        print(err)
        cat(sprintf("Http status code %s: %s", httr::status_code(response), httr::content(response)))
        cat("Trying to Reconnect EMS...\n")
        conn = connect_to_efoqa()
        response <- httr::DELETE(uri, body = body, httr::add_headers(.headers = headers), encode = encoding)
      })
    } else {
      stop(sprintf("%s: Unsupported request type.", rtype))
    }

    return( response )
  }
