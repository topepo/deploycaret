library(pins)
library(caret)
library(plumber)

set.seed(1)
lm_fit <- train(mpg ~ ., data = mtcars, method = "lm", trControl = trainControl(method = "cv"))

test_that("default endpoint", {
  b <- board_temp()

  m <- modelops(lm_fit, "mtcars_lm", b, data = mtcars[, -1])
  modelops_pin_write(m)

  p <- pr() %>% modelops_pr_predict(m)
  ep <- p$endpoints[[1]][[1]]
  expect_equal(ep$verbs, c("POST"))
  expect_equal(ep$path, "/predict")
})
