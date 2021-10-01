
<!-- README.md is generated from README.Rmd. Please edit that file -->

# deploycaret

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/deploycaret)](https://CRAN.R-project.org/package=deploycaret)
[![R-CMD-check](https://github.com/topepo/deploycaret/workflows/R-CMD-check/badge.svg)](https://github.com/topepo/deploycaret/actions)
<!-- badges: end -->

**This pre-release is available for feedback and experimenting.**

The goal of deploycaret is to provide fluent tooling to version, share,
and deploy a trained [caret](https://topepo.github.io/caret) model.
Functions handle both recording and checking the model’s input data
prototype, and loading the packages needed for prediction.

## Installation

~~You can install the released version of deploycaret from
[CRAN](https://CRAN.R-project.org) with:~~

``` r
install.packages("deploycaret") ## not yet
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("topepo/deploycaret")
```

## Example

You can use the [caret](https://topepo.github.io/caret) package to train
a model, with a wide variety of preprocessing and model estimation
options.

``` r
library(caret)
#> Loading required package: ggplot2
#> Loading required package: lattice
data(Sacramento, package = "modeldata")
Sacramento <- as.data.frame(Sacramento)

predictors <- Sacramento[, c("type", "sqft", "beds", "baths")]

set.seed(1)
rf_fit <-
  train(
    x = predictors,
    y = Sacramento$price,
    method = "ranger",
    tuneLength = 3,
    trControl = trainControl(method = "cv")
  )
rf_fit
#> Random Forest 
#> 
#> 932 samples
#>   4 predictor
#> 
#> No pre-processing
#> Resampling: Cross-Validated (10 fold) 
#> Summary of sample sizes: 839, 839, 839, 839, 839, 839, ... 
#> Resampling results across tuning parameters:
#> 
#>   mtry  splitrule   RMSE      Rsquared   MAE     
#>   2     variance    83939.56  0.5879285  61989.31
#>   2     extratrees  83284.93  0.5961290  61341.14
#>   3     variance    86016.01  0.5697237  63939.24
#>   3     extratrees  84213.49  0.5878709  61897.12
#>   4     variance    88394.65  0.5490859  65682.43
#>   4     extratrees  85738.59  0.5758477  63380.21
#> 
#> Tuning parameter 'min.node.size' was held constant at a value of 5
#> RMSE was used to select the optimal model using the smallest value.
#> The final values used for the model were mtry = 2, splitrule = extratrees
#>  and min.node.size = 5.
```

You can **version** and **share** your model by
[pinning](https://pins.rstudio.com/dev/) it, to a local folder, RStudio
Connect, Amazon S3, and more.

``` r
library(deploycaret)
library(pins)

model_board <- board_temp()
m <- modelops(rf_fit, "sacramento_rf_caret", model_board, data = predictors)
modelops_pin_write(m)
#> Creating new version '20211001T015648Z-aae94'
#> Writing to pin 'sacramento_rf_caret'
```

You can **deploy** your pinned model via a [Plumber
API](https://www.rplumber.io/), which can be [hosted in a variety of
ways](https://www.rplumber.io/articles/hosting.html).

``` r
library(plumber)

pr() %>%
    modelops_pr_predict(m) %>%
    pr_run(port = 8088)
```

Make predictions with your deployed model by creating an endpoint
object:

``` r
endpoint <- modelops_endpoint("http://127.0.0.1:8088/predict")
endpoint
#> 
#> ── A model API endpoint for prediction: 
#> http://127.0.0.1:8088/predict
```

A model API endpoint deployed with `modelops_pr_predict()` will return
predictions with appropriate new data.

``` r
new_sac <- head(predictors)

predict(endpoint, new_sac)
#> # A tibble: 20 x 1
#>      .pred
#>      <dbl>
#>  1 165042.
#>  2 212461.
#>  3 119008.
#>  4 201752.
#>  5 223096.
#>  6 115696.
#>  7 191262.
#>  8 211706.
#>  9 259336.
#> 10 206826.
#> 11 234952.
#> 12 221993.
#> 13 204983.
#> 14 548052.
#> 15 151186.
#> 16 299365.
#> 17 213439.
#> 18 287993.
#> 19 272017.
#> 20 226629.
```

## Contributing

This project is released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

-   For questions and discussions about tidymodels packages, modeling,
    and machine learning, please [post on RStudio
    Community](https://community.rstudio.com/new-topic?category_id=15&tags=tidymodels,question).

-   If you think you have encountered a bug, please [submit an
    issue](https://github.com/topepo/deploycaret/issues).

-   Either way, learn how to create and share a
    [reprex](https://reprex.tidyverse.org/articles/articles/learn-reprex.html)
    (a minimal, reproducible example), to clearly communicate about your
    code.

-   Check out further details on [contributing guidelines for tidymodels
    packages](https://www.tidymodels.org/contribute/) and [how to get
    help](https://www.tidymodels.org/help/).
