% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DataParameterChecks.R
\name{.check_outcome_type_plausibility}
\alias{.check_outcome_type_plausibility}
\title{Internal function for checking if the outcome type fits well to the data}
\usage{
.check_outcome_type_plausibility(
  data,
  outcome_type,
  outcome_column,
  censoring_indicator,
  event_indicator,
  competing_risk_indicator,
  check_stringency = "strict"
)
}
\arguments{
\item{data}{Data set as loaded using the \code{.load_data} function.}

\item{outcome_type}{Character string indicating the type of outcome being
assessed.}

\item{outcome_column}{Name of the outcome column in the data set.}

\item{censoring_indicator}{Name of censoring indicator.}

\item{event_indicator}{Name of event indicator.}

\item{competing_risk_indicator}{Name of competing risk indicator.}

\item{check_stringency}{Specifies stringency of various checks. This is mostly:
\itemize{
\item \code{strict}: default value used for \code{summon_familiar}. Thoroughly checks
input data. Used internally for checking development data.
\item \code{external_warn}: value used for \code{extract_data} and related methods. Less
stringent checks, but will warn for possible issues. Used internally for
checking data for evaluation and explanation.
\item \code{external}: value used for external methods such as \code{predict}. Less
stringent checks, particularly for identifier and outcome columns, which may
be completely absent. Used internally for \code{predict}.
}}
}
\description{
This function may help identify if the outcome type is plausible
given the outcome data. In practice it also tests whether the outcome column
is actually correct given the outcome type.
}
\keyword{internal}
