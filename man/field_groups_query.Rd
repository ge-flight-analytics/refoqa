% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/database_fields.R
\name{field_groups_query}
\alias{field_groups_query}
\title{Query for details of a database field group}
\usage{
field_groups_query(
  field_group_id,
  data_source_id,
  efoqa_connection = connect_to_efoqa()
)
}
\arguments{
\item{field_group_id}{Target EMS Schema ID for the group of interest}

\item{data_source_id}{EMS schema ID for target entity / database}

\item{efoqa_connection}{Optional EMS connection to override default}
}
\value{
List of details for the field group of interest.
}
\description{
Query for details of a database field group
}
