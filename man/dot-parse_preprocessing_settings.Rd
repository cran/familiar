% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ParseSettings.R
\name{.parse_preprocessing_settings}
\alias{.parse_preprocessing_settings}
\title{Internal function for parsing settings related to preprocessing}
\usage{
.parse_preprocessing_settings(
  config = NULL,
  data,
  parallel,
  outcome_type,
  feature_max_fraction_missing = waiver(),
  sample_max_fraction_missing = waiver(),
  filter_method = waiver(),
  univariate_test_threshold = waiver(),
  univariate_test_threshold_metric = waiver(),
  univariate_test_max_feature_set_size = waiver(),
  low_var_minimum_variance_threshold = waiver(),
  low_var_max_feature_set_size = waiver(),
  robustness_icc_type = waiver(),
  robustness_threshold_metric = waiver(),
  robustness_threshold_value = waiver(),
  transformation_method = waiver(),
  transformation_optimisation_criterion = waiver(),
  transformation_gof_test_p_value = waiver(),
  normalisation_method = waiver(),
  batch_normalisation_method = waiver(),
  imputation_method = waiver(),
  cluster_method = waiver(),
  cluster_linkage_method = waiver(),
  cluster_cut_method = waiver(),
  cluster_similarity_metric = waiver(),
  cluster_similarity_threshold = waiver(),
  cluster_representation_method = waiver(),
  parallel_preprocessing = waiver(),
  ...
)
}
\arguments{
\item{config}{A list of settings, e.g. from an xml file.}

\item{data}{Data set as loaded using the \code{.load_data} function.}

\item{parallel}{Logical value that whether familiar uses parallelisation. If
\code{FALSE} it will override \code{parallel_preprocessing}.}

\item{outcome_type}{Type of outcome found in the data set.}

\item{feature_max_fraction_missing}{(\emph{optional}) Numeric value between \code{0.0}
and \code{0.95} that determines the meximum fraction of missing values that
still allows a feature to be included in the data set. All features with a
missing value fraction over this threshold are not processed further. The
default value is \code{0.30}.}

\item{sample_max_fraction_missing}{(\emph{optional}) Numeric value between \code{0.0}
and \code{0.95} that determines the maximum fraction of missing values that
still allows a sample to be included in the data set. All samples with a
missing value fraction over this threshold are excluded and not processed
further. The default value is \code{0.30}.}

\item{filter_method}{(\emph{optional}) One or methods used to reduce
dimensionality of the data set by removing irrelevant or poorly
reproducible features.

Several method are available:
\itemize{
\item \code{none} (default): None of the features will be filtered.
\item \code{low_variance}: Features with a variance below the
\code{low_var_minimum_variance_threshold} are filtered. This can be useful to
filter, for example, genes that are not differentially expressed.
\item \code{univariate_test}: Features undergo a univariate regression using an
outcome-appropriate regression model. The p-value of the model coefficient
is collected. Features with coefficient p or q-value above the
\code{univariate_test_threshold} are subsequently filtered.
\item \code{robustness}: Features that are not sufficiently robust according to the
intraclass correlation coefficient are filtered. Use of this method
requires that repeated measurements are present in the data set, i.e. there
should be entries for which the sample and cohort identifiers are the same.
}

More than one method can be used simultaneously. Features with singular
values are always filtered, as these do not contain information.}

\item{univariate_test_threshold}{(\emph{optional}) Numeric value between \code{1.0} and
\code{0.0} that determines which features are irrelevant and will be filtered by
the \code{univariate_test}. The p or q-values are compared to this threshold.
All features with values above the threshold are filtered. The default
value is \code{0.20}.}

\item{univariate_test_threshold_metric}{(\emph{optional}) Metric used with the to
compare the \code{univariate_test_threshold} against. The following metrics can
be chosen:
\itemize{
\item \code{p_value} (default): The unadjusted p-value of each feature is used for
to filter features.
\item \code{q_value}: The q-value (Story, 2002), is used to filter features. Some
data sets may have insufficient samples to compute the q-value. The
\code{qvalue} package must be installed from Bioconductor to use this method.
}}

\item{univariate_test_max_feature_set_size}{(\emph{optional}) Maximum size of the
feature set after the univariate test. P or q values of features are
compared against the threshold, but if the resulting data set would be
larger than this setting, only the most relevant features up to the desired
feature set size are selected.

The default value is \code{NULL}, which causes features to be filtered based on
their relevance only.}

\item{low_var_minimum_variance_threshold}{(required, if used) Numeric value
that determines which features will be filtered by the \code{low_variance}
method. The variance of each feature is computed and compared to the
threshold. If it is below the threshold, the feature is removed.

This parameter has no default value and should be set if \code{low_variance} is
used.}

\item{low_var_max_feature_set_size}{(\emph{optional}) Maximum size of the feature
set after filtering features with a low variance. All features are first
compared against \code{low_var_minimum_variance_threshold}. If the resulting
feature set would be larger than specified, only the most strongly varying
features will be selected, up to the desired size of the feature set.

The default value is \code{NULL}, which causes features to be filtered based on
their variance only.}

\item{robustness_icc_type}{(\emph{optional}) String indicating the type of
intraclass correlation coefficient (\code{1}, \code{2} or \code{3}) that should be used to
compute robustness for features in repeated measurements. These types
correspond to the types in Shrout and Fleiss (1979). The default value is
\code{1}.}

\item{robustness_threshold_metric}{(\emph{optional}) String indicating which
specific intraclass correlation coefficient (ICC) metric should be used to
filter features. This should be one of:
\itemize{
\item \code{icc}: The estimated ICC value itself.
\item \code{icc_low} (default): The estimated lower limit of the 95\% confidence
interval of the ICC, as suggested by Koo and Li (2016).
\item \code{icc_panel}: The estimated ICC value over the panel average, i.e. the ICC
that would be obtained if all repeated measurements were averaged.
\item \code{icc_panel_low}: The estimated lower limit of the 95\% confidence interval
of the panel ICC.
}}

\item{robustness_threshold_value}{(\emph{optional}) The intraclass correlation
coefficient value that is as threshold. The default value is \code{0.70}.}

\item{transformation_method}{(\emph{optional}) The transformation method used to
change the distribution of the data to be more normal-like. The following
methods are available:
\itemize{
\item \code{none}: This disables transformation of features.
\item \code{yeo_johnson}: Transformation using the location and scale invariant
version of the Yeo-Johnson transformation (Yeo and Johnson, 2000;
Zwanenburg and Löck, 2023).
\item \code{yeo_johnson_robust} (default): A robust version of \code{yeo_johnson}.
This method is less sensitive to outliers.
\item \code{yeo_johnson_conventional}: As \code{yeo_johnson}, but without optimisation of
location and scale parameters. This method is equivalent to the original
transformation proposed by Yeo and Johnson (2001).
\item \code{box_cox}: Transformation using the location and scale invariant version
of the Box-Cox transformation (Box and Cox, 1964; Zwanenburg and Löck,
2023).
\item \code{box_cox_robust}: A robust version of \code{yeo_johnson}. This method is less
sensitive to outliers.
\item \code{box_cox_conventional}: As \code{box_cox}, but without optimisation of
location and scale parameters. This method is equivalent to the original
transformation proposed by Box and Cox (1964). This method requires
strictly positive feature values.
}

Transformation requires the \code{power.transform} package. Only features that
contain numerical data are transformed. Transformation parameters obtained
in development data are stored within \code{featureInfo} objects for later use
with validation data sets.}

\item{transformation_optimisation_criterion}{(\emph{optional}) Transformation
parameters are optimised using a criterion, conventionally
maximum-likelihood-estimation. \code{power.transform} implements multiple
optimisation criteria, of which the following are available:
\itemize{
\item \code{mle} (default): Optimisation using maximum likelihood estimation.
\item \code{cramer_von_mises}: Optimisation using the Cramér-von Mises
criterion. Zwanenburg and Löck (2023) found that this criterion was
relatively robust against outliers.
}}

\item{transformation_gof_test_p_value}{(\emph{optional}) Not all transformations
will lead to features that are roughly normally distributed. Zwanenburg and
Löck (2023) established a empirical goodness-of-fit test for central
normality. This parameter sets the significance for rejecting the
null-hypothesis that a feature distribution is centrally normal. When the
null-hypothesis is rejected, no transformation is performed. The default
value is \code{NULL}, which disables the test.}

\item{normalisation_method}{(\emph{optional}) The normalisation method used to
improve the comparability between numerical features that may have very
different scales. The following normalisation methods can be chosen:
\itemize{
\item \code{none}: This disables feature normalisation.
\item \code{standardisation}: Features are normalised by subtraction of their mean
values and division by their standard deviations. This causes every feature
to be have a center value of 0.0 and standard deviation of 1.0.
\item \code{standardisation_trim}: As \code{standardisation}, but based on the set of
feature values where the 5\% lowest and 5\% highest values are discarded.
This reduces the effect of outliers.
\item \code{standardisation_winsor}: As \code{standardisation}, but based on the set of
feature values where the 5\% lowest and 5\% highest values are winsorised.
This reduces the effect of outliers.
\item \code{standardisation_robust} (default): A robust version of \code{standardisation}
that relies on computing Huber's M-estimators for location and scale.
\item \code{normalisation}: Features are normalised by subtraction of their minimum
values and division by their ranges. This maps all feature values to a
\eqn{[0, 1]} interval.
\item \code{normalisation_trim}: As \code{normalisation}, but based on the set of feature
values where the 5\% lowest and 5\% highest values are discarded. This
reduces the effect of outliers.
\item \code{normalisation_winsor}: As \code{normalisation}, but based on the set of
feature values where the 5\% lowest and 5\% highest values are winsorised.
This reduces the effect of outliers.
\item \code{quantile}: Features are normalised by subtraction of their median values
and division by their interquartile range.
\item \code{mean_centering}: Features are centered by substracting the mean, but do
not undergo rescaling.
}

Only features that contain numerical data are normalised. Normalisation
parameters obtained in development data are stored within \code{featureInfo}
objects for later use with validation data sets.}

\item{batch_normalisation_method}{(\emph{optional}) The method used for batch
normalisation. Available methods are:
\itemize{
\item \code{none} (default): This disables batch normalisation of features.
\item \code{standardisation}: Features within each batch are normalised by
subtraction of the mean value and division by the standard deviation in
each batch.
\item \code{standardisation_trim}: As \code{standardisation}, but based on the set of
feature values where the 5\% lowest and 5\% highest values are discarded.
This reduces the effect of outliers.
\item \code{standardisation_winsor}: As \code{standardisation}, but based on the set of
feature values where the 5\% lowest and 5\% highest values are winsorised.
This reduces the effect of outliers.
\item \code{standardisation_robust}: A robust version of \code{standardisation} that
relies on computing Huber's M-estimators for location and scale within each
batch.
\item \code{normalisation}: Features within each batch are normalised by subtraction
of their minimum values and division by their range in each batch. This
maps all feature values in each batch to a \eqn{[0, 1]} interval.
\item \code{normalisation_trim}: As \code{normalisation}, but based on the set of feature
values where the 5\% lowest and 5\% highest values are discarded. This
reduces the effect of outliers.
\item \code{normalisation_winsor}: As \code{normalisation}, but based on the set of
feature values where the 5\% lowest and 5\% highest values are winsorised.
This reduces the effect of outliers.
\item \code{quantile}: Features in each batch are normalised by subtraction of the
median value and division by the interquartile range of each batch.
\item \code{mean_centering}: Features in each batch are centered on 0.0 by
substracting the mean value in each batch, but are not rescaled.
\item \code{combat_parametric}: Batch adjustments using parametric empirical Bayes
(Johnson et al, 2007). \code{combat_p} leads to the same method.
\item \code{combat_non_parametric}: Batch adjustments using non-parametric empirical
Bayes (Johnson et al, 2007). \code{combat_np} and \code{combat} lead to the same
method. Note that we reduced complexity from O(\eqn{n^2}) to O(\eqn{n}) by
only computing batch adjustment parameters for each feature on a subset of
50 randomly selected features, instead of all features.
}

Only features that contain numerical data are normalised using batch
normalisation. Batch normalisation parameters obtained in development data
are stored within \code{featureInfo} objects for later use with validation data
sets, in case the validation data is from the same batch.

If validation data contains data from unknown batches, normalisation
parameters are separately determined for these batches.

Note that for both empirical Bayes methods, the batch effect is assumed to
produce results across the features. This is often true for things such as
gene expressions, but the assumption may not hold generally.

When performing batch normalisation, it is moreover important to check that
differences between batches or cohorts are not related to the studied
endpoint.}

\item{imputation_method}{(\emph{optional}) Method used for imputing missing
feature values. Two methods are implemented:
\itemize{
\item \code{simple}: Simple replacement of a missing value by the median value (for
numeric features) or the modal value (for categorical features).
\item \code{lasso}: Imputation of missing value by lasso regression (using \code{glmnet})
based on information contained in other features.
}

\code{simple} imputation precedes \code{lasso} imputation to ensure that any missing
values in predictors required for \code{lasso} regression are resolved. The
\code{lasso} estimate is then used to replace the missing value.

The default value depends on the number of features in the dataset. If the
number is lower than 100, \code{lasso} is used by default, and \code{simple}
otherwise.

Only single imputation is performed. Imputation models and parameters are
stored within \code{featureInfo} objects for later use with validation data
sets.}

\item{cluster_method}{(\emph{optional}) Clustering is performed to identify and
replace redundant features, for example those that are highly correlated.
Such features do not carry much additional information and may be removed
or replaced instead (Park et al., 2007; Tolosi and Lengauer, 2011).

The cluster method determines the algorithm used to form the clusters. The
following cluster methods are implemented:
\itemize{
\item \code{none}: No clustering is performed.
\item \code{hclust} (default): Hierarchical agglomerative clustering. If the
\code{fastcluster} package is installed, \code{fastcluster::hclust} is used (Muellner
2013), otherwise \code{stats::hclust} is used.
\item \code{agnes}: Hierarchical clustering using agglomerative nesting (Kaufman and
Rousseeuw, 1990). This algorithm is similar to \code{hclust}, but uses the
\code{cluster::agnes} implementation.
\item \code{diana}: Divisive analysis hierarchical clustering. This method uses
divisive instead of agglomerative clustering (Kaufman and Rousseeuw, 1990).
\code{cluster::diana} is used.
\item \code{pam}: Partioning around medioids. This partitions the data into $k$
clusters around medioids (Kaufman and Rousseeuw, 1990). $k$ is selected
using the \code{silhouette} metric. \code{pam} is implemented using the
\code{cluster::pam} function.
}

Clusters and cluster information is stored within \code{featureInfo} objects for
later use with validation data sets. This enables reproduction of the same
clusters as formed in the development data set.}

\item{cluster_linkage_method}{(\emph{optional}) Linkage method used for
agglomerative clustering in \code{hclust} and \code{agnes}. The following linkage
methods can be used:
\itemize{
\item \code{average} (default): Average linkage.
\item \code{single}: Single linkage.
\item \code{complete}: Complete linkage.
\item \code{weighted}: Weighted linkage, also known as McQuitty linkage.
\item \code{ward}: Linkage using Ward's minimum variance method.
}

\code{diana} and \code{pam} do not require a linkage method.}

\item{cluster_cut_method}{(\emph{optional}) The method used to define the actual
clusters. The following methods can be used:
\itemize{
\item \code{silhouette}: Clusters are formed based on the silhouette score
(Rousseeuw, 1987). The average silhouette score is computed from 2 to
\eqn{n} clusters, with \eqn{n} the number of features. Clusters are only
formed if the average silhouette exceeds 0.50, which indicates reasonable
evidence for structure. This procedure may be slow if the number of
features is large (>100s).
\item \code{fixed_cut}: Clusters are formed by cutting the hierarchical tree at the
point indicated by the \code{cluster_similarity_threshold}, e.g. where features
in a cluster have an average Spearman correlation of 0.90. \code{fixed_cut} is
only available for \code{agnes}, \code{diana} and \code{hclust}.
\item \code{dynamic_cut}: Dynamic cluster formation using the cutting algorithm in
the \code{dynamicTreeCut} package. This package should be installed to select
this option. \code{dynamic_cut} can only be used with \code{agnes} and \code{hclust}.
}

The default options are \code{silhouette} for partioning around medioids (\code{pam})
and \code{fixed_cut} otherwise.}

\item{cluster_similarity_metric}{(\emph{optional}) Clusters are formed based on
feature similarity. All features are compared in a pair-wise fashion to
compute similarity, for example correlation. The resulting similarity grid
is converted into a distance matrix that is subsequently used for
clustering. The following metrics are supported to compute pairwise
similarities:
\itemize{
\item \code{mutual_information} (default): normalised mutual information.
\item \code{mcfadden_r2}: McFadden's pseudo R-squared (McFadden, 1974).
\item \code{cox_snell_r2}: Cox and Snell's pseudo R-squared (Cox and Snell, 1989).
\item \code{nagelkerke_r2}: Nagelkerke's pseudo R-squared (Nagelkerke, 1991).
\item \code{spearman}: Spearman's rank order correlation.
\item \code{kendall}: Kendall rank correlation.
\item \code{pearson}: Pearson product-moment correlation.
}

The pseudo R-squared metrics can be used to assess similarity between mixed
pairs of numeric and categorical features, as these are based on the
log-likelihood of regression models. In \code{familiar}, the more informative
feature is used as the predictor and the other feature as the reponse
variable. In numeric-categorical pairs, the numeric feature is considered
to be more informative and is thus used as the predictor. In
categorical-categorical pairs, the feature with most levels is used as the
predictor.

In case any of the classical correlation coefficients (\code{pearson},
\code{spearman} and \code{kendall}) are used with (mixed) categorical features, the
categorical features are one-hot encoded and the mean correlation over all
resulting pairs is used as similarity.}

\item{cluster_similarity_threshold}{(\emph{optional}) The threshold level for
pair-wise similarity that is required to form clusters using \code{fixed_cut}.
This should be a numerical value between 0.0 and 1.0. Note however, that a
reasonable threshold value depends strongly on the similarity metric. The
following are the default values used:
\itemize{
\item \code{mcfadden_r2} and \code{mutual_information}: \code{0.30}
\item \code{cox_snell_r2} and \code{nagelkerke_r2}: \code{0.75}
\item \code{spearman}, \code{kendall} and \code{pearson}: \code{0.90}
}

Alternatively, if the \verb{fixed cut} method is not used, this value determines
whether any clustering should be performed, because the data may not
contain highly similar features. The default values in this situation are:
\itemize{
\item \code{mcfadden_r2}  and \code{mutual_information}: \code{0.25}
\item \code{cox_snell_r2} and \code{nagelkerke_r2}: \code{0.40}
\item \code{spearman}, \code{kendall} and \code{pearson}: \code{0.70}
}

The threshold value is converted to a distance (1-similarity) prior to
cutting hierarchical trees.}

\item{cluster_representation_method}{(\emph{optional}) Method used to determine
how the information of co-clustered features is summarised and used to
represent the cluster. The following methods can be selected:
\itemize{
\item \code{best_predictor} (default): The feature with the highest importance
according to univariate regression with the outcome is used to represent
the cluster.
\item \code{medioid}: The feature closest to the cluster center, i.e. the feature
that is most similar to the remaining features in the cluster, is used to
represent the feature.
\item \code{mean}: A meta-feature is generated by averaging the feature values for
all features in a cluster. This method aligns all features so that all
features will be positively correlated prior to averaging. Should a cluster
contain one or more categorical features, the \code{medioid} method will be used
instead, as averaging is not possible. Note that if this method is chosen,
the \code{normalisation_method} parameter should be one of \code{standardisation},
\code{standardisation_trim}, \code{standardisation_winsor} or \code{quantile}.`
}

If the \code{pam} cluster method is selected, only the \code{medioid} method can be
used. In that case 1 medioid is used by default.}

\item{parallel_preprocessing}{(\emph{optional}) Enable parallel processing for the
preprocessing workflow. Defaults to \code{TRUE}. When set to \code{FALSE}, this will
disable the use of parallel processing while preprocessing, regardless of
the settings of the \code{parallel} parameter. \code{parallel_preprocessing} is
ignored if \code{parallel=FALSE}.}

\item{...}{Unused arguments.}
}
\value{
List of parameters related to preprocessing.
}
\description{
Internal function for parsing settings related to preprocessing
}
\references{
\enumerate{
\item Storey, J. D. A direct approach to false discovery rates. J.
R. Stat. Soc. Series B Stat. Methodol. 64, 479–498 (2002).
\item Shrout, P. E. & Fleiss, J. L. Intraclass correlations: uses in assessing
rater reliability. Psychol. Bull. 86, 420–428 (1979).
\item Koo, T. K. & Li, M. Y. A guideline of selecting and reporting intraclass
correlation coefficients for reliability research. J. Chiropr. Med. 15,
155–163 (2016).
\item Yeo, I. & Johnson, R. A. A new family of power transformations to
improve normality or symmetry. Biometrika 87, 954–959 (2000).
\item Box, G. E. P. & Cox, D. R. An analysis of transformations. J. R. Stat.
Soc. Series B Stat. Methodol. 26, 211–252 (1964).
\item Raymaekers, J., Rousseeuw,  P. J. Transforming variables to central
normality. Mach Learn. (2021).
\item Park, M. Y., Hastie, T. & Tibshirani, R. Averaged gene expressions for
regression. Biostatistics 8, 212–227 (2007).
\item Tolosi, L. & Lengauer, T. Classification with correlated features:
unreliability of feature ranking and solutions. Bioinformatics 27,
1986–1994 (2011).
\item Johnson, W. E., Li, C. & Rabinovic, A. Adjusting batch effects in
microarray expression data using empirical Bayes methods. Biostatistics 8,
118–127 (2007)
\item Kaufman, L. & Rousseeuw, P. J. Finding groups in data: an introduction
to cluster analysis. (John Wiley & Sons, 2009).
\item Muellner, D. fastcluster: fast hierarchical, agglomerative clustering
routines for R and Python. J. Stat. Softw. 53, 1–18 (2013).
\item Rousseeuw, P. J. Silhouettes: A graphical aid to the interpretation and
validation of cluster analysis. J. Comput. Appl. Math. 20, 53–65 (1987).
\item Langfelder, P., Zhang, B. & Horvath, S. Defining clusters from a
hierarchical cluster tree: the Dynamic Tree Cut package for R.
Bioinformatics 24, 719–720 (2008).
\item McFadden, D. Conditional logit analysis of qualitative choice behavior.
in Frontiers in Econometrics (ed. Zarembka, P.) 105–142 (Academic Press,
1974).
\item Cox, D. R. & Snell, E. J. Analysis of binary data. (Chapman and Hall,
1989).
\item Nagelkerke, N. J. D. A note on a general definition of the coefficient
of determination. Biometrika 78, 691–692 (1991).
}
}
\keyword{internal}
