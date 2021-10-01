#' caret model handler functions for API endpoint
#' @inheritParams modelops::modelops_pr_predict
#' @rdname handlers_predict.train
#' @export
handler_startup.train <- function(modelops, ...) {
    tune::load_pkgs(modelops$metadata$required_pkgs)
}

#' @rdname handlers_predict.train
#' @export
handler_predict.train <- function(modelops, ...) {

    function(req) {
        newdata <- req$body
        newdata <-  modelops_type_convert(newdata, modelops$ptype)
        predict(modelops$model, newdata = newdata, ...)

    }

}


