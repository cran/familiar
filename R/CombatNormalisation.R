#' @include FamiliarS4Generics.R
#' @include FamiliarS4Classes.R
#' @include Normalisation.R
NULL



# Parametric ComBat object -----------------------------------------------------
setClass(
  "featureInfoParametersNormalisationParametricCombat",
  contains = "featureInfoParametersNormalisationShiftScale",
  slots = list("method" = "character"),
  prototype = list("method" = NA_character_))

# Non-parametric ComBat object -------------------------------------------------
setClass(
  "featureInfoParametersNormalisationNonParametricCombat",
  contains = "featureInfoParametersNormalisationShiftScale",
  slots = list("method" = "character"),
  prototype = list("method" = NA_character_))


# Only included in .get_available_batch_normalisation_methods
.get_available_combat_parametric_normalisation_methods <- function() {
  return(c("combat", "combat_p", "combat_parametric"))
}

# Only included in .get_available_batch_normalisation_methods
.get_available_combat_non_parametric_normalisation_methods <- function() {
  return(c("combat_np", "combat_non_parametric"))
}



# add_feature_info_parameters (parametric ComBat, data.table) ------------------
setMethod(
  "add_feature_info_parameters",
  signature(
    object = "featureInfoParametersNormalisationParametricCombat",
    data = "data.table"),
  function(
    object, 
    data,
    batch_parameter_data,
    ...) {
    
    # Suppress NOTES due to non-standard evaluation in data.table
    feature <- batch_id <- NULL
    
    # Check if all required parameters have been set.
    if (feature_info_complete(object)) return(object)
    
    # Generate a replacement object that uses univariate
    # standardisation.
    replacement_object <- ..create_normalisation_parameter_skeleton(
      feature_name = object@name,
      method = "standardisation",
      batch = object@batch)
    
    # Select the current feature and batch from batch_parameter_data.
    batch_parameter_data <- batch_parameter_data[feature == object@name & batch_id == object@batch, ]
    
    # If the batch parameter data are empty, attempt to use univariate
    # standardisation.
    if (is_empty(batch_parameter_data)) {
      return(add_feature_info_parameters(
        object = replacement_object,
        data = data))
    }
    
    # If shift and scale parameters are not finite, attempt to use univariate
    # standardisation.
    if (!is.finite(batch_parameter_data$norm_shift) || !is.finite(batch_parameter_data$norm_scale)) {
      return(add_feature_info_parameters(
        object = replacement_object,
        data = data))
    }
    
    # Set shift and scale parameters.
    object@shift <- batch_parameter_data$norm_shift
    object@scale <- batch_parameter_data$norm_scale
    
    # Check for scales which are close to 0
    if (object@scale < 2.0 * .Machine$double.eps) object@scale <- 1.0
    
    # Mark complete.
    object@complete <- TRUE
    
    return(object)
  }
)



# add_feature_info_parameters (non-parametric ComBat, data.table) --------------
setMethod(
  "add_feature_info_parameters",
  signature(
    object = "featureInfoParametersNormalisationNonParametricCombat",
    data = "data.table"),
  function(
    object, 
    data,
    batch_parameter_data,
    ...) {
    
    # Suppress NOTES due to non-standard evaluation in data.table
    feature <- batch_id <- NULL
    
    # Check if all required parameters have been set.
    if (feature_info_complete(object)) return(object)
    
    # Generate a replacement object that uses univariate
    # standardisation.
    replacement_object <- ..create_normalisation_parameter_skeleton(
      feature_name = object@name,
      method = "standardisation",
      batch = object@batch)
    
    # Select the current feature and batch from batch_parameter_data.
    batch_parameter_data <- batch_parameter_data[feature == object@name & batch_id == object@batch, ]
    
    # If the batch parameter data are empty, attempt to use univariate
    # standardisation.
    if (is_empty(batch_parameter_data)) {
      return(add_feature_info_parameters(
        object = replacement_object,
        data = data))
    }
    
    # If shift and scale parameters are not finite, attempt to use
    # univariate standardisation.
    if (!is.finite(batch_parameter_data$norm_shift) || !is.finite(batch_parameter_data$norm_scale)) {
      return(add_feature_info_parameters(
        object = replacement_object,
        data = data))
    }
    
    # Set shift and scale parameters.
    object@shift <- batch_parameter_data$norm_shift
    object@scale <- batch_parameter_data$norm_scale
    
    # Check for scales which are close to 0
    if (object@scale < 2.0 * .Machine$double.eps) object@scale <- 1.0
    
    # Mark complete.
    object@complete <- TRUE
    
    return(object)
  }
)




.compute_combat_batch_normalisation_z_matrix <- function(data, feature_names) {
  # Suppress NOTES due to non-standard evaluation in data.table
  value <- n <- is_valid <- invariant <- n_features <- NULL
  gamma_hat <- .NATURAL <- NULL
  
  # Get the batch identifier column.
  batch_id_column <- get_id_columns(single_column = "batch")
  
  # Set a minimum threshold for valid sample sizes
  min_valid_samples <- 10
  min_valid_features <- 3
  
  # Convert the table from wide to long format
  x <- data.table::melt(
    data[, mget(c(batch_id_column, feature_names))],
    id.vars = batch_id_column,
    variable.name = "feature",
    value.name = "value")
  
  # Sum the number of instances with a valid value, and determine whether all
  # values are singular.
  aggregate_table <- x[, list(
    "n" = sum(is.finite(value)),
    "invariant" = is_singular_data(value)),
    by = c(batch_id_column, "feature")]
  
  # A feature/batch combination is valid if it is not invariant and has
  # sufficient instances with a finite value.
  aggregate_table[, "is_valid" := invariant == FALSE & n >= min_valid_samples]
  
  # Determine the number of features available in each batch.
  aggregate_table[, "n_features" := sum(is_valid), by = c(batch_id_column)]
  
  # If a batch does not have sufficient features (3 or more), mark as invalid.
  aggregate_table[n_features < min_valid_features, "is_valid" := FALSE]
  
  # Drop invariant and n_features columns, as these are no longer required.
  aggregate_table[, ":="("n_features" = NULL, "invariant" = NULL)]
  
  # First select for which combat can be used. This table is called z,
  # after the name for standardized data in Johnson et al. Note that overall
  # standardisation is conducted prior to batch-normalisation in familiar, and
  # is external to this function.
  z <- x[aggregate_table[is_valid == TRUE], on = .NATURAL]
  
  if (!is_empty(z)) {
    # Remove NA or infinite values.
    z <- z[is.finite(value)]
    
    # Determine the mean (gamma_hat) of each feature in each batch.
    z[, "gamma_hat" := mean(value), by = c(batch_id_column, "feature")]
    
    # Determine the variance (delta_hat_squared) of each feature in each batch.
    z[, "delta_hat_squared" := 1 / n * sum((value - gamma_hat)^2.0), by = c(batch_id_column, "feature")]
    
  } else {
    z <- NULL
  }
  
  return(z)
}



.combat_iterative_parametric_bayes_solver <- function(
    z,
    tolerance = 0.0001,
    max_iterations = 20,
    cl = NULL,
    progress_bar = FALSE) {
  # In the empirical Bayes approach with parametric priors, the posterior
  # estimations of gamma and delta_squared are iteratively optimised.
  
  # Suppress NOTES due to non-standard evaluation in data.table
  gamma_hat <- delta_hat_squared <- NULL
  
  # Check that z is not empty.
  if (is_empty(z)) return(NULL)
  
  # Get the batch identifier column.
  batch_id_column <- get_id_columns(single_column = "batch")
  
  # Create new table by removing value and taking only unique rows.
  z_short <- unique(data.table::copy(z)[, "value" := NULL])

  # Determine gamma_bar, which is the average value of gamma_hat across
  # features within each batch. 1 value per batch.
  z_short[, "gamma_bar" := mean(gamma_hat), by = batch_id_column]
  
  # Determine tau_bar_squared, which is the prior for variance in the normal
  # distribution of gamma_hat. 1 value per batch.
  z_short[, "tau_bar_squared" := stats::var(gamma_hat), by = batch_id_column]
  
  # Determine lambda_bar (also called alpha) priors for the inverse gamma
  # distribution according to Johnson et al, supplement A3.1. 1 value per batch
  z_short[, "lambda_bar" := ..combat_lambda_prior(delta_hat_squared), by = batch_id_column]
  
  # Determine theta_bar (also called beta) priors according to Johnson et al.
  # supplement A3.1. 1 value per batch
  z_short[, "theta_bar" := ..combat_theta_prior(delta_hat_squared), by = batch_id_column]

  # Split by batch.
  batch_parameters <- fam_lapply_lb(
    cl = cl,
    assign = NULL,
    X = split(z, by = batch_id_column),
    FUN = ..combat_iterative_parametric_bayes_solver,
    progress_bar = progress_bar,
    z_short = z_short,
    tolerance = tolerance,
    max_iterations = max_iterations)
  
  # Concatenate to single table.
  batch_parameters <- data.table::rbindlist(batch_parameters)
  
  return(batch_parameters)
}



..combat_iterative_parametric_bayes_solver <- function(
    z,
    z_short,
    tolerance,
    max_iterations) {
  # Perform the actual parametric estimations within each batch. Called from the
  # .combat_iterative_parametric_bayes_solver function
  
  # Suppress NOTES due to non-standard evaluation in data.table
  batch_id <- NULL
  value <- n <- gamma_hat <- tau_bar_squared <- gamma_bar <- gamma_star_new <- sum_squared_error <- NULL
  delta_star_squared_old <- delta_star_squared_new <- delta_hat_squared <- theta_bar <- lambda_bar <- NULL
  
  # Get the batch identifier column.
  batch_id_column <- get_id_columns(single_column = "batch")
  
  # Limit z_short to the current batch.
  current_batch_id <- z[[batch_id_column]][1]
  z_short <- data.table::copy(z_short[batch_id == current_batch_id])
  
  # Initialise conditional posteriors. 1 value per feature per batch.
  z_short[, ":="(
    "gamma_star_old" = gamma_hat,
    "delta_star_squared_old" = delta_hat_squared)]
  
  # Convergence update value.
  convergence_update <- 1.0
  iteration_count <- 0
  
  while (convergence_update > tolerance && iteration_count < max_iterations) {

    # Update the conditional gamma star posterior.
    z_short[, "gamma_star_new" := ..combat_gamma_posterior(
      n = n,
      tau_bar_squared = tau_bar_squared,
      gamma_hat = gamma_hat,
      delta_star_squared = delta_star_squared_old,
      gamma_bar = gamma_bar)]
    
    # Merge z_short back into z prior to computing the sum squared error.
    z_new <- merge(
      x = z[, mget(c(batch_id_column, "feature", "value"))],
      y = z_short[, mget(c(batch_id_column, "feature", "gamma_star_new"))],
      by = c(batch_id_column, "feature"),
      all = TRUE)
    
    # Compute sum squared error in equation 3.1 for the delta_star_squared posterior.
    z_new <- z_new[, list(
      "sum_squared_error" = sum((value - gamma_star_new)^2)),
      by = c(batch_id_column, "feature")]
    
    z_short <- merge(
      x = z_short,
      y = z_new,
      by = c(batch_id_column, "feature"),
      all = TRUE)
    
    # Update the conditional delta_star_squared posterior.
    z_short[, "delta_star_squared_new" := ..combat_delta_squared_posterior(
      theta_bar = theta_bar,
      sum_squared_error = sum_squared_error,
      n = n,
      lambda_bar = lambda_bar)]
    
    # Update convergence
    convergence_update <- max(
      abs((z_short$gamma_star_new - z_short$gamma_star_old) / z_short$gamma_star_old),
      abs((z_short$delta_star_squared_new - z_short$delta_star_squared_old) / z_short$delta_star_squared_old))
    
    # Replace old posterior values
    z_short[, ":="(
      "gamma_star_old" = gamma_star_new,
      "delta_star_squared_old" = delta_star_squared_new,
      "sum_squared_error" = NULL)]
    
    iteration_count <- iteration_count + 1
  }
  
  # Store delta_star
  z_short[, "delta_star" := sqrt(delta_star_squared_new)]
  
  # Rename gamma_star_new and delta_star_squared_new
  data.table::setnames(
    x = z_short,
    old = c("gamma_star_new", "delta_star"),
    new = c("norm_shift", "norm_scale"))

  return(z_short[, mget(c(batch_id_column, "feature", "norm_shift", "norm_scale", "n"))])
}



.combat_non_parametric_bayes_solver <- function(
    z,
    n_sample_features = 50,
    cl = NULL,
    progress_bar = TRUE) {
  # Computes batch parameters using non-parametric priors. Sadly, this seems to
  # be an O(2) problem because it compares each feature with every other
  # feature. Johnson et al. We may be able to cheat a bit by subsampling the
  # feature space, so that we have O(n_features * n_sample_features) instead of
  # O(n_features * (n_features-1)).
  #
  # One of the datasets of Johnson et al. had 54000 features, which led to
  # 2.916E9 computations times 3 batches that took about an hour to complete.
  # Using n_sample_features=50, this would have been 3 * 2.7E6 computations,
  # which is more tractable, and scales way better.
  
  # Check if z is not empty.
  if (is_empty(z)) return(NULL)
  
  # Create a shortened table containing gamma_hat and delta_hat_squared
  # parameters for each feature and batch. If we make this function parallel at
  # one point, I prefer not to distribute z (in its entirety) to clusters, due
  # to memory issues.
  z_short <- unique(data.table::copy(z)[, "value" := NULL])
  
  # Iterate over batches and features to obtain batch parameters.
  batch_parameters <- fam_lapply(
    cl = cl,
    assign = NULL,
    X = split(
      z,
      by = c(get_id_columns(single_column = "batch"), "feature"),
      drop = TRUE),
    FUN = ..combat_non_parametric_bayes_solver,
    progress_bar = progress_bar,
    z_short = z_short,
    n_sample_features = n_sample_features,
    chopchop = TRUE)
  
  # Concatenate to single table.
  batch_parameters <- data.table::rbindlist(batch_parameters)

  return(batch_parameters)
}



..combat_non_parametric_bayes_solver <- function(
    z,
    z_short,
    n_sample_features) {

  # Suppress NOTES due to non-standard evaluation in data.table
  batch_id <- feature <- NULL
  
  # Get the batch identifier column.
  batch_id_column <- get_id_columns(single_column = "batch")
  
  # Limit z_short to the current batch.
  current_batch_id <- z[[batch_id_column]][1]
  
  # Select the current cohort from z_short. Note that like in sva and other
  # codes, we interpret the g"=1...G in the supplement of Johnson et al. to
  # indicate that the current feature is not directly considered.
  z_short <- data.table::copy(z_short[batch_id == current_batch_id & feature != z$feature[1]])
  
  # Find the number of features that are used to compute w_ig".
  features <- z_short$feature
  
  # Adapt the number of sample features.
  n_sample_features <- ifelse(n_sample_features > length(features), length(features), n_sample_features)
  
  # Find the selected features
  selected_features <- fam_sample(
    features,
    size = n_sample_features,
    replace = FALSE)
  
  # Make selection
  z_short <- droplevels(z_short[feature %in% selected_features])
  
  # Compute data for the weights w_ig that are used to reconstruct gamma_star
  # and delta_star_squared for the selected feature in the calling function.
  # (the selected_features variable contains the set difference of all
  # difference and the feature in the calling features.)
  weight_data <- lapply(
    split(z_short, by = "feature", sorted = FALSE),
    function(prior_pair, x) {
      # Compute sum((x-gamma_hat)^2) term in the product of the probability
      # density functions of the normal distribution over x.
      sum_squared_error <- sum((x - prior_pair$gamma_hat[1])^2)
      
      # Compute w_ig" = L(Z_ig | gamma_hat_ig", delta_hat_squared_ig")
      # for the current feature in g".
      w_ig <- 1.0 / (2.0 * pi * prior_pair$delta_hat_squared[1])^(length(x) / 2) * 
        exp(-sum_squared_error / (2 * prior_pair$delta_hat_squared[1]))
      
      # Replace NaNs and other problematic values.
      if (!is.finite(w_ig)) w_ig <- 0.0
      
      return(data.table::data.table(
        "feature" = prior_pair$feature[1],
        "w" = w_ig,
        "gamma_hat" = prior_pair$gamma_hat[1],
        "delta_hat_squared" = prior_pair$delta_hat_squared[1]))
    },
    x = z$value)
  
  # Combine to data.table
  weight_data <- data.table::rbindlist(weight_data)
  
  # Compute gamma_star and delta_star_squared according to Johnson et al.
  gamma_star <- sum(weight_data$w * weight_data$gamma_hat) / sum(weight_data$w)
  delta_star_squared <- sum(weight_data$w * weight_data$delta_hat_squared) / sum(weight_data$w)
  
  return(data.table::data.table(
    "batch_id" = z[[batch_id_column]][1],
    "feature" = z$feature[1],
    "norm_shift" = gamma_star,
    "norm_scale" = sqrt(delta_star_squared),
    "n" = nrow(z)))
}



..combat_lambda_prior <- function(delta_hat_squared) {
  # Computes the lambda prior from Johnson et al. See suppl. A3.1 for more
  # details. It seems that the supplement contains an error, where the prior is
  # created using V instead of V^2. Since V^2 appears in other code
  # implementations of combat (e.g. sva) and is actually found in other
  # publications, e.g. (https://arxiv.org/pdf/1605.01019.pdf). Manual
  # derivation confirms that V^2 should be used.
  v <- mean(delta_hat_squared)
  s_squared <- stats::var(x = delta_hat_squared)
  
  return((v^2 / s_squared) + 2.0)
}



..combat_theta_prior <- function(delta_hat_squared) {
  # Computes the theta prior from Johnson et al. See suppl. A3.1 for more
  # details.
  v <- mean(delta_hat_squared)
  s_squared <- stats::var(x = delta_hat_squared)
  
  return(v * (1 + (v^2 / s_squared)))
}



..combat_gamma_posterior <- function(
    n,
    tau_bar_squared,
    gamma_hat,
    delta_star_squared,
    gamma_bar) {
  # Computes conditional posterior for gamma, see equation 3.1 in Johnson et al.
  gamma_star <- (n * tau_bar_squared * gamma_hat + delta_star_squared * gamma_bar) /
    (n * tau_bar_squared + delta_star_squared)
  
  return(gamma_star)
}



..combat_delta_squared_posterior <- function(
    theta_bar,
    sum_squared_error,
    n,
    lambda_bar) {
  # Computes conditional posterior for delta_star_squared, see equation 3.1 in Johnson et al.
  delta_star_squared <- (theta_bar + 0.5 * sum_squared_error) / (0.5 * n + lambda_bar - 1.0)
  
  return(delta_star_squared)
}
