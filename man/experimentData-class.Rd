% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FamiliarS4Classes.R
\docType{class}
\name{experimentData-class}
\alias{experimentData-class}
\title{Experiment data}
\description{
An experimentData object contains information concerning the experiment.
These objects can be used to instantiate multiple experiments using the same
iterations, feature information and variable importance.
}
\details{
experimentData objects are primarily used to improve
reproducibility, since these allow for training models on a shared
foundation.
}
\section{Slots}{

\describe{
\item{\code{experiment_setup}}{Contains regarding the experimental setup that is used
to generate the iteration list.}

\item{\code{iteration_list}}{List of iteration data that determines which instances
are assigned to training, validation and test sets.}

\item{\code{feature_info}}{Feature information objects. Only available if the
experimentData object was generated using the \code{precompute_feature_info} or
\code{precompute_vimp} functions.}

\item{\code{vimp_table_list}}{List of variable importance table objects. Only
available if the experimentData object was created using the
\code{precompute_vimp} function.}

\item{\code{project_id}}{Identifier of the project that generated the experimentData
object.}

\item{\code{familiar_version}}{Version of the familiar package used to create this
experimentData.}
}}

\seealso{
\code{\link{precompute_data_assignment}}
\code{\link{precompute_feature_info}}, \code{\link{precompute_vimp}}
}
