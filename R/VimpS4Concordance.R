#' @include FamiliarS4Generics.R
#' @include FamiliarS4Classes.R
NULL

setClass("familiarConcordanceVimp",
         contains="familiarVimpMethod")


.get_available_concordance_vimp_method <- function(show_general=TRUE){
  return("concordance")
}


#####is_available#####
setMethod("is_available", signature(object="familiarConcordanceVimp"),
          function(object, ...){
            return(TRUE)
          })



#####get_default_hyperparameters#####
setMethod("get_default_hyperparameters", signature(object="familiarConcordanceVimp"),
          function(object, data=NULL, ...) return(list()))



#####..vimp,univariate######
setMethod("..vimp", signature(object="familiarConcordanceVimp"),
          function(object, data, ...){
            # Suppress NOTES due to non-standard evaluation in data.table
            score <- NULL
            
            if(is_empty(data)) return(callNextMethod())
            
            # Use concordance-based measures for variable importance:
            # - Gini index for binomial and multinomial outcomes
            # - Kendall's Tau for continuous and counts outcomes
            # - Concordance index for survival features
            
            if(object@outcome_type %in% c("binomial", "multinomial")){
              # Compute gini index for categorical outcomes.
              
              # Create a new vimp object, and replace the vimp_method slot.
              new_vimp_object <- methods::new("familiarCoreLearnGiniVimp", object)
              new_vimp_object@vimp_method <- "gini"
              
              return(..vimp(object=new_vimp_object,
                            data=data))
              
            } else if(object@outcome_type %in% c("continuous", "count")){
              # For continuous outcomes use kendall's tau.
              
              # Create a new vimp object, and replace the vimp_method slot.
              new_vimp_object <- methods::new("familiarCorrelationVimp", object)
              new_vimp_object@vimp_method <- "kendall"
              
              return(..vimp(object=new_vimp_object,
                            data=data))
              
            } else if(object@outcome_type == "survival"){
              # Compute the concordance index for each feature.
              
              # Use effect coding to convert categorical data into encoded data -
              # this is required to deal with factors with missing/new levels
              # between training and test data sets.
              encoded_data <- encode_categorical_variables(data=data,
                                                           object=object,
                                                           encoding_method="dummy",
                                                           drop_levels=FALSE)
              
              # Find feature columns in the data.
              feature_columns <- get_feature_columns(x=encoded_data$encoded_data)
              
              # Compute concordance indices
              c_index <- sapply(feature_columns, function(feature, data){
                return(..compute_concordance_index(x=data[[feature]],
                                                   time=data$outcome_time,
                                                   event=data$outcome_event))

              }, data=encoded_data$encoded_data@data)
              
              # Create the variable importance table.
              vimp_table <- data.table::data.table("score"=abs(c_index - 0.5),
                                                   "name"=feature_columns)
              
              # Decode any categorical variables.
              vimp_table <- decode_categorical_variables_vimp(object=encoded_data$reference_table,
                                                              vimp_table=vimp_table,
                                                              method="max")
              
              # Add ranks and set multivariate flag.
              vimp_table[, "rank":=data.table::frank(-score, ties.method="min")]
              vimp_table[, "multi_var":=FALSE]
              
              return(vimp_table)
              
            } else {
              ..error_outcome_type_not_implemented(object@outcome_type)
            }
          })
