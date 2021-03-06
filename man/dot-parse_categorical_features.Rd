% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ParseData.R
\name{.parse_categorical_features}
\alias{.parse_categorical_features}
\title{Internal function for setting categorical features}
\usage{
.parse_categorical_features(data, outcome_type)
}
\arguments{
\item{data}{data.table with feature data}

\item{outcome_type}{character, indicating the type of outcome}

\item{reference}{list with class levels (\code{levels}) and ordering (\code{ordered})
per list entry. Each list entry should have the name of the corresponding
feature. The intended use is that \code{featureInfo} objects are parsed to
generate such a reference.}
}
\value{
data.table with several features converted to factor.
}
\description{
Internal function for setting categorical features
}
\details{
This function parses columns containing feature data to factors if
the data contained therein have logical (TRUE, FALSE), character, or factor
classes.  Unless passed as feature names with \code{reference}, numerical data,
including integers, are not converted to factors.
}
\keyword{internal}
