#' @include FamiliarS4Generics.R
#' @include FamiliarS4Classes.R
NULL


# plot_all (generic) -----------------------------------------------------------
setGeneric("plot_all", function(object, ...) standardGeneric("plot_all"))



# plot_all (collection) --------------------------------------------------------
setMethod(
  "plot_all",
  signature(object = "familiarCollection"),
  function(object, dir_path = NULL, ...) {
    
    if (!is.null(dir_path)) dir_path <- encapsulate_path(dir_path)

    # Make sure the collection object is updated.
    object <- update_object(object = object)

    # Feature univariate p-values (horizontal bars)
    do.call(
      plot_univariate_importance,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Feature occurrence (unclustered)
    do.call(
      plot_feature_selection_occurrence,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Feature ranking (unclustered)
    do.call(
      plot_feature_selection_variable_importance,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Model signature occurrence (unclustered)
    do.call(
      plot_model_signature_occurrence,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Model signature ranking (unclustered)
    do.call(
      plot_model_signature_variable_importance,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Permutation variable importance
    do.call(
      plot_permutation_variable_importance,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Feature similarity heatmap
    do.call(
      plot_feature_similarity,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Calibration curves
    do.call(
      plot_calibration_data,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Model performance
    do.call(
      plot_model_performance,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # AUC-ROC curve
    do.call(
      plot_auc_roc_curve,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # AUC-PR curve
    do.call(
      plot_auc_precision_recall_curve,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Decision curve
    do.call(
      plot_decision_curve,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Kaplan-Meier curves
    do.call(
      plot_kaplan_meier,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Feature expressions
    do.call(
      plot_sample_clustering,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Confusion matrix
    do.call(
      plot_confusion_matrix,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Individual conditional expectation
    do.call(
      plot_ice,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))

    # Partial dependence
    do.call(
      plot_pd,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...)))
    
    return(invisible(NULL))
  }
)

# plot_all (general) -----------------------------------------------------------
setMethod(
  "plot_all",
  signature(object = "ANY"),
  function(object, dir_path = NULL, ...) {
    # Attempt conversion to familiarCollection object.
    
    object <- do.call(
      as_familiar_collection,
      args = c(
        list(
          "object" = object,
          "data_element" = "all"),
        list(...)))
    
    return(do.call(
      plot_all,
      args = c(
        list(
          "object" = object,
          "dir_path" = dir_path),
        list(...))))
  }
)
