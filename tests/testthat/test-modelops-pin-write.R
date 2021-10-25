library(pins)
library(caret)

set.seed(1)
lm_fit <- train(mpg ~ ., data = mtcars, method = "lm", trControl = trainControl(method = "cv"))

test_that("can pin a model", {
    b <- board_temp()
    m <- modelops(lm_fit, "mtcars_lm", b)
    modelops_pin_write(m)
    # expect_equal(
    #     pin_read(b, "mtcars_lm"),
    #     list(
    #         model = butcher::butcher(lm_fit),
    #         ptype = vctrs::vec_slice(mtcars[,2:11], 0)
    #     )
    # )
})

test_that("default metadata for model", {
    b <- board_temp()
    m <- modelops(lm_fit, "mtcars_lm", b)
    modelops_pin_write(m)
    meta <- pin_meta(b, "mtcars_lm")
    expect_equal(meta$user, list())
    expect_equal(meta$description, "A linear regression regression model")
})

test_that("user can supply metadata for model", {
    b <- board_temp()
    m <- modelops(lm_fit, "mtcars_lm", b)
    m <- modelops(lm_fit, "mtcars_lm", b,
                  desc = "Linear regression for mtcars",
                  metadata = list(metrics = 1:10))
    modelops_pin_write(m)
    meta <- pin_meta(b, "mtcars_lm")
    # expect_equal(meta$user, list(metrics = 1:10)) # TODO  user?
    expect_equal(meta$description, "Linear regression for mtcars")
})

test_that("can read a pinned model", {
    skip("different environments")
    b <- board_temp()
    m <- modelops(lm_fit, "mtcars_lm", b)
    modelops_pin_write(m)
    m1 <- modelops_pin_read(b, "mtcars_lm")
    meta <- pin_meta(b, "mtcars_lm")
    expect_equal(m1$model, m$model)
    expect_equal(m1$model_name, m$model_name)
    expect_equal(m1$board, m$board)
    expect_equal(m1$desc, m$desc)
    expect_equal(
        m1$metadata,
        list(user = m$metadata$user,
             version = meta$local$version,
             url = meta$local$url)
    )
    expect_equal(m1$ptype, m$ptype)
    expect_equal(m1$versioned, FALSE)
})
