# First test if all selectable learners are also available
familiar:::test_all_learners_available(
  learners = familiar:::.get_available_naive_bayes_learners(show_general = TRUE))

# Don't perform any further tests on CRAN due to time of running the complete test.
testthat::skip_on_cran()
testthat::skip_on_ci()

familiar:::test_all_learners_train_predict_vimp(
  learners = familiar:::.get_available_naive_bayes_learners(show_general = FALSE),
  hyperparameter_list = list(
    "binomial" = list("laplace" = 0.0),
    "multinomial" = list("laplace" = 0.0)),
  has_vimp = FALSE)

familiar:::test_all_learners_parallel_train_predict_vimp(
  learners = familiar:::.get_available_naive_bayes_learners(show_general = FALSE),
  hyperparameter_list = list(
    "binomial" = list("laplace" = 0.0),
    "multinomial" = list("laplace" = 0.0)),
  has_vimp = FALSE)

# Binomial tests----------------------------------------------------------------

# Create test data sets.
good_data <- familiar:::test_create_good_data("binomial")
wide_data <- familiar:::test_create_wide_data("binomial")

# Train the model using the good dataset.
good_model <- familiar:::test_train(
  data = good_data,
  cluster_method = "none",
  imputation_method = "simple",
  hyperparameter_list = list(
    "sign_size" = familiar:::get_n_features(good_data),
    "laplace" = 0.0),
  learner = "naive_bayes")

# Train the model using wide data.
wide_model <- familiar:::test_train(
  data = wide_data,
  cluster_method = "none",
  imputation_method = "simple",
  hyperparameter_list = list(
    "sign_size" = familiar:::get_n_features(wide_data),
    "laplace" = 0.0),
  learner = "naive_bayes")

testthat::test_that("Naive Bayes model trained correctly", {
  # Model trained
  testthat::expect_equal(familiar:::model_is_trained(good_model), TRUE)

  # That no deprecation warnings are given.
  familiar:::test_not_deprecated(good_model@messages$warning)

  # Test that no errors appear.
  testthat::expect_equal(good_model@messages$error, NULL)
})

testthat::test_that("Naive Bayes model has no variable importance", {
  # Extract the variable importance table.
  vimp_table <- familiar:::get_vimp_table(good_model)

  # Expect that the vimp table is empty.
  testthat::expect_equal(familiar:::is_empty(vimp_table), TRUE)
})

testthat::test_that("Naive Bayes model can train on wide data", {
  # Model trained
  testthat::expect_equal(familiar:::model_is_trained(wide_model), TRUE)

  # Variable importance table is absent.
  testthat::expect_true(familiar:::is_empty(familiar:::get_vimp_table(wide_model)))

  # Valid predictions.
  testthat::expect_true(familiar:::any_predictions_valid(
    familiar:::.predict(wide_model, wide_data),
    outcome_type = wide_data@outcome_type))

  # Test that no deprecation warnings are given.
  familiar:::test_not_deprecated(wide_model@messages$warning)

  # Test that no errors appear.
  testthat::expect_equal(wide_model@messages$error, NULL)
})

# Multinomial tests-------------------------------------------------------------

# Create test data sets.
good_data <- familiar:::test_create_good_data("multinomial")
wide_data <- familiar:::test_create_wide_data("multinomial")

# Train the model using the good dataset.
good_model <- suppressWarnings(familiar:::test_train(
  data = good_data,
  cluster_method = "none",
  imputation_method = "simple",
  hyperparameter_list = list(
    "sign_size" = familiar:::get_n_features(good_data),
    "laplace" = 0.0),
  learner = "naive_bayes"))

# Train the model using wide data.
wide_model <- familiar:::test_train(
  data = wide_data,
  cluster_method = "none",
  imputation_method = "simple",
  hyperparameter_list = list(
    "sign_size" = familiar:::get_n_features(wide_data),
    "laplace" = 0.0),
  learner = "naive_bayes")

testthat::test_that("Naive Bayes model trained correctly", {
  # Model trained
  testthat::expect_equal(familiar:::model_is_trained(good_model), TRUE)

  # That no deprecation warnings are given.
  familiar:::test_not_deprecated(good_model@messages$warning)

  # Test that no errors appear.
  testthat::expect_equal(good_model@messages$error, NULL)
})


testthat::test_that("Naive Bayes model has no variable importance", {
  # Extract the variable importance table.
  vimp_table <- familiar:::get_vimp_table(good_model)

  # Expect that the vimp table is empty.
  testthat::expect_equal(familiar:::is_empty(vimp_table), TRUE)
})

testthat::test_that("Naive Bayes model can train on wide data", {
  # Model cannot be trained.
  testthat::expect_equal(familiar:::model_is_trained(wide_model), TRUE)

  # Variable importance table is empty.
  testthat::expect_true(familiar:::is_empty(familiar:::get_vimp_table(wide_model)))

  # Valid predictions can be made.
  testthat::expect_true(familiar:::any_predictions_valid(
    familiar:::.predict(wide_model, wide_data),
    outcome_type = wide_data@outcome_type))

  # Test that no deprecation warnings are given.
  familiar:::test_not_deprecated(wide_model@messages$warning)

  # Test that no errors appear.
  testthat::expect_equal(wide_model@messages$error, NULL)
})

testthat::skip("Skip hyperparameter optimisation, unless manual.")

familiar:::test_hyperparameter_optimisation(
  learners = familiar:::.get_available_naive_bayes_learners(show_general = TRUE),
  debug = FALSE,
  parallel = FALSE)
