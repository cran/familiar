##### Generic test #############################################################
outcome_type <- "survival"

for(n_numeric_features in c(4, 3, 2, 1, 0)){
  
  data <- familiar:::test_create_synthetic_series_data(outcome_type=outcome_type, n_numeric=n_numeric_features)
  
  for(transformation_method in familiar:::.get_available_transformation_methods()){
    
    testthat::test_that(paste0("Transformation is correctly performed using the ", transformation_method,
                               " method and ", n_numeric_features, " numeric features."), {
      # Make a copy of the data.
      data_copy <- data.table::copy(data)
      
      # Create a list of featureInfo objects.
      feature_info_list <- familiar:::.get_feature_info_data(data=data_copy@data,
                                                             file_paths=NULL,
                                                             project_id=character(),
                                                             outcome_type=outcome_type)[[1]]
      
      # Update the feature info list.
      feature_info_list <- familiar:::add_transformation_parameters(feature_info_list=feature_info_list,
                                                                    data_obj=data_copy,
                                                                    transformation_method=transformation_method)
      
      # Perform the transformation.
      data_copy <- familiar:::transform_features(data=data_copy,
                                                 feature_info_list=feature_info_list)
      
      # Test whether the features are transformed (unless none).
      if(transformation_method == "none"){
        # Check that the data is not altered.
        testthat::expect_equal(data.table::fsetequal(data_copy@data, data@data), TRUE)
        
      } else {
        for(feature in familiar:::get_feature_columns(data_copy)){
          
          # Determine if the feature is numeric.
          if(feature_info_list[[feature]]@feature_type == "numeric"){
            
            # Expect that values are not NA.
            testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), FALSE)
            
          } else {
            # For categorical features test that the lambda value equals NA.
            testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), TRUE)
          }
        }
      }
      
      # Assert that inverting the transformation produces the original dataset.
      data_restored <- familiar:::transform_features(data=data_copy,
                                                     feature_info_list=feature_info_list,
                                                     invert=TRUE)
      
      # Iterate over features and compare. They should be equal
      for(feature in familiar:::get_feature_columns(data_restored)){
        # Expect that values are similar to a tolerance.
        testthat::expect_equal(data_restored@data[[feature]], data@data[[feature]])
      }
      
      # Assert that aggregating the transformation parameters works as expected.
      aggr_transform_parameters <- familiar:::..collect_and_aggregate_transformation_info(feature_info_list=feature_info_list)
      if(n_numeric_features > 0 & transformation_method != "none"){
        # Expect that the selected transformation method matches the selected
        # method.
        testthat::expect_equal(aggr_transform_parameters$parameters$transform_method, transformation_method)
        
        # Expect that the lambda is not NA.
        testthat::expect_equal(is.na(aggr_transform_parameters$parameters$transform_lambda), FALSE)
        
        # Expect that instance mask is equal to the number of numeric features.
        testthat::expect_equal(sum(aggr_transform_parameters$instance_mask) > 0, TRUE)
        testthat::expect_equal(sum(aggr_transform_parameters$instance_mask) <= n_numeric_features, TRUE)
        
      } else {
        # Expect that the selected transformation method matches the selected
        # method.
        testthat::expect_equal(aggr_transform_parameters$parameters$transform_method, "none")
        
        # Expect that the lambda is not NA.
        testthat::expect_equal(is.na(aggr_transform_parameters$parameters$transform_lambda), TRUE)
        
        # Expect that instance mask is equal to the number of numeric features.
        testthat::expect_equal(sum(aggr_transform_parameters$instance_mask) == familiar:::get_n_features(data_copy), TRUE)
      }
    })
  }
}


#### NA-value test #############################################################
for(n_numeric_features in c(4, 3, 2, 1, 0)){
  
  data <- familiar:::test_create_synthetic_series_na_data(outcome_type=outcome_type, n_numeric=n_numeric_features)
  
  for(transformation_method in familiar:::.get_available_transformation_methods()){
    
    testthat::test_that(paste0("Transformation is correctly performed using the ",
                               transformation_method, " method and ",
                               n_numeric_features, " numeric features for a dataset with some NA data."), {
                                 # Make a copy of the data.
                                 data_copy <- data.table::copy(data)
                                 
                                 # Create a list of featureInfo objects.
                                 feature_info_list <- familiar:::.get_feature_info_data(data=data_copy@data,
                                                                                        file_paths=NULL,
                                                                                        project_id=character(),
                                                                                        outcome_type=outcome_type)[[1]]
                                 
                                 # Update the feature info list.
                                 feature_info_list <- familiar:::add_transformation_parameters(feature_info_list=feature_info_list,
                                                                                              data_obj=data_copy,
                                                                                              transformation_method=transformation_method)
                                 
                                 # Perform a transformation.
                                 data_copy <- familiar:::transform_features(data=data_copy,
                                                                            feature_info_list=feature_info_list)
                                 
                                 
                                 # Test whether the features are transformed (unless none).
                                 if(transformation_method == "none"){
                                   # Check that the data is not altered.
                                   testthat::expect_equal(data.table::fsetequal(data_copy@data, data@data), TRUE)
                                   
                                 } else {
                                   for(feature in familiar:::get_feature_columns(data_copy)){
                                     
                                     # Determine if the feature is numeric.
                                     if(feature_info_list[[feature]]@feature_type == "numeric"){
                                       
                                       # Expect that values are not NA.
                                       testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), FALSE)
                                       
                                     } else {
                                       # For categorical features test that the lambda value equals NA.
                                       testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), TRUE)
                                     }
                                   }
                                 }
                               })
  }
}


#### One feature NA test ###########################################################
for(n_numeric_features in c(4, 3, 2, 1, 0)){
  
  data <- familiar:::test_create_synthetic_series_one_feature_all_na_data(outcome_type=outcome_type, n_numeric=n_numeric_features)
  
  for(transformation_method in familiar:::.get_available_transformation_methods()){
    
    testthat::test_that(paste0("Transformation is correctly performed using the ",
                               transformation_method, " method and ",
                               n_numeric_features, " numeric features for a dataset with one feature completely NA."), {
                                 # Make a copy of the data.
                                 data_copy <- data.table::copy(data)
                                 
                                 # Create a list of featureInfo objects.
                                 feature_info_list <- familiar:::.get_feature_info_data(data=data_copy@data,
                                                                                        file_paths=NULL,
                                                                                        project_id=character(),
                                                                                        outcome_type=outcome_type)[[1]]
                                 
                                 # Update the feature info list.
                                 feature_info_list <- familiar:::add_transformation_parameters(feature_info_list=feature_info_list,
                                                                                              data_obj=data_copy,
                                                                                              transformation_method=transformation_method)
                                 
                                 # Perform a normalisation.
                                 data_copy <- familiar:::transform_features(data=data_copy,
                                                                            feature_info_list=feature_info_list)
                                 
                                 
                                 # Test whether the features are transformed (unless none).
                                 if(transformation_method == "none"){
                                   # Check that the data is not altered.
                                   testthat::expect_equal(data.table::fsetequal(data_copy@data, data@data), TRUE)
                                   
                                 } else {
                                   for(feature in familiar:::get_feature_columns(data_copy)){
                                     
                                     # Determine if the feature is numeric.
                                     if(feature_info_list[[feature]]@feature_type == "numeric"){
                                       
                                       if(feature == "feature_2"){
                                         # Expect that the lambda is NA.
                                         testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), TRUE)
                                         
                                       } else {
                                         # Check that the lambda is not NA.
                                         testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), FALSE)
                                       }
                                       
                                     } else {
                                       # For categorical features test that the lambda value equals NA.
                                       testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), TRUE)
                                     }
                                   }
                                 }
                               })
  }
}



#### Invariant feature test ###########################################################
for(n_numeric_features in c(4, 3, 2, 1, 0)){
  
  data <- familiar:::test_create_synthetic_series_invariant_feature_data(outcome_type=outcome_type, n_numeric=n_numeric_features)
  
  for(transformation_method in familiar:::.get_available_transformation_methods()){
    
    testthat::test_that(paste0("Transformation is correctly performed using the ",
                               transformation_method, " method and ",
                               n_numeric_features, " numeric features for a dataset with invariant features."), {
                                 # Make a copy of the data.
                                 data_copy <- data.table::copy(data)
                                 
                                 # Create a list of featureInfo objects.
                                 feature_info_list <- familiar:::.get_feature_info_data(data=data_copy@data,
                                                                                        file_paths=NULL,
                                                                                        project_id=character(),
                                                                                        outcome_type=outcome_type)[[1]]
                                 
                                 # Update the feature info list.
                                 feature_info_list <- familiar:::add_transformation_parameters(feature_info_list=feature_info_list,
                                                                                              data_obj=data_copy,
                                                                                              transformation_method=transformation_method)

                                 # Perform the transformation.
                                 data_copy <- familiar:::transform_features(data=data_copy,
                                                                            feature_info_list=feature_info_list)
                                 
                                 
                                 # Test whether the features are transformed (unless none).
                                 if(transformation_method == "none"){
                                   # Check that the data is not altered.
                                   testthat::expect_equal(data.table::fsetequal(data_copy@data, data@data), TRUE)
                                   
                                 } else {
                                   for(feature in familiar:::get_feature_columns(data_copy)){
                                     
                                     # Determine if the feature is numeric.
                                     if(feature_info_list[[feature]]@feature_type == "numeric"){
                                       
                                       # Expect that the lambda is NA.
                                       testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), TRUE)
                                       
                                     } else {
                                       # For categorical features test that the lambda value equals NA.
                                       testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), TRUE)
                                     }
                                   }
                                 }
                               })
  }
}



#### One feature invariant test ###########################################################
for(n_numeric_features in c(4, 3, 2, 1, 0)){
  
  data <- familiar:::test_create_synthetic_series_one_feature_invariant_data(outcome_type=outcome_type, n_numeric=n_numeric_features)
  
  for(transformation_method in familiar:::.get_available_transformation_methods()){
    
    testthat::test_that(paste0("Transformation is correctly performed using the ",
                               transformation_method, " method and ",
                               n_numeric_features, " numeric features for a dataset with one invariant feature."), {
                                 # Make a copy of the data.
                                 data_copy <- data.table::copy(data)
                                 
                                 # Create a list of featureInfo objects.
                                 feature_info_list <- familiar:::.get_feature_info_data(data=data_copy@data,
                                                                                        file_paths=NULL,
                                                                                        project_id=character(),
                                                                                        outcome_type=outcome_type)[[1]]
                                 
                                 # Update the feature info list.
                                 feature_info_list <- familiar:::add_transformation_parameters(feature_info_list=feature_info_list,
                                                                                              data_obj=data_copy,
                                                                                              transformation_method=transformation_method)
                                 
                                 # Perform the transformation.
                                 data_copy <- familiar:::transform_features(data=data_copy,
                                                                            feature_info_list=feature_info_list)
                                 
                                 
                                 # Test whether the features are transformed (unless none).
                                 if(transformation_method == "none"){
                                   # Check that the data is not altered.
                                   testthat::expect_equal(data.table::fsetequal(data_copy@data, data@data), TRUE)
                                   
                                 } else {
                                   for(feature in familiar:::get_feature_columns(data_copy)){
                                     
                                     # Determine if the feature is numeric.
                                     if(feature_info_list[[feature]]@feature_type == "numeric"){
                                       
                                       if(feature == "feature_2"){
                                         # Expect that the lambda is NA.
                                         testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), TRUE)
                                         
                                       } else {
                                         # Check that the lambda is not NA.
                                         testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), FALSE)
                                       }
                                       
                                     } else {
                                       # For categorical features test that the lambda value equals NA.
                                       testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), TRUE)
                                     }
                                   }
                                 }
                               })
  }
}



#### One-sample test ###########################################################
for(n_numeric_features in c(4, 3, 2, 1, 0)){
  
  data <- familiar:::test_create_synthetic_series_one_sample_data(outcome_type=outcome_type, n_numeric=n_numeric_features)
  
  for(transformation_method in familiar:::.get_available_transformation_methods()){
    
    testthat::test_that(paste0("Transformation is correctly performed using the ",
                               transformation_method, " method and ",
                               n_numeric_features, " numeric features for a dataset with one sample."), {
                                 # Make a copy of the data.
                                 data_copy <- data.table::copy(data)
                                 
                                 # Create a list of featureInfo objects.
                                 feature_info_list <- familiar:::.get_feature_info_data(data=data_copy@data,
                                                                                        file_paths=NULL,
                                                                                        project_id=character(),
                                                                                        outcome_type=outcome_type)[[1]]
                                 
                                 # Update the feature info list.
                                 feature_info_list <- familiar:::add_transformation_parameters(feature_info_list=feature_info_list,
                                                                                              data_obj=data_copy,
                                                                                              transformation_method=transformation_method)
                                 
                                 # Perform the transformation.
                                 data_copy <- familiar:::transform_features(data=data_copy,
                                                                            feature_info_list=feature_info_list)
                                 
                                 
                                 # Test whether the features are transformed (unless none).
                                 if(transformation_method == "none"){
                                   # Check that the data is not altered.
                                   testthat::expect_equal(data.table::fsetequal(data_copy@data, data@data), TRUE)
                                   
                                 } else {
                                   for(feature in familiar:::get_feature_columns(data_copy)){
                                     
                                     # Determine if the feature is numeric.
                                     if(feature_info_list[[feature]]@feature_type == "numeric"){
                                       
                                       # Expect that the lambda is NA.
                                       testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), TRUE)
                                     } else {
                                       # Expect that the lambda is NA for categorical features.
                                       testthat::expect_equal(is.na(feature_info_list[[feature]]@transformation_parameters$transform_lambda), TRUE)
                                     }
                                   }
                                 }
                               })
  }
}
