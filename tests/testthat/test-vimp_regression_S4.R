familiar:::test_all_vimp_methods_available(
  familiar:::.get_available_univariate_regression_vimp_methods(show_general = TRUE))
familiar:::test_all_vimp_methods_available(
  familiar:::.get_available_multivariate_regression_vimp_methods(show_general = TRUE))

# Don't perform any further tests on CRAN due to time of running the complete
# test.
testthat::skip_on_cran()
testthat::skip_on_ci()

familiar:::test_hyperparameter_optimisation(
  vimp_methods = familiar:::.get_available_univariate_regression_vimp_methods(show_general = TRUE),
  debug = FALSE,
  parallel = FALSE,
  not_available_no_samples = FALSE)

familiar:::test_all_vimp_methods(
  familiar:::.get_available_univariate_regression_vimp_methods(show_general = FALSE))
familiar:::test_all_vimp_methods_parallel(
  familiar:::.get_available_univariate_regression_vimp_methods(show_general = FALSE))

familiar:::test_hyperparameter_optimisation(
  vimp_methods = familiar:::.get_available_multivariate_regression_vimp_methods(show_general = TRUE),
  debug = FALSE,
  parallel = FALSE,
  not_available_no_samples = FALSE
)

familiar:::test_all_vimp_methods(
  familiar:::.get_available_multivariate_regression_vimp_methods(show_general = FALSE))
familiar:::test_all_vimp_methods_parallel(
  familiar:::.get_available_multivariate_regression_vimp_methods(show_general = FALSE))

# Count outcome ----------------------------------------------------------------
data <- familiar:::test_create_good_data("count")

# Process dataset.
vimp_object <- familiar:::prepare_vimp_object(
  data = data,
  vimp_method = "multivariate_regression",
  vimp_method_parameter_list = NULL,
  outcome_type = "count",
  cluster_method = "none",
  imputation_method = "simple")

testthat::test_that(paste0("Multivariate regression correctly ranks count data."), {
  vimp_table <- suppressWarnings(familiar:::get_vimp_table(
    familiar:::.vimp(vimp_object, data)))
  
  testthat::expect_true(all(vimp_table[rank <= 2]$name %in% c(
    "per_capita_crime", "lower_status_percentage",
    "residence_before_1940_proportion", "avg_rooms", "pupil_teacher_ratio")))
})

# Continuous outcome -----------------------------------------------------------
data <- familiar:::test_create_good_data("continuous")

# Process dataset.
vimp_object <- familiar:::prepare_vimp_object(
  data = data,
  vimp_method = "multivariate_regression",
  vimp_method_parameter_list = NULL,
  outcome_type = "continuous",
  cluster_method = "none",
  imputation_method = "simple")

testthat::test_that(paste0("Multivariate regression correctly ranks continuous data."), {
  vimp_table <- suppressWarnings(familiar:::get_vimp_table(
    familiar:::.vimp(vimp_object, data)))

  testthat::expect_true(any(vimp_table[rank <= 2]$name %in% c("enrltot", "avginc", "calwpct")))
})

# Binomial outcome -------------------------------------------------------------
data <- familiar:::test_create_good_data("binomial")

# Process dataset.
vimp_object <- familiar:::prepare_vimp_object(
  data = data,
  vimp_method = "multivariate_regression",
  vimp_method_parameter_list = NULL,
  outcome_type = "binomial",
  cluster_method = "none",
  imputation_method = "simple")

testthat::test_that(paste0("Multivariate regression correctly ranks binomial data.."), {
  vimp_table <- suppressWarnings(familiar:::get_vimp_table(
    familiar:::.vimp(vimp_object, data)))

  testthat::expect_true(all(vimp_table[rank <= 2]$name %in% c(
    "cell_shape_uniformity", "clump_thickness", "bare_nuclei", "normal_nucleoli")))
})

# Multinomial outcome ----------------------------------------------------------
data <- familiar:::test_create_good_data("multinomial")

# Process dataset.
vimp_object <- familiar:::prepare_vimp_object(
  data = data,
  vimp_method = "multivariate_regression",
  vimp_method_parameter_list = NULL,
  outcome_type = "multinomial",
  cluster_method = "none",
  imputation_method = "simple")

testthat::test_that(paste0("Multivariate regression correctly ranks multinomial outcome data."), {
  vimp_table <- suppressWarnings(familiar:::get_vimp_table(
    familiar:::.vimp(vimp_object, data)))

  testthat::expect_true(all(vimp_table[rank <= 2]$name %in% c(
    "Petal_Length", "Petal_Width", "Sepal_Length")))
})

# Survival outcome -------------------------------------------------------------
data <- familiar:::test_create_good_data("survival")

# Process dataset.
vimp_object <- familiar:::prepare_vimp_object(
  data = data,
  vimp_method = "multivariate_regression",
  vimp_method_parameter_list = NULL,
  outcome_type = "survival",
  cluster_method = "none",
  imputation_method = "simple")

testthat::test_that(paste0("Multivariate regression correctly ranks survival outcome data."), {
  vimp_table <- suppressWarnings(familiar:::get_vimp_table(
    familiar:::.vimp(vimp_object, data)))

  testthat::expect_true(all(vimp_table[rank <= 2]$name %in% c("nodes", "rx", "adhere")))
})
