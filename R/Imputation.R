#' @include FamiliarS4Generics.R
#' @include FamiliarS4Classes.R
NULL

.get_available_imputation_methods <- function() {
  return(c(
    .get_available_simple_imputation_methods(),
    .get_available_lasso_imputation_methods()))
}

.get_available_simple_imputation_methods <- function() {
  return("simple")
}

.get_available_lasso_imputation_methods <- function() {
  return("lasso")
}

setClass(
  "featureInfoParametersImputation",
  contains = "featureInfoParameters",
  slots = list(
    "method" = "character",
    "type" = "character",
    "required_features" = "ANY"),
  prototype = list(
    "method" = NA_character_,
    "type" = NA_character_,
    "required_features" = NULL))

setClass(
  "featureInfoParametersImputationNone",
  contains = "featureInfoParametersImputation",
  slots = list("reason" = "ANY"),
  prototype = list("reason" = NULL))

setClass(
  "featureInfoParametersImputationSimple",
  contains = "featureInfoParametersImputation",
  slots = list("model" = "ANY"),
  prototype = list("model" = NULL))

setClass(
  "featureInfoParametersImputationLasso",
  contains = "featureInfoParametersImputation",
  slots = list(
    "simple" = "ANY",
    "model" = "ANY"),
  prototype = list(
    "simple" = NULL,
    "model" = NULL))

setClass(
  "featureInfoParametersImputationContainer",
  contains = "featureInfoParameters",
  slots = list(
    "type" = "character",
    "required_features" = "ANY",
    "model" = "ANY"),
  prototype = list(
    "type" = NA_character_,
    "required_features" = NULL,
    "model" = NULL))



create_imputation_parameter_skeleton <- function(
    feature_info_list,
    feature_names = NULL,
    imputation_method,
    .override_existing = FALSE) {
  # Creates a skeleton for the provided imputation method.
  
  # Determine feature names from the feature info list, if provided.
  if (is.null(feature_names)) feature_names <- names(feature_info_list)
  
  # Select only features that appear in the feature info list.
  feature_names <- intersect(
    names(feature_info_list),
    feature_names)
  
  # Skip step if no feature info objects are updated.
  if (is_empty(feature_names)) return(feature_info_list)
  
  # Check that method is applicable.
  .check_parameter_value_is_valid(
    x = imputation_method,
    var_name = "imputation_method",
    values = .get_available_imputation_methods())
  
  # Update familiar info objects with a feature normalisation skeleton.
  updated_feature_info <- fam_lapply(
    X = feature_info_list[feature_names],
    FUN = .create_imputation_parameter_skeleton,
    method = imputation_method,
    .override_existing = .override_existing)
  
  # Provide names for the updated feature info objects.
  names(updated_feature_info) <- feature_names
  
  # Replace list elements.
  feature_info_list[feature_names] <- updated_feature_info
  
  return(feature_info_list)
}



.create_imputation_parameter_skeleton <- function(
    feature_info,
    method,
    .override_existing = FALSE) {
  # Check if imputation data was already completed, and does not require being
  # determined anew.
  if (feature_info_complete(feature_info@imputation_parameters)
      && !.override_existing) {
    return(feature_info)
  }
  
  # Pass to underlying function that constructs the skeleton.
  object <- ..create_imputation_parameter_skeleton(
    feature_name = feature_info@name,
    feature_type = feature_info@feature_type,
    available = is_available(feature_info),
    method = method)
  
  # Update imputation_parameters slot.
  feature_info@imputation_parameters <- object
  
  return(feature_info)
}



..create_imputation_parameter_skeleton <- function(
    feature_name,
    feature_type = "numeric",
    available = TRUE,
    method) {
  # This is the lowest level function for creating imputation parameter
  # skeletons.
  
  # Create the relevant objects.
  if (!available || method == "none") {
    object <- methods::new(
      "featureInfoParametersImputationNone",
      reason = "feature was omitted prior to transformation")
    
  } else if (method %in% .get_available_simple_imputation_methods()) {
    object <- methods::new(
      "featureInfoParametersImputationSimple",
      "method" = method)
    
  } else if (method %in% .get_available_lasso_imputation_methods()) {
    object <- methods::new(
      "featureInfoParametersImputationLasso",
      "method" = method)
    
  } else if (method == "container") {
    object <- methods::new("featureInfoParametersImputationContainer")
    
  } else {
    ..error_reached_unreachable_code(paste0(
      "..create_imputation_parameter_skeleton: encountered an unknown imputation method: ",
      paste_s(method)))
  }
  
  # Set the name and type of the object.
  object@name <- feature_name
  object@type <- feature_type
  
  # Update the familiar version.
  object <- add_package_version(object = object)
  
  return(object)
}



add_imputation_info <- function(
    cl = NULL,
    feature_info_list,
    data,
    verbose = FALSE) {
  # Determine normalisation parameters and add them to the feature_info_list.
  
  # Find feature columns.
  feature_names <- get_feature_columns(x = data)
  
  # Sanity check.
  if (!(setequal(feature_names, get_available_features(feature_info_list = feature_info_list)))) {
    ..error_reached_unreachable_code(paste0(
      "add_imputation_info: features in data and the feature info list ",
      "are expect to be the same, but were not."))
  }
  
  # Iterate over features and train univariate imputation.
  updated_feature_info <- fam_mapply(
    cl = cl,
    FUN = .add_imputation_info,
    feature_info = feature_info_list[feature_names],
    mask_data = data@data[, mget(feature_names)],
    MoreArgs = list("data" = data),
    progress_bar = verbose,
    chopchop = TRUE)
  
  # Provide names for the updated feature info objects.
  names(updated_feature_info) <- feature_names
  
  # Replace list elements.
  feature_info_list[feature_names] <- updated_feature_info
  
  # Apply initial results to the dataset.
  imputed_data <- .impute_features(
    data = data,
    feature_info_list = feature_info_list,
    initial_imputation = TRUE)
  
  # Check if there are any features that lack imputation (are of the
  # featureInfoParametersImputationNone class). These are subsequently skipped
  # to avoid having to rely on potentially missing data to infer other features.
  feature_names <- unname(feature_names[!sapply(
    feature_info_list[feature_names],
    function(x) (is(x@imputation_parameters, "featureInfoParametersImputationNone")))])
  
  if (length(feature_names) > 0) {
    # Iterate over features again to train multivariate imputation models.
    updated_feature_info <- fam_mapply(
      cl = cl,
      FUN = .add_imputation_info,
      feature_info = feature_info_list[feature_names],
      mask_data = data@data[, mget(feature_names)],
      MoreArgs = list("data" = imputed_data),
      progress_bar = verbose,
      chopchop = TRUE)
    
    # Provide names for the updated feature info objects.
    names(updated_feature_info) <- feature_names
    
    # Replace list elements.
    feature_info_list[feature_names] <- updated_feature_info
  }
  
  return(feature_info_list)
}



.add_imputation_info <- function(
    feature_info,
    data,
    mask_data) {
  
  # Pass to underlying function that adds the feature info.
  object <- add_feature_info_parameters(
    object = feature_info@imputation_parameters,
    data = data,
    mask_data = mask_data)
  
  # Update normalisation_parameters slot.
  feature_info@imputation_parameters <- object
  
  return(feature_info)
}



.impute_features <- function(
    cl = NULL,
    data,
    feature_info_list,
    initial_imputation,
    mask_data = NULL,
    verbose = FALSE) {
  
  # Check if data is empty
  if (is_empty(data)) return(data)
  
  # Check if data has features
  if (!has_feature_data(x = data)) return(data)
  
  # Find the columns containing features
  feature_names <- get_feature_columns(x = data)
  
  # Use data variable for masking uncensored data.
  if (is.null(mask_data)) mask_data <- data
  
  # Impute data.  
  imputation_list <- fam_mapply(
    cl = cl,
    FUN = ..impute_features,
    feature_info = feature_info_list[feature_names],
    mask_data = mask_data@data[, mget(feature_names)],
    MoreArgs = list(
      "data" = data,
      "initial_imputation" = initial_imputation),
    progress_bar = verbose,
    chopchop = TRUE)
  
  # Update name of data in columns.
  names(imputation_list) <- feature_names
  
  # Update with replacement in the data object.
  data <- update_with_replacement(
    data = data,
    replacement_list = imputation_list)
  
  return(data)
}



..impute_features <- function(
    feature_info,
    data,
    mask_data,
    initial_imputation) {
  
  # Find uncensored data.
  uncensored_data <- .mask_data_to_mask(
    mask_data = mask_data,
    type = feature_info@imputation_parameters@type)
  
  # Return data as is, if there is no censored data.
  if (all(uncensored_data)) {
    return(data@data[[feature_info@imputation_parameters@name]])
  }
  
  # Infer missing values.
  y <- apply_feature_info_parameters(
    object = feature_info@imputation_parameters,
    data = data,
    mask_data = mask_data,
    initial_imputation = initial_imputation)
  
  return(y)
}



# initialize (none) ------------------------------------------------------------
setMethod(
  "initialize",
  signature(.Object = "featureInfoParametersImputationNone"),
  function(.Object, ...) {
    
    # Update with parent class first.
    .Object <- callNextMethod()
    
    # The parameter set is by definition complete when no normalisation
    # is performed.
    .Object@complete <- TRUE
    
    return(.Object)
  }
)



# add_feature_info_parameters (generic imputation, ANY) ------------------------
setMethod(
  "add_feature_info_parameters",
  signature(
    object = "featureInfoParametersImputation",
    data = "ANY"),
  function(
    object,
    data,
    mask_data,
    ...) {
    
    # Check if all required parameters have been set.
    if (feature_info_complete(object)) return(object)
    
    # Check that any data is present.
    if (is_empty(data)) {
      # Return a none-class object.
      object <- ..create_imputation_parameter_skeleton(
        feature_name = object@name,
        feature_type = object@type,
        method = "none")
      
      object@reason <- "insufficient data to infer imputation parameters"
      
      return(object)
    }
    
    # Find uncensored data.
    mask_data <- .mask_data_to_mask(
      mask_data = mask_data,
      type = object@type)
    
    # If there are no uncensored data, we cannot determine imputation
    # parameters.
    if (!any(mask_data)) {
      # Return a none-class object.
      object <- ..create_imputation_parameter_skeleton(
        feature_name = object@name,
        feature_type = object@type,
        method = "none")
      
      object@reason <- "insufficient data to infer imputation parameters"
      
      return(object)
    }
    
    return(object)
  }
)



# add_feature_info_parameters (simple imputation, data object) -----------------
setMethod(
  "add_feature_info_parameters",
  signature(
    object = "featureInfoParametersImputationSimple",
    data = "dataObject"),
  function(
    object,
    data,
    mask_data,
    ...) {
    
    # Check if all required parameters have been set.
    if (feature_info_complete(object)) return(object)
    
    # Run general checks for imputation. This may yield none-class objects which
    # are complete by default.
    object <- callNextMethod()
    
    # Check if all required parameters have been set now.
    if (feature_info_complete(object)) return(object)
    
    # Find uncensored data.
    mask_data <- .mask_data_to_mask(
      mask_data = mask_data,
      type = object@type)
    
    # Select data.
    y <- data@data[mask_data, mget(object@name)][[1]]
    
    # Select value.
    if (object@type == "numeric") {
      # Select median values
      common_value <- stats::median(y)
      
    } else if (object@type == "factor") {
      # Select the mode as the replacement value
      common_value <- get_mode(y)
    }
    
    # Add value to object.
    object@model <- common_value
    
    # Set required feature.
    object@required_features <- object@name
    
    # Set complete.
    object@complete <- TRUE
    
    return(object)
  }
)



# add_feature_info_parameters (lasso imputation, data object) ------------------
setMethod(
  "add_feature_info_parameters",
  signature(
    object = "featureInfoParametersImputationLasso",
    data = "dataObject"),
  function(
    object, 
    data,
    mask_data,
    ...) {
    
    # Suppress NOTES due to non-standard evaluation in data.table
    name <- NULL
    
    # Check if all required parameters have been set.
    if (feature_info_complete(object)) return(object)
    
    # Run general checks for imputation. This may yield none-class
    # objects which are complete by default.
    object <- callNextMethod()
    
    # Check if all required parameters have been set now.
    if (feature_info_complete(object)) return(object)
    
    # Check if simple inference values have been set. For multivariate inference
    # methods, an initial univariate step is used to fill any holes in the data,
    # prior to prediction. This method is therefore first called to set
    # parameters of the univariate, prior to determining the LASSO model.
    if (!feature_info_complete(object@simple)) {
      object@simple <- ..create_imputation_parameter_skeleton(
        feature_name = object@name,
        feature_type = object@type,
        method = "simple")
      
      # Determine parameters.
      object@simple <- add_feature_info_parameters(
        object = object@simple,
        data = data,
        mask_data = mask_data)
      
      return(object)
    }
    
    # Determine if more than one feature is present.
    if (get_n_features(data) == 1) {
      # Switch to simple  univariate inference only, in case only one feature is
      # present.
      return(object@simple)
    }
    
    # Find uncensored data.
    mask_data <- .mask_data_to_mask(
      mask_data = mask_data,
      type = object@type)
    
    # Select finite data.
    distribution <- ifelse(object@type == "numeric", "gaussian", "multinomial")
    
    # Check that the glmnet package is installed.
    require_package(
      x = "glmnet",
      purpose = "to impute data using lasso regression")
    
    # Select known data as response variable.
    y <- data@data[[object@name]][mask_data]
    if (distribution == "multinomial") y <- droplevels(y)
    
    # Select features.
    x <- filter_features(data, remove_features = object@name)
    
    # Use effect coding to convert categorical data into encoded data.
    encoded_data <- encode_categorical_variables(
      data = x,
      object = NULL,
      encoding_method = "dummy",
      drop_levels = FALSE)
    
    # Extract data table with contrasts.
    x <- encoded_data$encoded_data
    
    # Perform a cross-validation to derive a optimal lambda. This may rarely
    # fail if y is numeric but does not change in a particular fold. In that
    # case, skip.
    lasso_model <- suppressWarnings(tryCatch(
      glmnet::cv.glmnet(
        x = as.matrix(x@data[mask_data, mget(get_feature_columns(x))]),
        y = y,
        family = distribution,
        alpha = 1,
        standardize = FALSE,
        nfolds = min(sum(mask_data), 20),
        parallel = FALSE),
      error = identity))
    
    if (inherits(lasso_model, "error")) return(object@simple)
    
    # Determine the features with non-zero coefficients. We want to have the
    # minimal required support for the model to minimise the effort that is
    # required for external model validation. GLMNET by definition wants to have
    # the exact same complete input space, even though but a few features are
    # used. That is a bad idea for portability. Therefore we will be jumping
    # through some hoops to make a model with minimum support.
    if (distribution == "multinomial") {
      # Read coefficient lists
      coef_list <- tryCatch(
        coef(lasso_model, s = "lambda.1se"),
        error = identity)
      
      if (inherits(coef_list, "error")) return(object@simple)
      
      # Parse into matrix and retrieve row names
      coef_mat <- sapply(coef_list, as.matrix)
      rownames(coef_mat) <- dimnames(coef_list[[1]])[[1]]
      
      # Calculate score
      score <- apply(abs(coef_mat), 1, max)
      
    } else {
      # Read coefficient lists
      coef_list <- tryCatch(
        coef(lasso_model, s = "lambda.1se"),
        error = identity)
      
      if (inherits(coef_list, "error")) return(object@simple)
      
      # Read coefficient matrix
      coef_mat <- as.matrix(coef_list)
      
      # Calculate score
      score <- abs(coef_mat)[, 1]
    }
    
    # Parse score to data.table
    vimp_table <- data.table::data.table(
      "score" = score,
      "name" = names(score))
    
    # Throw out the intercept and elements with 0.0 coefficients
    vimp_table <- vimp_table[name != "(Intercept)" & score != 0.0]
    
    # Create variable importance object.
    vimp_object <- methods::new(
      "vimpTable",
      vimp_table = vimp_table,
      encoding_table = encoded_data$reference_table,
      score_aggregation = "max",
      invert = TRUE)
    
    # Find the original names
    vimp_table <- get_vimp_table(vimp_object, "decoded")
    
    # Check that the optimal model complexity lambda is connected to at least
    # one feature. If not, we have to use the simple estimate.
    if (is_empty(vimp_table)) return(object@simple)
    
    # Derive required features
    required_features <- vimp_table$name
    
    # Select features.
    x <- filter_features(data, available_features = required_features)
    
    # Use effect coding to convert categorical data into encoded data.
    encoded_data <- encode_categorical_variables(
      data = x,
      object = NULL,
      encoding_method = "dummy",
      drop_levels = FALSE)
    
    # Extract data table with contrasts.
    x <- encoded_data$encoded_data@data[mask_data, mget(get_feature_columns(encoded_data$encoded_data))]
    
    # Check the number of columns in train_data. glmnet wants at least two
    # columns.
    if (ncol(x) == 1) x[, "bogus__variable__" := 0.0]
    
    # Force x locally, otherwise an error may occur.
    x <- as.matrix(x)
    
    # Train a small model at this lambda.1se.
    lasso_model <- suppressWarnings(tryCatch(
      glmnet::glmnet(
        x = x,
        y = y,
        family = distribution,
        lambda = lasso_model$lambda.1se,
        standardize = FALSE),
      error = identity))
    
    if (inherits(coef_list, "error")) return(object@simple)
    
    # Remove extraneous information from the model.
    lasso_model <- ..trim_glmnet(lasso_model)
    
    # Add LASSO regression model to object.
    object@model <- lasso_model
    object@required_features <- required_features
    
    # Set complete
    object@complete <- TRUE
    
    return(object)
  }
)



# apply_feature_info_parameters (none, data object) ----------------------------
setMethod(
  "apply_feature_info_parameters",
  signature(
    object = "featureInfoParametersImputationNone",
    data = "dataObject"),
  function(
    object, 
    data,
    mask_data,
    ...) {
    
    return(data@data[[object@name]])
  }
)


# apply_feature_info_parameters (simple, data object) --------------------------
setMethod(
  "apply_feature_info_parameters",
  signature(
    object = "featureInfoParametersImputationSimple",
    data = "dataObject"),
  function(
    object, 
    data,
    mask_data,
    ...) {
    
    # Find uncensored data.
    mask_data <- .mask_data_to_mask(
      mask_data = mask_data,
      type = object@type)
    
    # Return data as is, if there is no censored data.
    if (all(mask_data)) return(data@data[[object@name]])
    
    # Get intended data.
    y <- data@data[[object@name]]
    
    # Replace censored values.
    y[!mask_data] <- object@model
    
    return(y)
  }
)



# apply_feature_info_parameters (none, data object) ----------------------------
setMethod(
  "apply_feature_info_parameters",
  signature(
    object = "featureInfoParametersImputationLasso",
    data = "dataObject"),
  function(
    object, 
    data,
    mask_data,
    initial_imputation,
    ...) {
    
    # For initial imputation use univariate imputer.
    if (initial_imputation) {
      return(apply_feature_info_parameters(
        object = object@simple,
        data = data,
        mask_data = mask_data,
        initial_imputation = initial_imputation))
    }
    
    # Find uncensored data.
    mask_data <- .mask_data_to_mask(
      mask_data = mask_data,
      type = object@type)
    
    # Return data as is, if there is no censored data.
    if (all(mask_data)) return(data@data[[object@name]])
    
    # Check that features required for imputation are present in data.
    if (!all(object@required_features %in% get_feature_columns(data))) {
      return(apply_feature_info_parameters(
        object = object@simple,
        data = data,
        mask_data = mask_data,
        initial_imputation = initial_imputation))
    }
    
    # Check that the glmnet package is installed.
    require_package(
      x = "glmnet",
      purpose = "to impute data using lasso regression")
    
    # Get intended data.
    y <- data@data[[object@name]]
    
    # Select features.
    x <- filter_features(data, available_features = object@required_features)
    
    # Use effect coding to convert categorical data into encoded data.
    encoded_data <- encode_categorical_variables(
      data = x,
      object = NULL,
      encoding_method = "dummy",
      drop_levels = FALSE)
    
    # Extract data table with contrasts.
    x <- encoded_data$encoded_data@data[!mask_data, mget(get_feature_columns(encoded_data$encoded_data))]
    
    # Check if the validation data has two or more columns
    if (ncol(x) == 1) x[, "bogus__variable__" := 0.0]
    
    # Force x locally, otherwise an error may occur.
    x <- as.matrix(x)
    
    # Get the type of response for glmnet predict
    response_type <- ifelse(object@type == "numeric", "response", "class")
    
    # Impute values for censored values.
    y[!mask_data] <- drop(predict(
      object = object@model,
      newx = x,
      type = response_type))
    
    return(y)
  }
)



# apply_feature_info_parameters (container, data object) -----------------------
setMethod(
  "apply_feature_info_parameters",
  signature(
    object = "featureInfoParametersImputationContainer",
    data = "dataObject"),
  function(
    object, 
    data,
    mask_data,
    initial_imputation,
    ...) {
    
    # Find uncensored data.
    uncensored_data <- .mask_data_to_mask(
      mask_data = mask_data,
      type = object@type)
    
    # Return data as is, if there is no censored data.
    if (all(uncensored_data)) return(data@data[[object@name]])
    
    # Get intended data.
    y <- data@data[[object@name]]
    
    # Push only rows of data to be imputed.
    censored_data <- data
    censored_data@data <- data.table::copy(censored_data@data[!uncensored_data, ])
    
    # Set aggregation function for 
    if (object@type == "numeric") {
      aggregation_function <- mean
      
    } else if (object@type == "factor") {
      aggregation_function <- get_mode
    }
    
    # Dispatch to imputers in the container.
    imputed_values <- lapply(
      object@model,
      apply_feature_info_parameters,
      data = censored_data,
      mask_data = mask_data[!uncensored_data],
      initial_imputation = initial_imputation)
    
    # Set as data.table.
    imputed_values <- data.table::as.data.table(imputed_values)
    
    # Aggregate by row.
    imputed_values <- imputed_values[, list(
      "value" = aggregation_function(do.call(c, .SD))),
      .SDcols = colnames(imputed_values),
      by = seq_len(nrow(imputed_values))]
    
    # Replace censored values in y.
    y[!uncensored_data] <- imputed_values$value
    
    return(y)
  }
)



.mask_data_to_mask <- function(mask_data, type) {
  if (type == "numeric") {
    mask_data <- is.finite(mask_data)
    
  } else if (type == "factor") {
    mask_data <- !is.na(mask_data)
    
  } else {
    ..error_reached_unreachable_code(paste0(".mask_data_to_mask: encountered unknown feature type: ", type))
  }
  
  return(mask_data)
}



..collect_and_aggregate_imputation_info <- function(
    feature_info_list,
    feature_name,
    feature_type) {
  # Aggregate transformation parameters. This function exists so that it can be
  # tested as part of a unit test.
  
  # Create container object.
  container_object <- ..create_imputation_parameter_skeleton(
    feature_name = feature_name,
    feature_type = feature_type,
    method = "container")
  
  # Extract and store imputation objects.
  container_object@model <- lapply(
    feature_info_list,
    function(x) {
      # Filter out "none" class imputation
      # objects.
      if (is(x@imputation_parameters, "featureInfoParametersImputationNone")) return(NULL)
      
      return(x@imputation_parameters)
    })
  
  if (is_empty(container_object@model)) {
    container_object@model <- list(
      ..create_imputation_parameter_skeleton(
        feature_name = feature_name,
        feature_type = feature_type,
        method = "none"))
  }
  
  # Set required parameters.
  container_object@required_features <- unique(unlist(lapply(
    container_object@model,
    function(x) (x@required_features))))
  
  # Mark as complete.
  container_object@complete <- TRUE
  
  return(list("parameters" = container_object))
}
