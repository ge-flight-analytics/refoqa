% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filter_on_dimensions.R
\name{filter_airframe_engine_by_string}
\alias{filter_airframe_engine_by_string}
\title{Add a filter for an airframe-engine by string name rather than ID}
\usage{
filter_airframe_engine_by_string(
  efoqa_connection = connect_to_efoqa(),
  query_list,
  target_airframe_engine_string,
  data_source_id = "[ems-core][entity-type][foqa-flights]",
  field_id =
    "[-hub-][field][[[ems-core][entity-type][foqa-flights]][[airframe-engine-field-set][base-field][airframe-engine]]]"
)
}
\arguments{
\item{efoqa_connection}{optional existing efoqa connection for re-use or advanced use}

\item{query_list}{The target query to add the airframe engine filter to}

\item{target_airframe_engine_string}{The airframe engine to filter on}

\item{data_source_id}{Optional input for when the data type is not FDW flights.}

\item{field_id}{Optional input for the airframe engine field ID for when the data type is not FDW flights.}
}
\value{
The original target query with an additional filter for the target airframe-engine
}
\description{
Add a filter for an airframe-engine by string name rather than ID
}
\examples{
\dontrun{
filter_airframe_engine_by_string( efoqa_connection,
data_source_id = "[ems-core][entity-type][foqa-flights]",
query_list = standard_flight_query_json,
target_airframe_engine_string = "717-200")
}
}
