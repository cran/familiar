# First test if all selectable learners are also available
familiar:::test_all_learners_available(learners = familiar:::.get_available_mboost_lm_learners(show_general = TRUE))

# Don't perform any further tests on CRAN due to time of running the complete test.
testthat::skip_on_cran()
testthat::skip_on_ci()

familiar:::test_all_learners_train_predict_vimp(
  learners = familiar:::.get_available_mboost_lm_learners(show_general = FALSE),
  hyperparameter_list = list(
    "count" = list(
      "n_boost" = 2,
      "learning_rate" = -5
    ),
    "continuous" = list(
      "n_boost" = 2,
      "learning_rate" = -3
    ),
    "binomial" = list(
      "n_boost" = 2,
      "learning_rate" = -3
    ),
    "survival" = list(
      "n_boost" = 2,
      "learning_rate" = -3
    )
  ),
  except_predict_survival = c(
    "boosted_glm_loglog",
    "boosted_glm_lognormal",
    "boosted_glm_weibull"
  )
)

familiar:::test_all_learners_parallel_train_predict_vimp(
  learners = familiar:::.get_available_mboost_lm_learners(show_general = FALSE),
  hyperparameter_list = list(
    "count" = list(
      "n_boost" = 2,
      "learning_rate" = -5
    ),
    "continuous" = list(
      "n_boost" = 2,
      "learning_rate" = -3
    ),
    "binomial" = list(
      "n_boost" = 2,
      "learning_rate" = -3
    ),
    "survival" = list(
      "n_boost" = 2,
      "learning_rate" = -3
    )
  )
)

##### Count outcome tests-------------------------------------------------------------

# Create test data sets.
good_data <- familiar:::test_create_good_data("count")
wide_data <- familiar:::test_create_wide_data("count")

# Train the model using the good dataset.
good_model <- familiar:::test_train(
  data = good_data,
  cluster_method = "none",
  imputation_method = "simple",
  hyperparameter_list = list(
    "sign_size" = familiar:::get_n_features(good_data),
    "n_boost" = 2,
    "learning_rate" = -5
  ),
  learner = "boosted_glm_poisson"
)

# Train the model using wide data.
wide_model <- familiar:::test_train(
  data = wide_data,
  cluster_method = "none",
  imputation_method = "simple",
  hyperparameter_list = list(
    "sign_size" = familiar:::get_n_features(wide_data),
    "n_boost" = 2,
    "learning_rate" = -5
  ),
  learner = "boosted_glm_poisson"
)


testthat::test_that("Gradient boosting regression model trained correctly", {
  # Model trained
  testthat::expect_equal(familiar:::model_is_trained(good_model), TRUE)

  # Test that no deprecation warnings are given.
  familiar:::test_not_deprecated(good_model@messages$warning)

  # Test that no errors appear.
  testthat::expect_equal(good_model@messages$error, NULL)
})


testthat::test_that("Gradient boosting regression model has variable importance", {
  # Extract the variable importance table.
  vimp_table <- familiar:::get_vimp_table(good_model)

  # Expect that the vimp table has two rows.
  testthat::expect_equal(nrow(vimp_table), 13)

  # Expect that the names are the same as that of the features.
  testthat::expect_equal(all(vimp_table$name %in% familiar:::get_feature_columns(good_data)), TRUE)

  # Expect that lower_status_percentage has rank 1 and avg_rooms has rank 2.
  testthat::expect_equal(vimp_table[rank == 1, ]$name, "lower_status_percentage")
  testthat::expect_equal(vimp_table[rank == 2, ]$name, "avg_rooms")
})


testthat::test_that("Gradient boosting regression model can train on wide data", {
  # Model trained
  testthat::expect_equal(familiar:::model_is_trained(wide_model), TRUE)

  # Variable importance table is present.
  testthat::expect_equal(familiar:::is_empty(familiar:::get_vimp_table(wide_model)), FALSE)

  # Valid predictions.
  testthat::expect_equal(familiar:::any_predictions_valid(familiar:::.predict(wide_model, wide_data), outcome_type = wide_data@outcome_type), TRUE)

  # That no deprecation warnings are given.
  familiar:::test_not_deprecated(wide_model@messages$warning)

  # Test that no errors appear.
  testthat::expect_equal(wide_model@messages$error, NULL)
})


##### Continuous outcome tests-------------------------------------------------------------

# Create test data sets.
good_data <- familiar:::test_create_good_data("continuous")
wide_data <- familiar:::test_create_wide_data("continuous")

# Train the model using the good dataset.
good_model <- familiar:::test_train(
  data = good_data,
  cluster_method = "none",
  imputation_method = "simple",
  hyperparameter_list = list(
    "sign_size" = familiar:::get_n_features(good_data),
    "n_boost" = 2,
    "learning_rate" = -1
  ),
  learner = "boosted_glm_gaussian"
)

# Train the model using wide data.
wide_model <- familiar:::test_train(
  data = wide_data,
  cluster_method = "none",
  imputation_method = "simple",
  hyperparameter_list = list(
    "sign_size" = familiar:::get_n_features(wide_data),
    "n_boost" = 2,
    "learning_rate" = -1
  ),
  learner = "boosted_glm_gaussian"
)


testthat::test_that("Gradient boosting regression model trained correctly", {
  # Model trained
  testthat::expect_equal(familiar:::model_is_trained(good_model), TRUE)

  # Test that no deprecation warnings are given.
  familiar:::test_not_deprecated(good_model@messages$warning)

  # Test that no errors appear.
  testthat::expect_equal(good_model@messages$error, NULL)
})


testthat::test_that("Gradient boosting regression model has variable importance", {
  # Extract the variable importance table.
  vimp_table <- familiar:::get_vimp_table(good_model)

  # Expect that the vimp table has two rows.
  testthat::expect_equal(nrow(vimp_table), 10)

  # Expect that the names are the same as that of the features.
  testthat::expect_equal(all(vimp_table$name %in% familiar:::get_feature_columns(good_data)), TRUE)

  # Expect that avginc has rank 1 and calwpct has rank 2.
  testthat::expect_true(all(vimp_table[rank <= 2, ]$name %in% c("avginc", "calwpct")))
})


testthat::test_that("Gradient boosting regression model can train on wide data", {
  # Model trained
  testthat::expect_equal(familiar:::model_is_trained(wide_model), TRUE)

  # Variable importance table is present.
  testthat::expect_equal(familiar:::is_empty(familiar:::get_vimp_table(wide_model)), FALSE)

  # Valid predictions.
  testthat::expect_equal(familiar:::any_predictions_valid(familiar:::.predict(wide_model, wide_data), outcome_type = wide_data@outcome_type), TRUE)

  # That no deprecation warnings are given.
  familiar:::test_not_deprecated(wide_model@messages$warning)

  # Test that no errors appear.
  testthat::expect_equal(wide_model@messages$error, NULL)
})


##### Binomial tests-------------------------------------------------------------

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
    "n_boost" = 2,
    "learning_rate" = -1
  ),
  learner = "boosted_glm_logistic"
)

# Train the model using wide data.
wide_model <- suppressWarnings(familiar:::test_train(
  data = wide_data,
  cluster_method = "none",
  imputation_method = "simple",
  hyperparameter_list = list(
    "sign_size" = familiar:::get_n_features(wide_data),
    "n_boost" = 2,
    "learning_rate" = -1
  ),
  learner = "boosted_glm_logistic"
))

testthat::test_that("Gradient boosting regression model trained correctly", {
  # Model trained
  testthat::expect_equal(familiar:::model_is_trained(good_model), TRUE)

  # Test that no deprecation warnings are given.
  familiar:::test_not_deprecated(good_model@messages$warning)

  # Test that no errors appear.
  testthat::expect_equal(good_model@messages$error, NULL)
})


testthat::test_that("Gradient boosting regression model has variable importance", {
  # Extract the variable importance table.
  vimp_table <- familiar:::get_vimp_table(good_model)

  # Expect that the vimp table has two rows.
  testthat::expect_equal(nrow(vimp_table), 8)

  # Expect that the names are the same as that of the features.
  testthat::expect_equal(all(familiar:::get_feature_columns(good_data) %in% vimp_table$name), TRUE)

  # Expect that cell_shape_uniformity has rank 1 and bare_nuclei has rank 2.
  testthat::expect_equal(vimp_table[rank == 1, ]$name, "cell_shape_uniformity")
  testthat::expect_equal(vimp_table[rank == 2, ]$name, "bare_nuclei")
})


testthat::test_that("Gradient boosting regression model can train on wide data", {
  # Model trained
  testthat::expect_equal(familiar:::model_is_trained(wide_model), TRUE)

  # Variable importance table is present.
  testthat::expect_equal(familiar:::is_empty(familiar:::get_vimp_table(wide_model)), FALSE)

  # Valid predictions.
  testthat::expect_equal(familiar:::any_predictions_valid(familiar:::.predict(wide_model, wide_data), outcome_type = wide_data@outcome_type), TRUE)

  # That no deprecation warnings are given.
  familiar:::test_not_deprecated(wide_model@messages$warning)

  # Test that no errors appear.
  testthat::expect_equal(wide_model@messages$error, NULL)
})



##### Survival tests-------------------------------------------------------------

# Create test data sets.
good_data <- familiar:::test_create_good_data("survival")
wide_data <- familiar:::test_create_wide_data("survival")

# Train the model using the good dataset.
good_model <- familiar:::test_train(
  data = good_data,
  cluster_method = "none",
  imputation_method = "simple",
  hyperparameter_list = list(
    "sign_size" = familiar:::get_n_features(good_data),
    "n_boost" = 2,
    "learning_rate" = -1
  ),
  time_max = 1832,
  learner = "boosted_glm_cox"
)

# Train the model using wide data.
wide_model <- familiar:::test_train(
  data = wide_data,
  cluster_method = "none",
  imputation_method = "simple",
  hyperparameter_list = list(
    "sign_size" = familiar:::get_n_features(wide_data),
    "n_boost" = 2,
    "learning_rate" = -1
  ),
  time_max = 1832,
  learner = "boosted_glm_cox"
)


testthat::test_that("Gradient boosting regression model trained correctly", {
  # Model trained
  testthat::expect_equal(familiar:::model_is_trained(good_model), TRUE)

  # Test the prediction type
  testthat::expect_equal(familiar:::get_prediction_type(good_model), "hazard_ratio")

  # Test that the model predicts hazard ratios
  testthat::expect_equal(familiar:::get_prediction_type(good_model, type = "survival_probability"), "survival_probability")

  # Test that no deprecation warnings are given.
  familiar:::test_not_deprecated(good_model@messages$warning)

  # Test that no errors appear.
  testthat::expect_equal(good_model@messages$error, NULL)
})


testthat::test_that("Gradient boosting regression model has variable importance", {
  # Extract the variable importance table.
  vimp_table <- familiar:::get_vimp_table(good_model)

  # Expect that the vimp table has two rows.
  testthat::expect_equal(nrow(vimp_table), 3)

  # Expect that the names are the same as that of the features.
  testthat::expect_equal(all(familiar:::get_feature_columns(good_data) %in% vimp_table$name), TRUE)

  # Expect that nodes has rank 1 and rx has rank 2.
  testthat::expect_equal(vimp_table[rank == 1, ]$name, "nodes")
  testthat::expect_equal(vimp_table[rank == 2, ]$name, "rx")
})


testthat::test_that("Gradient boosting regression model can train and predict on wide data", {
  # Model was trained
  testthat::expect_equal(familiar:::model_is_trained(wide_model), TRUE)

  # Variable importance table is present.
  testthat::expect_equal(familiar:::is_empty(familiar:::get_vimp_table(wide_model)), FALSE)

  # Valid predictions are present.
  testthat::expect_equal(familiar:::any_predictions_valid(familiar:::.predict(wide_model, wide_data), outcome_type = wide_data@outcome_type), TRUE)

  # Valid survival probability predictions can be made.
  testthat::expect_equal(familiar:::any_predictions_valid(familiar:::.predict(wide_model, wide_data, type = "survival_probability", time = 1000), outcome_type = wide_data@outcome_type), TRUE)

  # That no deprecation warnings are given.
  familiar:::test_not_deprecated(wide_model@messages$warning)

  # Test that no errors appear.
  testthat::expect_equal(wide_model@messages$error, NULL)
})


testthat::skip("Skip hyperparameter optimisation, unless manual.")


familiar:::test_hyperparameter_optimisation(
  learners = familiar:::.get_available_mboost_lm_learners(show_general = TRUE),
  debug = FALSE,
  parallel = FALSE
)
