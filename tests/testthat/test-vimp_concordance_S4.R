familiar:::test_all_vimp_methods_available(familiar:::.get_available_concordance_vimp_method(show_general=TRUE))

# Don't perform any further tests on CRAN due to running time.
testthat::skip_on_cran()
testthat::skip_on_ci()

familiar:::test_hyperparameter_optimisation(vimp_methods=familiar:::.get_available_concordance_vimp_method(show_general=TRUE),
                                            debug=FALSE,
                                            parallel=FALSE)

familiar:::test_all_vimp_methods(familiar:::.get_available_concordance_vimp_method(show_general=FALSE))
familiar:::test_all_vimp_methods_parallel(familiar:::.get_available_concordance_vimp_method(show_general=FALSE))

##### Count outcome #####
data <- familiar:::test.create_good_data_set("count")

# Process dataset.
vimp_object <- familiar:::prepare_vimp_object(data=data,
                                              vimp_method="concordance",
                                              vimp_method_parameter_list=NULL,
                                              outcome_type="count",
                                              cluster_method="none",
                                              imputation_method="simple")


testthat::test_that(paste0("The concordance method correctly ranks count data."), {
  
  vimp_table <- suppressWarnings(familiar:::get_vimp_table(familiar:::.vimp(vimp_object, data)))
  
  testthat::expect_equal(all(vimp_table[rank <= 2]$name %in% c("per_capita_crime", "lower_status_percentage")), TRUE)
})



##### Continuous outcome #####
data <- familiar:::test.create_good_data_set("continuous")

# Process dataset.
vimp_object <- familiar:::prepare_vimp_object(data=data,
                                              vimp_method="concordance",
                                              vimp_method_parameter_list=NULL,
                                              outcome_type="continuous",
                                              cluster_method="none",
                                              imputation_method="simple")


testthat::test_that(paste0("The concordance method correctly ranks continuous data."), {
  
  vimp_table <- suppressWarnings(familiar:::get_vimp_table(familiar:::.vimp(vimp_object, data)))
  
  testthat::expect_equal(any(vimp_table[rank <= 2]$name %in% c("enrltot", "avginc", "calwpct")), TRUE)
})



##### Binomial outcome #####
data <- familiar:::test.create_good_data_set("binomial")

# Process dataset.
vimp_object <- familiar:::prepare_vimp_object(data=data,
                                              vimp_method="concordance",
                                              vimp_method_parameter_list=NULL,
                                              outcome_type="binomial",
                                              cluster_method="none",
                                              imputation_method="simple")


testthat::test_that(paste0("The concordance method correctly ranks binomial data.."), {
  
  vimp_table <- suppressWarnings(familiar:::get_vimp_table(familiar:::.vimp(vimp_object, data)))
  
  testthat::expect_equal(all(vimp_table[rank <= 2]$name %in% c("cell_shape_uniformity", "normal_nucleoli")), TRUE)
})



##### Multinomial outcome #####
data <- familiar:::test.create_good_data_set("multinomial")

# Process dataset.
vimp_object <- familiar:::prepare_vimp_object(data=data,
                                              vimp_method="concordance",
                                              vimp_method_parameter_list=NULL,
                                              outcome_type="multinomial",
                                              cluster_method="none",
                                              imputation_method="simple")


testthat::test_that(paste0("The concordance method correctly ranks multinomial outcome data."), {
  
  vimp_table <- suppressWarnings(familiar:::get_vimp_table(familiar:::.vimp(vimp_object, data)))
  
  testthat::expect_equal(all(c("Petal_Length", "Petal_Width") %in% vimp_table[rank <= 2]$name), TRUE)
})


##### Survival outcome #####
data <- familiar:::test.create_good_data_set("survival")

# Process dataset.
vimp_object <- familiar:::prepare_vimp_object(data=data,
                                              vimp_method="concordance",
                                              vimp_method_parameter_list=NULL,
                                              outcome_type="survival",
                                              cluster_method="none",
                                              imputation_method="simple")


testthat::test_that(paste0("The concordance method correctly ranks survival outcome data."), {
  
  vimp_table <- suppressWarnings(familiar:::get_vimp_table(familiar:::.vimp(vimp_object, data)))
  
  testthat::expect_equal(all(vimp_table[rank <= 2]$name %in% c("nodes", "rx")), TRUE)
})
