library(mlflow)
library(tidymodels)
library(tidyverse)
library(carrier)
library(glmnet)

EXPERIMENT_NAME <- "Iris Elasticnet"
mlflow_set_tracking_uri("https://mk-mlflow-test.herokuapp.com/")

if (!EXPERIMENT_NAME %in% mlflow_list_experiments()$name) {
  experiment_id <- mlflow_create_experiment(
    EXPERIMENT_NAME
  )
} else {
  experiment_id <- mlflow_get_experiment(name = EXPERIMENT_NAME)$experiment_id
}

with(mlflow_start_run(experiment_id = experiment_id), {
  d <- iris %>%
    filter(
      Species != "versicolor"
    ) %>%
    mutate(
      Species = droplevels(as.factor(Species)),
      Noise = rnorm(n())
    )

  s <- logistic_reg(
    penalty = tune(),
    mixture = tune()
  ) %>%
    set_mode("classification") %>%
    set_engine("glmnet")

  r <- recipe(
    Species ~ Petal.Width + Noise,
    data = d
  )

  w <- workflow() %>%
    add_model(s) %>%
    add_recipe(r)

  p <- parameters(
    penalty(),
    mixture()
  )

  f <- mc_cv(
    d,
    times = 5
  )

  t <- tune_grid(
    w,
    resamples = f,
    param_info = p,
    grid = 5
  )

  best_trick <- t %>%
    show_best("accuracy", n = 1)

  mlflow_log_metric(
    "AUC",
    best_trick$mean
  )

  mlflow_log_param(
    "penalty",
    best_trick$penalty
  )

  mlflow_log_param(
    "mixture",
    best_trick$mixture
  )

  model <- w %>%
    finalize_workflow(
      select_best(t, "roc_auc")
    ) %>%
    fit(d)

  ## TODO: Figure out how to save models + artifacts to S3
  # mlflow_log_artifact()

  ## This will save the prediction function, but not the raw model afaict
  mlflow_log_model(
    model = crate(
      function(x) predict(model, x)
    ),
    "model"
  )

  mlflow_create_registered_model(
    EXPERIMENT_NAME,
    description = "Predicting flower species with random noise and the petal width. Used elasticnet."
  )
})
